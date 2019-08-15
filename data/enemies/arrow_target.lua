local enemy = ...

local recent_obstacle = 0
local speed

function enemy:on_created()

  self:set_life(9999)
  self:set_damage(4)
  self:create_sprite("enemies/arrow_target")
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_invincible()
  self:set_obstacle_behavior("flying")
  self:set_attack_consequence("sword", "protected")
  self:set_attack_consequence("thrown_item", "protected")
  self:set_attack_consequence("hookshot", "protected")
  self:set_attack_consequence("boomerang", "protected")
  self:set_arrow_reaction(1)
  self:set_pushed_back_when_hurt(false)
  speed = 32
end

function enemy:on_restarted()

  local sprite = self:get_sprite()
  local direction4 = sprite:get_direction()
  local m = sol.movement.create("path")
  m:set_path{direction4 * 2}
  m:set_speed(speed)
  m:set_loop(true)
  m:start(self)
end

function enemy:on_hurt()
  speed = speed + 8
end

function enemy:on_obstacle_reached()

  local sprite = self:get_sprite()
  local direction4 = sprite:get_direction()
  sprite:set_direction((direction4 + 2) % 4)

  local hero = self:get_map():get_hero()

  recent_obstacle = 8
  self:restart()
end

function enemy:on_position_changed()

  if recent_obstacle > 0 then
    recent_obstacle = recent_obstacle - 1
  end
end
