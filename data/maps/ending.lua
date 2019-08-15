local map = ...
local game = map:get_game()

--Défilement des crédits
local i = 1
local current_credits = sol.surface.create(sol.language.get_language().."/credits/credits_"..i..".png")
local opacity = 0
current_credits:set_opacity(opacity)
local function fade_in()
	opacity = opacity + 5
	current_credits:set_opacity(opacity)
  if opacity < 255 then
		sol.timer.start(100,fade_in)
  end
end
local function fade_out()
	opacity = opacity - 5
	current_credits:set_opacity(opacity)
  if opacity > 0 then
		sol.timer.start(100,fade_out)
  end
end
function map:on_draw(dst_surface)
  current_credits:draw(dst_surface)
end

function map:on_started()
  game:set_hud_enabled(false) 
  game:set_pause_allowed(false)
  hero:set_visible(false)
  sol.audio.play_music("ending_1",false)
  sol.timer.start(map,82000,function() sol.audio.play_music("ending_2") end)
end

function map:on_opening_transition_finished()
  local movement_hero = sol.movement.create("straight")
  movement_hero:set_angle(0)
  movement_hero:set_speed(28)
  movement_hero:set_max_distance(0)

  local sprite
  if game:get_ability("tunic") == 1 then sprite = flying_tails_tunic_1 else sprite = flying_tails_tunic_2 end
  local m = sol.movement.create("target")
  m:set_speed(72)
  m:set_ignore_obstacles()
  m:set_target(target_tails_1)
  m:start(sprite,function()
    local m2 = sol.movement.create("straight")
    m2:set_speed(28)
    m2:set_ignore_obstacles()
    m2:set_angle(0)
    m2:set_max_distance(0)
    m2:start(sprite)
    hero:freeze()
    movement_hero:start(hero)
  end)

  sol.timer.start(map,1000,fade_in)
  sol.timer.start(map,9000,fade_out)
  sol.timer.start(map,14000,function()
    i = i + 1
    current_credits = sol.surface.create(sol.language.get_language().."/credits/credits_"..i..".png")
    current_credits:set_opacity(opacity)
    sol.timer.start(1000,fade_in)
    sol.timer.start(9000,fade_out)
    if i < 5 then return true end
  end)
end

function map:on_key_pressed(key)
  if key == "space" then hero:teleport("ending_2") end
end

function map:on_joypad_button_pressed(button)
  hero:teleport("ending_2")
end