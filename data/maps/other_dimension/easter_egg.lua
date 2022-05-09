local map = ...
local game = map:get_game()

function map:on_started()
  hero:set_visible(false)
end

function map:on_opening_transition_finished()
  hero:freeze()
  sol.timer.start(map,7777,function()
    sol.audio.play_sound("zeldo_laugh")
    hero:teleport("outside/B1","cheat_cave")
  end)
end

map:register_event("on_finished", function(map)
  game:set_pause_allowed(true)
  game:set_hud_enabled(true)
  map:get_hero():set_walking_speed(88)
  map:get_hero():set_visible(true)
  hero_slowed = false
end)