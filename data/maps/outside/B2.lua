local map = ...
local game = map:get_game()

local function npc_walk(npc)
  local movement = sol.movement.create("random_path")
  movement:start(npc)
end

texte_lieu = sol.surface.create(sol.language.get_language().."/texte_lieu/forest.png")

-- DEBUT DE LA MAP
function map:on_started()
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
    map:set_entities_enabled("lumberjack_1",false)
  end

  --Certains personnages bougent
  npc_walk(lumberjack_1)
end

--DIALOGUES AVEC L'AINE DES BUCHERON: RAPPELTOUT CONTRE CORDE
function lumberjack_1:on_interaction()
  if game:get_value("get_wooden_board") then game:start_dialog("forest.lumberjack_1.trade_done")
  else game:start_dialog("forest.lumberjack_1.need_item") end
end
function lumberjack_1:on_interaction_item(item)
  if item == game:get_item("inventory/echange") and item:get_variant() == 5 then
    game:start_dialog("forest.lumberjack_1.question",function(answer)
      if answer == 1 then
        game:start_dialog("forest.lumberjack_1.answer_yes",function()
          hero:start_treasure("inventory/echange",6,"get_wooden_board")
        end)
      else game:start_dialog("forest.lumberjack_1.answer_no") end
    end)
  end
end

--LUNES DE PUISSANCE CACHEES
function destructible_power_moon_1:on_cut() sol.timer.start(map,300,function() 
  if hidden_power_moon_30 ~= nil then hidden_power_moon_30:set_enabled(true) end 
end) end
function destructible_power_moon_1:on_lifting() 
  if hidden_power_moon_30 ~= nil then hidden_power_moon_30:set_enabled(true) end
end
function destructible_power_moon_2:on_cut() sol.timer.start(map,300,function() 
  if hidden_power_moon_31 ~= nil then hidden_power_moon_31:set_enabled(true) end 
end) end
function destructible_power_moon_2:on_lifting() 
  if hidden_power_moon_31 ~= nil then hidden_power_moon_31:set_enabled(true) end
end
function destructible_power_moon_3:on_cut() sol.timer.start(map,300,function() 
  if hidden_power_moon_32 ~= nil then hidden_power_moon_32:set_enabled(true) end 
end) end
function destructible_power_moon_3:on_lifting() 
  if hidden_power_moon_32 ~= nil then hidden_power_moon_32:set_enabled(true) end
end
function destructible_power_moon_4:on_cut() sol.timer.start(map,300,function() 
  if hidden_power_moon_33 ~= nil then hidden_power_moon_33:set_enabled(true) end 
end) end
function destructible_power_moon_4:on_lifting() 
  if hidden_power_moon_33 ~= nil then hidden_power_moon_33:set_enabled(true) end
end
function destructible_power_moon_5:on_cut() sol.timer.start(map,300,function() 
  if hidden_power_moon_34 ~= nil then hidden_power_moon_34:set_enabled(true) end 
end) end
function destructible_power_moon_5:on_lifting() 
  if hidden_power_moon_34 ~= nil then hidden_power_moon_34:set_enabled(true) end
end