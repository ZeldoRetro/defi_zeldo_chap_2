--Power Moon: Permit to detect the power moons into a map.

local item = ...

function item:on_created()
  self:set_sound_when_picked(nil)
  self:set_shadow(nil)
  self:set_savegame_variable("possession_power_moon_detector")
end