local effm = {}


local current_effect

local function apply_effect(map, effect)
  effect:on_map_changed(map)
end


local function on_map_draw(map,dst)
  if current_effect then
    current_effect:on_map_draw(map,dst)
  end
end

local current_game

local function init(game)
  game:register_event('on_map_changed', function(game,map)
    if current_effect then
      apply_effect(map,current_effect)
    end
    map:register_event('on_draw', on_map_draw)
  end)
  if game:get_map() then
    game:get_map():register_event('on_draw',on_map_draw)
  end
  current_game = game
end

function effm:set_effect(game, effect)
  if current_effect == effect then
    return --nothing to change
  end

  if current_game ~= game then
    init(game)
  end

  local map = game and game:get_map() or nil
  if current_effect then
    current_effect:clean(map)
  end

  if effect then
    apply_effect(map,effect)
  end
  current_effect = effect
end


return effm
