local map = ...
local game = map:get_game()

function map:on_started()

  game:set_pause_allowed(false)
  game:set_hud_enabled(false)
  hero:set_visible(false)
  hero_slowed = true
end

function map:on_opening_transition_finished()
    hero:freeze()
    local m = sol.movement.create("straight")
    m:set_angle(3 * math.pi / 2)
    m:set_speed(256)
    m:set_smooth(true)
    m:start(hero)
end

map:register_event("on_finished", function(map)
  game:set_pause_allowed(true)
  game:set_hud_enabled(true)
  map:get_hero():set_walking_speed(88)
  map:get_hero():set_visible(true)
  hero_slowed = false
end)