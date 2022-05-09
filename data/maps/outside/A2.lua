local map = ...
local game = map:get_game()

texte_lieu = sol.surface.create(sol.language.get_language().."/texte_lieu/takapa_village.png")

-- DEBUT DE LA MAP
function map:on_started()
  game:set_hud_enabled(true)
  map:set_entities_enabled("hidden_power_moon_",false)
  --Système jour/nuit
  if game:get_value("day") or game:get_value("twilight") then
    --Jour/Crépuscule
    map:set_entities_enabled("night_entity",false)
  elseif game:get_value("night") or game:get_value("dawn") then
    --Nuit/Aube
    map:set_entities_enabled("day_entity",false)
  end

  --Introduction passée
  if game:get_value("intro_done") then
    map:set_entities_enabled("intro_wall",false)
    sahasrahla:set_enabled(false)
  end

  --Soldat perdu rentré après l'échange
  if game:get_value("get_pokeball") then lost_man:set_enabled(true) else lost_man:set_enabled(false) end
end

--ON PERD LA CLE EN SORTANT DE L'AUBERGE
function exit_inn:on_activated()
  game:set_value("get_inn_key",false)
  game:set_value("inn_room_opened",false)
end

--INTRODUCTION: MURS INVISIBLES
function intro_wall_1:on_activated()
  game:start_dialog("takapa_village.sahasrahla.intro_wall",function()
    hero:freeze()
    hero:set_direction(3)
    hero:set_animation("walking")
    local movement = sol.movement.create("straight")
    movement:set_speed(88)
    movement:set_angle(3 * math.pi / 2)
    movement:set_ignore_obstacles()
    movement:set_max_distance(16)
    movement:start(hero,function()  
      hero:unfreeze()
    end)  
  end)
end
function intro_wall_2:on_activated()
  game:start_dialog("takapa_village.sahasrahla.intro_wall",function()
    hero:freeze()
    hero:set_direction(2)
    hero:set_animation("walking")
    local movement = sol.movement.create("straight")
    movement:set_speed(88)
    movement:set_angle(math.pi)
    movement:set_ignore_obstacles()
    movement:set_max_distance(16)
    movement:start(hero,function()  
      hero:unfreeze()
    end)  
  end)
end
function intro_wall_3:on_activated()
  game:start_dialog("takapa_village.sahasrahla.intro_wall",function()
    hero:freeze()
    hero:set_direction(0)
    hero:set_animation("walking")
    local movement = sol.movement.create("straight")
    movement:set_speed(88)
    movement:set_angle(0)
    movement:set_ignore_obstacles()
    movement:set_max_distance(16)
    movement:start(hero,function()  
      hero:unfreeze()
    end)  
  end)
end

--INTRODUCTION: DIALOGUE AVEC SAHASRAHLA
function sahasrahla:on_interaction()
  game:start_dialog("takapa_village.sahasrahla.intro",function()
    hero:freeze()
    sol.audio.play_sound("warp")
    map:set_entities_enabled("intro_wall",false)
    game:set_value("intro_done",true)
    sahasrahla:get_sprite():fade_out(30,function() sahasrahla:set_enabled(false) hero:unfreeze() end)
  end)
end

--TROU CACHE
function secret_bush:on_lifting()
  secret_bush_ground:set_enabled(false)
  sol.audio.play_sound("secret")
end
function secret_bush:on_cut()
  secret_bush_ground:set_enabled(false)
  sol.audio.play_sound("secret")
end

--DIALOGUES AVEC LE SOLDAT PERDU DE RETOUR APRES SON ECHANGE
function lost_man:on_interaction()
  game:start_dialog("lost_man.trade_done")
end

--STATUE DE HIBOU
function owl_statue:on_interaction()
  game:set_dialog_style("stone")
  local game = map:get_game()
  if game:get_value("owl_takapa_village_activated") then
    game:start_dialog("teleportation.question",function(answer)
      if answer == 1 then
        sol.audio.play_sound("warp")
        hero:teleport("telep_light_world")
      end
    end)
  else
    game:start_dialog("teleportation.activation")
    game:set_value("owl_takapa_village_activated",true)
  end
end

--LUNES DE PUISSANCE CACHEES
function destructible_power_moon_1:on_cut() sol.timer.start(map,300,function() 
  if hidden_power_moon_26 ~= nil then hidden_power_moon_26:set_enabled(true) end 
end) end
function destructible_power_moon_1:on_lifting() 
  if hidden_power_moon_26 ~= nil then hidden_power_moon_26:set_enabled(true) end
end
function destructible_power_moon_2:on_cut() sol.timer.start(map,300,function() 
  if hidden_power_moon_27 ~= nil then hidden_power_moon_27:set_enabled(true) end 
end) end
function destructible_power_moon_2:on_lifting() 
  if hidden_power_moon_27 ~= nil then hidden_power_moon_27:set_enabled(true) end
end
function destructible_power_moon_3:on_cut() sol.timer.start(map,300,function() 
  if hidden_power_moon_28 ~= nil then hidden_power_moon_28:set_enabled(true) end 
end) end
function destructible_power_moon_3:on_lifting() 
  if hidden_power_moon_28 ~= nil then hidden_power_moon_28:set_enabled(true) end
end