--Title screen

local title_screen = {}
local is skipping = false
local space = false

-- show a background that depends on the hour of the day
local hours = tonumber(os.date("%H"))
local time_of_day
if hours >= 8 and hours < 18 then
  time_of_day = "daylight"
elseif hours >= 18 and hours < 20 then
  time_of_day = "sunset"
else
  time_of_day = "night"
end
  
local logo_img = sol.surface.create("menus/title_logo.png")
local background_img = sol.surface.create("menus/title_" .. time_of_day
      .. "_background.png")
local clouds_img = sol.surface.create("menus/title_" .. time_of_day
      .. "_clouds.png")
local release_img = sol.surface.create("menus/title_release.png")
local press_space_img

-- make the clouds move
local clouds_xy = {x = 320, y = 240}
local function move_clouds()

  clouds_xy.x = clouds_xy.x + 1
  clouds_xy.y = clouds_xy.y - 1
  if clouds_xy.x >= 535 then
    clouds_xy.x = clouds_xy.x - 535
  end
  if clouds_xy.y < 0 then
    clouds_xy.y = clouds_xy.y + 299
  end
  sol.timer.start(50, move_clouds)
end
sol.timer.start(50, move_clouds)

function title_screen:on_started()
  press_space_img = sol.surface.create(sol.language.get_language().."/title/title_press_space.png")
  logo_img:fade_in(25)
  background_img:fade_in(25)
  clouds_img:fade_in(30)
  release_img:fade_in(25)
  press_space_img:fade_in(25)
  sol.timer.start(500,function() if space then space = false else space = true end return true end)
  sol.audio.play_music("title")
end

function title_screen:on_draw(dst_surface)

  background_img:draw(dst_surface)
  -- clouds
  local x, y = clouds_xy.x, clouds_xy.y
  clouds_img:draw(dst_surface, x, y)
  x = clouds_xy.x - 535
  clouds_img:draw(dst_surface, x, y)
  x = clouds_xy.x
  y = clouds_xy.y - 299
  clouds_img:draw(dst_surface, x, y)
  x = clouds_xy.x - 535
  y = clouds_xy.y - 299
  clouds_img:draw(dst_surface, x, y)

	logo_img:draw(dst_surface)
	release_img:draw(dst_surface)
  if space then press_space_img:draw(dst_surface) end

end

function title_screen:on_key_pressed(key)
  if is_skipping then
    return true
  end
  is_skipping = true
  sol.audio.play_sound("save_menu_start_game")
  logo_img:fade_out(25)
  press_space_img:fade_out(25)
  release_img:fade_out(25,function() sol.menu.stop(title_screen) end)
end

function title_screen:on_joypad_button_pressed(button)
  return self:on_key_pressed("space")
end

return title_screen