local enemy = ...

--Chuchu yellow: Electrocute the hero

function enemy:on_created()
  self:set_life(4)
  self:set_damage(2)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_size(16, 16)
  self:set_origin(8, 13)
end

function enemy:on_restarted()
  local m = sol.movement.create("path_finding")
  m:set_speed(32)
  sol.timer.start(enemy, math.random(3000,5000), function() enemy:disappear() end)
  m:start(self)
end

function enemy:disappear()
  local sprite = self:get_sprite()
  sprite:set_animation("disappearing")

  function sprite:on_animation_finished(animation)
    enemy:set_can_attack(false)
    enemy:set_invincible()
    sol.timer.start(enemy, math.random(3000,8000), function() enemy:reappear() end)
  end
end

function enemy:reappear()
  local sprite = self:get_sprite()
  enemy:set_can_attack(true)
  enemy:set_attack_consequence ("sword", 1)
  enemy:set_attack_consequence ("thrown_item", 1)
  enemy:set_attack_consequence ("explosion", 2)
  enemy:set_attack_consequence ("boomerang", "immobilized")
  enemy:set_hookshot_reaction("immobilized")
  enemy:set_fire_reaction(2)
  enemy:set_hammer_reaction(2)
  enemy:set_arrow_reaction(2)
  sprite:set_animation("reappearing")
  function sprite:on_animation_finished(animation) enemy:restart() end
end

function enemy:on_immobilized()
  enemy:set_attack_consequence ("sword", 1)
  enemy:set_attack_consequence ("thrown_item", 1)
  enemy:set_attack_consequence ("explosion", 2)
  enemy:set_attack_consequence ("boomerang", "immobilized")
  enemy:set_hookshot_reaction("immobilized")
  enemy:set_fire_reaction(2)
  enemy:set_hammer_reaction(2)
  enemy:set_arrow_reaction(2)
end

function enemy:on_hurt_by_sword(hero, enemy_sprite)
  if enemy:get_sprite():get_animation() == "immobilized" or enemy:get_sprite():get_animation() == "shaking" then
    enemy:remove_life(1)
 else
    enemy:set_pushed_back_when_hurt(false)
  	enemy:get_game():remove_life(3)
    hero:start_hurt(1)
    hero:freeze()
  	hero:set_animation("electrocuted")
    sol.audio.play_sound("hero_hurt")
    sol.timer.start(1000, function () hero:unfreeze()   enemy:set_pushed_back_when_hurt(true) end)
  end
end

function enemy:on_attacking_hero(hero, enemy_sprite)
	enemy:get_game():remove_life(3)
  hero:start_hurt(enemy, 1)
  hero:freeze()
	hero:set_animation("electrocuted")
  sol.audio.play_sound("hero_hurt")
  sol.timer.start(1000, function () hero:unfreeze() end)
end