-- Stone shot by Octorok.

local enemy = ...

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(2)
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_size(8, 8)
  enemy:set_origin(4, 4)
  enemy:set_invincible()
  enemy:set_obstacle_behavior("flying")
  enemy:set_minimum_shield_needed(1) -- Wooden shield.
end

function enemy:on_obstacle_reached()
  enemy:set_can_attack(false)
  enemy:stop_movement()
  sol.audio.play_sound("stone")
  enemy:get_sprite():set_animation("destroy", function()
    enemy:remove()
  end)
end

function enemy:go(direction4)

  local angle = direction4 * math.pi / 2
  local movement = sol.movement.create("straight")
  movement:set_speed(144)
  movement:set_angle(angle)
  movement:set_smooth(false)
  movement:start(enemy)

  enemy:get_sprite():set_direction(direction4)
end