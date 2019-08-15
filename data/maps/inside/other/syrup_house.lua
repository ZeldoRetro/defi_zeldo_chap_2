local map = ...
local game = map:get_game()

--INTERACTIONS AVEC SYRUP: ECHANGER UN CHAMPIGNON CONTRE DE LA POUDRE MAGIQUE
function syrup:on_interaction()
  if game:get_value("get_magic_powder") then 
    game:start_dialog("forest.syrup.get_mushroom")
  else 
    game:start_dialog("forest.syrup.need_mushroom") 
  end
end
function syrup:on_interaction_item(item)
  if item == game:get_item("inventory/magic_mushroom") then
    game:start_dialog("forest.syrup.give_powder",function()
      hero:start_treasure("inventory/magic_powder",1,"get_magic_powder",function()
        if game:get_item_assigned(1) == game:get_item("inventory/magic_mushroom") then game:set_item_assigned(1, game:get_item("inventory/magic_powder")) end
        if game:get_item_assigned(2) == game:get_item("inventory/magic_mushroom") then game:set_item_assigned(2, game:get_item("inventory/magic_powder")) end
      end)
    end)
  end
end