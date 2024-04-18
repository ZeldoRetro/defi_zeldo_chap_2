-- Initialize carried_object behavior specific to this quest.

require("scripts/multi_events")
local entity_manager= require("scripts/entity_manager") 

local carried_meta = sol.main.get_metatable("carried_object")


carried_meta:register_event("on_removed", function(carried_object)
    local game = carried_object:get_game()
    local map = game:get_map()
    if carried_object:get_ground_below()== "hole" then
      entity_manager:create_falling_entity(carried_object)
    elseif carried_object:get_ground_below()== "deep_water" then
      entity_manager:create_drowning_entity(carried_object)
    elseif carried_object:get_ground_below()== "lava" then
      entity_manager:create_burning_entity(carried_object)
    end
  end)

return true