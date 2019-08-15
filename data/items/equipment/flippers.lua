--Flippers: Allows you to swim.

local item = ...

function item:on_created()
  self:set_sound_when_picked(nil)
  self:set_shadow(nil)
  self:set_savegame_variable("possession_flippers")
end

function item:on_obtaining()
	item:get_game():set_ability("swim", 1)
end