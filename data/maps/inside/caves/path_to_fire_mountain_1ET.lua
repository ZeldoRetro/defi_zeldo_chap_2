local map = ...
local game = map:get_game()

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local chest_manager = require("maps/lib/chest_manager")
chest_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

--EFFET DE CHALEUR
local heat = sol.surface.create(320,240)
heat:set_opacity(80)
heat:fill_color({255,40,0})

function map:on_draw(dst_surface)
  heat:draw(dst_surface)
end

-- DEBUT DE LA MAP
function map:on_started()
  map:set_entities_enabled("hidden_power_moon_",false)
end

--LUNES DE PUISSANCE CACHEES
function destructible_power_moon_1:on_cut() sol.timer.start(map,300,function() 
  if hidden_power_moon_19 ~= nil then hidden_power_moon_19:set_enabled(true) end 
end) end
function destructible_power_moon_1:on_lifting() 
  if hidden_power_moon_19 ~= nil then hidden_power_moon_19:set_enabled(true) end
end