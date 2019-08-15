local enemy = ...

--Keese

function enemy:on_created()
  self:set_life(1)
  self:set_damage(2)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_attack_consequence("boomerang", 1)
  self:set_hookshot_reaction(1)
  self:set_obstacle_behavior("flying")
  self:set_layer_independent_collisions(true)
  self:set_size(16, 16)
  self:set_origin(8, 13)
end

function enemy:on_restarted()

  local m = sol.movement.create("path_finding")
  m:set_speed(32)
  m:start(self)
end