local map = ...
local game = map:get_game()
local music_map = map:get_music()
texte_lieu = sol.surface.create(sol.language.get_language().."/texte_lieu/ice_palace.png")
texte_boss = sol.surface.create(sol.language.get_language().."/texte_boss/kholdstare.png")

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local chest_manager = require("maps/lib/chest_manager")
chest_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)


--DEBUT DE LA MAP
function map:on_started()
  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)
  texte_boss_1:set_enabled(false)
  freezor_enemy_1:set_enabled(false)
  freezor_enemy_2:set_enabled(false)
  freezor_enemy_3:set_enabled(false)
  freezor_enemy_4:set_enabled(false)
  freezor_enemy_5:set_enabled(false)
  freezor_enemy_6:set_enabled(false)

  --Sol fissuré
  if map:get_game():get_value("weak_floor_102") then
    map:set_entities_enabled("switch_block_ice_1",true)
  else map:set_entities_enabled("switch_block_ice_1",false) end

  --Enigme clé de boss
  if game:get_value("boss_key_102") then block_ice_1:set_enabled(false) end

  --Boss vaincu
  if game:get_value("boss_102") then
    sensor_boss:set_enabled(false)
    map:set_doors_open("door_boss")
  else map:set_doors_open("door_boss_1") boss:set_enabled(false) end
end

--BLOCS DE GLACE
local function block_on_moved_ice(block)
  hero:unfreeze()
  local x, y, layer = block:get_position()
  -- Create a wall to prevent the hero from overlapping the block
  -- when it moves alone.
  local wall = map:create_wall({
    x = x - 8,
    y = y - 13,
    layer = layer,
    width = 16,
    height = 16,
    stops_hero = true,
    stops_blocks = false,
  })
  -- Move the block towards the next obstacle.
  local direction4 = hero:get_direction()
  local movement = sol.movement.create("straight")
  movement:set_speed(64)
  movement:set_angle(direction4 * math.pi / 2)
  movement:start(block)
  -- Stop the movement when reaching an obstacle.
  function movement:on_obstacle_reached()
    block:stop_movement()
    wall:remove()
  end
  -- Keep the wall in the block.
  function movement:on_position_changed()
    local x, y = block:get_position()
    wall:set_position(x - 8, y - 13)
  end
end
for block in map:get_entities("block_ice") do
  block.on_moved = block_on_moved_ice
end

--CLE DU BOSS
function switch_block_ice_1:on_activated()
  sol.timer.start(map,500,function()
    if switch_block_ice_1:is_activated() then
      local x = 496
      if block_ice_1:get_position() == x then
        hero:freeze()
        sol.audio.play_sound("ice_melt")
        sol.timer.start(map,1000,function()
          hero:unfreeze()
          block_ice_1:set_enabled(false)
          sol.audio.play_sound("secret")
          local x, y = map:get_entity("block_ice_1"):get_position()
          self:get_map():create_pickable{
            treasure_name = "dungeons/boss_key",
            treasure_variant = 1,
            treasure_savegame_variable = "boss_key_102",
            x = x,
            y = y,
            layer = 1
          }
        end)
      end
    end
  end)
end

--REVEIL DES FREEZORS
function freezor_sensor_1:on_activated()
  freezor_sensor_1:set_enabled(false)
  sol.audio.play_sound("enemy_awake")
  local x, y = freezor_statue_1:get_position()
  local i = 0
  local j = false
  sol.timer.start(map,50,function()
    i = i + 1
    if j then x = x + 1 j = false else x = x - 1 j = true end
    freezor_statue_1:set_position(x, y)
    if i < 20 then return true end
    freezor_statue_1:set_enabled(false)
    freezor_enemy_1:set_enabled(true)
  end)
end
function freezor_sensor_2:on_activated()
  freezor_sensor_2:set_enabled(false)
  sol.audio.play_sound("enemy_awake")
  local x, y = freezor_statue_2:get_position()
  local i = 0
  local j = false
  sol.timer.start(map,50,function()
    i = i + 1
    if j then y = y + 1 j = false else y = y - 1 j = true end
    freezor_statue_2:set_position(x, y)
    if i < 20 then return true end
    freezor_statue_2:set_enabled(false)
    freezor_enemy_2:set_enabled(true)
  end)
end
function freezor_sensor_3:on_activated()
  freezor_sensor_3:set_enabled(false)
  sol.audio.play_sound("enemy_awake")
  local x, y = freezor_statue_3:get_position()
  local i = 0
  local j = false
  sol.timer.start(map,50,function()
    i = i + 1
    if j then y = y + 1 j = false else y = y - 1 j = true end
    freezor_statue_3:set_position(x, y)
    if i < 20 then return true end
    freezor_statue_3:set_enabled(false)
    freezor_enemy_3:set_enabled(true)
  end)
end
function freezor_sensor_4:on_activated()
  freezor_sensor_4:set_enabled(false)
  sol.audio.play_sound("enemy_awake")
  local x, y = freezor_statue_4:get_position()
  local i = 0
  local j = false
  sol.timer.start(map,50,function()
    i = i + 1
    if j then x = x + 1 j = false else x = x - 1 j = true end
    freezor_statue_4:set_position(x, y)
    if i < 20 then return true end
    freezor_statue_4:set_enabled(false)
    freezor_enemy_4:set_enabled(true)
  end)
end
function freezor_sensor_5:on_activated()
  freezor_sensor_5:set_enabled(false)
  sol.audio.play_sound("enemy_awake")
  local x, y = freezor_statue_5:get_position()
  local i = 0
  local j = false
  sol.timer.start(map,50,function()
    i = i + 1
    if j then x = x + 1 j = false else x = x - 1 j = true end
    freezor_statue_5:set_position(x, y)
    if i < 20 then return true end
    freezor_statue_5:set_enabled(false)
    freezor_enemy_5:set_enabled(true)
  end)
end
function freezor_sensor_6:on_activated()
  freezor_sensor_6:set_enabled(false)
  sol.audio.play_sound("enemy_awake")
  local x, y = freezor_statue_6:get_position()
  local i = 0
  local j = false
  sol.timer.start(map,50,function()
    i = i + 1
    if j then x = x + 1 j = false else x = x - 1 j = true end
    freezor_statue_6:set_position(x, y)
    if i < 20 then return true end
    freezor_statue_6:set_enabled(false)
    freezor_enemy_6:set_enabled(true)
  end)
end