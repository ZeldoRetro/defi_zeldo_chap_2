local map = ...
local game = map:get_game()

-- Show the night overlay.
local night_overlay = sol.surface.create(map:get_size())
local alpha = 192
night_overlay:fill_color({0, 0, 64, alpha})
function map:on_draw(dst_surface)

  night_overlay:draw(dst_surface)
end

-- DEBUT DE LA MAP
function map:on_started(destination)

  if destination ~= start then
    snores:set_enabled(false)
    night_overlay:clear()  -- No night.
    if game:get_value("intro") then sleeping:set_enabled(false) end
    return
  end

  sleeping:set_enabled(false)

  -- The intro scene is playing.
  -- Let the hero sleep for two second.
  game:set_pause_allowed(false)
  snores:get_sprite():set_ignore_suspend(true)
  bed:get_sprite():set_animation("hero_sleeping")
  bed:get_sprite():set_direction(game:get_ability("tunic") - 1)
  hero:freeze()
  hero:set_visible(false)
  sol.timer.start(map, 2000, function()
    -- Show Zelda's message.
    game:start_dialog("door.closed.1", function()
      sol.timer.start(map, 1000, function()
        -- Wake up.
        snores:remove()
        bed:get_sprite():set_animation("hero_waking")
        sol.timer.start(map, 500, function()
          -- Jump from the bed.
          hero:set_visible(true)
          hero:start_jumping(0, 24, true)
          game:set_pause_allowed(true)
          game:set_hud_enabled(true)
          bed:get_sprite():set_animation("empty_open")
          sol.audio.play_sound("hero_lands")

          -- Start the savegame from outside the bed next time.
          game:set_starting_location(map:get_id(), "from_savegame")

          -- Make the sun rise.
          sol.timer.start(map, 20, function()
            alpha = alpha - 1
            if alpha <= 0 then
              alpha = 0
            end
            night_overlay:clear()
            night_overlay:fill_color({0, 0, 64, alpha})

            -- Continue the timer if there is still night.
            return alpha > 0  
          end)

        end)
      end)
    end)
  end)
end



--LIT POUR DORMIR:Passage jour/nuit + Restauration d'une partie de la santé
function sleeping:on_interaction()

    	game:start_dialog("auberge.lit.repos",function(answer)
        if answer == 1 then
    			sol.audio.play_sound("day_night")
    			if game:get_value("night") or game:get_value("dawn") then
            game:set_value("daytime", 1)
            game:set_value("day",true)
            game:set_value("twilight",false) 
            game:set_value("night",false)
            game:set_value("dawn",false)			
    			else
            game:set_value("daytime", 4)
            game:set_value("day",false)
            game:set_value("twilight",false) 
            game:set_value("night",true)
            game:set_value("dawn",false)
    			end 
    			hero:teleport(map:get_id(),"sortie_lit","fade")  
          sol.timer.start(600,function()
            game:add_life(48)
            game:set_pause_allowed(false)
            snores:set_enabled(true)
            snores:get_sprite():set_ignore_suspend(true)
            bed:get_sprite():set_animation("hero_sleeping")
            bed:get_sprite():set_direction(game:get_ability("tunic") - 1)
            hero:freeze()
            hero:set_visible(false)
            sol.timer.start(map, 2000, function()
              -- Begin dialog
              map:set_entities_enabled("exit",false)
              sol.timer.start(map, 1000, function()
                -- Wake up.
                snores:set_enabled(false)
                bed:get_sprite():set_animation("hero_waking")
                bed:get_sprite():set_direction(game:get_ability("tunic") - 1)
                sol.timer.start(1000,function()
                  -- Jump from the bed.
                  hero:set_visible(true)
                  hero:start_jumping(0, 24, true)
                  game:set_pause_allowed(true)
                  bed:get_sprite():set_animation("empty_open")
                  sol.audio.play_sound("hero_lands")
                end)
              end)
            end)
 				  end)
        end
    	end)
end
