--Power bracelets/Power gloves: Allows you to lift destructibles.

local item = ...

function item:on_created()
  self:set_sound_when_picked(nil)
  self:set_shadow(nil)
  self:set_savegame_variable("possession_power_bracelet")
end

function item:on_variant_changed(variant)
  -- the possession state of the glove determines the built-in ability "lift"
  self:get_game():set_ability("lift", variant)
end