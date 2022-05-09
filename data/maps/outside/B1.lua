local map = ...
local game = map:get_game()

texte_lieu = sol.surface.create(sol.language.get_language().."/texte_lieu/ruins.png")

map.overlay_angles = {
  3 * math.pi / 4,
  5 * math.pi / 4,
      math.pi / 4,
  7 * math.pi / 4
}
map.overlay_step = 1

-- DEBUT DE LA MAP
function map:on_started()
  map:set_entities_enabled("hidden_power_moon_",false)
  --Système jour/nuit
  if game:get_value("day") or game:get_value("twilight") then
    --Jour/Crépuscule
    map:set_entities_enabled("night_entity",false)
    map:set_entities_enabled("day_entity",true)
  elseif game:get_value("night") or game:get_value("dawn") then
    --Nuit/Aube
    map:set_entities_enabled("night_entity",true)
    map:set_entities_enabled("day_entity",false)
  end

  map:set_overlay()

  --Tombe poussée
  if game:get_value("b1_grave_opened") then grave:set_position(216,16) map:get_entity("ts.b1_grave_inscription"):set_enabled(false) end
  if game:get_value("CHARA") then map:set_entities_enabled("grave_teletransporter",false) end
end

--DIALOGUE DE BIENVENUE DU MARCHAND AMBULANT
function trigger_shop:on_activated() 
  trigger_shop:set_enabled(false) 
  if game:get_value("get_hookshot") and game:get_value("get_glove") and game:get_value("get_flippers") then game:start_dialog("shop.welcome_merchant_all_sold")
  elseif game:get_value("trader_before_ruins_1st_time") then game:start_dialog("shop.welcome_merchant")
  else game:start_dialog("shop.welcome_merchant_1st_time") game:set_value("trader_before_ruins_1st_time",true) end
end

--DIALOGUES AVEC LE MARCHAND AMBULANT: DIAMANT CONTRE CAPE MAGIQUE
function trader:on_interaction()
  if game:get_value("get_magic_cape") then game:start_dialog("ruins_trader.trade_done")
  else game:start_dialog("ruins_trader.need_item") end
end
function trader:on_interaction_item(item)
  if item == game:get_item("inventory/echange") and item:get_variant() == 8 then
    game:start_dialog("ruins_trader.question",function(answer)
      if answer == 1 then
        game:start_dialog("ruins_trader.answer_yes",function()
          hero:start_treasure("inventory/magic_cape",1,"get_magic_cape",function()
            if game:get_item_assigned(1) == game:get_item("inventory/echange") then game:set_item_assigned(1, game:get_item("inventory/magic_cape")) end
            if game:get_item_assigned(2) == game:get_item("inventory/echange") then game:set_item_assigned(2, game:get_item("inventory/magic_cape")) end
          end)
        end)
      else game:start_dialog("ruins_trader.answer_no") end
    end)
  end
end

--TOMBE: ALLUMER BOUGIES POUR LA DEPLACER
local torch_prefix = "torch_grave_"
local remaining = 0
local function torch_on_lit()
  if not game:get_value("b1_grave_opened") then
    remaining = remaining - 1
    if remaining == 0 then
      map:move_camera(232,0,256,function() 
        local hall_stone_x,hall_stone_y = map:get_entity("grave"):get_position()
        local i = 0
        sol.timer.start(map,100,function()
          i = i + 1
          hall_stone_y = hall_stone_y - 1
          grave:set_position(hall_stone_x, hall_stone_y)
          if i < 16 then return true end
          sol.audio.play_sound("secret")
          game:set_value("b1_grave_opened",true)
          map:get_entity("ts.b1_grave_inscription"):set_enabled(false)
          grave_teletransporter:set_enabled(true)
        end)
      end,1000,3000)
    end
  end
end
local has_torches = false
for torch in map:get_entities(torch_prefix) do
  if game:get_value("b1_grave_opened") then torch:set_lit(true) end
  if torch:is_lit() == false then
    remaining = remaining + 1
  end
  torch.on_lit = torch_on_lit
  has_torches = true
end

--EFFET DE BRUME
map:register_event("on_draw", function(map, destination_surface)

 -- Make the overlay scroll with the camera, but slightly faster to make
  -- a depth effect.
  local camera_x, camera_y = map:get_camera():get_position()
  local overlay_width, overlay_height = map.overlay:get_size()
  local screen_width, screen_height = destination_surface:get_size()
  local x, y = camera_x + map.overlay_offset_x, camera_y + map.overlay_offset_y
  x, y = -math.floor(x * 1.5), -math.floor(y * 1.5)

  -- The overlay's image may be shorter than the screen, so we repeat its
  -- pattern. Furthermore, it also has a movement so let's make sure it
  -- will always fill the whole screen.
  x = x % overlay_width - 2 * overlay_width
  y = y % overlay_height - 2 * overlay_height

  local dst_y = y
  while dst_y < screen_height + overlay_height do
    local dst_x = x
    while dst_x < screen_width + overlay_width do
      -- Repeat the overlay's pattern.
      map.overlay:draw(destination_surface, dst_x, dst_y)
      dst_x = dst_x + overlay_width
    end
    dst_y = dst_y + overlay_height
  end

end,true)

function map:set_overlay()

  map.overlay = sol.surface.create("backgrounds/fog.png")
  map.overlay:set_opacity(192)
  map.overlay_offset_x = 0  -- Used to keep continuity when getting lost.
  map.overlay_offset_y = 0
  map.overlay_m = sol.movement.create("straight")
  map.restart_overlay_movement()

end

function map:restart_overlay_movement()

  map.overlay_m:set_speed(16) 
  map.overlay_m:set_max_distance(100)
  map.overlay_m:set_angle(map.overlay_angles[map.overlay_step])
  map.overlay_step = map.overlay_step + 1
  if map.overlay_step > #map.overlay_angles then
    map.overlay_step = 1
  end
  map.overlay_m:start(map.overlay, function()
    map:restart_overlay_movement()
  end)

end

--STATUE DE HIBOU
function owl_statue:on_interaction()
  game:set_dialog_style("stone")
  local game = map:get_game()
  if game:get_value("owl_ruins_activated") then
    game:start_dialog("teleportation.question",function(answer)
      if answer == 1 then
        sol.audio.play_sound("warp")
        hero:teleport("telep_light_world")
      end
    end)
  else
    game:start_dialog("teleportation.activation")
    game:set_value("owl_ruins_activated",true)
  end
end

--LUNES DE PUISSANCE CACHEES
function destructible_power_moon_1:on_lifting() 
  if hidden_power_moon_36 ~= nil then hidden_power_moon_36:set_enabled(true) end
end
function destructible_power_moon_2:on_cut() sol.timer.start(map,300,function() 
  if hidden_power_moon_38 ~= nil then hidden_power_moon_38:set_enabled(true) end 
end) end
function destructible_power_moon_2:on_lifting() 
  if hidden_power_moon_38 ~= nil then hidden_power_moon_38:set_enabled(true) end
end