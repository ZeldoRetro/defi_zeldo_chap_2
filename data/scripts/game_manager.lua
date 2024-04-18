-- Script that creates a game ready to be played.

-- Usage:
-- local game_manager = require("scripts/game_manager")
-- local game = game_manager:create("savegame_file_name")
-- game:start()

local game_manager = {}

local dungeon_manager = require("scripts/dungeons")
local equipment_manager = require("scripts/equipment")
local camera_manager = require("scripts/camera_manager")

-- Measures the time played in this savegame.
local function run_chronometer(game)

  local timer = sol.timer.start(game, 100, function()
    local time = game:get_value("time_played")
    time = time + 100
    game:set_value("time_played", time)
    return true  -- Repeat the timer.
  end)
  timer:set_suspended_with_map(false)
end

-- Creates a game ready to be played.
function game_manager:create(file)

  -- Create the game (but do not start it).
  local exists = sol.game.exists(file)
  local game = sol.game.load(file)
  if not exists then
    -- New game settings.
    game:set_starting_location("prologue","start")
    game:set_max_life(11*4)
    game:set_life(game:get_max_life())
    game:get_item("equipment/tunic"):set_variant(1)
    game:get_item("equipment/sword"):set_variant(3)
    game:get_item("equipment/shield"):set_variant(2)
    game:get_item("equipment/rupee_bag"):set_variant(1)
    game:get_item("magic_bar"):set_variant(1)
    game:get_item("inventory/lamp"):set_variant(1)
    game:get_item("inventory/boomerang"):set_variant(1)
    game:get_item("equipment/bomb_bag"):set_variant(1)
    local bombs_counter = game:get_item("inventory/bombs_counter")
    bombs_counter:set_variant(1)
    bombs_counter:set_amount(20)
    game:set_value("keyboard_look", "s")
    game:set_value("keyboard_save", "escape")
    game:set_value("force", 2)
    game:set_value("defense", 2)
    game:set_value("time_played", 0)
    game:set_value("death_counter", 0)
    game:set_value("daytime", 1)
    game:set_value("day",true)

    if heroic_mode_enabled_for_this_savegame then game:set_value("heroic_mode",true) heroic_mode_enabled_for_this_savegame = false end
  end
  
  sol.main.load_file("scripts/dialog_box.lua")(game)
  sol.main.load_file("scripts/game_over.lua")(game)
  local hud_manager = require("scripts/hud/hud")
  local hud
  local pause_manager = require("scripts/menus/pause")
  local pause_menu

  -- Function called when the player runs this game.
  function game:on_started()

    -- Prepare the dialog box menu and the HUD.
    game:initialize_dialog_box()
    hud = hud_manager:create(game)
    pause_menu = pause_manager:create(game)
	  dungeon_manager:create(game)
    equipment_manager:create(game)
    camera_manager:create(game)

    -- Measure the time played.
    run_chronometer(game)

    --Apply the FSA effect
    local eff_m = require('scripts/effect_manager')
    local fsa = require('scripts/fsa_effect')
    eff_m:set_effect(sol.main.get_game(),fsa)
  end

  -- Function called when the game stops.
  function game:on_finished()

    -- Clean the dialog box and the HUD.
    game:quit_dialog_box()
    hud:quit()
    hud = nil
    pause_menu = nil

  end

  -- Function called when the game is paused.
  function game:on_paused()

    -- Tell the HUD we are paused.
    hud:on_paused()

    -- Start the pause menu.
    sol.menu.start(game, pause_menu)
  end

  -- Function called when the game is paused.
  function game:on_unpaused()

    -- Tell the HUD we are no longer paused.
    hud:on_unpaused()

    -- Stop the pause menu.
    sol.menu.stop(pause_menu)
  end

  -- Function called when the player presses a key during the game.
  function game:on_key_pressed(key)

    if game.customizing_command then
      -- Don't treat this input normally, it will be recorded as a new command binding.
      return false
    end

    local handled = false

    if game:is_pause_allowed() then  -- Keys below are menus.
      if key == game:get_value("keyboard_save") then
        if not game:is_paused() and
            not game:is_dialog_enabled() and
            game:get_life() > 0 and not arcade_game then
          game:start_dialog("_save", function(answer)
            if answer == 1 then
              -- Sauvegarde
              game:save()
              if game:get_value("CHARA") then sol.audio.play_sound("screamer") end
              sol.audio.play_sound("save_menu_start_game")
            else
              -- Pas de sauvegarde
              sol.audio.play_sound("pause_closed")
            end
          end)
          sol.timer.start(1,function()
          game:start_dialog("_quit", function(answer)
            if answer == 1 then
              -- Continuer la partie
              sol.audio.play_sound("pause_closed")
            else
              -- Quitter le jeu
              game:set_value("dark_room",false)
              sol.audio.play_sound("pause_closed")
              sol.main.reset()
            end
          end)
          end)
          handled = true
        end
      end
   end

    return handled
  end

  -- Function called when the player presses a joypad button during the game.
  function game:on_joypad_button_pressed(button)

    if game.customizing_command then
      -- Don't treat this input normally, it will be recorded as a new command binding.
      return false
    end

    local handled = false

    local joypad_action = "button " .. button

    if game:is_pause_allowed() then  -- Keys below are menus.
      if joypad_action == game:get_value("joypad_save") then
        if not game:is_paused() and
            not game:is_dialog_enabled() and
            game:get_life() > 0 and not arcade_game then
          game:start_dialog("_save", function(answer)
            if answer == 1 then
              -- Sauvegarde
              game:save()
              if game:get_value("CHARA") then sol.audio.play_sound("screamer") end
              sol.audio.play_sound("save_menu_start_game")
            else
              -- Pas de sauvegarde
              sol.audio.play_sound("pause_closed")
            end
          end)
          sol.timer.start(1,function()
          game:start_dialog("_quit", function(answer)
            if answer == 1 then
              -- Continuer la partie
              sol.audio.play_sound("pause_closed")
            else
              -- Quitter le jeu
              sol.audio.play_sound("pause_closed")
              sol.main.reset()
            end
          end)
          end)
          handled = true
        end
      end
    end

    return handled
  end

  -- Function called when the player goes to another map.
  game.on_map_changed = function(game, map)

    -- Notify the HUD (some HUD elements need to know that).
    hud:on_map_changed(map)

  end

  local custom_command_effects = {}
  -- Returns the current customized effect of the action or attack command.
  -- nil means that the built-in effect.
  function game:get_custom_command_effect(command)
    return custom_command_effects[command]
  end

  -- Overrides the effect of the action or attack command.
  -- Set the effect to nil to restore the built-in effect.
  function game:set_custom_command_effect(command, effect)
    custom_command_effects[command] = effect
  end

  -- Returns whether the HUD is currently shown.
  function game:is_hud_enabled()
    return hud:is_enabled()
  end

  -- Enables or disables the HUD.
  function game:set_hud_enabled(enable)
    return hud:set_enabled(enable)
  end

  function game:switch_pause_menu(submenu_name)
    pause_menu:switch_submenu(submenu_name)
  end

  -- Returns the game time in seconds.
  function game:get_time_played()
    local milliseconds = game:get_value("time_played")
    local total_seconds = math.floor(milliseconds / 1000)
    return total_seconds
  end

  -- Returns a string representation of the game time.
  function game:get_time_played_string()
    local total_seconds = game:get_time_played()
    local seconds = total_seconds % 60
    local total_minutes = math.floor(total_seconds / 60)
    local minutes = total_minutes % 60
    local total_hours = math.floor(total_minutes / 60)
    local time_string = string.format("%02d:%02d:%02d", total_hours, minutes, seconds)
    return time_string
  end

  return game
end

return game_manager