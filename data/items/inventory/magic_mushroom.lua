local item = ...

function item:on_created()

  -- Define the properties.
  self:set_savegame_variable("possession_magic_mushroom")
  self:set_sound_when_picked(nil)
  self:set_assignable(true)
end

function item:on_using()
    item:set_finished()
end