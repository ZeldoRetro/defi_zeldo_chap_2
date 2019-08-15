local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
function map:on_started()
  snores:set_enabled(false)
end

--INTERACTIONS AVEC L'AUBERGISTE
for npc in map:get_entities("inn_npc") do
  function npc:on_interaction()
    if hero:get_direction() == 1 then map:get_entity("inn_manager"):get_sprite():set_direction(3) else map:get_entity("inn_manager"):get_sprite():set_direction(0) end
    local price = 20
  	if game:get_value("get_inn_key") then
  		game:start_dialog("inn.good_stay")
  	else
  		game:start_dialog("inn.question",function(answer)
        if answer == 1 then
          if game:get_money() >= price then
            game:remove_money(price)
         	  game:start_dialog("inn.answer_yes", function()
              hero:start_treasure("other/inn_key", 1, "get_inn_key")
            end)
          else
            sol.audio.play_sound("wrong")
            game:start_dialog("inn.no_money")
          end
        else
          game:start_dialog("inn.answer_no")
        end
  		end)
  	end
  end
end

--ON PERD LA CLE EN SORTANT DE L'AUBERGE
function map:on_finished()
  game:set_value("get_inn_key",false)
end