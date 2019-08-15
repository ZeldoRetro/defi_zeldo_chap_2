local enemy = ...
local chain = nil

-- Knight with a chain and ball.

function enemy:on_created()
  self:set_life(16); self:set_damage(8)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_invincible()
  self:set_attack_consequence("sword", 1)
  self:set_attack_consequence("boomerang", "protected")
  self:set_attack_consequence("explosion", 1)
  self:set_hookshot_reaction("protected")
  self:set_fire_reaction("protected")
  self:set_hammer_reaction("protected")
  self:set_arrow_reaction(1)
  self:set_attack_consequence("thrown_item", 8)
end

function enemy:on_restarted()
  -- Set the movement.
  local sprite = enemy:get_sprite()
  sprite:set_animation("walking")
  local movement = sol.movement.create("target")
  movement:set_speed(32)
  movement:start(enemy)

  if chain ~= nil then
    chain:set_enabled(true)
  end
end

function enemy:on_movement_changed(movement)

  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end

function enemy:on_hurt(attack)
  if self:get_life() <= 0 then
    -- dying: remove the chain and ball.
    chain:remove()
  else
    -- hurt: disable the chain and ball for a while.
    chain:set_enabled(false)
  end
end

function enemy:on_enabled()
  if chain == nil then
    -- Create the chain and ball.
    local chain_name = self:get_name() .. "_chain"
    chain = self:create_enemy{
      name = chain_name,
      breed = "chain_and_ball",
      x = 8,
      y = -16,
    }
    chain:set_center_enemy(self)
    chain:set_enabled(true)
  end
end