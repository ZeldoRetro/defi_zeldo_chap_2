-- Initialize map features specific to this quest.

require("scripts/multi_events")

local map_meta = sol.main.get_metatable("map")
texte_lieu_on = false
texte_boss_on = false

local monicle_img = sol.surface.create("backgrounds/monicle.png")
monicle_img:set_opacity(92)
     
--SYSTEME DE JOUR/NUIT
--Crépuscule (+ aube avec effet soleil levant)
local twilight_surface_yellow = sol.surface.create(320,240)
twilight_surface_yellow:set_blend_mode("add")
twilight_surface_yellow:fill_color({63, 42, 0})
local twilight_surface_red = sol.surface.create(320,240)
twilight_surface_red:set_blend_mode("multiply")
twilight_surface_red:fill_color({255, 173, 226})
--Nuit
local night_surface = sol.surface.create(320,240)
night_surface:set_blend_mode("multiply")
night_surface:fill_color({0, 33, 164})

function map_meta:on_draw(dst_surface)
  local game = self:get_game()
  local hero = self:get_hero()

  --EFFET MONOCLE DE VERITE
  if game:get_value("monicle_active") then
    monicle_img:draw(dst_surface)
  end

  --SYSTEME JOUR/NUIT
  if game:get_map():get_world() == "outside" or game:get_map():get_world() == "outside_2" or game:get_map():get_id() == "dungeons/memories_tower/7ET" then
    if game:get_value("twilight") then twilight_surface_red:draw(dst_surface) twilight_surface_yellow:draw(dst_surface) end
  end


  --AFFICHAGE LIEU
  if texte_lieu_on then texte_lieu:draw(dst_surface) end
  --AFFICHAGE BOSS
  if texte_boss_on then texte_boss:draw(dst_surface) end
end

function map_meta:on_opening_transition_finished()
  local game = self:get_game()
  --Temps qui passe
  if not game:get_value("intro") and game:get_map():get_world() == "outside" then
    sol.timer.start(30000, function() 
      daytime_increment = true 
      sol.audio.play_sound("shield")
    end)
  end

  --Détecteur: Bruit si fragment de Force a proximité
  if game:get_value("get_power_moon_detector") then
    for entity in game:get_map():get_entities("power_moon_") do
      sol.audio.play_sound("detector")
    end
    for entity in game:get_map():get_entities("hidden_power_moon_") do
      sol.audio.play_sound("detector")
    end
  end
end

function map_meta:move_camera(x, y, speed, callback, delay_before, delay_after)

  local camera = self:get_camera()
  local game = self:get_game()
  local hero = self:get_hero()

  delay_before = delay_before or 1000
  delay_after = delay_after or 1000

  local back_x, back_y = camera:get_position_to_track(hero)
  game:set_suspended(true)
  camera:start_manual()

  local movement = sol.movement.create("target")
  movement:set_target(camera:get_position_to_track(x, y))
  movement:set_ignore_obstacles(true)
  movement:set_speed(speed)
  movement:start(camera, function()
    local timer_1 = sol.timer.start(self, delay_before, function()
      if callback ~= nil then
        callback()
      end
      local timer_2 = sol.timer.start(self, delay_after, function()
        local movement = sol.movement.create("target")
        movement:set_target(back_x, back_y)
        movement:set_ignore_obstacles(true)
        movement:set_speed(speed)
        movement:start(camera, function()
          game:set_suspended(false)
          camera:start_tracking(hero)
          if self.on_camera_back ~= nil then
            self:on_camera_back()
          end
        end)
      end)
      timer_2:set_suspended_with_map(false)
    end)
    timer_1:set_suspended_with_map(false)
  end)
end

function map_meta:on_finished()
  local game = self:get_game()
  texte_lieu_on = false
  nb_torches_lit = 0
  temporary_torches = false
  --Système jour/nuit: Temps qui passe
  if daytime_increment then
    daytime_increment = false
    game:set_value("daytime",game:get_value("daytime") + 1)
    if game:get_value("daytime") > 6 then game:set_value("daytime", 1) end
    if game:get_value("daytime") == 3 then 
      game:set_value("day",false)
      game:set_value("twilight",true) 
      game:set_value("night",false)
      game:set_value("dawn",false)
    elseif game:get_value("daytime") == 4 or game:get_value("daytime") == 5 then
      game:set_value("day",false)
      game:set_value("twilight",false) 
      game:set_value("night",true)
      game:set_value("dawn",false)
    elseif game:get_value("daytime") == 6 then
      game:set_value("day",false)
      game:set_value("twilight",false) 
      game:set_value("night",false)
      game:set_value("dawn",true)
    else
      game:set_value("day",true)
      game:set_value("twilight",false) 
      game:set_value("night",false)
      game:set_value("dawn",false)
    end
  end
end

return true