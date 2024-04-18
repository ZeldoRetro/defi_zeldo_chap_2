local console = require("scripts/console")
local game_manager = require("scripts/game_manager")

local debug = {}

function debug:on_key_pressed(key, modifiers)

  local handled = true
  if key == "f1" then
    if sol.game.exists("save1.dat") then
      sol.main.start_game(game_manager:create("save1.dat"))
    end
  elseif key == "f2" then
    if sol.game.exists("save2.dat") then
      sol.main.start_game(game_manager:create("save2.dat"))
    end
  elseif key == "f3" then
    if sol.game.exists("save3.dat") then
      sol.main.start_game(game_manager:create("save3.dat"))
    end
  elseif key == "f12" and not console.enabled then
    sol.menu.start(sol.main, console)
  elseif sol.main.game ~= nil and not console.enabled then
    -- In-game cheating keys.
    local game = sol.main.game
    local hero = nil
    if game ~= nil and game:get_map() ~= nil then
      hero = game:get_map():get_entity("hero")
    end

    if key == "p" then
      game:add_life(5)
    elseif key == "m" then
      game:remove_life(1)
    elseif key == "o" then
      game:add_money(50)
    elseif key == "l" then
      game:add_money(15)
    elseif key == "i" then
      game:add_magic(10)
    elseif key == "k" then
      game:remove_magic(4)
    elseif key == "kp 7" then
      game:set_max_magic(0)
    elseif key == "kp 8" then
      game:set_max_magic(42)
    elseif key == "kp 9" then
      game:set_max_magic(84)
    elseif key == "kp 1" then
      local tunic = game:get_item("equipment/tunic")
      local variant = math.max(1, tunic:get_variant() - 1)
      tunic:set_variant(variant)
      game:set_ability("tunic", variant)
      game:set_value("defense",game:get_value("defense") - 1)
    elseif key == "kp 4" then
      local tunic = game:get_item("equipment/tunic")
      local variant = math.min(3, tunic:get_variant() + 1)
      tunic:set_variant(variant)
      game:set_ability("tunic", variant)
      game:set_value("defense",game:get_value("defense") + 1)
    elseif key == "kp 2" then
      local sword = game:get_item("equipment/sword")
      local variant = math.max(1, sword:get_variant() - 1)
      sword:set_variant(variant)
      game:set_value("force",game:get_value("force") - 1)
    elseif key == "kp 5" then
      local sword = game:get_item("equipment/sword")
      local variant = math.min(4, sword:get_variant() + 1)
      sword:set_variant(variant)
      game:set_value("force",game:get_value("force") + 1)
    elseif key == "kp 3" then
      local shield = game:get_item("equipment/shield")
      local variant = math.max(1, shield:get_variant() - 1)
      shield:set_variant(variant)
    elseif key == "kp 6" then
      local shield = game:get_item("equipment/shield")
      local variant = math.min(3, shield:get_variant() + 1)
      shield:set_variant(variant)
    elseif key == "g" and hero ~= nil then
      local x, y, layer = hero:get_position()
      if layer ~= -9 then
        hero:set_position(x, y, layer - 1)
      end
    elseif key == "t" and hero ~= nil then
      local x, y, layer = hero:get_position()
      if layer ~= 9 then
        hero:set_position(x, y, layer + 1)
      end
    elseif key == "r" then
      if hero:get_walking_speed() == 300 then
        hero:set_walking_speed(debug.normal_walking_speed)
      else
        debug.normal_walking_speed = hero:get_walking_speed()
        hero:set_walking_speed(300)
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

-- The shift key skips dialogs
-- and the control key traverses walls.
local hero_movement = nil
local ctrl_pressed = false
function debug:on_update()

  local game = sol.main.game
  if game ~= nil then

    if game:is_dialog_enabled() then
      if sol.input.is_key_pressed("left shift") or sol.input.is_key_pressed("right shift") then
        game:get_dialog_box():show_all_now()
      end
    end

    local hero = game:get_hero()
    if hero ~= nil then
      if hero:get_movement() ~= hero_movement then
        -- The movement has changed.
        hero_movement = hero:get_movement()
        if hero_movement ~= nil
            and ctrl_pressed
            and not hero_movement:get_ignore_obstacles() then
          -- Also traverse obstacles in the new movement.
          hero_movement:set_ignore_obstacles(true)
        end
      end
      if hero_movement ~= nil then
        if not ctrl_pressed
            and (sol.input.is_key_pressed("left control") or sol.input.is_key_pressed("right control")) then
          hero_movement:set_ignore_obstacles(true)
          ctrl_pressed = true
        elseif ctrl_pressed
            and (not sol.input.is_key_pressed("left control") and not sol.input.is_key_pressed("right control")) then
          hero_movement:set_ignore_obstacles(false)
          ctrl_pressed = false
        end
      end
    end
  end
end

return debug