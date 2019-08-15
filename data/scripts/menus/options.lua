local options_menu = {}

local gui_designer = require("scripts/menus/lib/gui_designer")
local layout
local cursor_img = sol.sprite.create("entities/items")
cursor_img:set_animation("pickable/fairy")
local slider_img = sol.surface.create("menus/slider.png")
local cursor_position
local music_slider_x
local sound_slider_x
local slider_cursor_img = sol.surface.create("menus/slider_cursor.png")
local languages = sol.language.get_languages()
local language_index
local records = require("scripts/records_manager")
local last_option

-- Cursor position:
-- 1: music volume
-- 2: sound volume
-- 3: video filter
-- 4: language
-- 5: back
local cursor_position
local shader

local function build_layout()

  layout = gui_designer:create(320, 240)

  layout:make_wooden_frame(8, 32, 304, 200)
  layout:make_wooden_frame(16, 8, 160, 32)
  layout:make_text(sol.language.get_string("options_menu.title"), 95, 16, "center")
  layout:make_green_frame(16, 48, 288, 128)
  layout:make_green_frame(16, 192, 136, 32)
  layout:make_text(sol.language.get_string("options_menu.music_volume"), 64, 56)
  layout:make_image(slider_img, 128, 56)
  layout:make_text(sol.language.get_string("options_menu.sound_volume"), 64, 88)
  layout:make_image(slider_img, 128, 88)
  layout:make_text(sol.language.get_string("options_menu.video_filter"), 64, 120)
  if sol.video.get_shader()== nil then layout:make_text("< " .. sol.language.get_string("options_menu.video_filter_nil") .. " >", 288, 120, "right")
  else shader = sol.video.get_shader() layout:make_text("< " .. shader:get_id() .. " >", 288, 120, "right") end
  layout:make_text(sol.language.get_string("options_menu.language"), 64, 152)
  layout:make_text("< " .. sol.language.get_language_name() .. " >", 288, 152, "right")
  layout:make_text(sol.language.get_string("options_menu.back"), 64, 200)
  layout:make_yellow_frame(168, 192, 136, 32)
  if records:get_rank_100_percent() and records:get_rank_speed() and records:get_rank_ultimate() then
    last_option = "options_menu.last_option"
  else
    last_option = "options_menu.last_option_hidden"    
  end
  layout:make_text(sol.language.get_string(last_option), 236, 200, "center")
end

-- Places the cursor on option 1, 2 or 3, 4
-- or on the back button (5).
local function set_cursor_position(index)

  cursor_position = index
  cursor_img:set_xy(32, 37 + index * 32)
  if cursor_position == 5 then cursor_img:set_xy(32, 212) end
  if cursor_position == 6 then cursor_img:set_xy(184, 212) end
end

local function update_music_slider()

  local volume = sol.audio.get_music_volume()
  music_slider_x = 136 + (volume * 128 / 100)
end

local function update_sound_slider()

  local volume = sol.audio.get_sound_volume()
  sound_slider_x = 136 + (volume * 128 / 100)
end

local function increase_music_volume()

  local volume = sol.audio.get_music_volume()
  if volume < 100 then
    volume = volume + 10
    sol.audio.set_music_volume(volume)
    update_music_slider()
  end
end

local function decrease_music_volume()

  local volume = sol.audio.get_music_volume()
  if volume > 0 then
    volume = volume - 10
    sol.audio.set_music_volume(volume)
    update_music_slider()
  end
end

local function increase_sound_volume()

  local volume = sol.audio.get_sound_volume()
  if volume < 100 then
    volume = volume + 10
    sol.audio.set_sound_volume(volume)
    update_sound_slider()
  end
end

local function decrease_sound_volume()

  local volume = sol.audio.get_sound_volume()
  if volume > 0 then
    volume = volume - 10
    sol.audio.set_sound_volume(volume)
    update_sound_slider()
  end
end

local function previous_video_mode()

  if sol.video.get_shader() == nil then
	shader = sol.shader.create("sepia")
  elseif shader:get_id() == "sepia" then
  shader = sol.shader.create("ntsc2pal")
  elseif shader:get_id() == "ntsc2pal" then
  shader = sol.shader.create("heavybloom")
  elseif shader:get_id() == "heavybloom" then
  shader = sol.shader.create("6xbrz")
  elseif shader:get_id() == "6xbrz" then
  shader = sol.shader.create("hq2x")
  elseif shader:get_id() == "hq2x" then
	shader = nil
  end
	sol.video.set_shader(shader)
  build_layout()
end

local function next_video_mode()

  if sol.video.get_shader() == nil then
  shader = sol.shader.create("hq2x")
  elseif shader:get_id() == "hq2x" then
  shader = sol.shader.create("6xbrz")
  elseif shader:get_id() == "6xbrz" then
  shader = sol.shader.create("heavybloom")
  elseif shader:get_id() == "heavybloom" then
  shader = sol.shader.create("ntsc2pal")
  elseif shader:get_id() == "ntsc2pal" then
  shader = sol.shader.create("sepia")
  elseif shader:get_id() == "sepia" then
  shader = nil
  end
	sol.video.set_shader(shader)
  build_layout()
end

local function previous_language()

  language_index = ((language_index - 2) % #languages) + 1
  sol.language.set_language(languages[language_index])
  build_layout()
end

local function next_language()

  language_index = (language_index % #languages) + 1
  sol.language.set_language(languages[language_index])
  build_layout()
end

function options_menu:on_started()

  records:load()
  build_layout()
  set_cursor_position(5)  -- Back.
  update_music_slider()
  update_sound_slider()

  for i, language in ipairs(languages) do
    if language == sol.language.get_language() then
      language_index = i
    end
  end
end

function options_menu:on_draw(dst_surface)

  layout:draw(dst_surface)
  cursor_img:draw(dst_surface)
  slider_cursor_img:draw(dst_surface, music_slider_x, 56)
  slider_cursor_img:draw(dst_surface, sound_slider_x, 88)
end

function options_menu:on_key_pressed(key)

  if key == "down" then
    sol.audio.play_sound("save_menu_cursor")
    if cursor_position < 5 then
      set_cursor_position(cursor_position + 1)
    else
      set_cursor_position(1)
    end
  elseif key == "up" then
    sol.audio.play_sound("save_menu_cursor")
    if cursor_position > 1 then
      set_cursor_position(cursor_position - 1)
    else
      set_cursor_position(5)
    end
  elseif key == "left" then
    if cursor_position == 1 then
      decrease_music_volume()
      sol.audio.play_sound("pause_turn")
    elseif cursor_position == 2 then
      decrease_sound_volume()
      sol.audio.play_sound("pause_turn")
    elseif cursor_position == 3 then
      previous_video_mode()
      sol.audio.play_sound("pause_turn")
    elseif cursor_position == 4 then
      previous_language()
      sol.audio.play_sound("pause_turn")
    elseif cursor_position == 5 then
      set_cursor_position(6)
      sol.audio.play_sound("save_menu_cursor")
      handled = true
    elseif cursor_position == 6 then
      set_cursor_position(5)
      sol.audio.play_sound("save_menu_cursor")
      handled = true
    end
  elseif key == "right" then
    if cursor_position == 1 then
      increase_music_volume()
      sol.audio.play_sound("pause_turn")
    elseif cursor_position == 2 then
      increase_sound_volume()
      sol.audio.play_sound("pause_turn")
    elseif cursor_position == 3 then
      next_video_mode()
      sol.audio.play_sound("pause_turn")
    elseif cursor_position == 4 then
      next_language()
      sol.audio.play_sound("pause_turn")
    elseif cursor_position == 5 then
      set_cursor_position(6)
      sol.audio.play_sound("save_menu_cursor")
      handled = true
    elseif cursor_position == 6 then
      set_cursor_position(5)
      sol.audio.play_sound("save_menu_cursor")
      handled = true
    end
  elseif key == "space" then
    if cursor_position == 5 then
      sol.audio.play_sound("save_menu_cancel")
      sol.menu.stop(options_menu)
    elseif cursor_position == 6 then
      -- ???: You must earn all the achievements to unlock this last option
      show_popup()
    end
  end

  -- Don't forward the key event to the savegame menu below.
  return true
end

-- Creates a popup with information about the selected rank.
-- TODO this could be in gui_designer
function show_popup()

  local popup = {}
  local text
  if records:get_rank_100_percent() and records:get_rank_speed() and records:get_rank_ultimate() then
    text = sol.language.get_string("options_menu.cheats_unlocked")
    sol.audio.play_sound("secret")
    if not sol.file.exists("debug_player.dat") then
      local file = sol.file.open("debug_player.dat", "w")
      file:write("1")
    end
  else
    text = sol.language.get_string("options_menu.need_achievements")
    sol.audio.play_sound("wrong")
  end

  assert(text ~= nil)

  local max_width = 0
  local total_height = 0
  local lines = {}
  for line in text:gmatch("[^$]+") do
    local line_text = sol.text_surface.create({
      font = "alttp",
      text = line,
    })
    local width, height = line_text:get_size()
    max_width = math.max(width, max_width)
    total_height = total_height + height
    lines[#lines + 1] = line
  end
  max_width = max_width + 16  -- Extra space for borders.
  total_height = total_height + 16
  local screen_width, screen_height = sol.video.get_quest_size()
  local popup_x = screen_width / 2 - max_width / 2
  local popup_y = screen_height / 2 - total_height / 2

  local layout = gui_designer:create(max_width, total_height)
  layout:make_wooden_frame()
  local y = 8
  for _, line in ipairs(lines) do
    layout:make_text(line, 8, y)
    y = y + 16
  end

  function popup:on_key_pressed(key)

    if key == "space" then
      sol.menu.stop(popup)
    end

    return true
  end

  function popup:on_draw(dst_surface)

    layout:draw(dst_surface, popup_x, popup_y)
  end

  gui_designer:map_joypad_to_keyboard(popup)
  sol.menu.start(options_menu, popup)
end

gui_designer:map_joypad_to_keyboard(options_menu)

return options_menu
