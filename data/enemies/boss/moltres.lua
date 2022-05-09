local enemy = ...
local map = enemy:get_map()

-- Moltres: Legendary Firebird

local main_sprite = nil
local claw_sprite = nil
local nb_sons_created = 0
local initial_life = 32

function enemy:on_created()

  self:set_life(initial_life)
  self:set_damage(16)
  self:set_hurt_style("boss")
  main_sprite = self:create_sprite("enemies/" .. enemy:get_breed())
  claw_sprite = self:create_sprite("enemies/" .. enemy:get_breed())
  claw_sprite:set_animation("claw")
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_obstacle_behavior("flying")
  self:set_layer_independent_collisions(true)

  self:set_invincible()
  self:set_attack_consequence("sword", 1)
  self:set_attack_consequence("boomerang", "protected")
  self:set_attack_consequence("explosion", 16)
  self:set_attack_consequence("thrown_item", "protected")
  self:set_arrow_reaction("protected")
  self:set_hookshot_reaction("protected")
  self:set_hammer_reaction("protected")
  self:set_fire_reaction("protected")
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(true)
end

function enemy:on_restarted()

  claw_sprite:set_animation("claw")
  local m = sol.movement.create("random")
  m:set_speed(48)
  m:start(self)
  sol.timer.start(self, math.random(750, 1500), function()
    self:prepare_flames()
  end)
end

function enemy:prepare_flames()

  local prefix = self:get_name() .. "_son_"
  local life_lost = initial_life - self:get_life()
  local nb_to_create = 3 + life_lost

  function repeat_throw_flame()
    sol.audio.play_sound("fire")
    nb_sons_created = nb_sons_created + 1
    local son_name = prefix .. nb_sons_created
    self:create_enemy{
      name = son_name,
      breed = "boss/moltres_red_flame",
      x = 0,
      y = -16,
      layer = 1,
    }
    nb_to_create = nb_to_create - 1
    if nb_to_create > 0 then
      sol.timer.start(self, 200, repeat_throw_flame)
    end
  end
  repeat_throw_flame()

  sol.timer.start(self, math.random(4000, 6000), function()
    self:prepare_flames()
  end)
end

function enemy:on_hurt(attack)

  if self:get_life() <= 0 then
    self:get_map():remove_entities(self:get_name() .. "_son_")
  end
end