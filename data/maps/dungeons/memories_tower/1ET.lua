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


--DEBUT DE LA MAP
function map:on_started()
  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)
  map:set_doors_open("auto_door_2_back")
  freezor_enemy:set_enabled(false)

  --Clé 1 obtenue
  if game:get_value("key_300_8") then auto_chest_key_1:set_enabled(true) end

  --Mur déjà déplacé
  if game:get_value("dungeon_300_sliding_wall") then
    map:set_entities_enabled("sliding_wall",false)
    for torch in map:get_entities("torch_sliding_wall") do torch:set_lit(true) end
  else map:set_entities_enabled("after_slide",false) end

  -- Dalles piégées
  map:set_entities_enabled("evil_tile_", false)
  map:set_doors_open("evil_tiles_door", true)
end

--PORTES OUVERTES: COMBATS/SWITCHES
if game:get_value("door_300_13") then sensor_falling_auto_door_2_back:set_enabled(false) end

--REVEIL DU FREEZOR
function freezor_sensor:on_activated()
  freezor_sensor:set_enabled(false)
  sol.audio.play_sound("enemy_awake")
  local x, y = freezor_statue:get_position()
  local i = 0
  local j = false
  sol.timer.start(map,50,function()
    i = i + 1
    if j then x = x + 1 j = false else x = x - 1 j = true end
    freezor_statue:set_position(x, y)
    if i < 20 then return true end
    freezor_statue:set_enabled(false)
    freezor_enemy:set_enabled(true)
  end)
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

--ALLUMER TORCHES POUR DEPLACER LE MUR
local lit_torch = 0
for torch in map:get_entities("torch_sliding_wall") do
  function torch:on_lit()
    lit_torch = lit_torch + 1
    if lit_torch == 4 then
      sol.audio.play_sound("correct")
      map:move_camera(2240,540,256,function() 
        local sliding_wall_1_x, sliding_wall_1_y = map:get_entity("sliding_wall_1"):get_position()
        local sliding_wall_2_x, sliding_wall_2_y = map:get_entity("sliding_wall_2"):get_position()
        local sliding_wall_3_x, sliding_wall_3_y = map:get_entity("sliding_wall_3"):get_position()
        local sliding_wall_4_x, sliding_wall_4_y = map:get_entity("sliding_wall_4"):get_position()
        local i = 0
        local camera = map:get_camera()
        local shake_config = {
          count = 310,
          amplitude = 2,
        }
        camera:shake(shake_config)
        sol.timer.start(map,70,function()
          sol.audio.play_sound("hero_pushes")
          i = i + 1
          sliding_wall_1_x = sliding_wall_1_x - 1
          sliding_wall_2_x = sliding_wall_2_x - 1
          sliding_wall_3_x = sliding_wall_3_x - 1
          sliding_wall_4_x = sliding_wall_4_x - 1
          sliding_wall_1:set_position(sliding_wall_1_x, sliding_wall_1_y)
          sliding_wall_2:set_position(sliding_wall_2_x, sliding_wall_2_y)
          sliding_wall_3:set_position(sliding_wall_3_x, sliding_wall_3_y)
          sliding_wall_4:set_position(sliding_wall_4_x, sliding_wall_4_y)
          if i < 176 then return true end
          sol.audio.play_sound("secret")
          map:set_entities_enabled("after_slide",true)
          game:set_value("dungeon_300_sliding_wall",true)
        end)
      end,1000,14000)     
    end
  end
end

--CHANGEMENTS DE TILESET
function tileset_desert_sensor:on_activated() map:set_tileset("Absolute Dungeon 05")end
function tileset_ice_sensor:on_activated() map:set_tileset("Absolute Dungeon 11")end