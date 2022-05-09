-- Initialize hero behavior specific to this quest.

require("scripts/multi_events")
local hero_meta = sol.main.get_metatable("hero")

local link_voice_manager = require("scripts/link_voice_manager")

hero_meta:register_event("on_state_changed", function(hero)
  local current_state = hero:get_state()
  if hero.previous_state == "carrying" then
    hero:notify_object_thrown()
  end
  hero.previous_state = current_state
end)
hero_meta:register_event("notify_object_thrown", function() end)

hero_meta:register_event("on_state_changed", function(hero , state)

  local game = hero:get_game()
  local map = game:get_map()

  -- Avoid to lose any life when drowning.
  if state == "back to solid ground" then
    local ground = hero:get_ground_below()
    if ground == "deep_water" then
      game:add_life(1)
    end
  elseif state == "sword swinging" then
    -- Sword swinging
    local index = math.random(1, 3)
    if link_voice_manager:get_link_voice_enabled() then sol.audio.play_sound("link_voices/sword_voice_" .. index) end
  elseif state == "falling" then
    if link_voice_manager:get_link_voice_enabled() then sol.audio.play_sound("link_voices/hero_falls") else sol.audio.play_sound("hero_falls") end
  elseif state == "sword spin attack" then
    -- Sword spinning
    local index = math.random(1, 3)
    if link_voice_manager:get_link_voice_enabled() then sol.audio.play_sound("link_voices/spin_voice_" .. index) end
  end
end)

-- Return true if the hero is walking.
function hero_meta:is_walking()

  local m = self:get_movement()
  return m and m.get_speed and m:get_speed() > 0
end

function hero_meta:on_taking_damage(damage)

  -- Here, self is the hero.
  local game = self:get_game()

  -- In the parameter, the damage unit is 1/2 of a heart.

  local defense = game:get_value("defense")
  if defense == 0 then
    -- Multiply the damage by two if the hero has no defense at all.
    damage = damage * 2
  else
    damage = math.floor(damage / defense)
    if damage <= 0 then
      damage = 1
    end
  end
  --Double damage if heroic mode
  if game:get_value("heroic_mode") then
    damage = damage * 2
  end

  game:remove_life(damage)

  if link_voice_manager:get_link_voice_enabled() then sol.audio.play_sound("link_voices/hero_hurt") else sol.audio.play_sound("hero_hurt") end
end

-- Set fixed stopped/walking animations for the hero (or nil to disable them).
function hero_meta:set_fixed_animations(new_stopped_animation, new_walking_animation)

  fixed_stopped_animation = new_stopped_animation
  fixed_walking_animation = new_walking_animation
  -- Initialize fixed animations if necessary.
  local state = self:get_state()
  if state == "free" then
    if self:is_walking() then self:set_animation(fixed_walking_animation or "walking")
    else self:set_animation(fixed_stopped_animation or "stopped") end
  end
end

return true