local map = ...
local game = map:get_game()
local music_map = map:get_music()


--DEBUT DE LA MAP
function map:on_started(destination)
  --Pendant la journée, lumière qui sort des fenètres/portes d'entrée
  if game:get_value("night") or game:get_value("dawn") then
    --Jour/Crépuscule
    map:set_entities_enabled("day_entity",false)
  end

  --Epée prète après un certain temps
  if game:get_value("time_when_sword_ready") == game:get_value("daytime") then game:set_value("sword_ready",true) end

  --Forgeron en plein travail après avoir forgé notre épée
  if game:get_value("smith_working") then smith:get_sprite():set_animation("hammer") end
end

--DIALOGUES AVEC LE FORGERON: IL FORGE NOTRE EPEE CONTRE DU MINERAI DORE ET 100 RUBIS
function smith:on_interaction()
  if game:get_value("get_sword_2") then 
    game:start_dialog("takapa_village.smith.finished")
  elseif game:get_value("smith_working") then
    if game:get_value("sword_ready") then
      game:start_dialog("takapa_village.smith.sword_ready",function()
        hero:start_treasure("equipment/sword",4,"get_sword_2")
      end)
    else sol.audio.play_sound("wrong") game:start_dialog("takapa_village.smith.sword_not_ready") end
  else
    if game:get_value("get_golden_ore") then 
      game:start_dialog("takapa_village.smith.temper_question",function(answer)
        if answer == 1 then
          if game:get_money() >= 100 then
            game:remove_money(100)
            game:set_ability("sword",0)
            game:set_value("smith_working",true)
            game:start_dialog("takapa_village.smith.temper_yes",function() smith:get_sprite():set_animation("hammer") end)
          else sol.audio.play_sound("wrong") game:start_dialog("takapa_village.smith.temper_no_money") end
        else game:start_dialog("takapa_village.smith.temper_no") end
      end)
    else game:start_dialog("takapa_village.smith.welcome") end
  end
end

function interrupt_sensor:on_activated_repeat()
  if game:get_value("smith_working") and hero:get_direction() == 3 and hero:get_sprite():get_animation() == "hammer" then
    interrupt_sensor:set_enabled(false)
    sol.timer.start(350,function() game:start_dialog("takapa_village.smith.interupt_working") interrupt_sensor:set_enabled(true) end)
  end
end

function map:on_finished()
  if game:get_value("smith_working") then
    game:set_value("time_when_sword_ready",1)
    if game:get_value("daytime") == 1 then game:set_value("daytime",2) end
  end
end