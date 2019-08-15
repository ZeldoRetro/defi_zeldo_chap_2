-- Flame shot by Kodongo.

local enemy = ...
local map = enemy:get_map()

require("scripts/fsa_effect")
local el = create_light(map,-256,-256,0,"80","193,185,100")

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(4)
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_invincible()
  enemy:set_obstacle_behavior("flying")
  enemy:set_minimum_shield_needed(3) -- Miror shield.

  function el:on_update()
    el:set_position(enemy:get_position())
  end
end

function enemy:on_obstacle_reached()
  enemy:stop_movement()
  enemy:get_sprite():set_animation("stare")
  sol.timer.start(self, 1500, function()
    self:get_sprite():set_animation("disapear",function() 
      enemy:remove()
      el:set_enabled(false)
    end)
  end)
end

function enemy:go(direction4)

  local angle = direction4 * math.pi / 2
  local movement = sol.movement.create("straight")
  movement:set_speed(96)
  movement:set_angle(angle)
  movement:set_smooth(false)
  movement:start(enemy)

  enemy:get_sprite():set_direction(direction4)
end