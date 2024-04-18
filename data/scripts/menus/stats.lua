-- Statistics screen about completing the game.

local stats_manager = { }

local gui_designer = require("scripts/menus/lib/gui_designer")
local records_manager = require("scripts/records_manager")
local heroic_mode_manager = require("scripts/heroic_mode_manager")

local inventory_background = sol.surface.create("menus/stats_background.png")
local function create_menu_title_widget(game)
  local widget = gui_designer:create(88, 28)
  widget:set_xy(124, 8)
  widget:make_wooden_frame()
  widget:make_text(sol.language.get_string("stats_menu.title"), 6, 6, "left")
  return widget
end

function stats_manager:new(game)

  local stats = {}

  local layout
  local death_count
  local num_pieces_of_heart
  local max_pieces_of_heart
  local num_items
  local max_items
  local num_items_inventory
  local max_items_inventory
  local num_items_equipment
  local max_items_equipment
  local num_items_dungeons
  local max_items_dungeons
  local num_items_main_quest
  local max_items_main_quest
  local num_force_gems
  local max_force_gems
  local percent
  local tr = sol.language.get_string

  local menu_title_widget = create_menu_title_widget(game)

  local function get_game_time_string()
    return tr("stats_menu.game_time") .. " " .. game:get_time_played_string()
  end

  local function get_death_count_string()
    death_count = game:get_value("death_counter") or 0
    return tr("stats_menu.death_count"):gsub("%$v", death_count)
  end

  local function get_pieces_of_heart_string()
    local item = game:get_item("quest_items/piece_of_heart")
    num_pieces_of_heart = item:get_total_pieces_of_heart()
    max_pieces_of_heart = item:get_max_pieces_of_heart()
    return tr("stats_menu.pieces_of_heart") .. " "  ..
        num_pieces_of_heart .. " / " .. max_pieces_of_heart
  end

  local function get_items_inventory_string()

    num_items_inventory = 0
    if game:get_value("get_hookshot") then num_items_inventory = num_items_inventory + 1 end
    if game:get_value("get_bottle_1") then num_items_inventory = num_items_inventory + 1 end
    if game:get_value("get_bottle_2") then num_items_inventory = num_items_inventory + 1 end
    if game:get_value("get_bow") then num_items_inventory = num_items_inventory + 1 end
    if game:get_value("get_cane_of_somaria") then num_items_inventory = num_items_inventory + 1 end
    if game:get_value("get_hammer") then num_items_inventory = num_items_inventory + 1 end
    if game:get_value("get_fire_rod") then num_items_inventory = num_items_inventory + 1 end
    if game:get_value("get_mushroom") then num_items_inventory = num_items_inventory + 1 end
    if game:get_value("get_magic_powder") then num_items_inventory = num_items_inventory + 1 end
    if game:get_value("get_beer") then num_items_inventory = num_items_inventory + 1 end
    if game:get_value("get_frying_pan") then num_items_inventory = num_items_inventory + 1 end
    if game:get_value("get_fire_stone") then num_items_inventory = num_items_inventory + 1 end
    if game:get_value("get_rappeltout") then num_items_inventory = num_items_inventory + 1 end
    if game:get_value("get_wooden_board") then num_items_inventory = num_items_inventory + 1 end
    if game:get_value("get_pokeball") then num_items_inventory = num_items_inventory + 1 end
    if game:get_value("get_diamond") then num_items_inventory = num_items_inventory + 1 end
    if game:get_value("get_magic_cape") then num_items_inventory = num_items_inventory + 1 end
    max_items_inventory = 17
    return tr("stats_menu.items_inventory") .. " " .. num_items_inventory .. " / "  ..max_items_inventory
  end

  local function get_items_equipment_string()

    num_items_equipment = 0
    if game:get_value("get_flippers") then num_items_equipment = num_items_equipment + 1 end
    if game:get_value("get_glove") then num_items_equipment = num_items_equipment + 1 end
    if game:get_value("get_quiver_2") then num_items_equipment = num_items_equipment + 1 end
    if game:get_value("get_bomb_bag_2") then num_items_equipment = num_items_equipment + 1 end
    if game:get_value("get_tunic_2") then num_items_equipment = num_items_equipment + 1 end
    if game:get_value("get_sword_2") then num_items_equipment = num_items_equipment + 1 end
    if game:get_value("get_power_moon_detector") then num_items_equipment = num_items_equipment + 1 end
    if game:get_value("get_ice_key") then num_items_equipment = num_items_equipment + 1 end
    if game:get_value("get_golden_ore") then num_items_equipment = num_items_equipment + 1 end
    if game:get_value("get_pegasus_boots") then num_items_equipment = num_items_equipment + 1 end
    if game:get_value("heart_container_0") then num_items_equipment = num_items_equipment + 1 end
    if game:get_value("heart_container_1") then num_items_equipment = num_items_equipment + 1 end
    max_items_equipment = 12
    return tr("stats_menu.items_equipment") .. " " .. num_items_equipment .. " / "  ..max_items_equipment
  end

  local function get_items_dungeons_string()

    num_items_dungeons = 0
    for i = 1, 999 do
      if game:get_value("dungeon_" .. i .. "_map") then
        num_items_dungeons = num_items_dungeons + 1
      end
      if game:get_value("dungeon_" .. i .. "_compass") then
        num_items_dungeons = num_items_dungeons + 1
      end
      if game:get_value("dungeon_" .. i .. "_boss_key") then
        num_items_dungeons = num_items_dungeons + 1
      end
    end
    max_items_dungeons = 5
    return tr("stats_menu.items_dungeons") .. " " .. num_items_dungeons .. " / "  ..max_items_dungeons
  end

  local function get_items_main_quest_string()

    num_items_main_quest = 2
    if game:get_value("get_certificate") then num_items_main_quest = num_items_main_quest + 1 end
    max_items_main_quest = 3
    return tr("stats_menu.items_main_quest") .. " " .. num_items_main_quest .. " / "  ..max_items_main_quest
  end

  local function get_force_gems_string()

    num_force_gems = game:get_item("quest_items/power_moon"):get_amount()
    max_force_gems = 50

    return tr("stats_menu.force_gems") .. " " .. num_force_gems .. " / "  ..max_force_gems
  end

  local function get_percent_string()
    local current = num_pieces_of_heart + num_items_inventory + num_items_equipment + num_items_dungeons + num_items_main_quest
    local max = max_pieces_of_heart + max_items_inventory + max_items_equipment + max_items_dungeons + max_items_main_quest
    percent = math.floor(current / max * 100)
    return tr("stats_menu.percent"):gsub("%$v", percent)
  end

  local function build_layout(page)

    layout = gui_designer:create(320, 240)

    local y = 24
    local x = 24
    y = y + 20
    layout:make_text(get_game_time_string(), x, y)
    x = x + 180
    layout:make_text(get_death_count_string(), x, y)
    x = 24
    y = y + 24
    layout:make_text(get_items_main_quest_string(), x, y)
    y = y + 24
    layout:make_text(get_items_inventory_string(), x, y)
    y = y + 16
    layout:make_text(get_items_equipment_string(), x, y)
    y = y + 16
    layout:make_text(get_items_dungeons_string(), x, y)
    y = y + 24
    layout:make_text(get_pieces_of_heart_string(), x, y)
    y = y + 24
    x = 24
    layout:make_text(get_force_gems_string(), x, y)

    y = y + 32
    layout:make_text(get_percent_string(), x, y)

  end

  build_layout(page)

  function stats:on_command_pressed(command)

    local handled = false
    if command == "action" then
      game:set_value("game_finished",true)
      game:save()

      records_manager:load()
      local time_played = game:get_time_played()
      records_manager:add_candidate_time(time_played)
      if time_played <= 3600 then
        records_manager:set_rank_speed()
        print("speed_rank")
        records_manager:save()
      end
      if percent == 100 then
        records_manager:set_rank_100_percent()
        print("100_percent_rank")
        records_manager:save()
      end
      if death_count == 0 and
        game:get_value("heroic_mode") and
        not game:has_item("inventory/bottle_1") and
        not game:has_item("inventory/bottle_2") and
        not game:get_value("get_tunic_2") and
        not game:get_value("get_sword_2") and
        game:get_max_life() == 44 then
        records_manager:set_rank_ultimate()
        print("ultimate_rank")
        records_manager:save()
      end
      if not heroic_mode_manager:get_heroic_mode_enabled() then
          sol.audio.play_sound("secret")
          heroic_mode_manager:set_heroic_mode_enabled()
          heroic_mode_manager:save()
          game:start_dialog("end.get_heroic_mode",function() sol.main.reset() end)
      else
        game:save()
        sol.main.reset()
      end

      return true
    end
    return handled
  end

  function stats:on_draw(dst_surface)

    inventory_background:draw(dst_surface)
    layout:draw(dst_surface)
    menu_title_widget:draw(dst_surface)
  end

  return stats
end

gui_designer:map_joypad_to_keyboard(stats_manager)

return stats_manager