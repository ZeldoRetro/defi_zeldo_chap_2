--Small key: a standard small key who opens a locked door.

local item = ...

function item:on_created()

  self:set_shadow("small")
  self:set_sound_when_picked(nil)
  self:set_sound_when_brandished("treasure_key")
end

function item:on_obtaining(variant, savegame_variable)
  self:get_game():add_small_key()
end