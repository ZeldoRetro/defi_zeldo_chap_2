-- Hearts view used in game screen and in the savegames selection screen.

local hearts_builder = {}

function hearts_builder:new(game)

  local hearts = {}

  function hearts:initialize()

    hearts.surface = sol.surface.create(200, 18)
    hearts.empty_heart_sprite = sol.sprite.create("hud/empty_heart")
    hearts.dst_x = 0
    hearts.dst_y = 0
    hearts.nb_max_hearts_displayed = game:get_max_life() / 4
    hearts.nb_current_hearts_displayed = game:get_life()
    hearts.all_hearts_img = sol.surface.create("hud/hearts.png")
  end

  function hearts:on_started()

    -- This function is called when the HUD starts or
    -- was disabled and gets enabled again.
    -- Unlike other HUD elements, the timers were canceled because they
    -- are attached to the menu and not to the game
    -- (this is because the hearts are also used in the savegame menu).
    hearts.danger_sound_timer = nil
    hearts:check()
    hearts:rebuild_surface()
  end

  -- Checks whether the view displays correct information
  -- and updates it if necessary.
  function hearts:check()

    local need_rebuild = false

    -- Maximum life.
    local nb_max_hearts = game:get_max_life() / 4
    if nb_max_hearts ~= hearts.nb_max_hearts_displayed then
      need_rebuild = true
      hearts.nb_max_hearts_displayed = nb_max_hearts
    end

    -- Current life.
    local nb_current_hearts = game:get_life()
    if nb_current_hearts ~= hearts.nb_current_hearts_displayed then

      need_rebuild = true
      if nb_current_hearts < hearts.nb_current_hearts_displayed then
        hearts.nb_current_hearts_displayed = hearts.nb_current_hearts_displayed - 1
      else
        hearts.nb_current_hearts_displayed = hearts.nb_current_hearts_displayed + 1
        if game:is_started()
            and hearts.nb_current_hearts_displayed % 4 == 0 then
          sol.audio.play_sound("heart")
        end
      end
    end

    -- If we are in-game, play an animation and a sound if the life is low.
    if game:is_started() then

      if game:get_life() <= game:get_max_life() / 4
          and not game:is_suspended() then
        need_rebuild = true
        -- TODO Show animation "danger" of the empty heart sprite if not already done.
        if hearts.empty_heart_sprite:get_animation() ~= "danger" then
          hearts.empty_heart_sprite:set_animation("danger")
        end
        if hearts.danger_sound_timer == nil then
          hearts.danger_sound_timer = sol.timer.start(hearts, 250, function()
            hearts:repeat_danger_sound()
          end)
          hearts.danger_sound_timer:set_suspended_with_map(true)
        end
      else
        if hearts.empty_heart_sprite:get_animation() ~= "normal" then
          hearts.empty_heart_sprite:set_animation("normal")
          need_rebuild = true
        end
      end
    end

    -- Redraw the surface only if something has changed.
    if need_rebuild then
      hearts:rebuild_surface()
    end

    -- Schedule the next check.
    sol.timer.start(game, 50, function()
      hearts:check()
    end)
  end

  function hearts:repeat_danger_sound()

    if game:get_life() <= game:get_max_life() / 4 then

      sol.audio.play_sound("danger")
      hearts.danger_sound_timer = sol.timer.start(hearts, 1000, function()
        hearts:repeat_danger_sound()
      end)
      hearts.danger_sound_timer:set_suspended_with_map(true)
    else
      hearts.danger_sound_timer = nil
    end
  end

  -- Pour modifier le nb de coeurs par rangée: changer la valeur (i % x)
  function hearts:rebuild_surface()

    hearts.surface:clear()

    -- Display the hearts.
    for i = 0, hearts.nb_max_hearts_displayed - 1 do
      local x, y = (i % 8) * 9, math.floor(i / 8) * 9
      -- TODO Draw the heart container sprite before the heart.
      hearts.empty_heart_sprite:draw(hearts.surface, x, y)
      if i < math.floor(hearts.nb_current_hearts_displayed / 4) then
        -- This heart is full.
        hearts.all_hearts_img:draw_region(27, 0, 9, 8, hearts.surface, x, y)
      end
    end

    -- Last fraction of heart.
    local i = math.floor(hearts.nb_current_hearts_displayed / 4)
    local remaining_fraction = hearts.nb_current_hearts_displayed % 4
    if remaining_fraction ~= 0 then
      local x, y = (i % 8) * 9, math.floor(i / 8) * 9
      hearts.all_hearts_img:draw_region((remaining_fraction - 1) * 9, 0, 9, 8, hearts.surface, x, y)
    end
  end

  function hearts:set_dst_position(x, y)
    hearts.dst_x = x
    hearts.dst_y = y
  end

  function hearts:on_draw(dst_surface)

    local x, y = hearts.dst_x, hearts.dst_y
    local width, height = dst_surface:get_size()
    if x < 0 then
      x = width + x
    end
    if y < 0 then
      y = height + y
    end

    hearts.surface:draw(dst_surface, x, y)
  end

  hearts:initialize()

  return hearts
end

return hearts_builder

