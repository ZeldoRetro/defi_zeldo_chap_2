local enemy = ...

--Electric Keese: Can electrocute the hero

function enemy:on_created()
  self:set_life(4)
  self:set_damage(4)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_attack_consequence("boomerang", 1)
  self:set_hookshot_reaction(2)
  self:set_obstacle_behavior("flying")
  self:set_layer_independent_collisions(true)
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:get_sprite():set_animation("stopped")
  self:set_fire_reaction(4)
end

function enemy:on_restarted()

  enemy:get_sprite():set_animation("walking")
  local m = sol.movement.create("path_finding")
  m:set_speed(48)
  m:start(self)
end

function enemy:on_hurt_by_sword(hero, enemy_sprite)
  enemy:set_pushed_back_when_hurt(false)
  enemy:get_game():remove_life(3)
  hero:start_hurt(1)
  hero:freeze()
  hero:set_animation("electrocuted")
  sol.audio.play_sound("hero_hurt")
  sol.timer.start(1000, function () hero:unfreeze()   enemy:set_pushed_back_when_hurt(true) end)
end

function enemy:on_attacking_hero(hero)
	enemy:get_game():remove_life(3)
  hero:start_hurt(enemy, 1)
  hero:freeze()
	hero:set_animation("electrocuted")
  sol.audio.play_sound("hero_hurt")
  sol.timer.start(1000, function () hero:unfreeze() end)
end