local enemy = ...
local map = enemy:get_map()

-- A red flame shot by another enemy.

function enemy:on_created()
  self:set_life(1)
  self:set_damage(4)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_invincible()
  self:set_obstacle_behavior("flying")
  self:set_layer_independent_collisions(true)
  self:set_optimization_distance(0)
end

function enemy:on_restarted()
  sol.timer.start(self, 1000, function()
    self:get_sprite():set_animation("disapear",function() 
      enemy:remove()
    end)
  end)
end

function enemy:go(angle)

  local m = sol.movement.create("straight")
  m:set_speed(144)
  m:set_angle(angle)
  m:set_smooth(false)
  m:start(self)
end