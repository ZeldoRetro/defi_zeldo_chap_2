local map = ...
local game = map:get_game()

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

local monicle_img = sol.surface.create("backgrounds/monicle.png")
monicle_img:set_opacity(92)

--INTERRUPTEUR ROUILLE
function rusty_switch_1:on_activated()
  sol.timer.start(200,function()
    local door_x,door_y = map:get_entity("auto_door_4"):get_position()
    sol.audio.play_sound("correct")
    map:move_camera(door_x,door_y,256,function() 
      map:open_doors("auto_door_4")
    end)
  end)
end