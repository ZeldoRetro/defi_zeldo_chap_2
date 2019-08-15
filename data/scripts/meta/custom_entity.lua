-- Initialize custom entities behavior specific to this quest.

require("scripts/multi_events")

local custom_entity_meta = sol.main.get_metatable("custom_entity")

function custom_entity_meta:on_created()

  local name = self:get_name()
  if name == nil then
    return
  end

  if name:match("^invisible_tile") then
    self:set_visible(false)
  end
  if name:match("^invisible_path") then
    self:set_visible(false)
  end
end

return true