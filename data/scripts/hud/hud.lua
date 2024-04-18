-- Script that creates a head-up display for a game.

-- Usage:
-- local hud_manager = require("scripts/hud/hud")
-- local hud = hud_manager:create(game)

local hud_manager = {}

-- Creates and runs a HUD for the specified game.
function hud_manager:create(game)

  -- Set up the HUD.
  local hud = {
    enabled = false,
    showing_dialog = false,
    top_left_opacity = 255,
    elements = {},
  }

  -- Create each element of the HUD.
  local hearts_builder = require("scripts/hud/hearts")
  local magic_bar_builder = require("scripts/hud/magic_bar")
  local rupees_builder = require("scripts/hud/rupees")
  local small_keys_builder = require("scripts/hud/small_keys")
  local floor_builder = require("scripts/hud/floor")
  local action_icon_builder = require("scripts/hud/action_icon")
  local attack_icon_builder = require("scripts/hud/attack_icon")
  local pause_icon_builder = require("scripts/hud/pause_icon")
  local item_icon_builder = require("scripts/hud/item_icon")
  local boss_life_builder = require("scripts/hud/boss_life")
  local clock_builder = require("scripts/hud/clock")

  local hearts = hearts_builder:new(game)
  hearts:set_dst_position(-312, 6)
  hud.elements[#hud.elements + 1] = hearts

  local magic_bar = magic_bar_builder:new(game)
  magic_bar:set_dst_position(-312, 25)
  hud.elements[#hud.elements + 1] = magic_bar

  local rupees = rupees_builder:new(game)
  rupees:set_dst_position(8, -20)
  hud.elements[#hud.elements + 1] = rupees

  local small_keys = small_keys_builder:new(game)
  small_keys:set_dst_position(10, -30)
  hud.elements[#hud.elements + 1] = small_keys

  local floor = floor_builder:new(game)
  floor:set_dst_position(5, 102)
  hud.elements[#hud.elements + 1] = floor

  local pause_icon = pause_icon_builder:new(game)
  pause_icon:set_dst_position(225, 7)
  hud.elements[#hud.elements + 1] = pause_icon

  local item_icon_1 = item_icon_builder:new(game, 1)
  item_icon_1:set_dst_position(236, 29)
  hud.elements[#hud.elements + 1] = item_icon_1

  local item_icon_2 = item_icon_builder:new(game, 2)
  item_icon_2:set_dst_position(288, 29)
  hud.elements[#hud.elements + 1] = item_icon_2

  local action_icon = action_icon_builder:new(game)
  action_icon:set_dst_position(251, 51)
  hud.elements[#hud.elements + 1] = action_icon

  local attack_icon = attack_icon_builder:new(game)
  attack_icon:set_dst_position(238, 29)
  hud.elements[#hud.elements + 1] = attack_icon

  local boss_life = boss_life_builder:new(game)
  boss_life:set_dst_position(110, 220)
  hud.elements[#hud.elements + 1] = boss_life

  local clock = clock_builder:new(game)
  clock:set_dst_position(280, 200)
  hud.elements[#hud.elements + 1] = clock


  -- Destroys the HUD.
  function hud:quit()

    if hud:is_enabled() then
      -- Stop all HUD elements.
      hud:set_enabled(false)
    end
  end

  -- Function called regularly to update the opacity and the position
  -- of HUD elements depending on various factors.
  local function check_hud()

    local map = game:get_map()
    if map ~= nil then
      -- If the hero is below the top-left icons, make them semi-transparent.
      local hero = map:get_entity("hero")
      local hero_x, hero_y = hero:get_position()
      local camera_x, camera_y = map:get_camera_position()
      local x = hero_x - camera_x
      local y = hero_y - camera_y
      local opacity = nil

      if hud.top_left_opacity == 255
          and not game:is_suspended()
          and x > 220
          and y < 80 then
        opacity = 96
      elseif hud.top_left_opacity == 96
          and (game:is_suspended()
          or x <= 220
          or y >= 80) then
        opacity = 255
      end

      if opacity ~= nil then
        hud.top_left_opacity = opacity
        item_icon_1.surface:set_opacity(opacity)
        item_icon_2.surface:set_opacity(opacity)
        pause_icon.surface:set_opacity(opacity)
        action_icon.surface:set_opacity(opacity)
        attack_icon.surface:set_opacity(opacity)
      end
    end

    sol.timer.start(game, 50, check_hud)
  end

  -- Call this function to notify the HUD that the current map has changed.
  function hud:on_map_changed(map)

    if hud:is_enabled() then
      for _, menu in ipairs(hud.elements) do
        if menu.on_map_changed ~= nil then
          menu:on_map_changed(map)
        end
      end
    end
  end

  -- Call this function to notify the HUD that the game was just paused.
  function hud:on_paused()

    if hud:is_enabled() then
      for _, menu in ipairs(hud.elements) do
        if menu.on_paused ~= nil then
          menu:on_paused()
        end
      end
    end
  end

  -- Call this function to notify the HUD that the game was just unpaused.
  function hud:on_unpaused()

    if hud:is_enabled() then
      for _, menu in ipairs(hud.elements) do
        if menu.on_unpaused ~= nil then
          menu:on_unpaused()
        end
      end
    end
  end

  -- Returns whether the HUD is currently enabled.
  function hud:is_enabled()
    return hud.enabled
  end

  -- Enables or disables the HUD.
  function hud:set_enabled(enabled)

    if enabled ~= hud.enabled then
      hud.enabled = enabled

      for _, menu in ipairs(hud.elements) do
        if enabled then
          -- Start each HUD element.
          sol.menu.start(game, menu)
        else
          -- Stop each HUD element.
          sol.menu.stop(menu)
        end
      end
    end
  end

  -- Start the HUD.
  hud:set_enabled(true)

  -- Update it regularly.
  check_hud()

  -- Return the HUD.
  return hud
end

return hud_manager

