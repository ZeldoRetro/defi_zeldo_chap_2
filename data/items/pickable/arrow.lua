local item = ...
local game = item:get_game()

function item:on_created()

  self:set_shadow("small")
  self:set_can_disappear(true)
  self:set_brandish_when_picked(false)
  self:set_sound_when_brandished(nil)
  self:set_sound_when_picked(nil)
end

function item:on_started()

  -- Disable pickable arrows if the player has no bow.
  -- We cannot do this from on_created() because we don't know if the bow
  -- is already created there.
  item:set_obtainable(game:has_item("inventory/bow"))
end

function item:on_obtaining(variant, savegame_variable)
  -- This function can also be called by a light arrows.

  -- Obtaining arrows increases the counter of the bow.
  local amounts = { 1, 5, 10, 30}
  local amount = amounts[variant]
  if amount == nil then error("Invalid variant '" .. variant .. "' for item 'arrow'") end
  if variant == 4 then sol.audio.play_sound("treasure_small") else sol.audio.play_sound("picked_item") end

  game:get_item("inventory/bow"):add_amount(amount)
end