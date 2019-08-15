local map = ...
local game = map:get_game()

--DEBUT DE LA MAP
function map:on_started()

  --Quarts de coeur achetés
  if hp_1 ~= nil then
    hp_2:set_enabled(false)
    hp_3:set_enabled(false)
    hp_4:set_enabled(false)
  elseif hp_2 ~= nil then
    hp_3:set_enabled(false)
    hp_4:set_enabled(false)
  elseif hp_3 ~= nil then
    hp_4:set_enabled(false)
  end

  --Lunes achetées
  if power_moon_41 ~= nil then
    power_moon_42:set_enabled(false)
    power_moon_43:set_enabled(false)
    power_moon_44:set_enabled(false)
    power_moon_45:set_enabled(false)
    power_moon_46:set_enabled(false)
    power_moon_47:set_enabled(false)
    power_moon_48:set_enabled(false)
    power_moon_49:set_enabled(false)
    power_moon_50:set_enabled(false)
  elseif power_moon_42 ~= nil then
    power_moon_43:set_enabled(false)
    power_moon_44:set_enabled(false)
    power_moon_45:set_enabled(false)
    power_moon_46:set_enabled(false)
    power_moon_47:set_enabled(false)
    power_moon_48:set_enabled(false)
    power_moon_49:set_enabled(false)
    power_moon_50:set_enabled(false)
  elseif power_moon_43 ~= nil then
    power_moon_44:set_enabled(false)
    power_moon_45:set_enabled(false)
    power_moon_46:set_enabled(false)
    power_moon_47:set_enabled(false)
    power_moon_48:set_enabled(false)
    power_moon_49:set_enabled(false)
    power_moon_50:set_enabled(false)
  elseif power_moon_44 ~= nil then
    power_moon_45:set_enabled(false)
    power_moon_46:set_enabled(false)
    power_moon_47:set_enabled(false)
    power_moon_48:set_enabled(false)
    power_moon_49:set_enabled(false)
    power_moon_50:set_enabled(false)
  elseif power_moon_45 ~= nil then
    power_moon_46:set_enabled(false)
    power_moon_47:set_enabled(false)
    power_moon_48:set_enabled(false)
    power_moon_49:set_enabled(false)
    power_moon_50:set_enabled(false)
  elseif power_moon_46 ~= nil then
    power_moon_47:set_enabled(false)
    power_moon_48:set_enabled(false)
    power_moon_49:set_enabled(false)
    power_moon_50:set_enabled(false)
  elseif power_moon_47 ~= nil then
    power_moon_48:set_enabled(false)
    power_moon_49:set_enabled(false)
    power_moon_50:set_enabled(false)
  elseif power_moon_48 ~= nil then
    power_moon_49:set_enabled(false)
    power_moon_50:set_enabled(false)
  elseif power_moon_49 ~= nil then
    power_moon_50:set_enabled(false)
  end
end

--DIALOGUES DE BIENVENUE DU MARCHAND
function trigger_dialog_ss1:on_activated()
  trigger_dialog_ss1:set_enabled(false)
  if game:get_value("get_bottle_1") and game:get_value("hp_8") and game:get_value("power_moon_50") then game:start_dialog("shop.welcome_takapa_shop_ss1_all_sold") 
  else game:start_dialog("shop.welcome_takapa_shop_ss1")
  end
end

function map:on_obtained_treasure(item, variant, savegame_variable)

  --Achat des quarts de coeur: Le suivant sera plus cher.
  if item:get_name() == "quest_items/piece_of_heart" and variant == 1 then
      local next_hp
      if savegame_variable == "hp_5" then
        next_hp = hp_2
      elseif savegame_variable == "hp_6" then
        next_hp = hp_3
      elseif savegame_variable == "hp_7" then
        next_hp = hp_4
      elseif savegame_variable == "hp_8" then
        sol.timer.start(10,function() game:start_dialog("takapa_village.shop.hp_done") end)
      end
      if next_hp ~= nil then
        sol.timer.start(10,function() game:start_dialog("takapa_village.shop.next_hp", function()
          next_hp:set_enabled(true)
        end)
        end)
      end
  end

  --Achat des Lunes de Puissance: La suivante sera plus cher.
  if item:get_name() == "quest_items/power_moon" and variant == 1 then
      local next_moon
      if savegame_variable == "power_moon_41" then
        next_moon = power_moon_42
      elseif savegame_variable == "power_moon_42" then
        next_moon = power_moon_43
      elseif savegame_variable == "power_moon_43" then
        next_moon = power_moon_44
      elseif savegame_variable == "power_moon_44" then
        next_moon = power_moon_45
      elseif savegame_variable == "power_moon_45" then
        next_moon = power_moon_46
      elseif savegame_variable == "power_moon_46" then
        next_moon = power_moon_47
      elseif savegame_variable == "power_moon_47" then
        next_moon = power_moon_48
      elseif savegame_variable == "power_moon_48" then
        next_moon = power_moon_49
      elseif savegame_variable == "power_moon_49" then
        next_moon = power_moon_50
      elseif savegame_variable == "power_moon_50" then
        sol.timer.start(10,function() game:start_dialog("takapa_village.shop.moons_done") end)
      end
      if next_moon ~= nil then
        sol.timer.start(10,function() game:start_dialog("takapa_village.shop.next_moon", function()
          next_moon:set_enabled(true)
        end)
        end)
      end
  end
end