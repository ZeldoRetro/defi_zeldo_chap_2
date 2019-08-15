-- A very weaked ground who disappear after the hero walk on it.

local very_weak_ground = ...

local allowed_states = {
  ["carrying"] = true,
  ["free"] = true,
  ["pulling"] = true,
  ["pushing"] = true,
  ["running"] = true,
  ["swimming"] = true,
  ["sword loading"] = true,
  ["sword spin attack"] = true,
  ["sword swinging"] = true,
  ["sword tapping"] = true,
}

function very_weak_ground:on_created()

  very_weak_ground:set_size(16, 16)
  very_weak_ground:set_origin(8, 13)
  very_weak_ground:set_traversable_by(true)
  very_weak_ground:set_drawn_in_y_order(false)
  very_weak_ground:set_modified_ground("traversable")

end

very_weak_ground:add_collision_test("center", function(very_weak_ground, entity)

  if entity:get_type() ~= "hero" then
    return
  end

  local hero = entity

  local current_state = hero:get_state()
  if not allowed_states[current_state] then
    return
  end

  local map = very_weak_ground:get_map()
  very_weak_ground:get_sprite():set_animation("shaking")
  if not map.very_weak_ground_recent_sound then
    sol.audio.play_sound("enemy_awake")
    -- Avoid loudy simultaneous sounds if there are several entities.
    map.very_weak_ground_recent_sound = true
    sol.timer.start(map, 200, function()
      map.very_weak_ground_recent_sound = nil
    end)
  end
  sol.timer.start(map,750,function() 
    if not map.very_weak_ground_recent_sound_2 then
      sol.audio.play_sound("jump")
      -- Avoid loudy simultaneous sounds if there are several entities.
      map.very_weak_ground_recent_sound_2 = true
      sol.timer.start(map, 250, function()
        map.very_weak_ground_recent_sound_2 = nil
      end)
    end
    very_weak_ground:set_enabled(false) 
    sol.timer.start(map,10000,function() very_weak_ground:set_enabled(true) very_weak_ground:get_sprite():set_animation("normal") end)
  end)
end)