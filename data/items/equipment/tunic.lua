--Tunic: increases the defense.

local item = ...
local map = item:get_map()

function item:on_created()
  self:set_savegame_variable("possession_tunic")
  self:set_sound_when_picked(nil)
  self:set_shadow(nil)
end

function item:on_obtained(variant, savegame_variable)
  local map = item:get_map()
  -- Give the built-in ability "tunic", but only after the treasure sequence is done.
  self:get_game():set_ability("tunic", variant)

  local game = item:get_game()
  local hero = game:get_hero()
    hero:freeze()
    game:set_pause_allowed(false)
    game:set_life(game:get_max_life())
    game:set_magic(game:get_max_magic())
    game:set_dungeon_finished()
    sol.audio.play_music("victory")
    sol.timer.start(9500,function() 
       hero:start_victory()
       sol.timer.start(1000,function()
    	  game:set_pause_allowed(true)
        hero:teleport("outside/A1","sortie_temple")
       end)     
    end)
end

function item:on_obtaining(variant)

  -- Obtaining a new tunic increases the defense.
  local game = item:get_game()
  local map = game:get_map()
  local defense = game:get_value("defense")
  defense = defense + 1
  game:set_value("defense", defense)
end