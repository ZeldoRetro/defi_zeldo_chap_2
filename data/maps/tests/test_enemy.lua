local map = ...
local game = map:get_game()

local init_evil_tiles = sol.main.load_file("maps/lib/evil_tiles")
init_evil_tiles(map)

local init_falling_tiles = sol.main.load_file("maps/lib/falling_tiles")
init_falling_tiles(map)

local cannonball_manager = require("maps/lib/cannonball_manager")
cannonball_manager:create_cannons(map, "cannon_")

function switch_knight_chain_and_ball:on_activated()
  knight_chain_and_ball:set_enabled(true)
end

--DEBUT DE LA MAP
function map:on_started()
  --Enemis et entités invisibles
  for entity in map:get_entities("invisible_path") do
	 entity:set_visible(false)
  end
  for entity in map:get_entities("invisible_enemy") do
  	entity:set_visible(false)
  end

  knight_chain_and_ball:set_enabled(false)

  -- Dalles piégées
  map:set_entities_enabled("evil_tile_", false)
  map:set_doors_open("evil_tiles_door", true)

  -- Dalles qui tombent
  map:set_entities_enabled("falling_tile_", false)
end

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

--YEUX LASERS
local laser_eye_1_repeat
local laser_eye_2_repeat
local laser_eye_3_repeat
local laser_eye_4_repeat
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
      x = x + 16,
      y = y - 5,
      direction = 0,
      breed = "eye_laser",
    })
    sol.timer.start(500,function()
      sol.audio.play_sound("laser")
      map:create_enemy({
        layer = layer,
        x = x + 16,
        y = y - 5,
        direction = 0,
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
function eye_3_sensor:on_activated()
  laser_eye_3_repeat = true
  local x,y,layer = eye_3:get_position()
  eye_3:get_sprite():set_animation("opened")
  sol.timer.start(150,function()
    sol.audio.play_sound("laser")
    map:create_enemy({
      layer = layer,
      x = x,
      y = y - 16,
      direction = 1,
      breed = "eye_laser",
    })
    sol.timer.start(500,function()
      sol.audio.play_sound("laser")
      map:create_enemy({
        layer = layer,
        x = x,
        y = y - 16,
        direction = 1,
        breed = "eye_laser",
      })
      if laser_eye_3_repeat then return true end
    end)
  end)
end
function eye_3_sensor_closed_1:on_activated()
  eye_3:get_sprite():set_animation("closed")
  laser_eye_3_repeat = false
end
function eye_3_sensor_closed_2:on_activated()
  eye_3:get_sprite():set_animation("closed")
  laser_eye_3_repeat = false
end
function eye_4_sensor:on_activated()
  laser_eye_4_repeat = true
  local x,y,layer = eye_4:get_position()
  eye_4:get_sprite():set_animation("opened")
  sol.timer.start(150,function()
    sol.audio.play_sound("laser")
    map:create_enemy({
      layer = layer,
      x = x - 16,
      y = y - 5,
      direction = 2,
      breed = "eye_laser",
    })
    sol.timer.start(500,function()
      sol.audio.play_sound("laser")
      map:create_enemy({
        layer = layer,
        x = x - 16,
        y = y - 5,
        direction = 2,
        breed = "eye_laser",
      })
      if laser_eye_4_repeat then return true end
    end)
  end)
end
function eye_4_sensor_closed_1:on_activated()
  eye_4:get_sprite():set_animation("closed")
  laser_eye_4_repeat = false
end
function eye_4_sensor_closed_2:on_activated()
  eye_4:get_sprite():set_animation("closed")
  laser_eye_4_repeat = false
end