--Sword: increases the attack.

local item = ...

function item:on_created()

  self:set_savegame_variable("possession_sword")
  self:set_sound_when_picked(nil)
  self:set_shadow(nil)
end


function item:on_obtaining(variant)

  -- Obtaining the sword increases the force.
  local game = item:get_game()
  local map = game:get_map()
  local force = game:get_value("force")
  force = force + 1
  game:set_value("force", force)
end

function item:on_variant_changed(variant)
  -- The possession state of the sword determines the built-in ability "sword".
  self:get_game():set_ability("sword", variant)
end