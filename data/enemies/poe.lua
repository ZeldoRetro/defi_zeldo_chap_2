local enemy = ...

-- Poe: A ghost who needs the Lens of Truth to be seen. Weakeness: Light (Master Sword/Light Arrow)

function enemy:on_created()

  self:set_life(8)
  self:set_damage(8)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_obstacle_behavior("flying")
  self:set_invincible()
  if enemy:get_game():get_ability("sword") > 2 then
    enemy:set_attack_consequence("sword", 2)
  else enemy:set_attack_consequence("sword", 1) end

  if enemy:get_game():has_item("inventory/bow_light") then
    enemy:set_arrow_reaction(8)
  end
end

function enemy:on_restarted()

  local m = sol.movement.create("path_finding")
  m:set_speed(48)
  m:start(self)
end

function enemy:on_movement_changed(movement)

  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end