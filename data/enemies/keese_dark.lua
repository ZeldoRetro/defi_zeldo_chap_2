local enemy = ...

--Dark Keese: Remove 1/4 of live

function enemy:on_created()
  self:set_life(6)
  self:set_damage(4)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_attack_consequence("boomerang", 1)
  self:set_hookshot_reaction(2)
  self:set_obstacle_behavior("flying")
  self:set_layer_independent_collisions(true)
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:get_sprite():set_animation("stopped")
  self:set_fire_reaction(4)
end

function enemy:on_restarted()

  enemy:get_sprite():set_animation("walking")
  local m = sol.movement.create("path_finding")
  m:set_speed(48)
  m:start(self)
end

function enemy:on_attacking_hero(hero)
  local game = enemy:get_game()
  hero:start_hurt(enemy, 0)
  game:remove_life(math.floor(game:get_life() / 4))
end