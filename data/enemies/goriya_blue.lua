--Goriya blue

local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

-- Event called when the enemy is initialized.
function enemy:on_created()

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  self:set_life(2)
  self:set_damage(12)
  self:set_invincible()
  self:set_push_hero_on_sword(true)
  enemy:set_arrow_reaction(1)
  self:set_attack_consequence("sword", "protected")
  self:set_attack_consequence("thrown_item", "protected")
  self:set_attack_consequence("explosion", "protected")
  self:set_attack_consequence("boomerang", "protected")
  self:set_hookshot_reaction("protected")
  self:set_fire_reaction("protected")

end

-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.
function enemy:on_restarted()
  
  local sprite = enemy:get_sprite()
  sprite:set_animation("walking")
  sprite:set_paused(true)
  movement = sol.movement.create("target")
  local x_hero, y_hero = hero:get_position()
  sol.timer.start(enemy, 50, function()
    if hero:get_state() ~= "running" then
      local direction = 0
      local movement_hero = hero:get_movement()
      if not movement_hero then
        direction = hero:get_sprite():get_direction()
      else
        direction = movement_hero:get_direction4()
      end
      local direction_enemy = 0
      if direction == 0 then
        direction_enemy = 2
      elseif direction == 1 then
        direction_enemy = 3
      elseif direction == 3 then
        direction_enemy = 1
      end
      local x_new_hero, y_new_hero = hero:get_position()
      local x_enemy, y_enemy = enemy:get_position()
      local diff_x = x_new_hero - x_hero
      local diff_y = y_new_hero - y_hero
      if diff_x ~= 0 or diff_y  ~= 0 then
            sprite:set_paused(false)
      else
            sprite:set_paused(true)
      end
      x_enemy = x_enemy - diff_x
      y_enemy = y_enemy - diff_y
      enemy:get_sprite():set_direction(direction_enemy)
      movement:set_target(x_enemy, y_enemy)
      movement:set_speed(88)
      movement:start(enemy)
      x_hero = x_new_hero
      y_hero  = y_new_hero
  else
      local x_new_hero, y_new_hero = hero:get_position()
      x_hero = x_new_hero
      y_hero  = y_new_hero
  end
  return true
end)

end