--Piece of Heart: Collects 4 of them to have an heart container.

local item = ...
local game = item:get_game()

local message_id = {
  "found_piece_of_heart.1",
  "found_piece_of_heart.2",
  "found_piece_of_heart.3",
  "found_piece_of_heart.4"
}
local icon_sprite
local icon_widget = {}

-- Returns the current number of pieces of heart between 0 and 3.
function item:get_num_pieces_of_heart()
  return game:get_value("num_pieces_of_heart") or 0
end

-- Returns the total number of pieces of hearts already found.
function item:get_total_pieces_of_heart()
  return game:get_value("total_pieces_of_heart") or 0
end

-- Returns the number of pieces of hearts existing in the game.
function item:get_max_pieces_of_heart()
  return 12
end

function item:on_created()
  self:set_sound_when_picked(nil)
  self:set_sound_when_brandished("piece_of_heart")
end

function item:on_obtained(variant)

  -- The dialog has just finished, stop showing the piece of heart icon.
  sol.menu.stop(icon_widget)

  -- Show another dialog indicating the number of pieces of heart
  -- remaining to get a new heart container.
  local num_pieces_of_heart = item:get_num_pieces_of_heart()
  game:start_dialog(message_id[num_pieces_of_heart + 1], function()

    game:set_value("num_pieces_of_heart", (num_pieces_of_heart + 1) % 4)
    game:set_value("total_pieces_of_heart", item:get_total_pieces_of_heart() + 1)
    if num_pieces_of_heart == 3 then
      game:add_max_life(4)
    end
    game:set_life(game:get_max_life())
  end)
end

function icon_widget:on_started()

  if icon_sprite == nil then
    icon_sprite = sol.sprite.create("hud/piece_of_heart_icon")
  end
  icon_sprite:set_direction(item:get_num_pieces_of_heart() + 1)
end

function icon_widget:on_draw(dst_surface)
  icon_sprite:draw(dst_surface)
end

-- If you want to know your missing pieces of heart, uncomment the line below
-- item:print_pieces_of_heart()