local entity_manager={}
function entity_manager:fall(entity)
  local sprite = entity:get_sprite()
  if sprite:has_animation("falling") then
    sprite:set_animation("falling", function()
        entity:remove()
      end)
  else
    local x, y, layer = entity:get_position()
    entity:get_map():create_custom_entity({
      name="falling_entity_actor",
      sprite = "entities/falling",
      x = x,
      y = y,
      width = 16,
      height = 16,
      layer = layer,
      direction = 0,
    })
    entity:remove()
  end
end

function entity_manager:drown(entity)
  local sprite = entity:get_sprite()
  sprite:set_animation("normal", function()
    entity:remove()
  end)
end

function entity_manager:create_falling_entity(base_entity, sprite_name)
  --print "DOWN WE GOOOOOOooooooo........ !"
  local x, y, layer = base_entity:get_position()

  if not sprite_name then
    if base_entity:get_type()=="enemy" then
      sprite_name="enemies/"..base_entity:get_breed()
    else
      sprite_name=base_entity:get_sprite():get_animation_set()
    end
  end
  local falling_entity = base_entity:get_map():create_custom_entity({
      name="falling_entity_actor",
      sprite = sprite_name,
      x = x,
      y = y,
      width = 16,
      height = 16,
      layer = layer,
      direction = 0,
    })
  if falling_entity then --will be nil if the map is in finishing state
    falling_entity:set_can_traverse_ground("hole", true)
    entity_manager:fall(falling_entity)
  end
end

function entity_manager:create_drowning_entity(base_entity, sprite_name)
  --print "DOWN WE GOOOOOOooooooo........ !"
  local x, y, layer = base_entity:get_position()

  if not sprite_name then
    if base_entity:get_type()=="enemy" then
      sprite_name="enemies/"..base_entity:get_breed()
    else
      sprite_name=base_entity:get_sprite():get_animation_set()
    end
  end
  local falling_entity = base_entity:get_map():create_custom_entity({
      name="falling_entity_actor",
      sprite = "entities/splash",
      x = x,
      y = y,
      width = 16,
      height = 16,
      layer = layer,
      direction = 0,
    })
  if falling_entity then --will be nil if the map is in finishing state
    falling_entity:set_can_traverse_ground("deep_water", true)
    entity_manager:drown(falling_entity)
  end
end

function entity_manager:create_burning_entity(base_entity, sprite_name)
  --print "DOWN WE GOOOOOOooooooo........ !"
  local x, y, layer = base_entity:get_position()

  if not sprite_name then
    if base_entity:get_type()=="enemy" then
      sprite_name="enemies/"..base_entity:get_breed()
    else
      sprite_name=base_entity:get_sprite():get_animation_set()
    end
  end
  local falling_entity = base_entity:get_map():create_custom_entity({
      name="falling_entity_actor",
      sprite = "entities/splash_lava",
      x = x,
      y = y,
      width = 16,
      height = 16,
      layer = layer,
      direction = 0,
    })
  if falling_entity then --will be nil if the map is in finishing state
    falling_entity:set_can_traverse_ground("lava", true)
    entity_manager:drown(falling_entity)
  end
end

return entity_manager