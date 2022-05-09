local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
function map:on_started()
  local ground=game:get_value("tp_ground")
  if ground=="hole" then
    hero:set_visible(false)
  else
    hero:set_visible()
  end
end