local presentation_screen = {}

local presentation_img = sol.surface.create("menus/presentation.png")

function presentation_screen:on_started()
  sol.audio.play_sound("intro")
  sol.timer.start(presentation_screen,2000,function() presentation_img:fade_out(20,function() sol.menu.stop(presentation_screen) end) end)
end

function presentation_screen:on_draw(dst_surface)
  presentation_img:draw(dst_surface)
end

return presentation_screen