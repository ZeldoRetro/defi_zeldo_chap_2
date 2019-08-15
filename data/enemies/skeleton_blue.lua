local enemy = ...

--Skeleton blue

enemy:set_life(2)
enemy:set_damage(2)

local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())

-- The enemy was stopped for some reason and should restart.
function enemy:on_restarted()

  local m = sol.movement.create("straight")
  m:set_speed(0)
  m:start(self)
  self:check_hero()
end

-- An obstacle is reached: stop for a while, looking to a next direction.
function enemy:on_obstacle_reached(movement)

  -- Look to the left or to the right.
  local animation = sprite:get_animation()
  if animation == "walking" then
    self:look_left_or_right()
  end
end

-- The movement is finished: stop for a while, looking to a next direction.
function enemy:on_movement_finished(movement)
  -- Same thing as when an obstacle is reached.
  self:on_obstacle_reached(movement)
end

-- Makes the enemy walk towards a direction.
function enemy:go(direction4)

  -- Set the sprite.
  sprite:set_animation("walking")
  sprite:set_direction(direction4)

  -- Set the movement.
  local m = self:get_movement()
  local max_distance = 40 + math.random(120)
  m:set_max_distance(max_distance)
  m:set_smooth(true)
  m:set_speed(40)
  m:set_angle(direction4 * math.pi / 2)
end

-- Makes the enemy look to its left or to its right (random choice).
function enemy:look_left_or_right()

  local direction = sprite:get_direction()
  if math.random(2) == 1 then
    sprite:set_animation("stopped_watching_left")
    sol.timer.start(enemy, 500, function()
      enemy:go((direction + 1) % 4)
    end)
  else
    sprite:set_animation("stopped_watching_right")
    sol.timer.start(enemy, 500, function()
      enemy:go((direction + 3) % 4)
    end)
  end
end

function enemy:check_hero()

    local direction4 = math.random(4) - 1
    local hero = self:get_map():get_hero()
    local _, _, layer = self:get_position()
    local _, _, hero_layer = hero:get_position()
    local near_hero =
        layer == hero_layer
        and self:get_distance(hero) < 56
        and self:is_in_same_region(hero)

    if near_hero and hero:get_animation() == "sword" then
        self:jump()
    else
        self:go(direction4)
    end

    sol.timer.stop_all(self)
    sol.timer.start(self, 400, function() self:check_hero() end)
end

function enemy:jump()

  local hero = self:get_map():get_hero()
  local direction = hero:get_direction()
  local direction4 = math.random(4) - 1

  -- Set the sprite.
  sprite:set_animation("jumping")
  sprite:set_direction(direction)
  sol.audio.play_sound("throw")

  -- Set the movement.
  local m_jump = sol.movement.create("straight")
  m_jump:set_max_distance(48)
  m_jump:set_smooth(true)
  m_jump:set_speed(96)
  m_jump:set_angle(direction)
  m_jump:start(enemy,function() enemy:go(direction4) end)
end