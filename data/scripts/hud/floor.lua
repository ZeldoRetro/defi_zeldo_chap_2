-- The floor view shown when entering a map that has a floor.

local floor_view_builder = {}

function floor_view_builder:new(game)

  local floor_view = {}

  function floor_view:initialize()

    floor_view.visible = false
    floor_view.surface = sol.surface.create(32, 85)
    floor_view.floors_img = sol.surface.create("floors.png", true)  -- Language-specific image
    floor_view.floor = nil
  end

  function floor_view:get_dungeon()

    if game.get_dungeon == nil then
      -- This game does not define a get_dungeon() method
      -- so we are not in a dungeon.
      return nil
    end

    return game:get_dungeon()
  end

  function floor_view:on_map_changed(map)

    local need_rebuild = false
    local floor = map:get_floor()
    if floor == floor_view.floor
        or (floor == nil and floor_view:get_dungeon() == nil) then
      -- No floor or unchanged floor.
      floor_view.visible = false
    else
      -- Show the floor view during 3 seconds.
      floor_view.visible = true
      local timer = sol.timer.start(3000, function()
        floor_view.visible = false
      end)
      timer:set_suspended_with_map(false)
      need_rebuild = true
    end

    floor_view.floor = floor

    if need_rebuild then
      floor_view:rebuild_surface()
    end
  end

  function floor_view:rebuild_surface()

    local highest_floor_displayed
    local dungeon = floor_view:get_dungeon()
    highest_floor_displayed = floor_view.floor

    -- Show the current floor then.
    local src_y
    local dst_y

    if floor_view.floor == nil and dungeon ~= nil then
      -- Special case of the unknown floor in a dungeon.
      src_y = 32 * 12
      dst_y = 0
    else
      src_y = (15 - floor_view.floor) * 12
      dst_y = (highest_floor_displayed - floor_view.floor) * 12
    end

    floor_view.floors_img:draw_region(0, src_y, 32, 13, floor_view.surface, 0, dst_y)
  end

  function floor_view:set_dst_position(x, y)
    floor_view.dst_x = x
    floor_view.dst_y = y
  end

  function floor_view:on_draw(dst_surface)

    if floor_view.visible then
      local x, y = floor_view.dst_x, floor_view.dst_y
      local width, height = dst_surface:get_size()
      if x < 0 then
        x = width + x
      end
      if y < 0 then
        y = height + y
      end

      floor_view.surface:draw(dst_surface, x, y)
    end
  end

  floor_view:initialize()

  return floor_view
end

return floor_view_builder


