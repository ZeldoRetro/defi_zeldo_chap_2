--Inventory Menu: this version also shows equipment and quest status infos.

local inventory_manager = {}

local gui_designer = require("scripts/menus/lib/gui_designer")

local item_names = {
  -- Place inventory items here
  "inventory/bow",  -- Will be replaced by the light one if the player has it.   
  "inventory/boomerang",
  "inventory/bombs_counter",
  "inventory/bottle_1",
  "inventory/lamp",
  "inventory/hookshot",
  "inventory/hammer", 
  "inventory/bottle_2",
  "inventory/magic_mushroom",  
  "inventory/fire_rod",
  "inventory/cane_of_somaria",
  "inventory/echange",
}
local items_num_columns = 4
local items_num_rows = math.ceil(#item_names / items_num_columns)
local piece_of_heart_icon_img = sol.surface.create("hud/piece_of_heart_icon.png")
local icons_img = sol.surface.create("menus/stats_icons.png")
local items_img = sol.surface.create("entities/items.png")
local inventory_background = sol.surface.create("menus/inventory_background.png")
local movement_speed = 800
local movement_distance = 1

--FENETRE DES OBJETS D'INVENTAIRE
local function create_item_widget(game)
  local widget = gui_designer:create(176, 144)
  widget:set_xy(28 - movement_distance, 52)
  local items_surface = widget:get_surface()

  item_names[1] = game:has_item("inventory/bow_light") and "inventory/bow_light" or "inventory/bow"
  item_names[9] = game:has_item("inventory/magic_powder") and "inventory/magic_powder" or "inventory/magic_mushroom"
  item_names[12] = game:has_item("inventory/magic_cape") and "inventory/magic_cape" or "inventory/echange"

  for i, item_name in ipairs(item_names) do
    local variant = game:get_item(item_name):get_variant()
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
      item_sprite:set_xy(20 + column * 28 - 16, 13 + row * 32 - 16)
      item_sprite:draw(items_surface)
      if game:get_item(item_name):has_amount() then
        -- Show a counter in this case.
        local amount = game:get_item(item_name):get_amount()
        if game:get_item(item_name):get_amount() == game:get_item(item_name):get_max_amount() then
          widget:make_green_counter(amount, 20 + column * 28 - 16, 13 + row * 32 - 20)
        else
          widget:make_counter(amount, 20 + column * 28 - 16, 13 + row * 32 - 20)
        end
      end
    end
  end
  return widget
end

--TITRE DU MENU
local function create_menu_title_widget(game)
  local widget = gui_designer:create(72, 28)
  widget:set_xy(124, 8)
  widget:make_wooden_frame()
  widget:make_text(sol.language.get_string("menu_title.inventory"), 6, 6, "left")
  return widget
end

--QUARTS DE COEUR
local function create_pieces_of_heart_widget(game)
  local widget = gui_designer:create(48, 52)
  widget:set_xy(35, 184)
  local num_pieces_of_heart = game:get_item("quest_items/piece_of_heart"):get_num_pieces_of_heart()
  widget:make_image_region(piece_of_heart_icon_img, num_pieces_of_heart * 16, 0, 16, 16, 19, 13)
  return widget
end

--FENETRE DU STATUT QUETE
local function create_status_widget(game)
  local widget = gui_designer:create(192, 52)

  widget:set_xy(54, 184)

  --???
  local colonne_p = 26
  local rangee_p = 20
  if game:get_item("quest_items/certificate"):get_variant() == 1 then widget:make_image_region(items_img, 256, 48, 16, 16, colonne_p + 122, rangee_p - 7) end

  --Trophée défi originel
  if game:get_item("quest_items/trophy"):get_variant() == 1 then widget:make_image_region(items_img, 240, 48, 16, 16, colonne_p + 22, rangee_p - 7) end

  --Emblème de Tails: Jeu terminé
  if game:get_value("game_finished") then widget:make_image_region(items_img, 0, 80, 32, 32, 90, rangee_p - 15) end
 
  return widget
end

--FENETRE DES STATISTIQUES: ATTAQUE,DEFENSE,TEMPS DE JEU ET COMPTEUR DE MORTS
local function create_stats_widget(game)
  local widget = gui_designer:create(112, 38)

  widget:set_xy(192, 40)
  --Temps de jeu
  widget:make_image_region(icons_img, 24, 0, 12, 12, 10, 6)
  --Force
  widget:make_image_region(icons_img, 0, 0, 12, 12, 11, 18)
  widget:make_counter(game:get_value("force"), 21, 24)
  --Défense
  widget:make_image_region(icons_img, 12, 0, 12, 12, 31, 18)
  widget:make_counter(game:get_value("defense"), 43, 24)
  --Compteur de morts
   widget:make_image_region(icons_img, 36, 0, 12, 14, 51, 18)
   widget:make_counter(game:get_value("death_counter"), 64, 24)

  return widget
end

--FENETRE D'EQUIPEMENT: CAPACITES,EPEE/BOUCLIER/TUNIQUE, PENDENTIFS, ...
local function create_equipment_widget(game)
  local widget = gui_designer:create(112, 106)

  widget:set_xy(192, 78)

  --Capacités: Flèches, bombes, rubis
  local x_rupees = 9
  local y_rupees = 22
  local rangee_ep_1 = 44
  local rangee_ep_2 = 66

  if game:get_item("equipment/rupee_bag"):get_variant() == 1 then widget:make_image_region(items_img, 336, 0, 16, 16, x_rupees, y_rupees)
  elseif game:get_item("equipment/rupee_bag"):get_variant() == 2 then widget:make_image_region(items_img, 336, 16, 16, 16, x_rupees, y_rupees)
  elseif game:get_item("equipment/rupee_bag"):get_variant() == 3 then widget:make_image_region(items_img, 336, 32, 16, 16, x_rupees, y_rupees)
  elseif game:get_item("equipment/rupee_bag"):get_variant() == 4 then widget:make_image_region(items_img, 336, 48, 16, 16, x_rupees, y_rupees) end
  if game:get_item("equipment/quiver"):get_variant() == 1 then widget:make_image_region(items_img, 368, 0, 16, 16, x_rupees, rangee_ep_1)
  elseif game:get_item("equipment/quiver"):get_variant() == 2 then widget:make_image_region(items_img, 368, 16, 16, 16, x_rupees, rangee_ep_1)
  elseif game:get_item("equipment/quiver"):get_variant() == 3 then widget:make_image_region(items_img, 368, 32, 16, 16, x_rupees, rangee_ep_1) end
  if game:get_item("equipment/bomb_bag"):get_variant() == 1 then widget:make_image_region(items_img, 352, 0, 16, 16, x_rupees, rangee_ep_2)
  elseif game:get_item("equipment/bomb_bag"):get_variant() == 2 then widget:make_image_region(items_img, 352, 16, 16, 16, x_rupees, rangee_ep_2)
  elseif game:get_item("equipment/bomb_bag"):get_variant() == 3 then widget:make_image_region(items_img, 352, 32, 16, 16, x_rupees, rangee_ep_2) end

  --Equipement: Bottes, palmes, gants, ...
  if game:get_item("equipment/power_moon_detector"):get_variant() == 1 then widget:make_image_region(items_img, 256, 32, 16, 16, 31, y_rupees) end
  if game:get_item("equipment/ice_key"):get_variant() == 1 then widget:make_image_region(items_img, 256, 0, 16, 16, 53, y_rupees) end
  if game:get_item("equipment/golden_ore"):get_variant() == 1 then widget:make_image_region(items_img, 560, 16, 16, 16, 75, y_rupees) end
  if game:get_item("equipment/flippers"):get_variant() == 1 then widget:make_image_region(items_img, 240, 0, 16, 16, 31, rangee_ep_1) end
  if game:get_item("equipment/glove"):get_variant() == 1 then widget:make_image_region(items_img, 224, 16, 16, 16, 53, rangee_ep_1)
  elseif game:get_item("equipment/glove"):get_variant() == 2 then widget:make_image_region(items_img, 240, 16, 16, 16, 53, rangee_ep_1)
  elseif game:get_item("equipment/glove"):get_variant() == 3 then widget:make_image_region(items_img, 256, 16, 16, 16, 53, rangee_ep_1) end
  if game:get_item("equipment/pegasus_shoes"):get_variant() == 1 then widget:make_image_region(items_img, 224, 0, 16, 16, 75, rangee_ep_1) end

  --Tunique, épée, bouclier
  if game:get_item("equipment/tunic"):get_variant() == 1 then widget:make_image_region(items_img, 384, 0, 16, 16, 31, rangee_ep_2)
  elseif game:get_item("equipment/tunic"):get_variant() == 2 then widget:make_image_region(items_img, 384, 16, 16, 16, 31, rangee_ep_2)
  elseif game:get_item("equipment/tunic"):get_variant() == 3 then widget:make_image_region(items_img, 384, 32, 16, 16, 31, rangee_ep_2) end
  if game:get_item("equipment/sword"):get_variant() == 1 then widget:make_image_region(items_img, 400, 0, 16, 16, 53, rangee_ep_2)
  elseif game:get_item("equipment/sword"):get_variant() == 2 then widget:make_image_region(items_img, 400, 16, 16, 16, 53, rangee_ep_2)
  elseif game:get_item("equipment/sword"):get_variant() == 3 then widget:make_image_region(items_img, 400, 32, 16, 16, 53, rangee_ep_2)
  elseif game:get_item("equipment/sword"):get_variant() == 4 then widget:make_image_region(items_img, 400, 48, 16, 16, 53, rangee_ep_2) end
  if game:get_item("equipment/shield"):get_variant() == 1 then widget:make_image_region(items_img, 416, 0, 16, 16, 75, rangee_ep_2)
  elseif game:get_item("equipment/shield"):get_variant() == 2 then widget:make_image_region(items_img, 416, 16, 16, 16, 75, rangee_ep_2)
  elseif game:get_item("equipment/shield"):get_variant() == 3 then widget:make_image_region(items_img, 416, 32, 16, 16, 75, rangee_ep_2) end

  return widget
end

--FENETRE DU COMPTEUR DE GEMMES DE FORCE
local function create_force_gem_widget(game)
  local widget = gui_designer:create(48, 52)
  widget:set_xy(231, 184)
    local x_gems
    local amount = game:get_item("quest_items/power_moon"):get_amount()
    if amount < 10 then 
      x_gems = 21
      widget:make_counter(amount, x_gems + 10, 19)        
    elseif amount >= 10 and amount < 50 then
      x_gems = 19
      widget:make_counter(amount, x_gems + 10, 19) 
    elseif amount == game:get_item("quest_items/power_moon"):get_max_amount() then
      x_gems = 19
      widget:make_green_counter(amount, x_gems + 10, 19)
    end
    local item_sprite = sol.sprite.create("entities/items")
    item_sprite:set_animation("quest_items/power_moon")
    item_sprite:set_direction(0)
    item_sprite:set_xy(x_gems, 26)
    item_sprite:draw(widget:get_surface())
  return widget
end

function inventory_manager:new(game)

  local inventory = {}

  local state = "opening"  -- "opening", "ready" or "closing".

  local item_widget = create_item_widget(game)
  local menu_title_widget = create_menu_title_widget(game)
  local pieces_of_heart_widget = create_pieces_of_heart_widget(game)
  local status_widget = create_status_widget(game)
  local stats_widget = create_stats_widget(game)
  local equipment_widget = create_equipment_widget(game)
  local force_gem_widget = create_force_gem_widget(game)
  
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
    font = "white_digits",
    horizontal_alignment = "left",
    vertical_alignment = "top",
  }

  -- Draws the time played on the status widget.
  local function draw_time_played(dst_surface)
    local time_string = game:get_time_played_string()
    time_played_text:set_text(time_string)
    time_played_text:draw(dst_surface, 214, 48)
  end

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

  local cursor_index = game:get_value("pause_inventory_last_item_index") or 0
  local cursor_row = math.floor(cursor_index / items_num_columns)
  local cursor_column = cursor_index % items_num_columns

  -- Draws cursors on the selected and on the assigned items.
  local function draw_item_cursors(dst_surface)

    -- Selected item.
    local widget_x, widget_y = item_widget:get_xy()
    item_cursor_moving_sprite:draw(
        dst_surface,
        widget_x + 32 + 28 * cursor_column,
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
    pieces_of_heart_widget:draw(dst_surface)
    status_widget: draw(dst_surface)
    stats_widget: draw(dst_surface)
    equipment_widget: draw(dst_surface)
    force_gem_widget:draw(dst_surface)

    draw_time_played(dst_surface)
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
      if item == game:get_item_assigned(2) then
        sol.audio.play_sound("assign_item")
        game:set_item_assigned(2, game:get_item_assigned(1))
        game:set_item_assigned(1, item)
        item_assigned_row, item_assigned_column = cursor_row, cursor_column
        item_assigned_index = cursor_row * items_num_rows + cursor_column
        item_cursor_moving_sprite:set_animation("solid_fixed")
        item_cursor_moving_sprite:set_frame(0)
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
      if item == game:get_item_assigned(1) then
        sol.audio.play_sound("assign_item")
        game:set_item_assigned(1, game:get_item_assigned(2))
        game:set_item_assigned(2, item)
        item_assigned_row, item_assigned_column = cursor_row, cursor_column
        item_assigned_index = cursor_row * items_num_rows + cursor_column
        item_cursor_moving_sprite:set_animation("solid_fixed")
        item_cursor_moving_sprite:set_frame(0)
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
    -- Store the cursor position.
    game:set_value("pause_inventory_last_item_index", cursor_index)
  end

  set_cursor_position(cursor_row, cursor_column)
  move_widgets(function() state = "ready" end)

  return inventory
end

return inventory_manager