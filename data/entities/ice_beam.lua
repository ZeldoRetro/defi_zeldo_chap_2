-- An ice beam that can unlight torches and turn lava into blocks.
local ice_beam = ...
local sprites = {}
local ice_path_sprite

local enemies_touched = {}

function ice_beam:on_created()

  ice_beam:set_size(8, 8)
  ice_beam:set_origin(4, 5)
  ice_beam:create_sprite("entities/ice_beam")
end

-- Traversable rules.
ice_beam:set_can_traverse("crystal", false)
ice_beam:set_can_traverse("crystal_block", true)
ice_beam:set_can_traverse("hero", true)
ice_beam:set_can_traverse("jumper", true)
ice_beam:set_can_traverse("stairs", false)
ice_beam:set_can_traverse("stream", true)
ice_beam:set_can_traverse("teletransporter", true)
ice_beam:set_can_traverse_ground("deep_water", true)
ice_beam:set_can_traverse_ground("shallow_water", true)
ice_beam:set_can_traverse_ground("hole", true)
ice_beam:set_can_traverse_ground("lava", true)
ice_beam:set_can_traverse_ground("prickles", true)
ice_beam:set_can_traverse_ground("low_wall", true)
ice_beam.apply_cliffs = true

-- Can only traverse ground switches
ice_beam:add_collision_test("overlapping", function(ice_beam, entity)
  local entity_type = entity:get_type()
  if entity_type == "switch" then
    local switch = entity
    if switch:is_walkable() then ice_beam:set_can_traverse("switch", true) else ice_beam:set_can_traverse("switch", false) end
  end
end)

-- Hurt enemies.
ice_beam:add_collision_test("sprite", function(ice_beam, entity)

  if entity:get_type() == "enemy" then
    local enemy = entity
    if enemies_touched[enemy] then
      -- If protected we don't want to play the sound repeatedly.
      return
    end
    enemies_touched[enemy] = true
    local reaction = enemy:get_ice_reaction(enemy_sprite)
    enemy:receive_attack_consequence("ice", reaction)

    sol.timer.start(ice_beam, 200, function()
      ice_beam:remove()
    end)
  end
end)

function ice_beam:go(angle)

  local movement = sol.movement.create("straight")
  movement:set_speed(192)
  movement:set_angle(angle)
  movement:set_smooth(false)
  movement:start(ice_beam)
end

function ice_beam:on_obstacle_reached()

  ice_beam:remove()
end

function ice_beam:on_movement_finished()
  ice_beam:remove()
end

function ice_beam:on_position_changed()

  if sprites[1] == nil then
    -- Not initialized yet.
    return
  end
end