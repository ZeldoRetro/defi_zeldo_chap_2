local map = ...
local game = map:get_game()

local light_img = sol.surface.create(320,240)
light_img:fill_color({255, 255, 255})
local light = false

function map:on_started()
  game:set_pause_allowed(false)
  game:set_hud_enabled(false)
end

function sensor:on_activated()
  sensor:set_enabled(false)
  light_img:fade_in(60)
  light = true
  sol.timer.start(map, 5000, function()
    game:start_dialog("zeldo.triforce_chamber.intro",function()
      zeldo:set_enabled(true)
      sol.audio.play_music("zeldo_theme")
      light_img:fade_out(100,function()
        light = false
        sol.timer.start(map,1000,function()
          game:start_dialog("zeldo.triforce_chamber.1",function()
            zeldo:get_sprite():set_animation("spell")
            sol.audio.play_sound("boss_charge")
            game:start_dialog("zeldo.triforce_chamber.spell_1",function()
              local m = sol.movement.create("target")
              m:set_speed(512)
              m:set_target(wall)
              m:set_ignore_obstacles(true)
              hero:set_animation("hurt")
              m:start(hero,function()
                sol.audio.play_sound("explosion")
                m = sol.movement.create("jump")
                m:set_direction8(0)
                m:set_distance(24)
                m:set_speed(64)
                m:set_ignore_obstacles(true)
                hero:set_direction(2)
                m:start(hero,function()
                  hero:set_animation("dead")
                  m = sol.movement.create("straight")
                  m:set_speed(48)
                  m:set_angle(math.pi / 2)
                  m:set_ignore_obstacles(true)
                  m:set_max_distance(48)
                  m:start(zeldo,function()
                    triforce:set_enabled(true)
                    local m = sol.movement.create("target")
                    m:set_speed(320)
                    m:set_target(original_place)
                    m:set_ignore_obstacles(true)
                    zeldo:get_sprite():set_direction(2)
                    zeldo:get_sprite():set_animation("spell")
                    m:start(triforce,function()
                      sol.timer.start(map,1000,function()
                        triforce:set_enabled(false)
                        zeldo:get_sprite():set_direction(3)
                        zeldo:get_sprite():set_animation("laughing")
                        sol.audio.play_sound("zeldo_laugh")
                        sol.timer.start(map,3000,function()
                          zeldo:get_sprite():set_direction(2)
                          zeldo:get_sprite():set_animation("stopped")
                          game:start_dialog("zeldo.triforce_chamber.2",function()
                            zeldo:get_sprite():set_animation("spell")
                            sol.audio.play_sound("boss_charge")
                            game:start_dialog("zeldo.triforce_chamber.spell_2",function()
                              sol.audio.play_sound("warp")
                              hero:teleport("outside/B1","cheat_cave")
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
      end)
    end)
  end)
end

map:register_event("on_draw",function(map,dst_surface)
  if light then light_img:draw(dst_surface) end
end)

map:register_event("on_finished", function(map)
  game:set_pause_allowed(true)
  game:set_hud_enabled(true)
  map:get_hero():set_walking_speed(88)
  map:get_hero():set_visible(true)
  hero_slowed = false
end)