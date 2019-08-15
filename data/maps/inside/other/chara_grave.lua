local map = ...
local game = map:get_game()

local screamer = sol.surface.create("backgrounds/CHARA.png")
local screamer_activated = false

local speed = 64

-- DEBUT DE LA MAP
function map:on_started()
  game:set_hud_enabled(false) 
  game:set_pause_allowed(false)
  game:set_value("dark_room",true)
  sol.timer.start(map,10,function() game:set_value("dark_room",false) end)
  CHARA:set_enabled(false)
  sol.timer.start(map,5000,function()
    sol.audio.play_music("CHARA")
    game:set_dialog_style("blank")
    game:start_dialog("CHARA.1",function()
      screamer_activated = true
      sol.timer.start(map,100,function()
        screamer_activated = false
        sol.timer.start(map,5000,function()
          game:set_dialog_style("blank")
          game:start_dialog("CHARA.2",function()
            sol.timer.start(map,10000,function()
              game:set_dialog_style("blank")
              game:start_dialog("CHARA.3",function()
                CHARA:set_enabled(true)
                local movement = sol.movement.create("target")
                movement:set_target(hero)
                movement:set_speed(speed)
                movement:set_ignore_obstacles()
                sol.timer.start(map,1000,function() speed = speed + 4 movement:set_speed(speed) return true end)
                movement:start(CHARA,function()
                  game:set_dialog_style("blank")
                  game:start_dialog("CHARA.4",function()
                  	screamer_activated = true
                  	sol.audio.play_sound("screamer")
                    sol.timer.start(map,1000,function() game:set_value("CHARA",true) game:save() sol.main.exit() end)
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

function map:on_draw(dst_surface)
	if screamer_activated then
		screamer:draw(dst_surface)
	end
end