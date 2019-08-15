local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
function map:on_started()
  map:set_doors_open("door_battle")
  enemy:set_enabled(false)
  game:set_value("dark_room_middle",true)
  sol.timer.start(map,10,function() game:set_value("dark_room_middle",false) end)
  --Entrée éclairée si jour
  if game:get_value("day") or game:get_value("twilight") then 
    day_entity:set_enabled(true)
    map:set_entities_enabled("thief",false)
  elseif game:get_value("night") or game:get_value("dawn") then
    day_entity:set_enabled(false)
    if game:get_value("get_pegasus_boots") then map:set_entities_enabled("thief",false)
    elseif game:get_value("offering_done") then sol.audio.play_music(nil) map:set_entities_enabled("thief",true)
    else map:set_entities_enabled("thief",false) end
  end
end

--FONTAINES: ON PEUT Y FAIRE UNE OFFRANDE
for npc in map:get_entities("fountain_") do
  function npc:on_interaction()
    if game:get_value("get_pegasus_boots")then game:start_dialog("takapa_village.fountain.offering_done")
    else
      game:start_dialog("takapa_village.fountain.offering_question",function(answer)
        if answer == 1 then
          game:start_dialog("takapa_village.fountain.offering_question_how_much",function(answer)
            if answer == 1 then
              if game:get_money() < 5 then
                sol.audio.play_sound("wrong")
                game:start_dialog("takapa_village.fountain.offering_no_money")
              else
                game:remove_money(5)
                game:set_value("offering_done",true)
              end
            else
              if game:get_money() < 20 then
                sol.audio.play_sound("wrong")
                game:start_dialog("takapa_village.fountain.offering_no_money")
              else
                game:remove_money(20)
                game:set_value("offering_done",true)
              end
            end
          end)
        end
      end)
    end
  end
end

--VOLEUR PRIS LA MAIN DANS LE SAC: COMBAT
function thief_sensor:on_activated()
  thief_sensor:set_enabled(false)
  hero:freeze()
  game:start_dialog("takapa_village.thief.fountain",function()
    sol.timer.start(map,500,function()
      thief:get_sprite():set_direction(3)
      sol.timer.start(map,500,function()
        game:start_dialog("takapa_village.thief.before_battle",function()
          map:close_doors("door_battle")
          sol.audio.play_music("battle")
          thief:set_enabled(false)
          enemy:set_enabled(true)
          hero:unfreeze()
          map:set_entities_enabled("fountain",false)
        end)
      end)
    end)
  end)
end

--FIN DU COMBAT: VOLEUR FUIT EN ECHANGE DES BOTTES DE PEGASE
for enemy in map:get_entities("enemy") do
  function enemy:on_dying()
    enemy:set_life(1)
    sol.audio.play_music(nil)
    thief:set_position(enemy:get_position())
    enemy:set_enabled(false)
    thief:set_enabled(true)
    game:start_dialog("takapa_village.thief.battle_end",function()
      hero:start_treasure("equipment/pegasus_shoes",1,"get_pegasus_boots",function()
        game:start_dialog("takapa_village.thief.after_boots",function()
          hero:freeze()
          map:open_doors("door_battle")
          local m = sol.movement.create("target")
          m:set_speed(128)
          m:set_ignore_obstacles()
          m:set_target(entree)
          m:start(thief,function()
            local m2 = sol.movement.create("straight")
            m2:set_speed(128)
            m2:set_ignore_obstacles()
            m2:set_angle(3 * math.pi / 2)
            m2:set_max_distance(48)
            m2:start(thief,function()
              hero:unfreeze()
              map:set_entities_enabled("fountain",true)
            end)
          end)
        end)
      end)
    end)
  end
end