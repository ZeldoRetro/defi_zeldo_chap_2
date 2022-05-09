local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
function map:on_started()
  --Système jour/nuit
  if game:get_value("day") or game:get_value("twilight") then
    --Jour/Crépuscule
    map:set_entities_enabled("night_entity",false)
    if game:get_value("get_pegasus_boots") then map:set_entities_enabled("thief",false) end
  elseif game:get_value("night") or game:get_value("dawn") then
    --Nuit/Aube
    map:set_entities_enabled("thief",false)
    map:set_entities_enabled("day_guard",false)
    map:set_entities_enabled("day_entity",false)
    old_man:get_sprite():set_animation("sleeping")
  end

  if game:get_value("get_bottle_1") and game:get_value("hp_8") and game:get_value("power_moon_50") then night_entity_1:set_enabled(false) end
end

--DIALOGUES AVEC LE BARMAN: BIERE POUR 2 RUBIS
function barman_2:on_interaction()
  if game:get_value("get_beer") then game:start_dialog("takapa_village.bar.barman.beer_bought")
  else
    game:start_dialog("takapa_village.bar.barman.beer_question",function(answer)
      if answer == 1 then
        if game:get_money() > 1 then game:remove_money(2) hero:start_treasure("inventory/echange",1,"get_beer")
        else sol.audio.play_sound("wrong") game:start_dialog("takapa_village.bar.barman.beer_no_money") end
      else game:start_dialog("takapa_village.bar.barman.beer_answer_no") end
    end)
  end
end

--DIALOGUES AVEC CONKER: BIERE CONTRE POELE A FRIRE
function conker:on_interaction()
  if game:get_value("get_frying_pan") then game:start_dialog("takapa_village.bar.conker.trade_done")
  else game:start_dialog("takapa_village.bar.conker.need_beer") end
end
function conker:on_interaction_item(item)
  if item == game:get_item("inventory/echange") and item:get_variant() == 1 then
    game:start_dialog("takapa_village.bar.conker.question",function(answer)
      if answer == 1 then
        game:start_dialog("takapa_village.bar.conker.answer_yes",function()
          hero:start_treasure("inventory/echange",2,"get_frying_pan")
        end)
      else game:start_dialog("takapa_village.bar.conker.answer_no") end
    end)
  end
end

--DIALOGUES AVEC LE VIEIL HOMME (FRERE DE TAKAPA ET VRAI PERE D'ELLIE?)
function old_man:on_interaction()
  if game:get_value("day") or game:get_value("twilight") then
    game:start_dialog("takapa_village.bar.old_man_day")
  elseif game:get_value("night") or game:get_value("dawn") then
    game:start_dialog("takapa_village.bar.old_man_night")
  end
end