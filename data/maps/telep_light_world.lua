local map = ...
local game = map:get_game()

function map:on_started()

  game:set_pause_allowed(false)
  game:set_hud_enabled(false)
  hero:set_visible(false)
  cursor:set_position(hero:get_position())
  map:get_hero():set_walking_speed(144)
  hero_slowed = true

  --Liste des Téléporteurs découverts (ou non)
  if game:get_value("owl_takapa_village_activated") then location_takapa_village:set_enabled(true) location_takapa_village_sensor:set_enabled(true) end
  if game:get_value("owl_ruins_activated") then location_ruins:set_enabled(true) location_ruins_sensor:set_enabled(true) end
  if game:get_value("owl_ice_mountain_activated") then location_ice_mountain:set_enabled(true) location_ice_mountain_sensor:set_enabled(true) end
end

function map:on_opening_transition_finished()
  sword_level = game:get_ability("sword")
  game:set_ability("sword",0)
  item_assigned_slot_1 = game:get_item_assigned(1)
  game:set_item_assigned(1, nil)
  item_assigned_slot_2 = game:get_item_assigned(2)
  game:set_item_assigned(2, nil)
end

local can_select_location = false
local location_selected = false

--VILLAGE DE TAKAPA
function location_takapa_village_sensor:on_activated_repeat()
  can_select_location = true
  function map:on_key_pressed(key)
    if key == game:get_value("_keyboard_action") then 
      if can_select_location and not location_selected then
        location_selected = true
        game:start_dialog("teleportation.takapa_village",function(answer)
          if answer == 1 then
            game:set_ability("sword",sword_level)
            game:set_item_assigned(1, item_assigned_slot_1)
            game:set_item_assigned(2, item_assigned_slot_2)
            sol.audio.play_sound("warp") hero:teleport("outside/A2","flight_destination") 
          else location_selected = false end
        end)
      end
    end
  end
  function map:on_joypad_button_pressed(button)
    local joypad_action = "button " .. button
    if joypad_action == game:get_value("_joypad_action") then 
      if can_select_location and not location_selected then
        location_selected = true
        game:start_dialog("teleportation.takapa_village",function(answer)
          if answer == 1 then
            game:set_ability("sword",sword_level)
            game:set_item_assigned(1, item_assigned_slot_1)
            game:set_item_assigned(2, item_assigned_slot_2)
            sol.audio.play_sound("warp") hero:teleport("outside/A2","flight_destination") 
          else location_selected = false end
        end)
      end
    end
  end
end
function location_takapa_village_sensor:on_left()
  can_select_location = false
end

--RUINES DE LA BRUME
function location_ruins_sensor:on_activated_repeat()
  can_select_location = true
  function map:on_key_pressed(key)
    if key == game:get_value("_keyboard_action") then 
      if can_select_location and not location_selected then
        location_selected = true
        game:start_dialog("teleportation.ruins",function(answer)
          if answer == 1 then
            game:set_ability("sword",sword_level)
            game:set_item_assigned(1, item_assigned_slot_1)
            game:set_item_assigned(2, item_assigned_slot_2)
            sol.audio.play_sound("warp") hero:teleport("outside/B1","flight_destination") 
          else location_selected = false end
        end)
      end
    end
  end
  function map:on_joypad_button_pressed(button)
    local joypad_action = "button " .. button
    if joypad_action == game:get_value("_joypad_action") then 
      if can_select_location and not location_selected then
        location_selected = true
        game:start_dialog("teleportation.ruins",function(answer)
          if answer == 1 then
            game:set_ability("sword",sword_level)
            game:set_item_assigned(1, item_assigned_slot_1)
            game:set_item_assigned(2, item_assigned_slot_2)
            sol.audio.play_sound("warp") hero:teleport("outside/B1","flight_destination") 
          else location_selected = false end
        end)
      end
    end
  end
end
function location_ruins_sensor:on_left()
  can_select_location = false
end

--SOMMET ENNEIGÉ
function location_ice_mountain_sensor:on_activated_repeat()
  can_select_location = true
  function map:on_key_pressed(key)
    if key == game:get_value("_keyboard_action") then 
      if can_select_location and not location_selected then
        location_selected = true
        game:start_dialog("teleportation.ice_mountain",function(answer)
          if answer == 1 then
            game:set_ability("sword",sword_level)
            game:set_item_assigned(1, item_assigned_slot_1)
            game:set_item_assigned(2, item_assigned_slot_2)
            sol.audio.play_sound("warp") hero:teleport("outside/A1","flight_destination") 
          else location_selected = false end
        end)
      end
    end
  end
  function map:on_joypad_button_pressed(button)
    local joypad_action = "button " .. button
    if joypad_action == game:get_value("_joypad_action") then 
      if can_select_location and not location_selected then
        location_selected = true
        game:start_dialog("teleportation.ice_mountain",function(answer)
          if answer == 1 then
            game:set_ability("sword",sword_level)
            game:set_item_assigned(1, item_assigned_slot_1)
            game:set_item_assigned(2, item_assigned_slot_2)
            sol.audio.play_sound("warp") hero:teleport("outside/A1","flight_destination") 
          else location_selected = false end
        end)
      end
    end
  end
end
function location_ice_mountain_sensor:on_left()
  can_select_location = false
end

function map:on_update()
  cursor:set_position(hero:get_position())
end

map:register_event("on_finished", function(map)
  game:set_pause_allowed(true)
  game:set_hud_enabled(true)
  map:get_hero():set_walking_speed(88)
  map:get_hero():set_visible(true)
  hero_slowed = false
end)