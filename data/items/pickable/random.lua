local item = ...

-- When it is created, this item creates another item randomly chosen
-- and then destroys itself.

-- Probability of each item between 0 and 1000.
local probabilities = {
  [{ "pickable/bomb", 1 }]       = 50,    -- 1 bomb.
  [{ "pickable/bomb", 2 }]       = 10,    -- 5 bombs.
  [{ "pickable/arrow", 1 }]      = 50,    -- 1 arrow.
  [{ "pickable/arrow", 2 }]      = 10,    -- 5 arrows.
  [{ "pickable/rupee", 1 }]      = 50,   -- 1 rupee.
  [{ "pickable/rupee", 2 }]      = 10,   -- 5 rupees.
  [{ "pickable/magic_flask", 1}] = 200,   -- Small magic jar.
  [{ "pickable/heart", 1}]       = 200,  -- Heart.
}

function item:on_pickable_created(pickable)

  local treasure_name, treasure_variant = self:choose_random_item()
  if treasure_name ~= nil then
    local map = pickable:get_map()
    local x, y, layer = pickable:get_position()
    map:create_pickable{
      layer = layer,
      x = x,
      y = y,
      treasure_name = treasure_name,
      treasure_variant = treasure_variant,
    }
  end
  pickable:remove()
end

-- Returns an item name and variant.
function item:choose_random_item()

  local random = math.random(1000)
  local sum = 0

  for key, probability in pairs(probabilities) do
    sum = sum + probability
    if random < sum then
      return key[1], key[2]
    end
  end

  return nil
end