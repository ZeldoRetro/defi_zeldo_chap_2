local map = ...
local game = map:get_game()

local function npc_walk(npc)
  local movement = sol.movement.create("random_path")
  movement:start(npc)
end

-- DEBUT DE LA MAP
function map:on_started()
  --Certains personnages bougent
  npc_walk(cooker)
end

--INTERACTIONS AVEC L'AUBERGISTE
for npc in map:get_entities("inn_npc") do
  function npc:on_interaction()
    if hero:get_direction() == 1 then map:get_entity("inn_manager"):get_sprite():set_direction(3) else map:get_entity("inn_manager"):get_sprite():set_direction(0) end
    local price = 5
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

--DIALOGUES AVEC LA CUISINIERE: POELE A FRIRE CONTRE ROCHE VOLCANIQUE
function cooker:on_interaction()
  if game:get_value("get_fire_stone") then game:start_dialog("takapa_village.inn.cooker.trade_done",function() game:add_life(8) end)
  else game:start_dialog("takapa_village.inn.cooker.need_item") end
end
function cooker:on_interaction_item(item)
  if item == game:get_item("inventory/echange") and item:get_variant() == 2 then
    game:start_dialog("takapa_village.inn.cooker.question",function(answer)
      if answer == 1 then
        game:start_dialog("takapa_village.inn.cooker.answer_yes",function()
          hero:start_treasure("inventory/echange",3,"get_fire_stone")
        end)
      else game:start_dialog("takapa_village.inn.cooker.answer_no") end
    end)
  end
end