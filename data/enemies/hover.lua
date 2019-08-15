local enemy = ...

--Hover

function enemy:on_created()

  self:set_life(2)
  self:set_damage(2)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_obstacle_behavior("swimming")  -- Allow to traverse water.
end

function enemy:on_movement_changed(movement)

  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end

function enemy:on_restarted()
  local m = sol.movement.create("path_finding")
  m:set_speed(32)
  m:start(self)
end