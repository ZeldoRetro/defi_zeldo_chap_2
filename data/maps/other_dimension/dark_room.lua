local map = ...
local game = map:get_game()

function map:on_opening_transition_finished()
  hero:freeze()
  sol.timer.start(map,4000,function()
    hero:teleport("other_dimension/end","destination")
  end)
end
