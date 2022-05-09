--Fire balls

local enemy = ...
local map = enemy:get_map()

local sprites = {}

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:set_size(8, 8)
  enemy:set_origin(4, 4)
  enemy:set_obstacle_behavior("flying")
  enemy:set_can_hurt_hero_running(true)
  enemy:set_layer_independent_collisions(true)
  enemy:set_invincible()

  for i = 0, 2 do 
    sprites[#sprites + 1] = enemy:create_sprite("enemies/keese_dark")
  end
end

local function go(angle)

  local movement = sol.movement.create("straight")
  movement:set_speed(128)
  movement:set_angle(angle)
  movement:set_smooth(false)

  function movement:on_obstacle_reached()
    enemy:remove()
  end

  movement:start(enemy)
end

function enemy:on_restarted()

  local hero = enemy:get_map():get_hero()
  local angle = enemy:get_angle(hero:get_center_position())
  go(angle)
end

-- Remove 1/2 of life and destroy the fireball when the hero is touched.
function enemy:on_attacking_hero(hero, enemy_sprite)
  local game = enemy:get_game()
  hero:start_hurt(enemy, 0)
  game:remove_life(math.floor(game:get_life() / 2))
  enemy:remove()
end