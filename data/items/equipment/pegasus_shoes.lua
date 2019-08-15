--Pegasus shoes: Allows you to run.

local item = ...

function item:on_created()
  self:set_savegame_variable("possession_pegasus_shoes")
  self:set_sound_when_picked(nil)
  self:set_shadow(nil)

  -- Let the hero also run with the action key with old savegames.
  self:get_game():set_ability("run", self:get_variant())
end

function item:on_variant_changed(variant)
  self:get_game():set_ability("run", variant)
end

function item:on_using()
  self:get_map():get_entity("hero"):start_running()
  self:set_finished()
end