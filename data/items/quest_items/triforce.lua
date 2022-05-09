--The Triforce: The standard final item of a quest.

local item = ...

function item:on_created()
  self:set_sound_when_picked(nil)
  self:set_sound_when_brandished(nil)
  self:set_shadow(nil)
  self:set_savegame_variable("possession_triforce")
end

function item:on_obtaining()
  sol.audio.play_music("triforce_obtained",false)
end

function item:on_obtained()
  item:get_map():get_hero():freeze()
  item:get_map():get_hero():set_direction(3)
  item:get_map():get_entity("sensor"):set_enabled(true)
end