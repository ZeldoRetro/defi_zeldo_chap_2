-- A fixed enemy who shoots ice balls.

local enemy = ...

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(0)
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_size(16, 16)
  enemy:set_origin(8, 13)
  enemy:set_can_attack(false)
  enemy:set_optimization_distance(0)
  enemy:create_sprite("enemies/medusa")
  enemy:set_invincible()

  enemy:set_shooting(true)
end

function enemy:on_restarted()

  local map = enemy:get_map()
  local hero = map:get_hero()
  sol.timer.start(enemy, math.random(2000,5000), function()
    if not enemy.shooting then
      return true
    end
    if enemy:get_distance(hero) < 500 and enemy:is_in_same_region(hero) then

      if not map.medusa_recent_sound then
        sol.audio.play_sound("zora")
        -- Avoid loudy simultaneous sounds if there are several medusa.
        map.medusa_recent_sound = true
        sol.timer.start(map, 200, function()
          map.medusa_recent_sound = nil
        end)
      end

      enemy:create_enemy({
        breed = "fireball_white_small",
      })
    end
    return true  -- Repeat the timer.
  end)
end

-- Suspends or restores shooting fireballs.
function enemy:set_shooting(shooting)
  enemy.shooting = shooting
end