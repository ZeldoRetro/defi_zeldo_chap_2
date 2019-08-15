local item = ...
local map = item:get_map()

function item:on_created()

  self:set_can_disappear(true)
  self:set_brandish_when_picked(false)
  self:set_sound_when_brandished(nil)
  self:set_sound_when_picked(nil)
end

function item:on_started()

  -- Disable pickable bombs if the player has no bomb bag.
  -- We cannot do this from on_created() because we don't know if the bomb bag
  -- is already created there.
  local bomb_bag = self:get_game():get_item("equipment/bomb_bag")
  self:set_obtainable(bomb_bag:has_variant())
end

function item:on_obtaining(variant, savegame_variable)

  -- Obtaining bombs increases the bombs counter.
  local amounts = {1, 5, 10, 20}
  local amount = amounts[variant]

  if amount == nil then error("Invalid variant '" .. variant .. "' for item 'bomb'") end
  if variant == 4 then sol.audio.play_sound("treasure_small") else sol.audio.play_sound("picked_item") end
  self:get_game():get_item("inventory/bombs_counter"):add_amount(amount)
end