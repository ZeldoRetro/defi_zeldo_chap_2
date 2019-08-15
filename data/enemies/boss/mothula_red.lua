--Mothula boss: shoots bouncing rings and moves faster

local enemy = ...
-- shooting fireballs.
local shooting = false
local function enemy_shoot()
  shooting = false
  local map = enemy:get_map()
  local hero = map:get_hero()
  sol.timer.start(enemy, 10, function()
    if enemy:get_distance(hero) < 500 and enemy:is_in_same_region(hero) then
      if not map.medusa_recent_sound then
        sol.audio.play_sound("boss_fireball")
        -- Avoid loudy simultaneous sounds if there are several medusa.
        map.medusa_recent_sound = true
        sol.timer.start(map, 200, function()
          map.medusa_recent_sound = nil
        end)
      end
      enemy:create_enemy({
        name = "mothula_ring",
        breed = "boss/mothula_red_ring",
      })
    end
  end)
end

function enemy:on_created()

  self:set_life(32)
  self:set_damage(8)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_hurt_style("boss")
  self:set_invincible()
  self:set_attack_consequence("boomerang", 1)
  self:set_attack_consequence("thrown_item", 1)
  self:set_attack_consequence("sword", 1)
  self:set_attack_consequence("explosion", 1)
  self:set_arrow_reaction(1)
  self:set_hookshot_reaction(1)
  self:set_hammer_reaction(1)
  self:set_fire_reaction(2)
  self:set_layer_independent_collisions(true)
end

function enemy:on_restarted()

  local life = self:get_life() 
  local movement = sol.movement.create("path_finding")
  if life <= 24 and life > 16 then
  	movement:set_speed(56)
  elseif life <= 16 and life > 8 then
  	movement:set_speed(72)
  elseif life <= 8 then
  	movement:set_speed(80)
  else
  	movement:set_speed(40)
  end
  if shooting then enemy_shoot() end
  movement:start(enemy)
end

function enemy:on_hurt()
  local life = self:get_life()
  if life == 24 or life == 16 or life == 8 then shooting = true end
  if life <= 0 then enemy:get_map():set_entities_enabled("mothula_ring",false) end
end