local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
function map:on_started()
  game:set_value("dark_room_middle",true)
  sol.timer.start(map,10,function() game:set_value("dark_room_middle",false) end)
  --Entrée éclairée si jour
  if game:get_value("day") or game:get_value("twilight") then map:set_entities_enabled("day_entity",true) else map:set_entities_enabled("day_entity",false) end
end

--DIALOGUES AVEC L'ERMITE: ROCHE VOLCANIQUE CONTRE RAPPELTOUT
function hermit:on_interaction()
  if game:get_value("get_rappeltout") then game:start_dialog("hermit.trade_done")
  else game:start_dialog("hermit.need_item") end
end
function hermit:on_interaction_item(item)
  if item == game:get_item("inventory/echange") and item:get_variant() == 3 then
    game:start_dialog("hermit.question",function(answer)
      if answer == 1 then
        game:start_dialog("hermit.answer_yes",function()
          hero:start_treasure("inventory/echange",5,"get_rappeltout")
        end)
      else game:start_dialog("hermit.answer_no") end
    end)
  end
end