local map = ...
local game = map:get_game()
local music_map = map:get_music()
texte_lieu = sol.surface.create(sol.language.get_language().."/texte_lieu/fire_palace.png")

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local chest_manager = require("maps/lib/chest_manager")
chest_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

--EFFET DE CHALEUR
local heat = sol.surface.create(320,240)
heat:set_opacity(80)
heat:fill_color({255,40,0})

local detector_img = sol.surface.create("hud/detector.png")

function map:on_draw(dst_surface)
  heat:draw(dst_surface)

  --Détecteur: Symbole si fragment de Force a proximité
  if game:get_value("get_power_moon_detector") then
    for entity in game:get_map():get_entities("power_moon_") do
      detector_img:draw(dst_surface)
    end
    for entity in game:get_map():get_entities("hidden_power_moon_") do
      detector_img:draw(dst_surface)      
    end
  end

  --AFFICHAGE LIEU
  if texte_lieu_on then texte_lieu:draw(dst_surface) end
end


--DEBUT DE LA MAP
function map:on_started()
  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)
  map:set_doors_open("falling_door_1")
  map:set_doors_open("falling_door_2")
  map:set_doors_open("falling_door_3")
  map:set_doors_open("falling_door_4")
  map:set_doors_open("falling_door_5")
  map:set_doors_open("falling_door_6")
  map:set_entities_enabled("hidden_power_moon_",false)

  --Sol fissuré
  if map:get_game():get_value("weak_floor_101") then
    weak_floor:set_enabled(false)
    weak_floor_sensor:set_enabled(false)
  else
    weak_floor_teletransporter:set_enabled(false)
  end
end

--SOL FISSURE
function weak_floor_sensor:on_collision_explosion()
  if weak_floor:is_enabled() then
    weak_floor:set_enabled(false)
    weak_floor_sensor:set_enabled(false)
    weak_floor_teletransporter:set_enabled(true)
    sol.audio.play_sound("secret")
    map:get_game():set_value("weak_floor_101", true)
  end
end

--SALLE SECRETE: SON DE SECRET
function auto_separator_1:on_activating(direction4)
  if direction4 == 1 then sol.audio.play_sound("secret") end
end

--LUNES DE PUISSANCE CACHEES
function destructible_power_moon_1:on_cut() sol.timer.start(map,300,function() 
  if hidden_power_moon_2 ~= nil then hidden_power_moon_2:set_enabled(true) end 
end) end
function destructible_power_moon_1:on_lifting() 
  if hidden_power_moon_2 ~= nil then hidden_power_moon_2:set_enabled(true) end
end