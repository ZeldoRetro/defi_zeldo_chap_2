--Fire balls

local enemy = ...
local map = enemy:get_map()

local sprites = {}

require("scripts/fsa_effect")
local el = create_light(map,-256,-256,0,"80","193,185,100")

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:set_size(8, 8)
  enemy:set_origin(4, 4)
  enemy:set_obstacle_behavior("flying")
  enemy:set_can_hurt_hero_running(true)
  enemy:set_layer_independent_collisions(true)
  enemy:set_invincible()
  enemy:set_minimum_shield_needed(2) -- Hylian shield.

  for i = 0, 2 do 
    sprites[#sprites + 1] = enemy:create_sprite("enemies/" .. enemy:get_breed())
  end

  function el:on_update()
    el:set_position(enemy:get_position())
  end
end

local function go(angle)

  local movement = sol.movement.create("straight")
  movement:set_speed(144)
  movement:set_angle(angle)
  movement:set_smooth(false)

  function movement:on_obstacle_reached()
    enemy:remove()
    el:set_enabled(false)
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

-- Destroy the fireball when the hero is touched.
function enemy:on_attacking_hero(hero, enemy_sprite)
	enemy:get_game():remove_life(3)
  hero:start_hurt(enemy, 1)
  el:set_enabled(false)
  enemy:remove()
end