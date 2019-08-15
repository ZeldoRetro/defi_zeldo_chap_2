--Armos: Fake statue who targets the hero once awakened.

local enemy = ...
local going_hero = false
local timer

function enemy:on_created()
  self:set_life(4)
  self:set_damage(2)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:get_sprite():set_animation("immobilized")
  self:set_invincible(true)
  self:set_can_attack(false)
  self:set_traversable(false)
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
    and self:get_distance(hero) < 48

  if near_hero and not going_hero then
    timer:stop()
    timer = nil
    self:awakens()
  end
  timer = sol.timer.start(self, 1000, function() self:check_hero() end)
end

function enemy:awakens()
  sol.audio.play_sound("enemy_awake")
  self:get_sprite():set_animation("awakening")
  sol.timer.start(1000,function() self:go_hero() end)
end

function enemy:on_movement_changed(movement)
    local direction4 = movement:get_direction4()
    local sprite = self:get_sprite()
    sprite:set_direction(direction4)
end

function enemy:go_hero()
  self:set_arrow_reaction(2)
  self:set_hammer_reaction(4)
  self:set_fire_reaction(2)
  self:set_attack_consequence("sword", 1)
  self:set_attack_consequence("thrown_item", 2)
  self:set_attack_consequence("explosion", 2)
  self:set_can_attack(true)
  self:set_traversable(true)
  self:get_sprite():set_animation("walking")
  local m = sol.movement.create("target")
  m:set_speed(48)
  m:start(self)
  going_hero = true
end