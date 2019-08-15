local records_menu = {}

local gui_designer = require("scripts/menus/lib/gui_designer")
local records = require("scripts/records_manager")
local layout
local cursor_img = sol.sprite.create("entities/items")
cursor_img:set_animation("pickable/fairy")
local fairy_img = sol.surface.create("menus/fairy_cursor.png")
local icons_img = sol.surface.create("menus/icons.png")
local gray_triforce_img = sol.surface.create(16, 16)
icons_img:draw_region(16, 0, 16, 16, gray_triforce_img)
local yellow_triforce_img = sol.surface.create(16, 16)
icons_img:draw_region(0, 0, 16, 16, yellow_triforce_img)
local show_confirm_clear_popup
local show_rank_info_popup

-- Cursor position:
-- 1: 100% rank
-- 2: ultimate rank
-- 3: speed rank
-- 4: back
local cursor_position

local function build_layout()

  layout = gui_designer:create(320, 240)

  layout:make_wooden_frame(8, 32, 304, 200)
  layout:make_wooden_frame(16, 8, 288, 32)
  layout:make_text(sol.language.get_string("records_menu.title"), 64, 16, "center")

  layout:make_text(sol.language.get_string("records_menu.best_time"), 172, 16)
  layout:make_text(records:get_best_time_text(), 236, 16)

  layout:make_yellow_frame(16, 48, 288, 128)
  layout:make_text(sol.language.get_string("records_menu.100_percent_rank"), 44, 56)
  layout:make_image(records:get_rank_100_percent() and yellow_triforce_img or gray_triforce_img, 275, 56)

  layout:make_text(sol.language.get_string("records_menu.ultimate_rank"), 44, 104)
  layout:make_image(records:get_rank_ultimate() and yellow_triforce_img or gray_triforce_img, 275, 104)

  layout:make_text(sol.language.get_string("records_menu.speed_rank"), 44, 152)
  layout:make_image(records:get_rank_speed() and yellow_triforce_img or gray_triforce_img, 275, 152)

  layout:make_yellow_frame(16, 192, 136, 32)
  layout:make_text(sol.language.get_string("records_menu.back"), 64, 200)
end

-- Places the cursor on the record 1, 2 or 3,
-- or on the back button (4) or on the clear button (5).
local function set_cursor_position(index)

  cursor_position = index
  if index <= 4 then
    cursor_img:set_xy(32, 20 + index * 48)
  end
end

function records_menu:on_started()

  records:load()
  build_layout()
  set_cursor_position(4)  -- Back.
end

function records_menu:on_draw(dst_surface)

  layout:draw(dst_surface)
  cursor_img:draw(dst_surface)
end

function records_menu:on_key_pressed(key)

  if key == "down" then
    if cursor_position < 4 then
      set_cursor_position(cursor_position + 1)
    else
      set_cursor_position(1)
    end
    sol.audio.play_sound("save_menu_cursor")
  elseif key == "up" then
    if cursor_position > 1 then
      set_cursor_position(cursor_position - 1)
    else
      set_cursor_position(4)
    end
    sol.audio.play_sound("save_menu_cursor")
  elseif key == "space" then
    if cursor_position <= 3 then
      -- Show information about a rank.
      show_rank_info_popup()
    elseif cursor_position == 4 then
      -- Back.
      sol.audio.play_sound("save_menu_cancel")
      sol.menu.stop(records_menu)
    end
  end

  -- Don't forward the key event to the savegame menu below.
  return true
end

-- Creates a popup with information about the selected rank.
-- TODO this could be in gui_designer
function show_rank_info_popup()

  local popup = {}

  local text
  if cursor_position == 1 then
    text = sol.language.get_string("records_menu.rank_100_percent")
  elseif cursor_position == 2 then
    text = sol.language.get_string("records_menu.rank_ultimate")
  elseif cursor_position == 3 then
    text = sol.language.get_string("records_menu.rank_speed")
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
      sol.audio.play_sound("save_menu_cancel")
      sol.menu.stop(popup)
    end

    return true
  end

  function popup:on_draw(dst_surface)

    layout:draw(dst_surface, popup_x, popup_y)
  end

  gui_designer:map_joypad_to_keyboard(popup)
  sol.audio.play_sound("save_menu_select")
  sol.menu.start(records_menu, popup)
end

gui_designer:map_joypad_to_keyboard(records_menu)

return records_menu