local item = ...

function item:on_created()

  -- Define the properties.
  item:set_shadow("small")
  self:set_savegame_variable("trade")
  self:set_assignable(true)
end

function item:on_using()
  self:set_finished()
end