-- Initialize doors behavior specific to this quest.

require("scripts/multi_events")

local door_meta = sol.main.get_metatable("door")

function door_meta:on_opened()
  local game = self:get_game()
  local name = self:get_name()
  local hero = game:get_hero()
  local map = game:get_map()

  if name == nil then
    return
  end

  --Murs fissurés: son de secret quand on les ouvre
  if name:match("^weak_door") then
    sol.audio.play_sound("secret")
  end
end

return true