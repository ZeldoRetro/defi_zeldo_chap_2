local map = ...
local game = map:get_game()
local music_map = map:get_music()
texte_lieu = sol.surface.create(sol.language.get_language().."/texte_lieu/memories_tower.png")

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local chest_manager = require("maps/lib/chest_manager")
chest_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)


--DEBUT DE LA MAP
function map:on_started()
  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)
  zeldo:set_enabled(false)

  --Scene de Zeldo passée
  if game:get_value("zeldo_1st_time") then zeldo_cutscene:set_enabled(false) end

  --Boussole trouvée
  if game:get_value("compass_300") then map:set_entities_enabled("compass_hole",true)
  else map:set_entities_enabled("compass_hole",false) end

  --Téléporteur vers le boss débloqué
  if game:get_value("telep_boss_300") then map:set_entities_enabled("telep_boss",true) else map:set_entities_enabled("telep_boss",false) end
end

--BOUSSOLE: LA TROUVER FAIT APPARAITRE LES TROUS
function chest_compass:on_opened() 
  map:set_entities_enabled("compass_hole",true) 
  hero:start_treasure("dungeons/compass",1,"compass_300")
end

--CUTSCENE: APPARITION DE ZELDO
function zeldo_cutscene:on_activated()
  local back_x, back_y = map:get_camera():get_position_to_track(hero)
  zeldo_cutscene:set_enabled(false)
  game:set_value("zeldo_1st_time",true)
  sol.audio.play_music(nil)
  hero:freeze()
  game:set_pause_allowed(false)
  game:set_dialog_style("blank")
  game:start_dialog("zeldo.before_1st_encounter",function()
    sol.audio.play_music("zeldo_theme")
    local movement = sol.movement.create("target")
    movement:set_target(map:get_camera():get_position_to_track(zeldo:get_position()))
    movement:set_ignore_obstacles(true)
    movement:set_speed(96)
    movement:start(map:get_camera(), function()
      sol.timer.start(map,2000,function()
        zeldo:set_enabled(true)
        zeldo:get_sprite():fade_in(50,function()
          game:start_dialog("zeldo.1st_encounter",function()
            sol.audio.play_sound("zeldo_laugh")
            zeldo:get_sprite():set_animation("laughing")
            sol.timer.start(map,3000,function()
              zeldo:get_sprite():set_animation("stopped")
              game:start_dialog("zeldo.end_1st_encounter",function()
                zeldo:get_sprite():set_animation("protect")
                sol.audio.play_sound("warp")
                zeldo:get_sprite():fade_out(50,function() 
                  zeldo:set_enabled(false) 
                  local movement = sol.movement.create("target")
                  movement:set_target(back_x, back_y)
                  movement:set_ignore_obstacles(true)
                  movement:set_speed(96)
                  movement:start(map:get_camera(), function()
                    map:get_camera():start_tracking(hero)
                    game:set_pause_allowed(true)
                    hero:unfreeze()
                    sol.audio.play_music(music_map)
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