--Zeldo

local enemy = ...
local game = enemy:get_game()

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:set_hurt_style("boss")
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_attack_consequence("boomerang",1)
  enemy:set_hookshot_reaction(1)
end

function enemy:on_movement_changed(movement)

  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end

function enemy:on_restarted()

  local movement = sol.movement.create("target")
  movement:set_speed(32)
  movement:start(enemy)
end