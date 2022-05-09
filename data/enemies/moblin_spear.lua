--Spear shot by Moblin.

local enemy = ...
local map = enemy:get_map()

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(8)
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_invincible()
  enemy:set_obstacle_behavior("flying")
  enemy:set_minimum_shield_needed(1) -- Wooden shield.
end

function enemy:on_obstacle_reached()
  enemy:set_can_attack(false)
  enemy:stop_movement()
  sol.audio.play_sound("sword_tapping")
  enemy:get_sprite():set_animation("destroy", function()
    enemy:remove()
  end)
end

function enemy:go(direction4)

  local angle = direction4 * math.pi / 2
  local movement = sol.movement.create("straight")
  movement:set_speed(128)
  movement:set_angle(angle)
  movement:set_smooth(false)
  movement:start(enemy)

  enemy:get_sprite():set_direction(direction4)
end