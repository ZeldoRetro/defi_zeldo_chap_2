local map = ...
local game = map:get_game()

--DEBUT DE LA MAP
function map:on_started()

  --Article exemple unique acheté
  if game:get_value("trade_example_done") then pickable_trader_2:set_enabled(false) end
end

--MARCHANDS DE TROC
function trader_1:on_interaction()
  game:start_dialog("trade.question_apple",function(answer)
    if answer == 1 then
      if game:get_money() >= 10 then
        game:remove_money(10)
        hero:start_treasure("treasures/troc_apple",1)
      else
        sol.audio.play_sound("wrong")
        game:start_dialog("trade.not_enough")
      end
    end
  end)
end

function trader_2:on_interaction()
  if game:get_value("trade_example_done") then
    game:start_dialog("trade.no_item")
  else
    game:start_dialog("trade.question_hp",function(answer)
      if answer == 1 then
        if game:get_money() >= 20 and game:get_item("treasures/troc_apple"):get_amount() >= 3 then
          game:remove_money(20)
          game:get_item("treasures/troc_apple"):remove_amount(3)
          pickable_trader_2:set_enabled(false)
          hero:start_treasure("quest_items/piece_of_heart",1,"trade_example_done")
        else
          sol.audio.play_sound("wrong")
          game:start_dialog("trade.not_enough")
        end
      end
    end)
  end
end