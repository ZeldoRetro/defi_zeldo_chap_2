-- The magic bar shown in the game screen.

local magic_bar_builder = {}

function magic_bar_builder:new(game)

  local magic_bar = {}

  function magic_bar:initialize()

    magic_bar.surface = sol.surface.create(111, 8)
    magic_bar.magic_bar_img = sol.surface.create("hud/magic_bar.png")
    magic_bar.container_sprite = sol.sprite.create("hud/magic_bar")
	self.container_img = sol.surface.create("hud/magic_bar.png")
    magic_bar.magic_displayed = game:get_magic()
    magic_bar.max_magic_displayed = 0

    magic_bar:check()
    magic_bar:rebuild_surface()
  end

  -- Checks whether the view displays the correct info
  -- and updates it if necessary.
  function magic_bar:check()

    local need_rebuild = false
    local max_magic = game:get_max_magic()
    local magic = game:get_magic()

    -- Maximum magic.
    if max_magic ~= magic_bar.max_magic_displayed then
      need_rebuild = true
      if magic_bar.magic_displayed > max_magic then
        magic_bar.magic_displayed = max_magic
      end
      magic_bar.max_magic_displayed = max_magic
    end

    -- Current magic.
    if magic ~= magic_bar.magic_displayed then
      need_rebuild = true
      local increment
      if magic < magic_bar.magic_displayed then
        increment = -1
      elseif magic > magic_bar.magic_displayed then
        increment = 1
      end
      if increment ~= 0 then
        magic_bar.magic_displayed = magic_bar.magic_displayed + increment

        -- Play the magic bar sound.
        if (magic - magic_bar.magic_displayed) % 10 == 1 then
          sol.audio.play_sound("magic_bar")
        end
      end
    end

    -- Redraw the surface only if something has changed.
    if need_rebuild then
      magic_bar:rebuild_surface()
    end

    -- Schedule the next check.
    sol.timer.start(game, 20, function()
      magic_bar:check()
    end)
  end

  function magic_bar:rebuild_surface()

    magic_bar.surface:clear()

    -- Max magic.
  self.container_img:draw_region(46, 8, 2 + self.max_magic_displayed, 8, self.surface)
  self.container_img:draw_region(155, 8, 2, 8, self.surface, self.max_magic_displayed + 2, 0)

    -- Current magic.
    magic_bar.magic_bar_img:draw_region(46, 24, 2 + magic_bar.magic_displayed, 8, magic_bar.surface)
  end

  function magic_bar:set_dst_position(x, y)
    magic_bar.dst_x = x
    magic_bar.dst_y = y
  end

  function magic_bar:on_draw(dst_surface)

    -- Is there a magic bar to show?
    if magic_bar.max_magic_displayed > 0 then
      local x, y = magic_bar.dst_x, magic_bar.dst_y
      local width, height = dst_surface:get_size()
      if x < 0 then
        x = width + x
      end
      if y < 0 then
        y = height + y
      end

      magic_bar.surface:draw(dst_surface, x, y)
    end
  end

  magic_bar:initialize()

  return magic_bar
end

return magic_bar_builder

