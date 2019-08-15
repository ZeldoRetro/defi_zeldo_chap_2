--The thief of Takapa

local enemy = ...
local game = enemy:get_game()

function enemy:on_created()

  enemy:set_life(32)
  enemy:set_damage(16)
  enemy:set_hurt_style("boss")
  enemy:create_sprite("enemies/" .. enemy:get_breed())
end

function enemy:on_movement_changed(movement)

  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end

function enemy:on_restarted()

  local movement = sol.movement.create("target")
  movement:set_speed(80)
  movement:start(enemy)
end