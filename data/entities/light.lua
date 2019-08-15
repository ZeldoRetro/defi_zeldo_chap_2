-- Lua script of custom light light.

--this custom entity represent a light emission source, together with the light_manager
--it allows to light dark places TODO comment better


--This entity uses the following **custom properties** :
--   * color : vec3 => define the base color of the light ex `255,128,64`
--   * radius : scalar => define the radius of the light in pixels
--   * aperture : scalar => define the aperture of a light, turns it into a spot if `abs(aperture)` < 1, this is the cosine desired angle
--   * direction : vec2 => define the direction of the light, light will be aligned to the vector
--   * halo : scalar => define the smoothness of the shadow cone/disk
--   * cut : scalar => define how much the light is "cut" from the base cut \in [0,1] 0 no cut, 1 full cut   
--   * angle : scalar => alias for aperture that defines it from the **angle in degrees**

local light = ...
local game = light:get_game()
local map = light:get_map()
local light_mgr = require('scripts/lights/light_manager')

local radius = tonumber(light:get_property('radius')) or 120
local size = radius*2
local color_str = light:get_property('color') or '255,255,255'
local color = {color_str:match('(%d+),(%d+),(%d+)')}
for i,k in ipairs(color) do
  color[i] = k/256.0
end

local sqrt2radius = 1.41 * radius

light:set_can_traverse(true)

--set light properties
light.radius = radius
light.color = color
light.excluded_occs = {}
light.halo = tonumber(light:get_property('halo'))
local dir_str = light:get_property('direction')
if dir_str then
  light.direction = {dir_str:match('(-?%d+),(-?%d+)')}
  for i,k in ipairs(light.direction) do
    light.direction[i] = k*1
  end
end
light.cut = tonumber(light:get_property('cut'))
light.aperture = tonumber(light:get_property('aperture'))

local angle = light:get_property('angle')
if angle then
  light.aperture = math.cos((math.pi/180)* tonumber(angle))
end

local x,y = light:get_position()

local fire_dist = sol.shader.create('fire_dist')
local fire_sprite = light:get_sprite()
if fire_sprite then
  light:remove_sprite(fire_sprite)
  fire_sprite:set_shader(fire_dist)
end


-- Event called when the custom light is initialized.
function light:on_created()
  -- Initialize the properties of your custom light here,
  -- like the sprite, the size, and whether it can traverse other
  -- entities and be traversed by them.
  light_mgr:add_light(self,light:get_name())
  light:set_origin(radius,radius)
  local size8 = math.ceil(size/8)*8
  light:set_size(size8,size8)
end

function light:draw_visual(dst,drawable,x,y)
  local cx,cy = map:get_camera():get_position()
  drawable:draw(dst,x-cx,y-cy)
end

function light:get_topleft()
  local lx,ly,ll = self:get_position()
  return lx-radius,ly-radius,ll
end

function light:draw_light(dst, camera)

  --dont draw light if disabled
  if not self:is_enabled() then
    return
  end

  --dont draw light if outside of the camera
  camera:set_layer(self:get_layer()) --TODO verify if this is not a shitty idea
  if not camera:overlaps(self) then
    return
  end

  -- get the shadow_map for this light
  local shad_map = light_mgr:compute_light_shadow_map(light)

  --draw 1D shadow as additive shadows
  self:draw_visual(dst,shad_map, self:get_topleft())
end

function light:draw_disturb(dst)
  self:draw_visual(dst,fire_sprite,self:get_position())
end

function light:track_entity(ent,dx,dy,dl)
  ent:register_event("on_position_changed",function(ent,x,y,l)
    light:set_position(x+(dx or 0),y+(dy or 0), l+(dl or 0))
  end)
end