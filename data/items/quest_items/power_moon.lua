--Force Gem: A mysterious gem...

local item = ...
local game = item:get_game()

function item:on_created()
    self:set_amount_savegame_variable("power_moon_amount")
    self:set_sound_when_picked(nil)
    self:set_sound_when_brandished("treasure_moon")
    self:set_max_amount(50)
end

function item:on_obtained()
  self:add_amount(1)
  if game:get_value("power_moon_amount") == item:get_max_amount() then
    game:set_value("all_power_moons",true)
  end
end