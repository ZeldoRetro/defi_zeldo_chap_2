local map = ...

function map:on_started()
  local game = map:get_game()
  local hero = map:get_hero()
  local ground=game:get_value("tp_ground")
  if ground=="hole" then
    hero:set_visible(false)
  else
    hero:set_visible()
  end
end