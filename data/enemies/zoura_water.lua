-- A water enemy who shoots fireballs.

local enemy = ...
local sprite

function enemy:on_created()

  enemy:set_life(2)
  enemy:set_damage(2)
  enemy:set_attack_consequence("boomerang", 1)
  enemy:set_hookshot_reaction(2)
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

function enemy:on_restarted()

  local sprite = enemy:get_sprite()
  local hero = enemy:get_map():get_hero()
  sol.timer.start(enemy, 3000, function()
    if enemy:get_distance(hero) < 300 and enemy:is_in_same_region(hero)  then
      sol.audio.play_sound("zora")
      sprite:set_animation("shooting")
      enemy:create_enemy({
        breed = "fireball_blue_small",
      })
    end
    return true  -- Repeat the timer.
  end)
end