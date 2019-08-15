local fsa = {}

local light_mgr = require("scripts/lights/light_manager")

local tmp = sol.surface.create(sol.video.get_quest_size())
local reflection = sol.surface.create(sol.video.get_quest_size())
local fsa_texture = sol.surface.create(sol.video.get_quest_size())
local clouds_shadow = sol.surface.create("backgrounds/clouds_shadow.png")
clouds_shadow:set_blend_mode("multiply")

local effect = sol.surface.create"backgrounds/fsaeffect.png"
local shader = sol.shader.create"water_effect"
shader:set_uniform("reflection",reflection)
shader:set_uniform("fsa_texture",fsa_texture)
tmp:set_shader(shader)
local ew,eh = effect:get_size()

local clouds_speed = 0.01
local csw,csh = clouds_shadow:get_size()

--draw cloud shadow
function fsa:draw_clouds_shadow(dst,cx,cy)
  local t = sol.main.get_elapsed_time() * clouds_speed;
  local x,y = math.floor(t),math.floor(t)
  local cw,ch = dst:get_size()
  local tx,ty = (-cx+x) % csw, (-cy+y) % csh
  local imax = math.ceil(cw/csw)
  local jmax = math.ceil(ch/csh)
  for i=-1,imax do
    for j=-1,jmax do
      clouds_shadow:draw(dst,tx+i*csw,ty+j*csh)
    end
  end
end

-- read map file again to get lights position
local function get_lights_from_map(map)
  local map_id = map:get_id()
  local lights = {}
  -- Here is the magic: set up a special environment to load map data files.
  local environment = {
  }

  local big = "120"
  local small = "80"

  local radii = {

  }

  local win_cut = "0.1"
  local win_aperture = "0.707"

  local dirs = {

  }


  local colors = {

  }

  -- Make any other function a no-op (tile(), enemy(), block(), etc.).
  setmetatable(environment, {
    __index = function()
      return function() end
    end
  })

  -- Load the map data file as Lua.
  local chunk = sol.main.load_file("maps/" .. map_id .. ".dat")

  -- Apply our special environment (with functions properties() and chest()).
  setfenv(chunk, environment)

  -- Run it.
  chunk()
  return lights
end

--render fsa texture to fsa effect map
function fsa:render_fsa_texture(map)
  fsa_texture:clear()
  if false and not self.outside then
    fsa_texture:fill_color{255,255,255}
    return
  end
  local cw,ch = fsa_texture:get_size()
  local camera = map:get_camera()
  local dx,dy = camera:get_position()
  local tx = ew - dx % ew
  local ty = eh - dy % eh
  for i=-1,math.ceil(cw/ew) do
    for j=-1,math.ceil(ch/eh) do
      effect:draw(fsa_texture,tx+i*ew,ty+j*eh)
    end
  end
end


-- create a light that will automagically register to the light_manager
function create_light(map,x,y,layer,radius,color,dir,cut,aperture)
  local function dircutappprops(dir, cut, aperture)
    if dir and cut and aperture then
      return {key="direction",value=dir},
      {key="cut",value=cut},
      {key="aperture",value=aperture}
    end
  end
  return map:create_custom_entity{
    direction=0,
    layer = layer,
    x = x,
    y = y,
    width = 16,
    height = 16,
    sprite = "entities/fire_mask",
    model = "light",
    properties = {
      {key="radius",value = radius},
      {key="color",value = color},
      dircutappprops(dir,cut,aperture)
    }
  }
end

local function setup_inside_lights(map)
  light_mgr:init(map,
                 (function()
                    if map:get_game():get_value("dark_room") then return {12,12,12}
                    elseif map:get_game():get_value("dark_room_middle") then return {128,128,128}
                    elseif map:get_world() == "outside" or map:get_world() == "outside_2" or map:get_id() == "dungeons/memories_tower/7ET" then
                      if map:get_game():get_value("night") then return {0,33,164}
                      elseif map:get_game():get_value("dawn") then return {255,94,109}
                      else return {255,255,255}
                      end
                    end
                 end)())

  local default_radius = "120"
  local default_color = "193,185,100"

  if map:get_game():has_item("inventory/lamp") then
    local hero = map:get_hero()
    --create hero light
    local hl = create_light(map,-256,-256,0,"80",default_color)
    function hl:on_update()
      hl:set_position(hero:get_position())
    end
    hl.excluded_occs = {[hero]=true}
  end

  --add a static light for each torch pattern in the map
  local map_lights = get_lights_from_map(map)

  for _,l in ipairs(map_lights) do
    create_light(map,l.x,l.y,l.layer,l.radius or default_radius,l.color or default_color,
                 l.dir,l.cut,l.aperture)
  end

  --generate lights for crystal switches
  for en in map:get_entities_by_type("crystal") do
      local tx,ty,tl = en:get_position()
      local tw,th = 16,16
      local yoff = -8
      local light = create_light(map,tx+tw*0.5-8,ty+th*0.5+yoff,tl,"80",default_color)
      light:set_enabled(true)
  end

  --generate lights for particular enemies
  for en in map:get_entities_by_type("enemy") do
    local el = create_light(map,-256,-256,0,"80",default_color)
    if en:get_breed() == "bubble_red" then
      function el:on_update()
        el:set_position(en:get_position())
      end
    elseif en:get_breed() == "keese_fire" then
      function el:on_update()
        el:set_position(en:get_position())
      end
    end
    en:register_event("on_removed",function()
      el:set_enabled(false)
    end)
    en:register_event("on_dead",function()
      el:set_enabled(false)
    end)
  end

  --generate lights for dynamic torches
  for en in map:get_entities_by_type("custom_entity") do
    if en:get_model() == "torch" then
      local tx,ty,tl = en:get_position()
      local tw,th = en:get_size()
      local yoff = -8
      local light = create_light(map,tx+tw*0.5-8,ty+th*0.5+yoff,tl,default_radius,default_color)
      en:register_event("on_unlit",function()
                          light:set_enabled(false)
      end)
      en:register_event("on_lit",function()
                          light:set_enabled(true)
      end)
      light:set_enabled(en:is_lit())
  --generate lights for light entities
    elseif en:get_model() == "light" then
      local tx,ty,tl = en:get_position()
      local tw,th = 16,16
      local yoff = -8
      local light = create_light(map,tx+tw*0.5-8,ty+th*0.5+yoff,tl,default_radius,default_color)
      en:register_event("on_enabled",false,function()
                          light:set_enabled(false)
      end)
      en:register_event("on_enabled",true,function()
                          light:set_enabled(true)
      end)
      light:set_enabled(en:is_enabled())
    end
  end
end

function fsa:on_map_changed(map)
  if self.current_map == map then
    return -- already registered and created
  end
  setup_inside_lights(map)
  self.current_map = map
end

function fsa:on_map_draw(map,dst)
  dst:draw(tmp)
  fsa:render_fsa_texture(map)

  
  local camera = map:get_camera()
  local dx,dy = camera:get_position()
  local layer = map:get_hero():get_layer()
  tmp:draw(dst)
  light_mgr:draw(dst,map)
  if map:get_world() == "outside" or map:get_world() == "outside_2" then
    if map:get_id() == "outside/B1" or map:get_id() == "outside/B2" then return end
    fsa:draw_clouds_shadow(dst,dx,dy)
  end
end

function fsa:clean()

end

return fsa