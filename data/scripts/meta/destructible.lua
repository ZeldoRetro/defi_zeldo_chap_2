-- Initialize destructibles behavior specific to this quest.

require("scripts/multi_events")

local destructible_meta = sol.main.get_metatable("destructible")
  
-- destructible_meta represents the default behavior of all destructible.
  
function destructible_meta:on_looked()
  local game = self:get_game()
  if self:get_can_be_cut()
    and not self:get_can_explode()
    and not self:get_game():has_ability("sword") then
    -- The destructible can be cut, but the player has no cut ability.
    game:start_dialog("destructible_cannot_lift_should_cut")
  elseif not game:has_ability("lift") then
    -- No lift ability at all.
    game:start_dialog("destructible_cannot_lift_too_heavy")
  else
    -- Not enough lift ability.
    game:start_dialog("destructible_cannot_lift_still_too_heavy")
  end
end

return true