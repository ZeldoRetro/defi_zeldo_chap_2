--Treasures Menu: An optionnal menu who shows the treasures you collected.

local inventory_manager = {}

local gui_designer = require("scripts/menus/lib/gui_designer")

local item_names = {
  -- Names of up to 40 treasures to show.
  "treasures/loot_chuchu_red",
  "treasures/loot_chuchu_red",
  "treasures/loot_chuchu_red",
  "treasures/loot_chuchu_red",
  "treasures/treasure_amber_pearl",
  "treasures/treasure_amber_pearl",
  "treasures/treasure_amber_pearl",
  "treasures/treasure_amber_pearl",
  "treasures/loot_chuchu_red",
  "treasures/loot_chuchu_red",
  "treasures/loot_chuchu_red",
  "treasures/loot_chuchu_red",
  "treasures/treasure_amber_pearl",
  "treasures/treasure_amber_pearl",
  "treasures/treasure_amber_pearl",
  "treasures/treasure_amber_pearl",
  "treasures/loot_chuchu_red",
  "treasures/loot_chuchu_red",
  "treasures/loot_chuchu_red",
  "treasures/loot_lucky_egg",
  "treasures/treasure_amber_pearl",
  "treasures/treasure_amber_pearl",
  "treasures/treasure_amber_pearl",
  "treasures/treasure_amber_pearl",
  "treasures/troc_apple",
  "treasures/troc_apple",
  "treasures/troc_apple",
  "treasures/troc_apple",
  "treasures/treasure_amber_pearl",
  "treasures/treasure_amber_pearl",
  "treasures/treasure_golden_ore",
  "treasures/treasure_moon",
  "treasures/troc_apple",
  "treasures/troc_apple",
  "treasures/troc_apple",
  "treasures/troc_apple",
  "quest_items/fairy_power_fragment",
  "quest_items/fairy_power_fragment",
  "quest_items/fairy_power_fragment",
  "quest_items/fairy_power_fragment",
}

local items_num_columns = 8
local items_num_rows = math.ceil(#item_names / items_num_columns)
local piece_of_heart_icon_img = sol.surface.create("hud/piece_of_heart_icon.png")
local icons_img = sol.surface.create("menus/stats_icons.png")
local items_img = sol.surface.create("entities/items.png")
local inventory_background = sol.surface.create("menus/treasures_background.png")
local movement_speed = 800
local movement_distance = 1

--FENETRE DES OBJETS

local function create_item_widget(game)
  local widget = gui_designer:create(300, 180)
  widget:set_xy(24 - movement_distance, 48)
  local items_surface = widget:get_surface()

  for i, item_name in ipairs(item_names) do
    local variant = game:get_item(item_name):get_variant()
    local amount = game:get_item(item_name):get_amount()
    if variant > 0 then
      local column = (i - 1) % items_num_columns + 1
      local row = math.floor((i - 1) / items_num_columns + 1)
      -- Draw the sprite statically. This is okay as long as
      -- item sprites are not animated.
      -- If they become animated one day, they will have to be
      -- drawn at each frame instead (in on_draw()).
      local item_sprite = sol.sprite.create("entities/items")
      item_sprite:set_animation(item_name)
      item_sprite:set_direction(variant - 1)
      item_sprite:set_xy(8 + column * 32 - 16, 13 + row * 32 - 16)
      item_sprite:draw(items_surface)
      if game:get_item(item_name):get_amount() == game:get_item(item_name):get_max_amount() then
        widget:make_green_counter(amount, 8 + column * 32 - 16, 13 + row * 32 - 20)
      else
        widget:make_counter(amount, 8 + column * 32 - 16, 13 + row * 32 - 20)
      end
    end
  end
  return widget
end

local function create_menu_title_widget(game)
  local widget = gui_designer:create(72, 28)
  widget:set_xy(124, 8)
  widget:make_wooden_frame()
  widget:make_text(sol.language.get_string("menu_title.bags"), 6, 6, "left")
  return widget
end

function inventory_manager:new(game)

  local inventory = {}

  local state = "opening"  -- "opening", "ready" or "closing".

  local item_widget = create_item_widget(game)
  local menu_title_widget = create_menu_title_widget(game)
  
  local item_cursor_moving_sprite = sol.sprite.create("menus/item_cursor")
  item_cursor_moving_sprite:set_animation("solid_fixed")

  -- Determine the place of the item currently assigned if any.
  local item_assigned_row, item_assigned_column, item_assigned_index
  local item_assigned = game:get_item_assigned(1)
  if item_assigned ~= nil then
    local item_name_assigned = item_assigned:get_name()
    for i, item_name in ipairs(item_names) do

      if item_name == item_name_assigned then
        item_assigned_column = (i - 1) % items_num_columns
        item_assigned_row = math.floor((i - 1) / items_num_columns)
        item_assigned_index = i - 1
      end
    end
  end

  local time_played_text = sol.text_surface.create{
    font = "alttp",
    horizontal_alignment = "left",
    vertical_alignment = "top",
  }

  -- Rapidly moves the inventory widgets towards or away from the screen.
  local function move_widgets(callback)

    local angle_added = 0
    if item_widget:get_xy() > 0 then
      -- Opposite direction when closing.
      angle_added = math.pi * 2
    end

    local movement = sol.movement.create("straight")
    movement:set_speed(movement_speed)
    movement:set_max_distance(movement_distance)
    movement:set_angle(0 + angle_added)
    item_widget:start_movement(movement, callback)

  end

  local cursor_index = 0
  local cursor_row = math.floor(cursor_index / items_num_columns)
  local cursor_column = cursor_index % items_num_columns

  -- Draws cursors on the selected and on the assigned items.
  local function draw_item_cursors(dst_surface)

    -- Selected item.
    local widget_x, widget_y = item_widget:get_xy()
    item_cursor_moving_sprite:draw(
        dst_surface,
        widget_x + 24 + 32 * cursor_column,
        widget_y + 24 + 32 * cursor_row
    )
  end

  -- Changes the position of the item cursor.
  local function set_cursor_position(row, column)
    cursor_row = row
    cursor_column = column
    cursor_index = cursor_row * items_num_columns + cursor_column
    if cursor_index == item_assigned_index then
      item_cursor_moving_sprite:set_animation("solid_fixed")
    end
  end

  function inventory:on_draw(dst_surface)

    inventory_background:draw(dst_surface)
    item_widget:draw(dst_surface)
    menu_title_widget:draw(dst_surface)
    -- Show the item cursors.
    draw_item_cursors(dst_surface)
  end

  function inventory:on_command_pressed(command)

    if state ~= "ready" then
      return true
    end

    local handled = false

    if command == "pause" then
      -- Close the pause menu.
      state = "closing"
      sol.audio.play_sound("pause_closed")
      move_widgets(function() game:set_paused(false) end)
      handled = true

    elseif command == "item_1" then
      -- Assign an item.
      local item = game:get_item(item_names[cursor_index + 1])
      if item == game:get_item_assigned(2) then return
      elseif cursor_index ~= item_assigned_index
          and item:has_variant()
          and item:is_assignable() then
        sol.audio.play_sound("assign_item")
        game:set_item_assigned(1, item)
        item_assigned_row, item_assigned_column = cursor_row, cursor_column
        item_assigned_index = cursor_row * items_num_rows + cursor_column
        item_cursor_moving_sprite:set_animation("solid_fixed")
        item_cursor_moving_sprite:set_frame(0)
      end
      handled = true

    elseif command == "item_2" then
      -- Assign an item.
      local item = game:get_item(item_names[cursor_index + 1])
      if item == game:get_item_assigned(2) then return
      elseif cursor_index ~= item_assigned_index
          and item:has_variant()
          and item:is_assignable() then
        sol.audio.play_sound("assign_item")
        game:set_item_assigned(2, item)
        item_assigned_row, item_assigned_column = cursor_row, cursor_column
        item_assigned_index = cursor_row * items_num_rows + cursor_column
        item_cursor_moving_sprite:set_animation("solid_fixed")
        item_cursor_moving_sprite:set_frame(0)
      end
      handled = true

    elseif command == "right" then
      if cursor_column < items_num_columns - 1 then
        sol.audio.play_sound("cursor")
        set_cursor_position(cursor_row, cursor_column + 1)
        handled = true
      end

    elseif command == "up" then
      sol.audio.play_sound("cursor")
      if cursor_row > 0 then
        set_cursor_position(cursor_row - 1, cursor_column)
      else
        set_cursor_position(items_num_rows - 1, cursor_column)
      end
      handled = true

    elseif command == "left" then
      if cursor_column > 0 then
        sol.audio.play_sound("cursor")
        set_cursor_position(cursor_row, cursor_column - 1)
        handled = true
      end

    elseif command == "down" then
      sol.audio.play_sound("cursor")
      if cursor_row < items_num_rows - 1 then
        set_cursor_position(cursor_row + 1, cursor_column)
      else
        set_cursor_position(0, cursor_column)
      end
      handled = true
    end

    return handled
  end

  function inventory:on_finished()
    -- Reset the cursor
    game:set_value("pause_inventory_last_item_index", 0)
  end

  set_cursor_position(cursor_row, cursor_column)
  move_widgets(function() state = "ready" end)

  return inventory
end

return inventory_manager