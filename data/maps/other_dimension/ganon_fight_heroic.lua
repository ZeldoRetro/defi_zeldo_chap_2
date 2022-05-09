local map = ...
local game = map:get_game()

local init_falling_tiles = sol.main.load_file("maps/lib/falling_tiles")
init_falling_tiles(map)

-- DEBUT DE LA MAP
function map:on_started()
  local ground=game:get_value("tp_ground")
  if ground=="hole" then
    hero:set_visible(false)
  else
    hero:set_visible()
  end

  -- Dalles qui tombent
  map:set_entities_enabled("falling_tile_", false)

  if game:get_value("get_triforce") then
    back_to_highrule:set_enabled(true)
    triforce_room:set_enabled(false)
  end
end

function map:on_opening_transition_finished()
  --Effet de chute
  local hero = game:get_hero()
  local ground=game:get_value("tp_ground")
  if ground=="hole" then
    hero:set_invincible()
    hero:set_visible(false)
    hero:fall_from_ceiling(240, nil, function()
        sol.audio.play_sound("hero_lands")
        game:set_value("tp_ground","traversable")
        hero:set_invincible(false)
    end)
  end
  sol.timer.start(map,1500,function()
    game:start_dialog("ganon.intro",function()
      ganon_pnj:set_enabled(false)
      ganon_enemy:set_enabled(true)
      sol.audio.play_music("dimension_ganon_battle")
    end)
  end)
end

--DALLES QUI TOMBENT
for sensor in map:get_entities("falling_tiles_sensor") do
  function sensor:on_activated()
    map:set_entities_enabled("falling_tiles_sensor",false)
    sol.timer.start(10, function()
      map:start_falling_tiles()
    end)
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
    sol.timer.start(map,750,function() game:add_life(2) hero:teleport("other_dimension/pyramid_RDC","_same") end)
  end
end

function map:on_finished()
  local game = self:get_game()
  texte_lieu_on = false
  nb_torches_lit = 0
  temporary_torches = false
  fall_floor_below = false
end

--BOSS VISIBLE SI TOUTES LES LAMPES SONT ALLUMEES
local lit_torch = 0
for torch in map:get_entities("timed_torch_") do
  function torch:on_lit() 
    lit_torch = lit_torch + 1
    if not darkness_1:is_enabled() then darkness_2:set_enabled(false) end
    darkness_1:set_enabled(false)
    sol.timer.start(10000,function() 
      lit_torch = lit_torch - 1
      if darkness_2:is_enabled() then darkness_1:set_enabled(true) end
      darkness_2:set_enabled(true)
    end)
  end
end
function map:on_update()
  if ganon_enemy ~= nil then
    --sol.timer.start(map,10000,function() print(ganon_enemy:get_life()) end)
    if timed_torch_1:is_enabled() then
      if lit_torch == 0 then
        ganon_enemy:set_invincible()
        ganon_enemy:get_sprite():set_opacity(0)
        ganon_enemy:set_can_attack(false)
        ganon_enemy:set_layer(2)
      elseif lit_torch == 1 then
        ganon_enemy:set_invincible()
        ganon_enemy:set_can_attack(false)
        ganon_enemy:set_layer(2)
        ganon_enemy:get_sprite():set_opacity(128)
      else
        ganon_enemy:set_layer(1)
        ganon_enemy:get_sprite():set_opacity(255)
      end
    end
  end
end