local item = ...
local game = item:get_game()

function item:on_created()

  item:set_shadow("small")
  item:set_can_disappear(true)
  item:set_brandish_when_picked(false)
end

function item:on_started()

  -- Disable pickable arrows if the player has no bow.
  -- We cannot do this from on_created() because we don't know if the bow
  -- is already created there.
  item:set_obtainable(game:has_item("inventory/bow_light"))
end

function item:on_obtaining(variant, savegame_variable)

  -- Call the code of normal arrows (their counter is common).
  game:get_item("pickable/arrow"):on_obtaining(variant, savegame_variable)
end