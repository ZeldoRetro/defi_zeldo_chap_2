local enemy = ...
local going_hero = false
local timer

--Eyegore blue

function enemy:on_created()
  self:set_life(2)
  self:set_damage(4)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_hurt_style("monster")
  self:get_sprite():set_animation("immobilized")
  self:set_invincible(true)
  self:set_push_hero_on_sword(true)
  self:set_attack_consequence("sword", "protected")
  self:set_attack_consequence("thrown_item", "protected")
  self:set_attack_consequence("explosion", "protected")
  self:set_attack_consequence("boomerang", "protected")
  self:set_arrow_reaction("protected")
  self:set_hookshot_reaction("protected")
  self:set_fire_reaction("protected")
end

function enemy:on_obstacle_reached(movement)
  if not going_hero then
    self:sleep()
    self:check_hero()
  end
end

function enemy:on_restarted()
  if not going_hero then
    self:get_sprite():set_animation("immobilized")
    self:check_hero()
  else
    self:go_hero()
  end
end

function enemy:check_hero()
  local hero = self:get_map():get_entity("hero")
  local _, _, layer = self:get_position()
  local _, _, hero_layer = hero:get_position()
  local near_hero = layer == hero_layer
    and self:get_distance(hero) < 64

  if near_hero and not going_hero then
    timer:stop()
    timer = nil
    self:awakens()
  end
  timer = sol.timer.start(self, 1000, function() self:check_hero() end)
end

function enemy:sleep()
  self:set_arrow_reaction("protected")
  self:set_attack_consequence("sword", "protected")
  self:set_attack_consequence("thrown_item", "protected")
  self:set_attack_consequence("explosion", "protected")
  self:get_sprite():set_animation("sleeping",function()
    self:get_sprite():set_animation("immobilized")
    going_hero = false
    self:check_hero()
  end)
end

function enemy:awakens()
  self:get_sprite():set_animation("awakening",function()
    self:go_hero()
  end)
end

function enemy:on_movement_changed(movement)

    local direction4 = movement:get_direction4()
    local sprite = self:get_sprite()
    sprite:set_direction(direction4)
end

function enemy:go_hero()
  enemy:set_arrow_reaction(1)
  self:get_sprite():set_animation("walking")
  local m = sol.movement.create("target")
  m:set_speed(56)
  m:start(self)
  going_hero = true
  sol.timer.start(self,3000,function() 
    m:stop(self)
    self:sleep() 
  end)
end