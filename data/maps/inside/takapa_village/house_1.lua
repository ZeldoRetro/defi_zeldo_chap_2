local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
function map:on_started()

end

--DIALOGUES AVEC SAHASRAHLA
function sahasrahla:on_interaction()
  if game:get_value("sahasrahla_house_1st_time") then game:start_dialog("takapa_village.sahasrahla.house")
  else game:start_dialog("takapa_village.sahasrahla.house_1st_time") game:set_value("sahasrahla_house_1st_time",true) end
end