-- Initialize sensor behavior specific to this quest.

require("scripts/multi_events")

local sensor_meta = sol.main.get_metatable("sensor")

-- sensor_meta represents the default behavior of all sensors.
function sensor_meta:on_activated()
  -- self is the sensor.
  local hero = self:get_map():get_hero()
  local game = self:get_game()
  local map = self:get_map()
  local name = self:get_name()

  -- Sensors prefixed by "save_solid_ground_sensor" are where the hero come back
  -- when falling into a hole or other bad ground.
  if name:match("^save_solid_ground_sensor") then
    hero:save_solid_ground()
    return
  end
  -- Sensors prefixed by "reset_solid_ground_sensor" clear any place for the hero
  -- to come back when falling into a hole or other bad ground.
  if name:match("^reset_solid_ground_sensor") then
    hero:reset_solid_ground()
    return
  end

  -- Sensors prefixed by "dungeon_room_N" save the exploration state of the
  -- room "N" of the current dungeon floor.
  local room = name:match("^dungeon_room_(%d+)")
  if room ~= nil then
    game:set_explored_dungeon_room(nil, nil, tonumber(room))
    self:remove()
    return
  end

  --Prise en compte des layers et escaliers
  if name:match("^layer_up_sensor") then
    local x, y, layer = hero:get_position()
    if layer < map:get_max_layer() then
      hero:set_position(x, y, layer + 1)
    end
    return
  elseif name:match("^layer_down_sensor") then
    local x, y, layer = hero:get_position()
    if layer > map:get_min_layer() then
      hero:set_position(x, y, layer - 1)
    end
    return
  end

  --Affichage lieu
  local opacity = 1
  local function fade_in()
  	opacity = opacity - 5
  	texte_lieu:set_opacity(opacity)
    if opacity > 0 then
  		sol.timer.start(50,fade_in)
    else
      texte_lieu_on = false
    end
  end
  local function fade_out()
  	opacity = opacity + 5
  	texte_lieu:set_opacity(opacity)
    if opacity < 255 then
  		sol.timer.start(50,fade_out)
    else
      fade_in()
    end
  end
  local function affiche_lieu()
    texte_lieu_on = true
    fade_out()
    map:set_entities_enabled("texte_lieu",false)
  end
  if name:match("^texte_lieu") then
    affiche_lieu()
  end
  --Affichage boss
  local opacity_boss = 1
  local function fade_in_boss()
  	opacity_boss = opacity_boss - 5
  	texte_boss:set_opacity(opacity_boss)
    if opacity_boss > 0 then
  		sol.timer.start(50,fade_in_boss)
    else
      texte_boss_on = false
    end
  end
  local function fade_out_boss()
  	opacity_boss = opacity_boss + 5
  	texte_boss:set_opacity(opacity_boss)
    if opacity_boss < 255 then
  		sol.timer.start(50,fade_out_boss)
    else
      fade_in_boss()
    end
  end
  local function affiche_boss()
    texte_boss_on = true
    fade_out_boss()
    map:set_entities_enabled("texte_boss",false)
  end
  if name:match("^texte_boss") then
    affiche_boss()
  end
  if name:match("^not_texte") then
    map:set_entities_enabled("texte_lieu",false)
  end

  --Sensors qui ferment les portes derrière nous (définitives (ex:passage sens unique) ou temporaire (ex:combat))
  local j = 0
  while j ~= 9 do
    j = j + 1
    if name:match("^sensor_falling_auto_door_"..j) then
      map:set_entities_enabled(name,false)
      map:close_doors("auto_door_"..j)
    end
    --Le héros avance tout seul pour les portes qui se referment définitivement
    if name:match("^sensor_falling_door_"..j) then
      map:close_doors("falling_door_"..j)
    end
    if name:match("^sensor_falling_door_"..j.."_open") then
      map:set_doors_open("falling_door_"..j)
      hero:freeze()
      hero:set_animation("walking")
      local movement = sol.movement.create("straight")
      movement:set_speed(88)
      local angle
      if hero:get_direction() == 0 then angle = 0
      elseif hero:get_direction() == 1 then angle = math.pi / 2
      elseif hero:get_direction() == 2 then angle = math.pi
      elseif hero:get_direction() == 3 then angle = 3 * math.pi / 2 end
      movement:set_angle(angle)
      movement:set_max_distance(56) 
      movement:start(hero) 
      sol.timer.start(600,function() hero:unfreeze() end)
    end
  end

  --Son de secret après certains passages
  if name:match("^sensor_secret") then
    sol.audio.play_sound("secret")
  end  

  --Pas de sons dans certains lieux (ex:avant boss)
  if name:match("^no_sound_sensor") then
    sol.audio.play_music("none")
  end  

  --Son revient une fois sorti du passage sans son
  local music_map = map:get_music()
  if name:match("^sound_sensor") then
    sol.audio.play_music(music_map)
  end

  --Entrée dans pièces de batailles
  if name:match("^sensor_battle") then
    map:close_doors("door_battle")
    hero:freeze()
    sol.audio.stop_music()
    sol.timer.start(1000,function()
      hero:unfreeze()
      sol.audio.play_music("battle")
      map:set_entities_enabled(name,false)
      map:set_entities_enabled("wave_1",true)
    end)
  end

  --Entrée dans pièce de miniboss
  if name:match("^sensor_miniboss") then
      hero:freeze()
      map:close_doors("door_miniboss")
      sol.audio.play_music("none")
      sol.timer.start(1000,function()
        hero:unfreeze()
        map:set_entities_enabled("miniboss",true)
        for enemy in map:get_entities("miniboss") do enemy:set_hurt_style("boss") end
        sol.audio.play_music("miniboss")
        map:set_entities_enabled(name,false)
      end)
  end

  --Entrée dans pièce de Boss
  if name:match("^sensor_boss") then
      hero:freeze()
      map:close_doors("door_boss")
      sol.audio.play_music("none")
      sol.timer.start(1000,function()
        map:get_entity("texte_boss_1"):set_enabled(true)
        hero:unfreeze()
        map:get_entity("boss"):set_enabled(true)
        map:get_entity("boss"):set_hurt_style("boss")
        sol.audio.play_music("boss")
        map:set_entities_enabled(name,false)
        map:get_entity("texte_boss_1"):set_enabled(false)
      end)
  end
end

return true