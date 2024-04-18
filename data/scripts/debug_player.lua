local game_manager = require("scripts/game_manager")

local debug_player = {}

function debug_player:on_key_pressed(key, modifiers)

  local handled = true
  if sol.main.game ~= nil then
    -- In-game cheating keys.
    local game = sol.main.game
    local hero = nil
    if game ~= nil and game:get_map() ~= nil then
      hero = game:get_map():get_entity("hero")
    end

    if key == "p" then
      game:add_life(game:get_max_life())
    elseif key == "o" then
      game:set_money(game:get_max_money())
    elseif key == "i" then
      game:set_magic(game:get_max_magic())
    elseif key == "r" then
      if hero:get_walking_speed() == 256 then
        hero:set_walking_speed(debug.normal_walking_speed)
      else
        debug.normal_walking_speed = hero:get_walking_speed()
        hero:set_walking_speed(256)
      end
    else
      -- Not a known in-game debug key.
      handled = false
    end
  else
    -- Not a known debug key.
    handled = false
  end

  return handled
end

return debug_player