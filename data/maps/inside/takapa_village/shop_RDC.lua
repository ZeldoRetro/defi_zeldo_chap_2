local map = ...
local game = map:get_game()

--DIALOGUES DE BIENVENUE DU MARCHAND
function trigger_dialog_rdc:on_activated() trigger_dialog_rdc:set_enabled(false) game:start_dialog("shop.welcome_takapa_shop_rdc") end

function map:on_started(destination)
  if destination == rdc then trigger_dialog_rdc:set_enabled(false) end
end