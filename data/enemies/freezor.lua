-- An ice monster that can only be killed with fire.

local enemy = ...
local game = enemy:get_game()

local behavior = require("enemies/towards_hero")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 1,
  damage = 16,
  normal_speed = 64,
  faster_speed = 64,
  push_hero_on_sword = true,
  detection_distance = 220,
}

behavior:create(enemy, properties)

enemy:set_layer_independent_collisions(true)
enemy:set_invincible(true)
enemy:set_attack_consequence("boomerang", "protected")
enemy:set_attack_consequence("explosion", "protected")
enemy:set_attack_consequence("sword", "custom")
enemy:set_attack_consequence("thrown_item", "custom")
enemy:set_hammer_reaction("custom")
enemy:set_arrow_reaction("protected")
enemy:set_hookshot_reaction("protected")

enemy:set_fire_reaction(1)

function enemy:on_custom_attack_received(attack)

  -- Custom reaction: don't get hurt but step back.
  sol.timer.stop_all(enemy)  -- Stop the towards_hero behavior.
  sol.audio.play_sound("sword_tapping")
  local hero = enemy:get_map():get_hero()
  local angle = hero:get_angle(enemy)
  local movement = sol.movement.create("straight")
  movement:set_speed(128)
  movement:set_ignore_obstacles(properties.ignore_obstacles)
  movement:set_angle(angle)
  movement:start(enemy)
  sol.timer.start(enemy, 300, function()
    enemy:restart()
  end)
end

function enemy:on_attacking_hero(hero)
	enemy:get_game():remove_life(1)
  hero:start_hurt(enemy, 15)
  hero:freeze()
	hero:set_animation("frozen")
  sol.audio.play_sound("hero_hurt")
  sol.timer.start(1000, function () hero:unfreeze() end)
end