local map = ...
local game = map:get_game()
local music_map = map:get_music()

-- DEBUT DE LA MAP
function map:on_started()
  --Système jour/nuit
  if game:get_value("day") or game:get_value("twilight") then
    --Jour/Crépuscule
    sol.audio.play_music(music_map)
    map:set_entities_enabled("night_entity",false)
    map:set_entities_enabled("day_entity",true)
  elseif game:get_value("night") or game:get_value("dawn") then
    --Nuit/Aube
    sol.audio.play_music(music_map .. "_night")
    map:set_entities_enabled("night_entity",true)
    map:set_entities_enabled("day_entity",false)
  end
end