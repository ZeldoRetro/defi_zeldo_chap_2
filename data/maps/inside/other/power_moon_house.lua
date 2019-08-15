local map = ...
local game = map:get_game()

--INTERACTION AVEC LE TABLEAU DE MARIO: IT'S A ME, MARIO!
function mario_paint:on_interaction() sol.audio.play_sound("mario") end

--INTERACTIONS AVEC TOAD: RECOMPENSES TOUTES LES 10 LUNES
function toad:on_interaction()
  if not game:get_value("get_power_moon_detector") then  
    game:start_dialog("toad.1st_time",function()
      hero:start_treasure("equipment/power_moon_detector",1,"get_power_moon_detector")
    end) 
  end
  sol.timer.start(map,10,function()
    if game:get_item("quest_items/power_moon"):get_amount() > 9 then
      if not game:get_value("get_bottle_2") then
        game:start_dialog("toad.reward_10_moons",function()
          hero:start_treasure("inventory/bottle_2",1,"get_bottle_2")
        end)
      end
      if game:get_item("quest_items/power_moon"):get_amount() > 19 then
        sol.timer.start(map,10,function()
          if not game:get_value("get_bomb_bag_2") then
            game:start_dialog("toad.reward_20_moons",function()
              hero:start_treasure("equipment/bomb_bag",2,"get_bomb_bag_2")
            end)
          end
          if game:get_item("quest_items/power_moon"):get_amount() > 29 then
            sol.timer.start(map,10,function()
              if not game:get_value("get_quiver_2") then
                game:start_dialog("toad.reward_30_moons",function()
                  hero:start_treasure("equipment/quiver",2,"get_quiver_2")
                end)
              end
              if game:get_item("quest_items/power_moon"):get_amount() > 39 then
                sol.timer.start(map,10,function()
                  if not game:get_value("heart_container_1") then
                    game:start_dialog("toad.reward_40_moons",function()
                      hero:start_treasure("quest_items/heart_container",1,"heart_container_1")
                    end)
                  end
                  if game:get_item("quest_items/power_moon"):get_amount() == 50 then
                    sol.timer.start(map,10,function()
                      if not game:get_value("get_certificate") then
                        game:start_dialog("toad.reward_50_moons",function()
                          hero:start_treasure("quest_items/certificate",1,"get_certificate")
                        end)
                      end
                    end)
                  end
                end)
              end
            end)
          end
        end)
      end
    end
  end)
  sol.timer.start(map,100,function()
    if game:get_item("quest_items/power_moon"):get_amount() == 50 then
      if game:get_value("get_certificate") then game:start_dialog("toad.finished") end
    elseif game:get_item("quest_items/power_moon"):get_amount() > 39 then
      if game:get_value("heart_container_1") then game:start_dialog("toad.next_reward_50_moons") end
    elseif game:get_item("quest_items/power_moon"):get_amount() > 29 then
      if game:get_value("get_quiver_2") then game:start_dialog("toad.next_reward_40_moons") end
    elseif game:get_item("quest_items/power_moon"):get_amount() > 19 then
      if game:get_value("get_bomb_bag_2") then game:start_dialog("toad.next_reward_30_moons") end
    elseif game:get_item("quest_items/power_moon"):get_amount() > 9 then
      if game:get_value("get_bottle_2") then game:start_dialog("toad.next_reward_20_moons") end
    else game:start_dialog("toad.next_reward_10_moons") end
  end)
end