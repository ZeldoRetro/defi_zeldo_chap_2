local map = ...
local game = map:get_game()

local function npc_walk(npc)
  local movement = sol.movement.create("random_path")
  movement:start(npc)
end

-- DEBUT DE LA MAP
function map:on_started()
  map:set_entities_enabled("hidden_power_moon_",false)
  map:set_entities_enabled("tmp_takapa",false)
  --Système jour/nuit
  if game:get_value("day") or game:get_value("twilight") then
    --Jour/Crépuscule
    map:set_entities_enabled("night_body_guard",false)
  elseif game:get_value("night") or game:get_value("dawn") then
    --Nuit/Aube
    map:set_entities_enabled("body_guard",false)
    map:set_entities_enabled("takapa",false)
    map:set_entities_enabled("ellie",false)
    map:set_entities_enabled("captain_guard",false)
    map:set_entities_enabled("day_entity",false)
  end

  --Certains personnages bougent
  npc_walk(cooker)
end

--PIECE SECRETE CACHEE DERRIERE LE RIDEAU
function secret_curtain:on_cut() 
  sol.audio.play_sound("secret") 
  if game:get_value("hp_12") or game:get_value("takapa_treasure") then return end
  if game:get_value("day") or game:get_value("twilight") then
    game:start_dialog("takapa_village.takapa_secret")
  end
end

local rupees = 0
--TRESOR DE TAKAPA
for pickable in map:get_entities("treasure_") do
  function pickable:on_removed()
    local x, y = map:get_hero():get_position()
    if y < 240 then
      rupees = rupees + 1
      if rupees == 1 then
        game:start_dialog("takapa_village.takapa_warning_1")
      elseif rupees == 2 then
        game:start_dialog("takapa_village.takapa_HEY",function()
          hero:freeze()
          tmp_takapa:set_enabled(true)
          takapa:set_enabled(false)
          local movement = sol.movement.create("straight")
          movement:set_speed(88)
          movement:set_angle(math.pi / 2)
          movement:set_ignore_obstacles()
          movement:set_max_distance(64)
          movement:start(tmp_takapa,function()
            game:start_dialog("takapa_village.takapa_warning_2",function()
              hero:unfreeze()
              game:remove_money(40)
            end)
          end)
        end)
      elseif rupees == 3 then
        game:start_dialog("takapa_village.takapa_warning_3",function() game:set_money(0) end)
      elseif rupees == 4 then
        sol.audio.play_music(nil)
        game:start_dialog("takapa_village.takapa_warning_4",function()
          sol.audio.play_sound("boss_charge")
          game:start_dialog("takapa_village.takapa_spell",function() 
            sol.main.reset()
          end)
        end)
      end
    end
  end
end

--LUNES DE PUISSANCE CACHEES
function destructible_power_moon_1:on_cut() sol.timer.start(map,300,function() 
  if hidden_power_moon_13 ~= nil then hidden_power_moon_13:set_enabled(true) end 
end) end
function destructible_power_moon_1:on_lifting() 
  if hidden_power_moon_13 ~= nil then hidden_power_moon_13:set_enabled(true) end
end