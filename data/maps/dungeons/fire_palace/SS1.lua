local map = ...
local game = map:get_game()
local music_map = map:get_music()
texte_boss = sol.surface.create(sol.language.get_language().."/texte_boss/moltres.png")

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local chest_manager = require("maps/lib/chest_manager")
chest_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

--EFFET DE CHALEUR
local heat = sol.surface.create(320,240)
heat:set_opacity(120)
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

  --AFFICHAGE BOSS
  if texte_boss_on then texte_boss:draw(dst_surface) end
end

--DEBUT DE LA MAP
function map:on_started()
  --Pendant la journée, lumière qui sort des fenètres/portes d'entrée
  if game:get_value("night") or game:get_value("dawn") then
    --Jour/Crépuscule
    map:set_entities_enabled("day_entity",false)
  end
  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)

  local ground=game:get_value("tp_ground")
  if ground=="hole" then
    hero:set_visible(false)
  else
    hero:set_visible()
  end

  texte_boss_1:set_enabled(false)
  map:set_entities_enabled("hidden_power_moon_",false)

  --Boss vaincu
  if game:get_value("boss_101") then
    sensor_boss:set_enabled(false)
  else map:set_entities_enabled("bridge",false) boss:set_enabled(false) end
end

--BOSS: SULFURA
function sensor_boss:on_activated()
    sensor_boss:set_enabled(false)
    hero:freeze()
    sol.audio.play_music("none")
    sol.timer.start(1000,function()
      map:get_entity("texte_boss_1"):set_enabled(true)
      hero:unfreeze()
      map:get_entity("boss"):set_enabled(true)
      map:get_entity("boss"):set_hurt_style("boss")
      sol.audio.play_music("battle_ff")
      map:get_entity("texte_boss_1"):set_enabled(false)
    end)
end
if boss ~= nil then
 function boss:on_dying()
  hero:freeze()
  sol.audio.play_music(nil)
 end
 function boss:on_dead()
  sol.timer.start(1000,function()
    hero:unfreeze()
    sol.audio.play_music("after_battle")
    map:set_entities_enabled("bridge",true)
  end)
 end
end

--LUNES DE PUISSANCE CACHEES
function destructible_power_moon_1:on_cut() sol.timer.start(map,300,function() 
  if hidden_power_moon_3 ~= nil then hidden_power_moon_3:set_enabled(true) end 
end) end
function destructible_power_moon_1:on_lifting() 
  if hidden_power_moon_3 ~= nil then hidden_power_moon_3:set_enabled(true) end
end