local item = ...
local map = item:get_map()

function item:on_created()

  self:set_shadow("small")
  self:set_can_disappear(true)
  self:set_brandish_when_picked(false)
  self:set_sound_when_brandished("picked_item")
end

function item:on_started()
  if heroic_mode_enabled_for_this_savegame or item:get_game():get_value("heroic_mode") then item:set_obtainable(false) end
end

function item:on_obtaining(variant, savegame_variable)
  self:get_game():add_life(4)
end