-- Lua script of enemy moldorm.
-- This script is executed every time an enemy with this model is created.

-- Variables
local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprites_folder = "enemies/boss/" -- Rename this if necessary.
local body_parts = {} -- In this order: head, body_1, body_2, body_3, tail.
local normal_angle_speed, max_angle_speed = math.pi/2, math.pi -- Radians per second.
local life = 12
local min_radius, max_radius = 24, 80
local hurt_duration = 2000
local delay_between_parts = 120
local is_hurt, is_reattaching, found_obtacle

-- Include scripts
require("scripts/multi_events")

-- Event called when the enemy is initialized.
function enemy:on_created()

  -- Check the number of parts already created (by recurrence).
  local exists = map.moldorm_tail_exists
  if exists then return end -- Exit function.
  map.moldorm_tail_exists = true

  -- Define tail properties.
  local x, y, layer = enemy:get_position()
  local sprite = enemy:create_sprite(sprites_folder .. "moldorm")
  sprite:set_direction(3)
  body_parts[6] = enemy
  
  -- Create remaining body parts.
  for i = 1, 5 do  
    local e = map:create_enemy({
      breed = enemy:get_breed(),
      direction = 3,  x = x, y = y, layer = layer, width = 32, height = 32,
    })
    body_parts[i] = e
    e:set_invincible()
    e:clear_movement_info() -- Prepare lists.
  end

  -- Clear variable after body parts creation (necessary for several Moldorms).
  map.moldorm_tail_exists = nil
  -- Create sprites. Part 5 is spriteless, used to move the tail,
  -- so that the tail keeps its current movement even when restarted.
  local body_names = {"head", "body_1", "body_2", "body_3"}
  for i = 1, 4 do 
    body_parts[i]:create_sprite(sprites_folder .. "moldorm_" .. body_names[i])
  end
  local head = body_parts[1]
  local tail = body_parts[6]
  -- Prepare head.
  head:bring_to_front() -- Bring head to front.
  head:get_sprite():set_direction(6)
  -- Draw parts in correct order.
  for i = 1, 6 do local e = body_parts[i]; e:set_drawn_in_y_order(false) end
  for i = 2, 6 do local e = body_parts[i]; e:bring_to_back() end

  for i = 1, 6 do
    local e = body_parts[i]
    -- Define general properties.
    e:set_damage(8)
    e:set_life(life)
    e:set_hurt_style("boss")
    e:set_pushed_back_when_hurt(false)
    e:set_push_hero_on_sword(true)
    e:set_obstacle_behavior("normal")
    if i < 5 then e:set_attack_consequence("sword", "protected") end
  end

  -- Add index and parts getters.
  for i = 1, 6 do
    local e = body_parts[i]
    function e:get_index() return i end
    function e:get_body_part(i) return body_parts[i] end
    function e:get_head() return body_parts[1] end
    function e:get_tail() return body_parts[6] end
    function e:get_invisible_part() return body_parts[5] end
  end

  -- If some enemy part restarts, it breaks and needs to reattach.
  for i = 1, 5 do
    local e = body_parts[i]
    function e:on_restarted()
      if not e:is_reattaching() then e:reattach() end
    end
  end

  -- Kill invincible parts when tail is killed.
  function tail:on_dying()
    for i = 1, 6 do -- Stop all body parts.
      e = tail:get_body_part(i)
      e:stop_movement(); sol.timer.stop_all(e)
      e:set_life(0)
    end
    tail:get_invisible_part():remove()
    map:set_entities_enabled("moldorm_hole",false)
    map:set_entities_enabled("carpet",true)
    game:set_value("boss_rush_300",true)
    hero:freeze()
    game:set_pause_allowed(false)
    sol.audio.play_music(nil)
    sol.timer.start(6000,function()
      local movement = sol.movement.create("target")
      movement:set_target(map:get_entity("front_zeldo_2"):get_position())
      movement:set_speed(88)
      hero:set_direction(1)
      hero:get_sprite():set_animation("walking_with_shield")
      movement:start(hero,function()
        hero:get_sprite():set_animation("stopped")
        game:start_dialog("zeldo.boss_rush.boss_rush_end",function()
          map:get_entity("zeldo"):get_sprite():set_animation("spell")
          sol.audio.play_sound("boss_charge")
          game:start_dialog("zeldo.boss_rush.spell_firewall_remove",function()
            sol.audio.play_sound("lamp")
            map:set_entities_enabled("fire_wall",false)
            map:get_entity("zeldo"):get_sprite():set_animation("stopped")
            sol.timer.start(1000,function()
              game:start_dialog("zeldo.boss_rush.true_follow",function()
                local movement = sol.movement.create("straight")
                movement:set_angle(math.pi / 2)
                movement:set_max_distance(128)
                movement:set_speed(88)
                movement:set_ignore_obstacles()
                movement:start(map:get_entity("zeldo"))
                hero:unfreeze()
                game:set_pause_allowed(true)
              end)
            end)
          end)
        end)
      end)
    end)
  end

  -- Synchronize sprites with tail sprite.
  function sprite:on_animation_changed(anim)
    for i = 1, 4 do
      local e = body_parts[i]
      for _, s in e:get_sprites() do s:set_animation(anim) end
    end
  end

  -- Start movement.
  tail:go_random()
  
end

-- Getter/setter for hurt state.
function enemy:is_hurt()
  
  return is_hurt
  
end

function enemy:set_hurt_state(hurt)
  
  is_hurt = hurt
  -- Tail part: invincibility properties.
  if enemy == enemy:get_tail() then
    if enemy:is_hurt() then
      enemy:set_invincible() -- Protection!
    else
      enemy:set_default_attack_consequences()
    end
  end
  -- Modify speed of current movement for all body parts.
  local m = enemy:get_movement()
  if m and sol.main.get_type(m) == "circle_movement" then
    if enemy:is_hurt() then
      m:set_angular_speed(max_angle_speed)
    else -- Not hurt.
      m:set_angular_speed(normal_angle_speed)
    end
  end
  
end

-- Attaching state.
function enemy:is_reattaching()
  
  return is_reattaching
  
end

function enemy:set_reattaching_state(state) is_reattaching = state end

-- Stop movements and timers only on head when the tail is hurt.
enemy:register_event("on_hurt", function()
  -- Start hurt states.
  for i = 1, 6 do
    local e = enemy:get_body_part(i)
    e:set_hurt_state(true)
    -- Finish hurt states.
    sol.timer.start(map, hurt_duration, function()
      e:set_hurt_state(false)
    end)
  end
  
end)

-- Create list with new movement info: radius, center, is_clockwise, init_angle, max_angle.
-- Remark: Only the head can call this function.
function enemy:create_new_movement_info()
  
  if enemy ~= enemy:get_head() then return end
  -- Create random properties.
  local radius = math.floor(math.random(min_radius, max_radius))
  local max_angle
  if math.random(0, 100) <= 75 then -- Small angle: probability 75%
    max_angle = (math.pi/4) + (math.pi/4) * math.random()
  else -- Big angle: : probability 25%
    max_angle = math.max(1, 2 * math.pi * math.random())
  end
  -- Revert direction if there is an obstacle.
  local reverse_direction = found_obstacle
  found_obstacle = nil -- Clean variable.
  local old_info = enemy:get_current_movement_info()
  local is_clockwise
  if old_info then
    if reverse_direction then -- Obstacle found.
      is_clockwise = old_info.is_clockwise
    else -- No obstacle found.
      is_clockwise = (not old_info.is_clockwise)
    end
  else is_clockwise = math.random(0,1) == 1 end
  -- Calculate current angle from current center.
  local x, y, layer = enemy:get_position()
  local current_angle_center
  if old_info then
    local current_center = old_info.center
    current_angle_center = sol.main.get_angle(current_center.x, current_center.y, x, y)
  else -- Random angle.
    current_angle_center = 2 * math.pi * math.random()
  end
  -- Calculate new init angle and new center.
  local init_angle = current_angle_center + math.pi
  -- Calculate new center.
  local center = {x = x + radius * math.cos(current_angle_center),
                  y = y - radius * math.sin(current_angle_center)}
  -- Return info.
  local info = {
    radius = radius, center = center, is_clockwise = is_clockwise,
    init_angle = init_angle, max_angle = max_angle
  }
  return info
  
end

-- Create a movement with the info.
function enemy:start_movement(info)
  
  local m = sol.movement.create("circle")
  m:set_radius(info.radius)
  m:set_center(info.center.x, info.center.y)
  m:set_clockwise(info.is_clockwise)
  m:set_angle_from_center(info.init_angle)
  m:set_max_rotations(0)
  if enemy:is_hurt() then m:set_angular_speed(max_angle_speed)
  else m:set_angular_speed(normal_angle_speed) end
  m:start(enemy)
  
end

-- Add next movement to the movement list.
function enemy:add_next_movement_info(info)
  
  local list = enemy.movement_list
  list[#list + 1] = info
  
end

-- Check if there is next movement in the movement list.
function enemy:has_next_movement_info()
  
  local list = enemy.movement_list
  return #list > 0
  
end

-- Get the info for the current movement.
function enemy:get_current_movement_info()
  
  return enemy.movement_list[1]
  
end

-- Destroy all movements info.
function enemy:clear_movement_info()
  
  enemy.movement_list = {num_positions = {}}
  
end

-- Remove last movement to the movement list.
function enemy:remove_last_movement_info()
  
  if enemy:has_next_movement_info() then
    local list = enemy.movement_list
    for i = 1, #list -1 do
      list[i] = list[i + 1]
    end
    list[#list] = nil
  end
  
end

-- Notify obstacle to reverse direction.
function enemy:notify_obstacle()
  
  local info = enemy:get_current_movement_info()
  found_obstacle = true
  
end

-- Start next movement, if any. If "is_random" is true, use random direction.
function enemy:start_next_movement(is_random)
  enemy:stop_movement() -- Stop previous movement.
  -- If the head needs next movement, create new movement info for all body parts.
  if enemy == enemy:get_head() then
    -- Replace previous info in "head" to get random direction, if necessary.
    if is_random then
      enemy:clear_movement_info()
      local info = enemy:create_new_movement_info()
      enemy:add_next_movement_info(info)
    end
    -- Create new movement info for all body parts.
    local info = enemy:create_new_movement_info()
    for i = 1, 5 do enemy:get_body_part(i):add_next_movement_info(info) end
  end
  -- Destroy old movement info.
  enemy:remove_last_movement_info()
  -- Start next movement if any.
  if enemy:has_next_movement_info() then
    local info = enemy:get_current_movement_info()
    enemy:start_movement(info)
  end
end

-- Create new movement in random direction when reaching obstacles.
function enemy:on_obstacle_reached(movement)
  if enemy ~= enemy:get_tail() then
    enemy:notify_obstacle()
    enemy:start_next_movement(true) -- Start next movement.
  end
end

-- Initialize a new random sequence of movements.
function enemy:go_random()
  local head = enemy:get_head()
  head:clear_movement_info() -- Clear info of previous iterations.
  local info = head:create_new_movement_info()
  for i = 1, 6 do
    local e = enemy:get_body_part(i)
    e:stop_movement(); sol.timer.stop_all(e)
  end
  for i = 1, 5 do
    local e = enemy:get_body_part(i)
    e:clear_movement_info()
    e:add_next_movement_info(info) -- This is removed in first iteration.
    sol.timer.start(map, 500 + i * delay_between_parts, function()
      e:start_next_movement()
    end)
  end
end

-- Check if the current movement has to be finished.
function enemy:on_position_changed(x, y, layer)
  enemy:get_head():bring_to_front() -- Bring head to front.
  -- Do nothing for the tail.
  if enemy == enemy:get_tail() then return end
  -- Move tail when the invisible part moves. This avoids tail stopping when hurt.
  if enemy == enemy:get_invisible_part() then
    enemy:get_tail():set_position(x, y, layer)
  end
  -- Do nothing if enemy is reattaching.
  if enemy:is_reattaching() then return end
  -- Count the position changes. This is used to check when to stop.
  local info = enemy:get_current_movement_info()
  info.num_positions = info.num_positions or {}
  local pos = info.num_positions
  local index = enemy:get_index()
  pos[index] = pos[index] and (pos[index] + 1) or 0
  local num_pos = pos[index]
  -- Calculate the differences of angles.
  local cx, cy = info.center.x, info.center.y
  local x, y, _ = enemy:get_position()
  local current_angle = sol.main.get_angle(cx, cy, x, y)
  local final_diff = info.max_angle % (2 * math.pi)
  local current_diff = (current_angle - info.init_angle) % (2 * math.pi)
  -- Stop if necessary, when the final angle is surpassed. Then start new movement.
  if current_diff >= final_diff and pos[index] > 0 then
    enemy:start_next_movement()
  end
  -- If the fore/back body part is too far (enemy broken), reattach it.
  if (not enemy:is_reattaching()) and enemy:get_index() > 1 then
    local fore_part = enemy:get_body_part(index - 1)
    local back_part = enemy:get_body_part(index + 1)
    if enemy:get_distance(fore_part) > 24 or enemy:get_distance(back_part) > 24 then
      enemy:reattach()
    end
  end
  -- Update direction for head sprite.
  if enemy == enemy:get_head() then
    local sign = info.is_clockwise and -1 or 1
    local dir = (enemy:get_direction8_to(cx, cy) - sign * 2) % 8
    enemy:get_sprite():set_direction(dir)
  end
end

-- Reattach all parts if the enemy breaks (when some part restarts or loses its movements).
function enemy:reattach()
  if enemy:is_reattaching() then return end -- Do nothing if already reattaching.
  -- Attach all parts.
  for i = 1, 6 do
    e = enemy:get_body_part(i)
    e:set_reattaching_state(true)
    e:stop_movement(); sol.timer.stop_all(e)
    if i ~= 6 then e:clear_movement_info() end
    if i > 1 then
      local m = sol.movement.create("target")
      m:set_ignore_obstacles(true)
      m:set_speed(120)
      m:set_target(enemy:get_head())
      m:start(e)
    end
  end
  -- Restart normal behavior.
  sol.timer.start(map, 2000, function()
    for i = 1, 6 do enemy:get_body_part(i):set_reattaching_state(false) end
    enemy:get_head():go_random()
  end)
end
