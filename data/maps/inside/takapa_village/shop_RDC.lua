local map = ...
local game = map:get_game()

--DIALOGUES DE BIENVENUE DU MARCHAND
function trigger_dialog_rdc:on_activated()
  trigger_dialog_rdc:set_enabled(false)
  if game:get_value("get_bottle_1") and game:get_value("hp_8") and game:get_value("power_moon_50") then
    game:start_dialog("shop.welcome_takapa_shop_rdc_ss1_empty")
  else
    game:start_dialog("shop.welcome_takapa_shop_rdc")
  end
end

function map:on_started(destination)
  if destination == rdc then trigger_dialog_rdc:set_enabled(false) end
end