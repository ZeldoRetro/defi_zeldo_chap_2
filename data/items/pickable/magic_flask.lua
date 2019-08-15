local item = ...
local map = item:get_map()

function item:on_created()

  self:set_shadow("small")
  self:set_can_disappear(true)
  self:set_brandish_when_picked(false)
  self:set_sound_when_brandished(nil)
  self:set_sound_when_picked(nil)
end

function item:on_started()

  -- Disable pickable magic jars if the player has no magic bar.
  -- We cannot do this from on_created() because we don't know if the magic bar
  -- is already created there.
  self:set_obtainable(self:get_game():has_item("magic_bar"))
end

function item:on_obtaining(variant, savegame_variable)

  local amounts = {8, 40}
  local amount = amounts[variant]

  if amount == nil then error("Invalid variant '" .. variant .. "' for item 'rupee'") end
  if variant == 2 then sol.audio.play_sound("treasure_small") elseif variant == 1 then sol.audio.play_sound("picked_item") end
  self:get_game():add_magic(amount)
end