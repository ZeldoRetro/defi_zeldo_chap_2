-- Kholdstare boss.

local enemy = ...
local game = enemy:get_game()

function enemy:on_created()

  enemy:set_life(24)
  enemy:set_damage(20)
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_hurt_style("boss")
  enemy:set_layer_independent_collisions(true)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:set_invincible()
  enemy:set_attack_consequence("sword", 1)
  enemy:set_attack_consequence("explosion", 1)
  enemy:set_attack_consequence("arrow", "protected")
  enemy:set_attack_consequence("hookshot", "protected")
  enemy:set_hammer_reaction("protected")
  enemy:set_fire_reaction(8)
end

function enemy:on_restarted()

  local movement = sol.movement.create("path_finding")
  movement:set_speed(64)
  movement:start(enemy)
end

function enemy:on_movement_changed(movement)

  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end

function enemy:on_attacking_hero(hero)
	enemy:get_game():remove_life(1)
  hero:start_hurt(enemy, 15)
  hero:freeze()
	hero:set_animation("frozen")
  sol.audio.play_sound("hero_hurt")
  sol.timer.start(1000, function () hero:unfreeze() end)
end