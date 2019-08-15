local item = ...
local game = item:get_game()
local cape_active = false

function item:on_created()

  -- Define the properties.
  item:set_shadow("small")
  self:set_savegame_variable("magic_cape")
  self:set_assignable(true)
end

function item:on_using()

	local map = item:get_map()
  	local magic_needed = 2  -- Number of magic points required


	if cape_active then
		sol.audio.play_sound("cane")
    game:get_hero():set_blinking(false)
    game:get_hero():set_invincible(false)
    game:set_ability("sword",sword_level)
    game:set_pause_allowed(true)
		cape_active = false
	else
  		if self:get_game():get_magic() >= magic_needed then
   			sol.audio.play_sound("cane")
        game:get_hero():set_blinking(true)
        game:get_hero():set_invincible(true)
        sword_level = game:get_ability("sword")
        game:set_ability("sword",0)
    	  game:set_pause_allowed(false)
			  cape_active = true
  		else
    			sol.audio.play_sound("wrong")
          game:start_dialog("_need_magic")
  		end
	end
  	self:set_finished()
end

-- FONCTIONS PERMETTANT LE DRAINAGE DE MAGIE
function item:on_map_changed()
  game:set_value("magic_drained",false)
end
function item:on_update()
	local map = item:get_map()
  if cape_active then
    if not game:get_value("magic_drained") then
      game:set_value("magic_drained",true)
      sol.timer.start(500,function() 
        if game:get_magic() < 1 then
          sol.audio.play_sound("cane")
          game:get_hero():set_blinking(false)
          game:get_hero():set_invincible(false)
          game:set_ability("sword",sword_level)
          game:set_pause_allowed(true)
      		cape_active = false
          game:set_value("magic_drained",false)
        else
        game:remove_magic(1) 
        game:set_value("magic_drained",false)
        end
      end)
    end
  end

end