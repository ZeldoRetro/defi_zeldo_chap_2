local map = ...
local game = map:get_game()

--FONCTION DE REVENTE DES OBJETS
local current_item
local variable_item
local amount
local price
local function resale()
  if game:get_item(current_item):get_amount() == 0 then sol.audio.play_sound("wrong") return end
  game:start_dialog("antiquarian.reflexion",function()
    game:start_dialog("antiquarian.amount_"..amount.."_resell",price,function()
      game:start_dialog("antiquarian.question",function(answer)
        if answer == 1 then
          game:add_money(price)
          game:get_item(current_item):remove_amount(1)
          if variable_item ~= nil then game:set_value("antiquarian_"..variable_item.."_sold",true) end
          game:start_dialog("antiquarian.resale_yes")
        else
          game:start_dialog("antiquarian.resale_no")
        end
      end)
    end)
  end)
end

--INTERACTIONS AVEC L'ANTIQUAIRE ET PRIX DES ARTICLES REVENDUS
function antiquarian:on_interaction_item(item)
  if item == game:get_item("treasures/loot_chuchu_red") then
    current_item = "treasures/loot_chuchu_red"
    amount = "very_small"
    price = 5
    resale()
  elseif item == game:get_item("treasures/loot_lucky_egg") then
    current_item = "treasures/loot_lucky_egg"
    amount = "big"
    price = 500
    resale()
  elseif item == game:get_item("treasures/treasure_amber_pearl") then
    current_item = "treasures/treasure_amber_pearl"
    variable_item = "treasure_amber_pearl"
    amount = "small"
    price = 50
    resale()
  elseif item == game:get_item("treasures/treasure_golden_ore") then
    current_item = "treasures/treasure_golden_ore"
    variable_item = "treasure_golden_ore"
    amount = "bigger"
    price = 5000
    resale()
  elseif item == game:get_item("treasures/treasure_moon") then
    current_item = "treasures/treasure_moon"
    variable_item = "treasure_moon"
    amount = "bigger"
    price = 9999
    resale()
  else
    sol.audio.play_sound("wrong")
    game:start_dialog("antiquarian.cant_resell")
  end
end

--LES TRESORS REVENDUS SONT PROPOSES PAR L'ANTIQUAIRE
function map:on_started()
  map:set_entities_enabled("article",false)
  if game:get_value("antiquarian_treasure_amber_pearl_sold") then article_amber_pearl:set_enabled(true) end
  if game:get_value("antiquarian_treasure_golden_ore_sold") then article_golden_ore:set_enabled(true) end
  if game:get_value("antiquarian_treasure_moon_sold") then article_moon:set_enabled(true) end
end

--DIALOGUES BASIQUES AVEC L'ANTIQUAIRE
function antiquarian:on_interaction()
  if game:get_value("antiquarian_1st_time") then game:start_dialog("antiquarian.welcome")
  else game:set_value("antiquarian_1st_time",true) game:start_dialog("antiquarian.1st_time") end
end