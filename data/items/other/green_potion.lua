--Green potion: Restores magic.

local item = ...
local map = item:get_map()
local game = item:get_game()

function item:on_started()
  -- Disable the potion if Link has no bottle
  item:set_obtainable(game:has_item("inventory/bottle_1") or game:has_item("inventory/bottle_2"))
end

function item:on_map_changed()
  -- Disable the potion if Link has no bottle
  item:set_obtainable(game:has_item("inventory/bottle_1") or game:has_item("inventory/bottle_2"))
end

function item:on_obtaining(variant, savegame_variable)

  local first_empty_bottle = self:get_game():get_first_empty_bottle()

  if first_empty_bottle ~= nil then
    first_empty_bottle:set_variant(4)
  end
end