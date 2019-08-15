-- The money counter shown in the game screen.

local rupees_builder = {}

function rupees_builder:new(game)

  local rupees = {}

  function rupees:initialize()

    rupees.surface = sol.surface.create(48, 12)
    rupees.surface:clear()
    rupees.digits_text = sol.text_surface.create({
      font = "white_digits",
    })
    rupees.digits_text:set_text(game:get_money())
    rupees.rupee_icons_img = sol.surface.create("hud/rupee_icon.png")
    rupees.rupee_bag_displayed = game:get_item("equipment/rupee_bag"):get_variant()
    rupees.money_displayed = game:get_money()

    rupees:check()
    rupees:rebuild_surface()
  end

  -- Checks whether the view displays correct information
  -- and updates it if necessary.
  function rupees:check()

    local need_rebuild = false
    local rupee_bag = game:get_item("equipment/rupee_bag"):get_variant()
    local money = game:get_money()

    -- Max money.
    if rupee_bag ~= rupees.rupee_bag_displayed then
      need_rebuild = true
      rupees.rupee_bag_displayed = rupee_bag
    end

    -- Current money.
    if money ~= rupees.money_displayed then
      need_rebuild = true

      if rupees.money_displayed < money then
        rupees.money_displayed = rupees.money_displayed + 1
      else
        rupees.money_displayed = rupees.money_displayed - 1
      end

      if rupees.money_displayed == money  -- The final value was just reached.
          or rupees.money_displayed % 5 == 0 then  -- Otherwise, play sound "rupee_counter_end" every 3 values.
        sol.audio.play_sound("rupee_counter_end")
      end
    end

    -- Redraw the surface only if something has changed.
    if need_rebuild then
      rupees:rebuild_surface()
    end

    -- Schedule the next check.
    sol.timer.start(game, 20, function()
      rupees:check()
    end)
  end

  function rupees:rebuild_surface()

    rupees.surface:clear()

    -- Max money (icon).
    rupees.rupee_icons_img:draw_region((rupees.rupee_bag_displayed - 1) * 12, 0, 12, 12, rupees.surface)

    -- Current rupee (counter).
    -- TODO show in green if the maximum is reached.
    if rupees.money_displayed == game:get_max_money() then
      rupees.digits_text:set_font("green_digits")
    else
      rupees.digits_text:set_font("white_digits")
    end
    rupees.digits_text:set_text(rupees.money_displayed)
    rupees.digits_text:draw(rupees.surface, 16, 5)
  end

  function rupees:set_dst_position(x, y)
    rupees.dst_x = x
    rupees.dst_y = y
  end

  function rupees:on_draw(dst_surface)

    local x, y = rupees.dst_x, rupees.dst_y
    local width, height = dst_surface:get_size()
    if x < 0 then
      x = width + x
    end
    if y < 0 then
      y = height + y
    end

    rupees.surface:draw(dst_surface, x, y)
  end

  rupees:initialize()

  return rupees
end

return rupees_builder