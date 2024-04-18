local light_mgr = {occluders={},lights={},occ_maps = {},occ_chunks={}}

light_mgr.light_acc = sol.surface.create(sol.video.get_quest_size())
light_mgr.light_acc:set_blend_mode('multiply')

local make_shadow_s = sol.shader.create("make_shadow1d")
local cast_shadow_s = sol.shader.create("cast_shadow1d")
local angular_resolution = 256
local shadow_map = sol.surface.create(angular_resolution,1)
shadow_map:set_blend_mode("add")
shadow_map:set_shader(cast_shadow_s)
local chunk_size = 512

function light_mgr:add_light(light,name)
  self.lights[name or light] = light
end

function light_mgr:chunk_id(chunk_x,chunk_y,layer)
  return chunk_x +
    chunk_y*self.chunk_width +
    (layer-self.map:get_min_layer())*self.chunk_width*self.chunk_height
end

function light_mgr:get_occ_chunk(chunk_x,chunk_y,layer)
  return chunk.surf
end

function light_mgr:invalidate_occ_chunks()
  for k,chunk in pairs(self.occ_chunks) do
    chunk.valid = false
  end
end

function light_mgr:get_occ_map(radius)
  if not self.occ_maps[radius] then
    self.occ_maps[radius] = sol.surface.create(radius*2,radius*2)
    self.occ_maps[radius]:set_shader(make_shadow_s)
  end
  return self.occ_maps[radius]
end

function light_mgr:compute_light_shadow_map(light)
  local radius = light.radius
  local occ_map = self:get_occ_map(radius)

  local size = radius*2

  --setup shaders for this light
  local resolution = {radius,radius}
  make_shadow_s:set_uniform("resolution",resolution)
  shadow_map:set_scale(size/angular_resolution,size)
  cast_shadow_s:set_uniform("resolution",resolution)
  cast_shadow_s:set_uniform("lcolor",light.color)
  cast_shadow_s:set_uniform("dir",light.direction or {1,0})
  cast_shadow_s:set_uniform("aperture",light.aperture or -1.5)
  cast_shadow_s:set_uniform("halo",light.halo or 0.2)
  cast_shadow_s:set_uniform("cut",light.cut or 0.0)

  occ_map:clear()

  occ_map:draw(shadow_map)
  return shadow_map
end

local function table_filter(table, pred)
  local res = {}
  for k,v in pairs(table) do
    if pred(k,v) then res[k] = v end
  end
  return res
end

function light_mgr:init(map,ambient)
  self.ambient = ambient
  self.occluders = table_filter(self.occluders,
    function(k,v) return k:get_map() == map end)
  self.lights = table_filter(self.lights,
    function(k,v) return v:get_map() == map end)

  --init occlusion chunks cache
  local mw, mh = map:get_size()
  self.occ_chunks = {}
  self.chunk_width = math.ceil(mw / chunk_size)
  self.chunk_height = math.ceil(mh / chunk_size)
  self.map = map
  --print("light manager initialized")
end

local inv_count = 0

function light_mgr:draw(dst,map)
  inv_count = inv_count + 1
  self.light_acc:fill_color(self.ambient or {255,255,255,255})
  local camera = map:get_camera()
  for n,l in pairs(self.lights) do
    l:draw_light(self.light_acc,camera)
  end
  self.map_occluder_layer = nil
  self.light_acc:draw(dst,0,0)
end

return light_mgr
