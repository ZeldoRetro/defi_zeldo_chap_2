--Rupee bag: determines how much rupees you can carry.

local item = ...

function item:on_created()
  self:set_savegame_variable("possession_rupee_bag")
  self:set_sound_when_picked(nil)
  self:set_shadow(nil)
end

function item:on_variant_changed(variant)

  -- Obtaining a rupee bag changes the max money.
  local max_moneys = {999, 1000, 5000, 9999}
  local max_money = max_moneys[variant]
  if max_money == nil then
    error("Invalid variant '" .. variant .. "' for item 'rupee_bag'")
  end

  self:get_game():set_max_money(max_money)
end