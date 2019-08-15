--The Triforce: The standard final item of a quest.

local item = ...

function item:on_created()
  self:set_sound_when_picked(nil)
  self:set_shadow(nil)
  self:set_savegame_variable("possession_certificate")
end