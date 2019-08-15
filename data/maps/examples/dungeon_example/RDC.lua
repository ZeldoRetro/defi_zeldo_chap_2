local map = ...
local game = map:get_game()
local music_map = map:get_music()
texte_lieu = sol.surface.create(sol.language.get_language().."/texte_lieu/example.png")

texte_boss = sol.surface.create(sol.language.get_language().."/texte_boss/example.png")

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local chest_manager = require("maps/lib/chest_manager")
chest_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)


--DEBUT DE LA MAP
function map:on_started()
  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)
  map:set_doors_open("auto_door_2_back")
  map:set_entities_enabled("miniboss",false)
  map:set_entities_enabled("wave",false)
  texte_boss_1:set_enabled(false)

  --Clé 1 obtenue
  if game:get_value("key_0_1") then auto_chest_key_1:set_enabled(true) end
  --Carte obtenue
  if game:get_value("map_0") then auto_chest_map:set_enabled(true) end
  --Clé 2 obtenue
  if game:get_value("key_0_2") then auto_chest_key_2:set_enabled(true) end
  --Boussole obtenue
  if game:get_value("compass_0") then auto_chest_compass:set_enabled(true) end

  --Miniboss vaincu
  if game:get_value("miniboss_0") then
    sensor_miniboss:set_enabled(false)
    map:set_doors_open("door_miniboss")
  else map:set_doors_open("door_miniboss_1") map:set_entities_enabled("telep_miniboss",false) end

  --Bataille 1 faite
  if game:get_value("battle_0_1") then
    map:set_entities_enabled("sensor_battle_1",false)
    map:set_doors_open("door_battle")
  else map:set_doors_open("door_battle_1_1") end

  --Téléporteur vers le boss débloqué
  if game:get_value("telep_boss_0") then map:set_entities_enabled("telep_boss",true) else map:set_entities_enabled("telep_boss",false) end

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

--PORTES OUVERTES: COMBATS
if game:get_value("door_0_2") then sensor_falling_auto_door_2_back:set_enabled(false) end

--PORTES INVISIBLES: SONS SECRETS
function secret_separator_1:on_activating(direction4)
  if direction4 == 2 then sol.audio.play_sound("secret") end
end

--BATAILLE 1
local wave = 1
local function battle_clear()
  local door_x, door_y = map:get_entity("door_battle_1_2"):get_position()
  map:move_camera(door_x,door_y,256,function() 
    map:open_doors("door_battle")
    game:set_value("battle_0_1",true)
    sol.audio.play_music(music_map)
  end) 
end
function map:on_update()
  for enemy in map:get_entities("wave_"..wave.."_enemy") do
    enemy.on_dead = function()
      if not map:has_entities("wave_"..wave.."_enemy") then
        sol.audio.play_sound("correct")
        wave = wave + 1
  		  map:set_entities_enabled("wave_"..wave.."_enemy",true)
        --Au bout de 3 vagues, fin de la bataille
        if wave == 4 then
          battle_clear()      
        end
      end
    end
  end
end