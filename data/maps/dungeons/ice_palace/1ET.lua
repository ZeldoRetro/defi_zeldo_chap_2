local map = ...
local game = map:get_game()
local music_map = map:get_music()
texte_lieu = sol.surface.create(sol.language.get_language().."/texte_lieu/ice_palace.png")

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local chest_manager = require("maps/lib/chest_manager")
chest_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)


--DEBUT DE LA MAP
function map:on_started()
  --Pendant la journée, lumière qui sort des fenètres/portes d'entrée
  if game:get_value("night") or game:get_value("dawn") then
    --Jour/Crépuscule
    map:set_entities_enabled("day_entity",false)
  end
  --Initialisation de base
  map:set_entities_enabled("auto_chest",false)
  auto_enemy_auto_door_6:set_enabled(false)
  freezor_enemy_2:set_enabled(false)
  map:set_entities_enabled("hidden_power_moon_",false)

  --Enigmes blocs de glace faites
  if game:get_value("key_102_1") then block_ice_1:set_enabled(false) end
  if game:get_value("key_102_3") then block_ice_2:set_enabled(false) end

  --Sol fissuré
  if map:get_game():get_value("weak_floor_102") then
    weak_floor:set_enabled(false)
    weak_floor_sensor:set_enabled(false)
  end
end

--TOMBER RAMENE A L'ETAGE DU DESSOUS
local fall_floor_below = true
function hero:on_state_changed(state)
  if state == "falling" and fall_floor_below == true then
    local hero=game:get_hero()
    local ground=hero:get_ground_below()
    fall_floor_below = false
    --game:set_value("tp_destination", teletransporter:get_destination_name())
    game:set_value("tp_ground", ground) --save last ground for the ceiling drop manager
    sol.timer.start(map,750,function() game:add_life(2) hero:teleport("dungeons/ice_palace/RDC","_same") end) 
  end
end

function map:on_finished()
  local game = self:get_game()
  texte_lieu_on = false
  nb_torches_lit = 0
  temporary_torches = false
  fall_floor_below = false
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

--CLE 1
function switch_block_ice_1:on_activated()
  sol.timer.start(map,500,function()
    if switch_block_ice_1:is_activated() then
      local x = 800
      if block_ice_1:get_position() == x then
        hero:freeze()
        sol.audio.play_sound("ice_melt")
        sol.timer.start(map,1000,function()
          hero:unfreeze()
          block_ice_1:set_enabled(false)
          sol.audio.play_sound("secret")
          local x, y = map:get_entity("block_ice_1"):get_position()
          self:get_map():create_pickable{
            treasure_name = "dungeons/small_key",
            treasure_variant = 1,
            treasure_savegame_variable = "key_102_1",
            x = x,
            y = y,
            layer = 1
          }
        end)
      end
    end
  end)
end
--CLE 3
function switch_block_ice_2:on_activated()
  sol.timer.start(map,500,function()
    if switch_block_ice_2:is_activated() then
      local x = 800
      if block_ice_2:get_position() == x then
        hero:freeze()
        sol.audio.play_sound("ice_melt")
        sol.timer.start(map,1000,function()
          hero:unfreeze()
          block_ice_2:set_enabled(false)
          sol.audio.play_sound("secret")
          local x, y = map:get_entity("block_ice_2"):get_position()
          self:get_map():create_pickable{
            treasure_name = "dungeons/small_key",
            treasure_variant = 1,
            treasure_savegame_variable = "key_102_3",
            x = x,
            y = y,
            layer = 1
          }
        end)
      end
    end
  end)
end

--SOL FISSURE
function weak_floor_sensor:on_collision_explosion()
  if weak_floor:is_enabled() then
    weak_floor:set_enabled(false)
    weak_floor_sensor:set_enabled(false)
    sol.audio.play_sound("secret")
    map:get_game():set_value("weak_floor_102", true)
  end
end

--SALLE SECRETE: SON DE SECRET
function secret_separator:on_activating(direction4)
  if direction4 == 0 then sol.audio.play_sound("secret") end
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
    auto_enemy_auto_door_6:set_enabled(true)
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
    if j then x = x + 1 j = false else x = x - 1 j = true end
    freezor_statue_2:set_position(x, y)
    if i < 20 then return true end
    freezor_statue_2:set_enabled(false)
    freezor_enemy_2:set_enabled(true)
  end)
end

--LUNES DE PUISSANCE CACHEES
function destructible_power_moon_1:on_cut() sol.timer.start(map,300,function() 
  if hidden_power_moon_4 ~= nil then hidden_power_moon_4:set_enabled(true) end 
end) end
function destructible_power_moon_1:on_lifting() 
  if hidden_power_moon_4 ~= nil then hidden_power_moon_4:set_enabled(true) end
end