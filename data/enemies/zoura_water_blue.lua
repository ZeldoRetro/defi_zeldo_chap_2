-- A water enemy who shoots fireballs.

local enemy = ...
local sprite

function enemy:on_created()

  enemy:set_life(4)
  enemy:set_damage(2)
  enemy:set_obstacle_behavior("swimming")
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_layer_independent_collisions(true)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)

  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  function sprite:on_animation_finished(animation)
    if animation == "shooting" then
      sprite:set_animation("walking")
    end
  end
end

function enemy:shoot()
  local i = 0
  sol.timer.start(enemy, 500,function()
    i = i + 1
    sol.audio.play_sound("zora")
    sprite:set_animation("shooting")
    enemy:create_enemy({
      breed = "fireball_blue_small",
    })
    if i == 3 then
      i = 0
      sol.timer.start(enemy, 1000, function()
        sprite:set_animation("walking")
        enemy:disappear()
      end)
    else return true end
  end) 
end

function enemy:appear()

  local sprite = enemy:get_sprite()
  enemy:set_visible(true)
  sprite:set_animation("plunging")
  sol.timer.start(enemy, 1000, function()
      enemy:set_can_attack(true)
      enemy:set_attack_consequence("boomerang", 1)
      enemy:set_attack_consequence("sword", 1)
      enemy:set_attack_consequence("explosion", 2)
      enemy:set_attack_consequence("thrown_item", 1)
      enemy:set_hookshot_reaction(2)
      enemy:set_fire_reaction(2)
      enemy:set_arrow_reaction(2)
      sprite:set_animation("walking")
      sol.timer.start(enemy,500, function() enemy:shoot() end)
  end)

end

function enemy:disappear()

  local hero = enemy:get_map():get_hero()
  local sprite = enemy:get_sprite()
  local direction = enemy:get_direction4_to(hero)
  sprite:set_direction(direction)
  enemy:set_invincible()
  enemy:set_can_attack(false)
  sprite:set_animation("plunging")
  sol.timer.start(enemy, 1000, function()
      enemy:set_visible(false)
      local m = sol.movement.create("random")
      m:set_speed(144)
      m:start(self)
      sol.timer.start(enemy, math.random(1000,3000), function()
        local direction = enemy:get_direction4_to(hero)
        local sprite = enemy:get_sprite()
        sprite:set_direction(direction)
        m:stop(self)
        if enemy:is_in_same_region(hero) and enemy:get_distance(hero) < 200 then enemy:appear() else enemy:restart() end
      end)  
  end)

end

function enemy:on_restarted()
  enemy:disappear()
end