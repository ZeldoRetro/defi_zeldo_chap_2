--Shield: the 1st you get increases the attack. It can also protect you against some projectiles.

local item = ...
local map = item:get_map()

function item:on_created()

  self:set_savegame_variable("possession_shield")
  self:set_sound_when_picked(nil)
  self:set_shadow(nil)
end

function item:on_variant_changed(variant)
  -- The possession state of the shield determines the built-in ability "shield".
  self:get_game():set_ability("shield", variant)
end

function item:on_obtaining(variant)
  -- The firts shield increases the defense level of 1
  -- Obtaining the Mirror shield increases the defense level of 1 point.
  local game = item:get_game()
  local defense = game:get_value("defense")
  if variant == 1 then
    if not game:get_value("first_shield") then
      game:set_value("first_shield",true)
      defense = defense + 1
      game:set_value("defense", defense)
      sol.timer.start(10,function() game:start_dialog("_1st_shield") end)
    end
  elseif variant == 2 then
    if not game:get_value("first_shield") then
      game:set_value("first_shield",true)
      defense = defense + 1
      game:set_value("defense", defense)
      sol.timer.start(10,function() game:start_dialog("_1st_shield") end)
    end
  elseif variant == 3 then
    defense = defense + 1
    if not game:get_value("first_shield") then
      game:set_value("first_shield",true)
      defense = defense + 1
    end
    game:set_value("defense", defense)
  end
end