--Wizzrobe white: A wizard who shoots magic beams.

local enemy = ...
local map = enemy:get_map()
local children = {}

function enemy:on_created()

  enemy:set_life(8)
  enemy:set_damage(8)
  enemy:set_invincible()
  enemy:create_sprite("enemies/" .. enemy:get_breed())
end

-- Wizzrobe appear
function enemy:appear()

  local sprite = enemy:get_sprite()
  enemy:set_visible(true)
  sprite:fade_in(20, function()
      enemy:set_attack_consequence("sword", 1)
      enemy:set_can_attack(true)
      sol.timer.start(enemy,500, function() enemy:shoot() end)
  end)

end


-- Wizzrobe disappear
function enemy:disappear()

  local hero = enemy:get_map():get_hero()
  local sprite = enemy:get_sprite()
  local direction = enemy:get_direction4_to(hero)
  sprite:set_direction(direction)
  enemy:set_invincible()
  enemy:set_can_attack(false)
  sprite:fade_out(20, function()
      enemy:set_visible(false)
      local m = sol.movement.create("random")
      m:set_speed(144)
      m:start(self)
      sol.timer.start(enemy, math.random(1000,3000), function()
        local direction = enemy:get_direction4_to(hero)
        local sprite = enemy:get_sprite()
        sprite:set_direction(direction)
        m:stop(self)
        enemy:appear()
      end)  
  end)

end

function enemy:shoot()

  local sprite = enemy:get_sprite()
  sprite:set_animation("shoot")
  local x, y, layer = enemy:get_position()
  local direction = sprite:get_direction()

  -- Where to start the beam from.
  local dxy = {
    {  0, -5 },
    {  0, -5 },
    {  0, -5 },
    {  0, -5 },
  }

  local beam = enemy:create_enemy({
    breed = "wizzrobe_beam",
    x = dxy[direction + 1][1],
    y = dxy[direction + 1][2],
  })
  children[#children + 1] = beam

  if not map.wizzrobe_recent_sound then
    sol.audio.play_sound("boss_fireball")
    -- Avoid loudy simultaneous sounds if there are several wizzrobes.
    map.wizzrobe_recent_sound = true
    sol.timer.start(map, 200, function()
      map.wizzrobe_recent_sound = nil
    end)
  end
  beam:go(direction)
  sol.timer.start(enemy, 1000, function()
    sprite:set_animation("stopped")
    enemy:disappear()
  end)  
end

function enemy:on_restarted()
    local sprite = enemy:get_sprite()
    sprite:set_animation("stopped")
    enemy:disappear()
end

local previous_on_removed = enemy.on_removed
function enemy:on_removed()

  if previous_on_removed then
    previous_on_removed(enemy)
  end

  for _, child in ipairs(children) do
    child:remove()
  end
end