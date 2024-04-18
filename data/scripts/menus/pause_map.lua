--Map Menu: Shows dungeon map overlay during dungeons/ overworld map in overworld.

local map_manager = {}

local gui_designer = require("scripts/menus/lib/gui_designer")
local chest_loader = require("scripts/lib/chest_loader")

--Dimensions de l'Overworld
local world_map_width, world_map_height = 2560, 1440
local world_map_left_margin, world_map_top_margin = 0, 0
local world_map_scale_x, world_map_scale_y = 2560 / 320, 1440 / 240 --A répéter ici
local dungeon_map_widget

function map_manager:new(game)

  local map_menu = {}

  local world_map_img = sol.surface.create("menus/world_map.png")
  local link_head_sprite = sol.sprite.create("menus/hero_head")
  local key_item_icon_img = sol.surface.create("menus/key_item_icon.png")
  local chest_icon_img = sol.surface.create("menus/chest_icon.png")
  local rooms_sprite
  local rooms_img
  local dungeon_map_widget
  local current_floor
  local selected_floor
  local num_floors
  local map
  local world
  local dungeon_index
  local dungeon
  local inventory_background = sol.surface.create("menus/map_background.png")

  -- Converts coordinates relative to the floor
  -- into coordinates relative to the dungeon minimap grid image.
  local function to_dungeon_minimap_coordinates(x, y)

    local scale_x, scale_y = 160 / 3200, 160 / 2400  -- The minimap is a grid of 10*10 rooms.
    x = x * scale_x
    y = y * scale_y
    return x, y
  end

  local function build_rooms_image()

    rooms_img = sol.surface.create(320, 168)
    rooms_sprite:set_animation(selected_floor)

    -- Background: show the whole floor as non visited.
    if game:has_dungeon_map() then
      rooms_sprite:set_direction(0)
      rooms_sprite:draw(rooms_img)
    end

    for i = 1, rooms_sprite:get_num_directions(floor_animation) - 1 do
      if game:has_explored_dungeon_room(dungeon_index, selected_floor, i) then
        -- If the room is visited, show it in another color.
        rooms_sprite:set_direction(i)
        rooms_sprite:draw(rooms_img)
      end
    end

    if game:has_dungeon_compass() then
      -- Key Item.
      local key_item = dungeon.key_item
      if key_item ~= nil
          and key_item.floor == selected_floor
          and key_item.savegame_variable ~= nil
          and not game:get_value(key_item.savegame_variable) then
        local dst_x, dst_y = to_dungeon_minimap_coordinates(key_item.x, key_item.y)
        dst_x, dst_y = dst_x - 4, dst_y - 4
        key_item_icon_img:draw(rooms_img, dst_x, dst_y)
      end

      -- Chests.
      if dungeon.chests == nil then
        -- Lazily load the chest information.
        dungeon.chests = chest_loader:load_chests(dungeon.maps)
      end
      for _, chest in ipairs(dungeon.chests) do
        if chest.floor == selected_floor
            and chest.savegame_variable ~= nil
            and not game:get_value(chest.savegame_variable) then
          -- Chests coordinates are already relative to their floor.
          local dst_x, dst_y = to_dungeon_minimap_coordinates(chest.x, chest.y)
          dst_x = dst_x - 13
          dst_y = dst_y - 1
          chest_icon_img:draw(rooms_img, dst_x, dst_y)
        end
      end
    end
  end

  local function build_dungeon_map_widget()
 
    dungeon_map_widget = gui_designer:create(320, 240)
    dungeon_map_widget:make_wooden_frame(124, 8, 72, 28)
    dungeon_map_widget:make_text(sol.language.get_string("menu_title.map"), 130, 14, "left")
    dungeon_map_widget:make_text(game:get_dungeon_name(), 112, 46)

    -- Dungeon items.
    if game:has_dungeon_map() then
      local sprite = sol.sprite.create("entities/items")
      sprite:set_animation("dungeons/map")
      dungeon_map_widget:make_sprite(sprite, 36, 213)
    end
    if game:has_dungeon_compass() then
      local sprite = sol.sprite.create("entities/items")
      sprite:set_animation("dungeons/compass")
      dungeon_map_widget:make_sprite(sprite, 76, 213)
    end
    if game:has_dungeon_boss_key() then
      local sprite = sol.sprite.create("entities/items")
      sprite:set_animation("dungeons/boss_key")
      dungeon_map_widget:make_sprite(sprite, 56, 213)
    end

    -- Floors.
    local lowest = dungeon.lowest_floor
    local highest = dungeon.highest_floor
    current_floor = game:get_map():get_floor()
    selected_floor = current_floor
    num_floors = highest - lowest + 1

    -- Rooms.
    rooms_sprite = sol.sprite.create(sol.language.get_language().."/dungeon_maps/map_" .. dungeon_index)
    build_rooms_image()
  end

  local function select_floor_up()

    sol.audio.play_sound("cursor")
    selected_floor = selected_floor + 1
    if selected_floor > dungeon.highest_floor then
      selected_floor = dungeon.lowest_floor
    end
    build_rooms_image()
  end

  local function select_floor_down()

    sol.audio.play_sound("cursor")
    selected_floor = selected_floor - 1
    if selected_floor < dungeon.lowest_floor then
      selected_floor = dungeon.highest_floor
    end
    build_rooms_image()
  end

  local function draw_dungeon_map(dst_surface)

    dungeon_map_widget:draw(dst_surface)

      -- Show rooms.
      rooms_img:draw(dst_surface, -32, 48)
    if game:has_dungeon_compass() then
      local map_x, map_y = map:get_location()
      local hero_x, hero_y = map:get_hero():get_position()
      dst_x, dst_y = to_dungeon_minimap_coordinates(map_x + hero_x, map_y + hero_y)
      dst_x, dst_y = dst_x + 128 - 20, dst_y + 48 - 6
      if selected_floor == current_floor then
        link_head_sprite:draw(dst_surface, dst_x, dst_y)
      end
    end
  end

  function map_menu:on_started()

    link_head_sprite:set_animation("tunic" .. game:get_ability("tunic"))

    map = game:get_map()
    world = map:get_world()
    dungeon_index = game:get_dungeon_index()
    dungeon = game:get_dungeon()
    rooms_img = nil
    local hero = map:get_hero()
    if dungeon == nil then
      -- World map.
      local map_x, map_y = map:get_location()
      map_x, map_y = map_x + world_map_left_margin, map_y + world_map_top_margin
      local hero_x, hero_y = 0, 0
      if world == "outside" then
        hero_x, hero_y = hero:get_position()
      end
      local x, y = map_x + hero_x, map_y + hero_y
      x, y = x / world_map_scale_x, y / world_map_scale_y
      x, y = x - 8, y - 8
      link_head_sprite:set_xy(x, y)
    else
      build_dungeon_map_widget()
    end
  end

  function map_menu:on_draw(dst_surface)

    if dungeon == nil then
      world_map_img:draw(dst_surface)
      link_head_sprite:draw(dst_surface)
    else
      inventory_background:draw(dst_surface)
      draw_dungeon_map(dst_surface)
    end
  end

  function map_menu:on_command_pressed(command)

    local handled = false
    if dungeon ~= nil then
      if command == "up" then
        if game:has_dungeon_map() then select_floor_up() end
        handled = true
      elseif command == "down" then
        if game:has_dungeon_map() then select_floor_down() end
        handled = true
      end
    end

    return handled
  end

  return map_menu
end

return map_manager