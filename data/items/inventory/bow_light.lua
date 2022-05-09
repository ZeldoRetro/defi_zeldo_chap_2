local item = ...
local game = item:get_game()
local bow

function item:on_created()
  self:set_sound_when_picked(nil)
  self:set_savegame_variable("possession_bow_light")
  self:set_amount_savegame_variable("amount_bow")
  self:set_assignable(true)
end

function item:on_using()

  -- Call the normal bow code.
  game:get_item("inventory/bow").on_using(item)
end

function item:on_amount_changed(amount)

  -- Call the normal bow code.
  game:get_item("inventory/bow").on_amount_changed(item, amount)
end

function item:on_obtaining(variant, savegame_variable)
  -- If the old bow was assigned to a game command, assign the new one.
  if game:get_item_assigned(1) == game:get_item("inventory/bow") then
    game:set_item_assigned(1, item)
  end
  if game:get_item_assigned(2) == game:get_item("inventory/bow") then
    game:set_item_assigned(2, item)
  end
  game:get_item("pickable/arrow_light"):set_obtainable(true)
  game:get_item("inventory/bow"):on_obtaining(variant, savegame_variable)
end

function item:get_force()

  return 4
end

function item:get_arrow_sprite_id()

  return "entities/arrow_light"
end