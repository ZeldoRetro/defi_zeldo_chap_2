local map = ...
local game = map:get_game()

local screamer = sol.surface.create("backgrounds/CHARA.png")
local screamer_activated = false
local current_credits_chara = sol.surface.create(sol.language.get_language().."/credits/end_chara.png")
local credit_chara = false

local stats_manager = require("scripts/menus/stats")

local current_credits = sol.surface.create(sol.language.get_language().."/credits/end.png")
function map:on_draw(dst_surface)
  current_credits:draw(dst_surface)
	if screamer_activated then screamer:draw(dst_surface) end
  if credit_chara then current_credits_chara:draw(dst_surface) end
end

function map:on_started()
  game:set_hud_enabled(false) 
  game:set_pause_allowed(false)
  hero:set_visible(false)
end

function map:on_opening_transition_finished()
  hero:freeze()
  sol.timer.start(5000,function()
    if game:get_value("CHARA") then
      screamer_activated = true
      sol.audio.play_sound("screamer")
      sol.timer.start(map,1000,function()
        screamer_activated = false
        credit_chara = true
        sol.audio.play_music("CHARA")
        game:set_dialog_style("blank")
        game:start_dialog("CHARA.5",function()
          -- Show the statistics menu.
          sol.audio.stop_music()
          local stats = stats_manager:new(game)
          sol.menu.start(map, stats)
        end)
      end)
    else
      -- Show the statistics menu.
      sol.audio.stop_music()
      local stats = stats_manager:new(game)
      sol.menu.start(map, stats)
    end
  end)
end