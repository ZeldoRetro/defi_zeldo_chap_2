local map = ...
local game = map:get_game()

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

texte_lieu = sol.surface.create(sol.language.get_language().."/texte_lieu/defi_zeldo.png")
texte_boss = sol.surface.create(sol.language.get_language().."/texte_boss/mothula.png")

--DEBUT DE LA MAP
function map:on_started()
  texte_boss_1:set_enabled(false)
  --Boss
  if game:get_value("boss_0") then 
    sensor_boss:set_enabled(false) 
    map:set_doors_open("door_boss")
    local x, y = heart_container_spot:get_position()
    map:create_pickable{
      treasure_name = "quest_items/heart_container",
      treasure_variant = 1,
      treasure_savegame_variable = "heart_container_0",
      x = x,
      y = y,
      layer = 1
    }
  else map:set_doors_open("door_boss_1") boss:set_enabled(false) end
end