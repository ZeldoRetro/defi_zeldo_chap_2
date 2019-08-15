local map = ...
local game = map:get_game()

function map:on_started() 

  --PIECE DANS LE NOIR COMPLET
  game:set_value("dark_room",true)
 
  --Pendant la journée, lumière qui sort des fenètres/portes d'entrée
  if game:get_value("night") or game:get_value("dawn") then
    --Jour/Crépuscule
    map:set_entities_enabled("day_entity",false)
  end
end