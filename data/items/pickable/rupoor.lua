local item = ...
local game = item:get_game()

function item:on_created()

  -- Define the properties of rupees.
  item:set_shadow("small")
  item:set_brandish_when_picked(false)
  item:set_can_disappear(true)
  self:set_sound_when_brandished("treasure_bad")
  self:set_sound_when_picked(nil)
end

function item:on_obtained(variant, savegame_variable)
  game:remove_money(50)
end