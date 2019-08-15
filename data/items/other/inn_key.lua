--INN key: Allows you to rest in an INN. This key is removed automatically when you go out the INN.

local item = ...

function item:on_created()
  self:set_savegame_variable('inn_key')
end