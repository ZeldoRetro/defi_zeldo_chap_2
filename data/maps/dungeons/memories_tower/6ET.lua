local map = ...
local game = map:get_game()
local music_map = map:get_music()

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local chest_manager = require("maps/lib/chest_manager")
chest_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)


--DEBUT DE LA MAP
function map:on_started(destination)
  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)
  map:set_entities_enabled("fire_wall",false)
  map:set_entities_enabled("mothula",false)
  map:set_entities_enabled("armos_knight",false)
  map:set_entities_enabled("moldorm_wall",false)
  map:set_entities_enabled("moldorm_hole",false)

  --Téléporteur vers le boss débloqué
  if game:get_value("telep_boss_300") then map:set_entities_enabled("telep_boss",true) else map:set_entities_enabled("telep_boss",false) end

  --Pas de musique si on vient du sommet
  if destination == escalier_sommet then sol.audio.play_music(nil) end

  --Initialisation du boss rush
  for stopper in map:get_entities("armos_center_wall") do
    stopper:set_traversable_by(true)
    stopper:set_traversable_by("destination", false)  -- Limit the movement of the center.
  end

  --Boss rush fini
  if game:get_value("boss_rush_300") then map:set_entities_enabled("zeldo",false) end
end

--CINEMATIQUE AVANT LE BOSS RUSH
function zeldo_cutscene:on_activated()
  zeldo_cutscene:set_enabled(false)
  hero:freeze()
  game:set_pause_allowed(false)
  game:start_dialog("zeldo.boss_rush.intro",function()
    sol.audio.play_music("zeldo_theme")
    local movement = sol.movement.create("target")
    movement:set_target(front_zeldo:get_position())
    movement:set_speed(88)
    hero:set_direction(1)
    hero:get_sprite():set_animation("walking_with_shield")
    movement:start(hero,function()
      game:start_dialog("zeldo.boss_rush.follow",function()
        local movement = sol.movement.create("straight")
        movement:set_speed(88)
        movement:set_angle(math.pi / 2)
        movement:set_max_distance(136)
        local movement2 = sol.movement.create("straight")
        movement2:set_speed(88)
        movement2:set_angle(math.pi / 2)
        movement2:set_max_distance(144)
        movement:start(hero)
        movement2:start(zeldo,function()
          hero:get_sprite():set_animation("stopped")
          game:start_dialog("zeldo.boss_rush.wait",function()
            zeldo:get_sprite():set_direction(3)
            sol.timer.start(500,function()
              zeldo:get_sprite():set_animation("spell")
              sol.audio.play_sound("boss_charge")
              game:start_dialog("zeldo.boss_rush.spell_firewall",function()
                zeldo:get_sprite():set_animation("stopped")
                sol.audio.play_sound("lamp")
                map:set_entities_enabled("fire_wall",true)
                sol.timer.start(1000,function()
                  sol.audio.play_sound("zeldo_laugh")
                  zeldo:get_sprite():set_animation("laughing")
                  sol.timer.start(map,3000,function()
                    zeldo:get_sprite():set_animation("stopped")
                    game:start_dialog("zeldo.boss_rush.intro_boss_rush",function()
                      zeldo:get_sprite():set_animation("spell")
                      sol.audio.play_sound("boss_charge")
                      game:start_dialog("zeldo.boss_rush.spell_mothula",function()
                        sol.audio.play_music("boss_rush")
                        zeldo:get_sprite():set_animation("stopped")
                        mothula:set_enabled(true)
                        hero:unfreeze()
                        game:set_pause_allowed(true)
                      end)
                    end)
                  end)
                end)
              end)
            end)
          end)
        end)       
      end)
    end)
  end) 
end

--BOSS 1: MOTHULA
if mothula ~= nil then
  function mothula:on_dead()
    hero:freeze()
    game:start_dialog("zeldo.boss_rush.before_armos",function()
      zeldo:get_sprite():set_animation("spell")
      sol.audio.play_sound("boss_charge")
      game:start_dialog("zeldo.boss_rush.spell_armos",function()
        map:set_entities_enabled("fire_wall_step_1",false)
        zeldo:get_sprite():set_animation("stopped")
        hero:unfreeze()
        sol.timer.start(map,5000,function()
          for enemy in map:get_entities("armos_knight") do
            enemy:set_enabled(true)
            enemy:set_center(armos_center)
          end
          local movement = sol.movement.create("target")
          movement:set_target(hero)
          movement:set_speed(24)
          movement:start(armos_center)
        end)
      end)
    end)
  end
end

--BOSS 2: ARMOS
for enemy in map:get_entities("armos_knight") do
  enemy.on_dead = function()
    if not map:has_entities("armos_knight") then
      hero:freeze()
      game:start_dialog("zeldo.boss_rush.before_moldorm",function()
        zeldo:get_sprite():set_animation("spell")
        sol.audio.play_sound("boss_charge")
        game:start_dialog("zeldo.boss_rush.spell_moldorm",function()
          map:set_entities_enabled("fire_wall_step_2",false)
          zeldo:get_sprite():set_animation("stopped")
          hero:unfreeze()
          sol.timer.start(map,5000,function()
            map:set_entities_enabled("moldorm_wall",true)
            map:set_entities_enabled("moldorm_hole",true)
            map:set_entities_enabled("carpet",false)            
            local x,y,layer = front_zeldo:get_position()
            local enemy = map:create_enemy{
              name = "moldorm",
              breed = "boss/moldorm",
              direction = 2,
              x = x,
              y = y,
              layer = layer
            }
          end)
        end)
      end)
    end
  end
end