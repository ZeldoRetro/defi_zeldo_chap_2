local map = ...
local game = map:get_game()

-- DEBUT DE LA MAP
function map:on_started()
  game:set_value("dark_room",true)
  sol.timer.start(map,10,function() game:set_value("dark_room",false) end)
end

function lit_up_1:on_activated()
  self:set_enabled(false)
  torch_1_1:set_lit(true)
  torch_1_1:on_lit()
  torch_1_2:set_lit(true)
  torch_1_2:on_lit()
  sol.audio.play_sound("lamp")
end

function lit_up_2:on_activated()
  self:set_enabled(false)
  torch_2_1:set_lit(true)
  torch_2_1:on_lit()
  torch_2_2:set_lit(true)
  torch_2_2:on_lit()
  sol.audio.play_sound("lamp")
end

function lit_up_3:on_activated()
  self:set_enabled(false)
  torch_3_1:set_lit(true)
  torch_3_1:on_lit()
  torch_3_2:set_lit(true)
  torch_3_2:on_lit()
  sol.audio.play_sound("lamp")
end

function lit_up_4:on_activated()
  self:set_enabled(false)
  torch_4_1:set_lit(true)
  torch_4_1:on_lit()
  torch_4_2:set_lit(true)
  torch_4_2:on_lit()
  sol.audio.play_sound("lamp")
end