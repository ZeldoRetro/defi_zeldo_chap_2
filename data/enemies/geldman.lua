local enemy = ...

-- Geldman: a basic desert enemy.

function enemy:on_created()
  self:set_life(3)
  self:set_damage(2)
  self:create_sprite("enemies/geldman")
  self:set_size(40, 16)
  self:set_origin(20, 13)
end

function enemy:on_restarted()

  local m = sol.movement.create("target")
  m:set_speed(40)
  m:start(self)
end
