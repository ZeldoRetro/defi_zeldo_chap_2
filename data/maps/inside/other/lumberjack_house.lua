local map = ...
local game = map:get_game()

local function npc_walk(npc)
  local movement = sol.movement.create("random_path")
  movement:start(npc)
end

-- DEBUT DE LA MAP
function map:on_started()
  --Système jour/nuit
  if game:get_value("day") or game:get_value("twilight") then
    --Jour/Crépuscule
    map:set_entities_enabled("night_entity",false)
    map:set_entities_enabled("lumberjack_1",false)
  end

  --Certains personnages bougent
  npc_walk(lumberjack_2)
end

--DIALOGUES AVEC L'AINE DES BUCHERON: RAPPELTOUT CONTRE CORDE
function lumberjack_1:on_interaction()
  if game:get_value("get_wooden_board") then game:start_dialog("forest.lumberjack_1.trade_done")
  else game:start_dialog("forest.lumberjack_1.need_item_2") end
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

--DIALOGUES AVEC LE CADET DES BUCHERON: DIALOGUE CHANGE ENTRE AVANT ET APRES LE RAPELTOUT
function lumberjack_2:on_interaction()
  if game:get_value("get_wooden_board") then game:start_dialog("forest.lumberjack_2.trade_done")
  else game:start_dialog("forest.lumberjack_2.before_trade") end
end