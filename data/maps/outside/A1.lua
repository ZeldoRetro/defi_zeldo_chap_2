local map = ...
local game = map:get_game()

local function npc_walk(npc)
  local movement = sol.movement.create("random_path")
  movement:start(npc)
end

texte_lieu = sol.surface.create(sol.language.get_language().."/texte_lieu/beach.png")

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

  --Certains personnages bougent
  npc_walk(pikachu)

  --Soldat perdu reparti après l'échange
  if game:get_value("get_pokeball") then map:set_entities_enabled("lost_man",false) end

  --Musique différente si on est au sommet enneigé
  if destination == cave_path_to_village or destination == cave_hermit or destination == sortie_temple or destination == flight_destination then sol.audio.play_music("ice_mountain") snow_effect:set_enabled(true) texte_lieu = sol.surface.create(sol.language.get_language().."/texte_lieu/ice_mountain.png") end
end

--Trou caché
function secret_bush:on_lifting()
  secret_bush_ground:set_enabled(false)
  sol.audio.play_sound("secret")
end
function secret_bush:on_cut()
  secret_bush_ground:set_enabled(false)
  sol.audio.play_sound("secret")
end

--DIALOGUES AVEC LE SOLDAT PERDU: CORDE CONTRE POKEBALL
function lost_man:on_interaction()
  if game:get_value("get_pokeball") then game:start_dialog("lost_man.ready_to_go") else game:start_dialog("lost_man.need_item") end
end
function lost_man:on_interaction_item(item)
  if item == game:get_item("inventory/echange") and item:get_variant() == 6 then
    game:start_dialog("lost_man.question",function(answer)
      if answer == 1 then
        game:start_dialog("lost_man.answer_yes",function()
          hero:start_treasure("inventory/echange",7,"get_pokeball")
        end)
      else game:start_dialog("lost_man.answer_no") end
    end)
  end
end

--DIALOGUES AVEC LE DRESSEUR DE POKEMONS: POKEBALL CONTRE DIAMANT
function pokemon_trainer:on_interaction()
  if game:get_value("get_diamond") then game:start_dialog("pokemon_trainer.trade_done")
  else game:start_dialog("pokemon_trainer.need_item") end
end
function pokemon_trainer:on_interaction_item(item)
  if item == game:get_item("inventory/echange") and item:get_variant() == 7 then
    game:start_dialog("pokemon_trainer.question",function(answer)
      if answer == 1 then
        game:start_dialog("pokemon_trainer.answer_yes",function()
          hero:start_treasure("inventory/echange",8,"get_diamond")
        end)
      else game:start_dialog("pokemon_trainer.answer_no") end
    end)
  end
end

--SON DE PIKACHU SI ON ESSAIE DE LUI PARLER
function pikachu:on_interaction()
  sol.audio.play_sound("pika")
end

--STATUE DE HIBOU
function owl_statue:on_interaction()
  game:set_dialog_style("stone")
  local game = map:get_game()
  if game:get_value("owl_ice_mountain_activated") then
    game:start_dialog("teleportation.question",function(answer)
      if answer == 1 then
        sol.audio.play_sound("warp")
        hero:teleport("telep_light_world")
      end
    end)
  else
    game:start_dialog("teleportation.activation")
    game:set_value("owl_ice_mountain_activated",true)
  end
end

--LUNES DE PUISSANCE CACHEES
function destructible_power_moon_1:on_cut() sol.timer.start(map,300,function() 
  if hidden_power_moon_21 ~= nil then hidden_power_moon_21:set_enabled(true) end 
end) end
function destructible_power_moon_1:on_lifting() 
  if hidden_power_moon_21 ~= nil then hidden_power_moon_21:set_enabled(true) end
end
function destructible_power_moon_2:on_cut() sol.timer.start(map,300,function() 
  if hidden_power_moon_22 ~= nil then hidden_power_moon_22:set_enabled(true) end 
end) end
function destructible_power_moon_2:on_lifting() 
  if hidden_power_moon_22 ~= nil then hidden_power_moon_22:set_enabled(true) end
end
function destructible_power_moon_3:on_lifting() 
  if hidden_power_moon_24 ~= nil then hidden_power_moon_24:set_enabled(true) end
end
function destructible_power_moon_4:on_cut() sol.timer.start(map,300,function() 
  if hidden_power_moon_25 ~= nil then hidden_power_moon_25:set_enabled(true) end
end) end
function destructible_power_moon_4:on_lifting() 
  if hidden_power_moon_25 ~= nil then hidden_power_moon_25:set_enabled(true) end
end