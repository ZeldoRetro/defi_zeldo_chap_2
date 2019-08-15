--Dark balls: Remove 1/ of life
local enemy = ...

local sprites = {}

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:set_size(8, 8)
  enemy:set_origin(4, 4)
  enemy:set_obstacle_behavior("flying")
  enemy:set_can_hurt_hero_running(true)
  enemy:set_invincible()
  enemy:set_minimum_shield_needed(2) -- Hylian shield.

  for i = 0, 2 do 
    sprites[#sprites + 1] = enemy:create_sprite("enemies/" .. enemy:get_breed())
  end
end

local function go(angle)

  local movement = sol.movement.create("straight")
  movement:set_speed(144)
  movement:set_angle(angle)
  movement:set_smooth(false)

  function movement:on_obstacle_reached()
    enemy:remove()
  end

  -- Compute the coordinate offset of follower sprites.
  local x = math.cos(angle) * 10
  local y = -math.sin(angle) * 10
  sprites[1]:set_xy(2 * x, 2 * y)
  sprites[2]:set_xy(x, y)

  sprites[1]:set_animation("walking")
  sprites[2]:set_animation("following_1")
  sprites[3]:set_animation("following_2")

  movement:start(enemy)
end

function enemy:on_restarted()

  local hero = enemy:get_map():get_hero()
  local angle = enemy:get_angle(hero:get_center_position())
  go(angle)
end

-- Remove 1/4 of life and destroy the fireball when the hero is touched.
function enemy:on_attacking_hero(hero, enemy_sprite)
  local game = enemy:get_game()
  hero:start_hurt(enemy, 0)
  game:remove_life(math.floor(game:get_life() / 4))
  enemy:remove()
end