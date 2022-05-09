local map = ...
local game = map:get_game()

function map:on_started()

  sword_level = game:get_ability("sword")
  game:set_ability("sword",0)
  item_assigned_slot_1 = game:get_item_assigned(1)
  game:set_item_assigned(1, nil)
  item_assigned_slot_2 = game:get_item_assigned(2)
  game:set_item_assigned(2, nil)

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

    sol.timer.start(map,2500,function()
            game:set_ability("sword",sword_level)
            game:set_item_assigned(1, item_assigned_slot_1)
            game:set_item_assigned(2, item_assigned_slot_2)
    end)
end

map:register_event("on_finished", function(map)
  game:set_pause_allowed(true)
  game:set_hud_enabled(true)
  map:get_hero():set_walking_speed(88)
  map:get_hero():set_visible(true)
  hero_slowed = false
end)