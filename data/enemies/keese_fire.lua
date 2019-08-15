local enemy = ...

--Fire Keese: Drop fire on the ground

function enemy:on_created()
  self:set_life(2)
  self:set_damage(4)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_attack_consequence("boomerang", 1)
  self:set_hookshot_reaction(2)
  self:set_obstacle_behavior("flying")
  self:set_layer_independent_collisions(true)
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:get_sprite():set_animation("stopped")
  self:set_fire_reaction("ignored")
end

function enemy:on_restarted()

  enemy:get_sprite():set_animation("walking")
  local m = sol.movement.create("path_finding")
  m:set_speed(48)
  m:start(self)
end

local fire_flame = false
function enemy:on_update()
  if not fire_flame then
      fire_flame = true
      sol.timer.start(600,function() 
          enemy:create_enemy({
            breed = "flame_red",
          }) 
        fire_flame = false
      end)   
  end
end

function enemy:on_dying()
  fire_flame = false
end