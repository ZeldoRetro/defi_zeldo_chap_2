local enemy = ...

-- Pike that always moves, horizontally or vertically
-- depending on its direction.

local recent_obstacle = 0

function enemy:on_created()

  self:set_life(1)
  self:create_sprite("enemies/pike_detect")
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_can_hurt_hero_running(true)
  self:set_invincible()
  self:set_attack_consequence("sword", "protected")
  self:set_attack_consequence("thrown_item", "protected")
  self:set_arrow_reaction("protected")
  self:set_hookshot_reaction("protected")
  self:set_attack_consequence("boomerang", "protected")
end

function enemy:on_restarted()

  local sprite = self:get_sprite()
  local direction4 = sprite:get_direction()
  local m = sol.movement.create("path")
  m:set_path{direction4 * 2}
  m:set_speed(120)
  m:set_loop(true)
  m:start(self)
end

function enemy:on_obstacle_reached()

  local sprite = self:get_sprite()
  local direction4 = sprite:get_direction()
  sprite:set_direction((direction4 + 2) % 4)

  local hero = self:get_map():get_hero()
  if recent_obstacle == 0 and self:is_in_same_region(hero) then
    sol.audio.play_sound("sword_tapping")
  end

  recent_obstacle = 8
  self:restart()
end

function enemy:on_position_changed()

  if recent_obstacle > 0 then
    recent_obstacle = recent_obstacle - 1
  end
end

--Le dommage de l'ennemi sera de 4, quelle que soit la défense
function enemy:on_attacking_hero(hero, enemy_sprite)
	enemy:get_game():remove_life(3)
  hero:start_hurt(enemy, 1)
end