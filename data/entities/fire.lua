-- A flame that can hurt enemies.
-- It is meant to by created by the lamp and the fire rod.
local fire = ...
local sprite

local enemies_touched = { }

fire:set_size(8, 8)
fire:set_origin(4, 5)
sprite = fire:create_sprite("entities/fire")
sprite:set_direction(fire:get_direction())

-- Remove the sprite if the animation finishes.
-- Use animation "flying" if you want it to persist.
function sprite:on_animation_finished()
  fire:remove()
end

-- Returns the sprite of a destrucible.
-- TODO remove this when the engine provides a function destructible:get_sprite()
local function get_destructible_sprite(destructible)

  return fire.get_sprite(destructible)
end

-- Returns whether a destructible is a bush.
local function is_bush(destructible)

  local sprite = get_destructible_sprite(destructible)
  if sprite == nil then
    return false
  end

  local sprite_id = sprite:get_animation_set()
  return sprite_id:match("^entities/Bushes/bush_")
end

local function bush_collision_test(fire, other)

  if other:get_type() ~= "destructible" then
    return false
  end

  if not is_bush(other) then
    return
  end

  -- Check if the fire box touches the one of the bush.
  -- To do this, we extend it of one pixel in all 4 directions.
  local x, y, width, height = fire:get_bounding_box()
  return other:overlaps(x - 1, y - 1, width + 2, height + 2)
end

-- Traversable rules.
fire:set_can_traverse("crystal", false)
fire:set_can_traverse("crystal_block", true)
fire:set_can_traverse("hero", true)
fire:set_can_traverse("jumper", true)
fire:set_can_traverse("block", false)
fire:set_can_traverse("door", false)
fire:set_can_traverse("stairs", false)
fire:set_can_traverse("stream", true)
fire:set_can_traverse("teletransporter", true)
fire:set_can_traverse_ground("deep_water", true)
fire:set_can_traverse_ground("shallow_water", true)
fire:set_can_traverse_ground("hole", true)
fire:set_can_traverse_ground("lava", true)
fire:set_can_traverse_ground("prickles", true)
fire:set_can_traverse_ground("low_wall", true)
fire:set_can_traverse(true)
fire.apply_cliffs = true

-- Can only traverse ground switches
fire:add_collision_test("overlapping", function(fire, entity)
  local entity_type = entity:get_type()
  if entity_type == "switch" then
    local switch = entity
    if switch:is_walkable() then fire:set_can_traverse("switch", true) else fire:set_can_traverse("switch", false) end
  end
end)

-- Burn bushes.
fire:add_collision_test(bush_collision_test, function(fire, entity)

  local map = fire:get_map()

  if entity:get_type() == "destructible" then
    if not is_bush(entity) then
      return
    end
    local bush = entity
    
    local bush_sprite = get_destructible_sprite(bush)
    if bush_sprite:get_animation() ~= "on_ground" then
      -- Possibly already being destroyed.
      return
    end

    fire:stop_movement()
    sprite:set_animation("stopped")

    -- TODO remove this when the engine provides a function destructible:destroy()
    local bush_sprite_id = bush_sprite:get_animation_set()
    local bush_x, bush_y, bush_layer = bush:get_position()
    local treasure = { bush:get_treasure() }
    if treasure ~= nil then
      local pickable = map:create_pickable({
        x = bush_x,
        y = bush_y,
        layer = bush_layer,
        treasure_name = treasure[1],
        treasure_variant = treasure[2],
        treasure_savegame_variable = treasure[3],
      })
    end

    sol.audio.play_sound(bush:get_destruction_sound())
    if bush:get_name() == "destructible_power_moon_1" or bush:get_name() == "destructible_power_moon_2" or bush:get_name() == "destructible_power_moon_3" or bush:get_name() == "destructible_power_moon_4" or bush:get_name() == "destructible_power_moon_5" then bush:on_cut() end
    bush:remove()

    local bush_destroyed_sprite = fire:create_sprite(bush_sprite_id)
    local x, y = fire :get_position()
    bush_destroyed_sprite:set_xy(bush_x - x, bush_y - y)
    bush_destroyed_sprite:set_animation("destroy")
  end
end)

-- Hurt enemies.
fire:add_collision_test("sprite", function(fire, entity)

  if entity:get_type() == "enemy" then
    local enemy = entity
    if enemies_touched[enemy] then
      -- If protected we don't want to play the sound repeatedly.
      return
    end
    enemies_touched[enemy] = true
    local reaction = enemy:get_fire_reaction(enemy_sprite)
    enemy:receive_attack_consequence("fire", reaction)

      fire:stop_movement()
      sprite:set_animation("stopped")
  end
end)

function fire:on_obstacle_reached()
    fire:stop_movement()
    sprite:set_animation("stopped")
end