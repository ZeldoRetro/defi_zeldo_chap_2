local item = ...
local game = item:get_game()

function item:on_created()

  -- Define the properties of rupees.
  item:set_shadow("small")
  item:set_brandish_when_picked(false)
  item:set_can_disappear(true)
  self:set_sound_when_brandished("treasure_rupee")
  self:set_sound_when_picked(nil)
end

function item:on_obtaining(variant, savegame_variable)
  if variant == 1 then sol.audio.play_sound("picked_rupee")
  elseif variant == 2 then sol.audio.play_sound("picked_rupee_blue")
  elseif variant > 2 then sol.audio.play_sound("picked_rupee_red")
  end
end

function item:on_obtained(variant, savegame_variable)

  local amounts = { 1, 5, 20, 50, 100, 200, 300 }
  local amount = amounts[variant]
  game:add_money(amount)
end