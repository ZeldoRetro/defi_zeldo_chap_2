local enemy = ...

--Crocorock

enemy:set_life(1)
enemy:set_damage(2)

local sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())


-- The enemy was stopped for some reason and should restart.
function enemy:on_restarted()
  local m = sol.movement.create("straight")
  m:start(self)
  self:set_traversable(true)
  enemy:set_attack_consequence("sword", "immobilized")
  enemy:set_attack_consequence("boomerang", "immobilized")
  enemy:set_attack_consequence("thrown_item", "immobilized")
  enemy:set_attack_consequence("explosion", "immobilized")
  enemy:set_arrow_reaction("immobilized")
  enemy:set_fire_reaction("immobilized")
  enemy:set_hookshot_reaction("immobilized")
  enemy:set_hammer_reaction("immobilized")
  self:go()
end

-- An obstacle is reached: try a new direction
function enemy:on_obstacle_reached()
    self:go()
end

-- Stop for a while, then keep going or change direction
function enemy:on_movement_finished()
    sprite:set_animation("walking")
        sol.timer.start(self, math.random(600,1200), function() 
            self:go()
    end)
end

-- Makes the rat walk towards a direction.
function enemy:go()

    -- Set the sprite.
    sprite:set_animation("walking")
    local direction = sprite:get_direction()
 
    local directions = { ((direction + 3) % 4), ((direction + 1) % 4), ((direction) % 4) }
    local direction4 = directions[math.random(3)]

    sprite:set_direction(direction4)
  
    -- Set the movement.
    local m = self:get_movement()
    local max_distance = 72 + math.random(128)
    m:set_speed(80)
    m:set_max_distance(max_distance)
    m:set_angle(direction4 * math.pi / 2)
end

function enemy:on_immobilized()
  self:set_life(1)
  self:set_invincible()
  self:set_traversable(false)
end