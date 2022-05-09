-- Mouser

local enemy = ...

local can_shoot = true

local quarter = math.pi * 0.5
local attacking_timer = nil

-- Configuration variables
local waiting_duration = 2000
local second_thow_delay = 200
local falling_duration = 600
local falling_height = 16
local falling_angle = 3 * quarter - 0.4
local falling_speed = 100
local running_speed = 100

local projectile_initial_speed = 150

function enemy:on_created()

  enemy:set_life(12)
  enemy:set_damage(12)
  enemy:create_sprite("enemies/" .. enemy:get_breed())
end

local function go_hero()

  local sprite = enemy:get_sprite()
  sprite:set_animation("walking")
  local movement = sol.movement.create("path_finding")
  movement:set_speed(24)
  movement:start(enemy)
end

local function shoot()

  local sprite = enemy:get_sprite()

  enemy:stop_movement()
  sprite:set_animation("shooting")
  sol.timer.start(enemy, 650, function()
    sprite:set_animation("stopped")
    local projectile = enemy:create_enemy({breed = "bomb"})
    projectile:go(nil, nil, angle, projectile_initial_speed)

    if on_throwed_callback then
      on_throwed_callback()
    end

    -- Call an enemy:on_enemy_created(projectile) event.
    if enemy.on_enemy_created then
      enemy:on_enemy_created(projectile)
    end

    enemy:restart()
  end)

end

function enemy:on_restarted()

  local map = enemy:get_map()
  local hero = map:get_hero()

  go_hero()

  can_shoot = true

  sol.timer.start(enemy, 100, function()

    local hero_x, hero_y = hero:get_position()
    local x, y = enemy:get_center_position()

    if can_shoot then
      local aligned = (math.abs(hero_x - x) < 16 or math.abs(hero_y - y) < 16) 
      if aligned and enemy:get_distance(hero) < 200 and enemy:is_in_same_region(hero) then
        shoot()
        can_shoot = false
        sol.timer.start(enemy, 1500, function()
          can_shoot = true
        end)
      end
    end
    return true  -- Repeat the timer.
  end)
end

function enemy:on_movement_changed(movement)

  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end