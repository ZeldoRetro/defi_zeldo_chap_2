-- The clock shows the cycle of the Time.

local clock_builder = {}

local clock_img_day = sol.surface.create("hud/clock_day.png")
local clock_img_twilight = sol.surface.create("hud/clock_twilight.png")
local clock_img_night = sol.surface.create("hud/clock_night.png")
local clock_img_dawn = sol.surface.create("hud/clock_dawn.png")

function clock_builder:new(game)

  local clock = {}

  function clock:set_dst_position(x, y)
    self.dst_x = x
    self.dst_y = y
  end

  function clock:on_draw(dst_surface)

    local x, y = self.dst_x, self.dst_y
    local width, height = dst_surface:get_size()
    if x < 0 then
      x = width + x
    end
    if y < 0 then
      y = height + y
    end

    if game:get_value("day") then
      clock_img_day:draw(dst_surface, x-2, y-2)
    elseif game:get_value("twilight") then
      clock_img_twilight:draw(dst_surface, x-2, y-2)
    elseif game:get_value("night") then
      clock_img_night:draw(dst_surface, x-2, y-2)
    elseif game:get_value("dawn") then
      clock_img_dawn:draw(dst_surface, x-2, y-2)
    end
  end

  return clock
end

return clock_builder