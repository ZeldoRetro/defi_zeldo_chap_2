local enemy = ...
local map = enemy:get_map()
local angry = false
local num_times_hurt = 0

-- Cucco (Hylian Chicken): Attacking it too much will bring the pain.

function enemy:on_created()
  self:set_life(9999); self:set_damage(4)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_size(16, 16); self:set_origin(8, 13)
end

function enemy:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  self:get_sprite():set_direction(direction4)
end

function enemy:on_obstacle_reached(movement)
  if not angry then
    enemy:go_random()
  else
    enemy:go_angry()
  end
end

function enemy:on_restarted()
  if angry then
    enemy:go_angry()
  else
    enemy:go_random()  
    sol.timer.start(enemy, 100, function()
      if map.angry_cuccos and not angry then
        enemy:go_angry()
        return false
      end
      return true  -- Repeat the timer.
    end)
  end
end

function enemy:go_random()
  angry = false
  local movement = sol.movement.create("random")
  movement:set_speed(32)
  movement:start(enemy)
  enemy:set_can_attack(false)
end

function enemy:go_angry()
  angry = true
  map.angry_cuccos = true
  going_hero = true
  local movement = sol.movement.create("target")
  movement:set_speed(128)
  movement:start(enemy)
  enemy:get_sprite():set_animation("angry")
  enemy:set_can_attack(true)
end

function enemy:on_hurt()
  sol.audio.play_sound("cucco")
  num_times_hurt = num_times_hurt + 1
  if num_times_hurt == 6 and not map.angry_cuccos then
    -- Make all cuccos of the map attack the hero.
    enemy:get_map():set_entities_enabled("cucco_wall",false)
    map.angry_cuccos = true
  end
end

--Le dommage de l'ennemi sera de 61, quelle que soit la défense
function enemy:on_attacking_hero(hero, enemy_sprite)
	enemy:get_game():remove_life(61)
  hero:start_hurt(enemy, 1)
end