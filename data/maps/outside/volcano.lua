local map = ...
local game = map:get_game()

texte_lieu = sol.surface.create(sol.language.get_language().."/texte_lieu/volcano.png")

--EFFET DE CHALEUR
local heat = sol.surface.create(320,240)
heat:set_opacity(80)
heat:fill_color({255,40,0})

function map:on_draw(dst_surface)
  heat:draw(dst_surface)
  --AFFICHAGE LIEU
  if texte_lieu_on then texte_lieu:draw(dst_surface) end
end

-- DEBUT DE LA MAP
function map:on_started(destination)
  map:set_entities_enabled("hidden_power_moon_",false)
  --Système jour/nuit
  if game:get_value("day") or game:get_value("twilight") then
    --Jour/Crépuscule
    map:set_entities_enabled("night_entity",false)
    map:set_entities_enabled("day_entity",true)
  elseif game:get_value("night") or game:get_value("dawn") then
    --Nuit/Aube
    map:set_entities_enabled("night_entity",true)
    map:set_entities_enabled("day_entity",false)
  end

  --Porte du Palais ouverte
  if game:get_value("fire_palace_door_opened") then palace_door:set_enabled(false) switch_palace_door:set_activated(true) end
end

--ENTREE DU PALAIS FERMEE PAR UN INTERRUPTEUR
function switch_palace_door:on_activated()
  sol.audio.play_sound("correct")
  map:move_camera(320,88,256,function() 
    palace_door:set_enabled(false) 
    sol.audio.play_sound("explosion")
    game:set_value("fire_palace_door_opened",true)
    sol.timer.start(map,700,function() sol.audio.play_sound("secret") end)
  end)
end

--LUNES DE PUISSANCE CACHEES
function destructible_power_moon_1:on_lifting() 
  if hidden_power_moon_39 ~= nil then hidden_power_moon_39:set_enabled(true) end
end
function destructible_power_moon_2:on_lifting() 
  if hidden_power_moon_40 ~= nil then hidden_power_moon_40:set_enabled(true) end
end