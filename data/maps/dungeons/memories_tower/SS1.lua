local map = ...
local game = map:get_game()
local music_map = map:get_music()

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local chest_manager = require("maps/lib/chest_manager")
chest_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

local init_evil_tiles = sol.main.load_file("maps/lib/evil_tiles")
init_evil_tiles(map)
local init_falling_tiles = sol.main.load_file("maps/lib/falling_tiles")
init_falling_tiles(map)


--DEBUT DE LA MAP
function map:on_started(destination)
  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)  
  map:set_doors_open("auto_door_1")

  if destination == escalier_est then map:set_tileset("Absolute Dungeon 06") end

	map:set_entities_enabled("waterfall",false)

  --Clé 1 obtenue
  if game:get_value("key_300_4") then auto_chest_key_1:set_enabled(true) end

  -- Dalles piégées
  map:set_entities_enabled("evil_tile_", false)
  map:set_doors_open("evil_tiles_door", true)

  -- Dalles qui tombent
  map:set_entities_enabled("falling_tile_", false)
end

--CHANGEMENTS DE TILESET
function tileset_grey_sensor:on_activated() map:set_tileset("Absolute Dungeon 12")end
function tileset_grey_sensor_2:on_activated() map:set_tileset("Absolute Dungeon 12")end
function tileset_blue_sensor:on_activated() map:set_tileset("Absolute Dungeon 02")end
function tileset_blue_sensor_2:on_activated() map:set_tileset("Absolute Dungeon 02")end

--DALLES PIEGEES
for sensor in map:get_entities("evil_tiles_sensor") do
  function sensor:on_activated()
    map:set_entities_enabled("evil_tiles_sensor",false)
    if evil_tiles_door_1:is_open() and evil_tile_enemy_1 ~= nil then
      map:close_doors("evil_tiles_door")
      sol.timer.start(2000, function()
        map:start_evil_tiles()
      end)
    end
  end
end
function map:finish_evil_tiles()
  sol.audio.play_sound("secret")
  map:open_doors("evil_tiles_door")
end

--DALLES QUI TOMBENT
for sensor in map:get_entities("falling_tiles_sensor") do
  function sensor:on_activated()
    map:set_entities_enabled("falling_tiles_sensor",false)
    sol.timer.start(5000, function()
      map:start_falling_tiles()
    end)
  end
end

--BASSIN
function switch_waterfall_1:on_activated()
  hero:freeze()
  sol.audio.play_sound("water_fill")
  sol.timer.start(1000,function()
    map:set_entities_enabled("waterfall_1_1",true)
    sol.timer.start(1000,function()
      map:set_entities_enabled("waterfall_1_2",true)
      sol.timer.start(1000,function()
        map:set_entities_enabled("waterfall_1_3",true)
        sol.audio.play_sound("secret")
        hero:unfreeze()
      end)
    end)
  end)
end

--TUYAUX
local path
function pipe_travel()
  local m = sol.movement.create("path")
  m:set_path(path)
  m:set_speed(192)
  m:set_ignore_obstacles(true) 
  map:set_entities_enabled("pipe",false)
  sol.audio.play_sound("pipe")
  hero:freeze()
  hero:set_visible(false)
  m:start(hero,function()
    map:set_entities_enabled("pipe",true)
    sol.audio.play_sound("pipe")
    hero:unfreeze()
    hero:set_visible(true)
  end)
end

function pipe_1_1:on_activated()
  hero:set_direction(1)
  path = {6,6,6,6,6,6,6,6,6,6,4,4,4,4,4,4,4,4,4,4,4,4,4,4,6,6,6,6,6,6,6,6,6,6,6,6,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,2,2,2,2,2,2,2,2,2,2,2,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,2,2,2,2,2,2,2,2,2,2,2}
  pipe_travel()
end
function pipe_1_2:on_activated()
  hero:set_direction(1)
  path = {6,6,6,6,6,6,6,6,6,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,6,6,6,6,6,6,6,6,6,6,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2}
  pipe_travel()
end
function pipe_2_1:on_activated()
  hero:set_direction(1)
  path = {4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,2,2,2,2,2,2,2,2,2}
  pipe_travel()
end
function pipe_2_2:on_activated()
  hero:set_direction(0)
  path = {6,6,6,6,6,6,6,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
  pipe_travel()
end
function pipe_3_1:on_activated()
  hero:set_direction(2)
  path = {6,6,6,6,6,6,6,6,6,6,6,6,4,4,4,4,4,4,4,4,4,4,4,4,6,6,6,6,6,6,6,6,6,6,6,6,4,4,4,4,4,4,4,4,4,4,6,6,6,6,6,6,6,6,6,6,6,6,6,6,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4}
  pipe_travel()
end
function pipe_3_2:on_activated()
  hero:set_direction(1)
  path = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2}
  pipe_travel()
end
function pipe_4_1:on_activated()
  hero:set_direction(3)
  path = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,6,6,6,6,6,6,6,6,6,6,6,6}
  pipe_travel()
end
function pipe_4_2:on_activated()
  hero:set_direction(2)
  path = {2,2,2,2,2,2,2,2,2,2,4,4,4,4,4,4,4,4,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4}
  pipe_travel()
end
function pipe_5_1:on_activated()
  hero:set_direction(2)
  path = {4,4,4,4,4,4,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,4,4,4,4,4,4,4,4,4,4,4,2,2,2,2,2,2,2,2,4,4,4,4,4,4,4,4,4,4,4,4,4,4}
  pipe_travel()
end
function pipe_5_2:on_activated()
  hero:set_direction(0)
  path = {0,0,0,0,0,0,0,0,0,0,0,0,6,6,6,6,6,6,6,6,0,0,0,0,0,0,0,0,0,0,0,0,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,0,0,0,0,0,0,0,0}
  pipe_travel()
end

--YEUX LASERS
local laser_eye_1_repeat
local laser_eye_2_repeat
function eye_1_sensor:on_activated()
  laser_eye_1_repeat = true
  local x,y,layer = eye_1:get_position()
  eye_1:get_sprite():set_animation("opened")
  sol.timer.start(150,function()
    sol.audio.play_sound("laser")
    map:create_enemy({
      layer = layer,
      x = x,
      y = y + 8,
      direction = 3,
      breed = "eye_laser",
    })
    sol.timer.start(500,function()
      sol.audio.play_sound("laser")
      map:create_enemy({
        layer = layer,
        x = x,
        y = y + 8,
        direction = 3,
        breed = "eye_laser",
      })
      if laser_eye_1_repeat then return true end
    end)
  end)
end
function eye_1_sensor_closed_1:on_activated()
  eye_1:get_sprite():set_animation("closed")
  laser_eye_1_repeat = false
end
function eye_1_sensor_closed_2:on_activated()
  eye_1:get_sprite():set_animation("closed")
  laser_eye_1_repeat = false
end
function eye_2_sensor:on_activated()
  laser_eye_2_repeat = true
  local x,y,layer = eye_2:get_position()
  eye_2:get_sprite():set_animation("opened")
  sol.timer.start(150,function()
    sol.audio.play_sound("laser")
    map:create_enemy({
      layer = layer,
      x = x,
      y = y + 8,
      direction = 3,
      breed = "eye_laser",
    })
    sol.timer.start(500,function()
      sol.audio.play_sound("laser")
      map:create_enemy({
        layer = layer,
        x = x,
        y = y + 8,
        direction = 3,
        breed = "eye_laser",
      })
      if laser_eye_2_repeat then return true end
    end)
  end)
end
function eye_2_sensor_closed_1:on_activated()
  eye_2:get_sprite():set_animation("closed")
  laser_eye_2_repeat = false
end
function eye_2_sensor_closed_2:on_activated()
  eye_2:get_sprite():set_animation("closed")
  laser_eye_2_repeat = false
end