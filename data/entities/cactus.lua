-- A cactus/pike that hurts the hero when he touches it.
-- Not implemented as an enemy because enemies hurt the hero when
-- overlapping them, not when touching them.
-- And we want the cactus/pike to be an obstacle.
local cactus = ...

local allowed_states = {
  ["carrying"] = true,
  ["free"] = true,
  ["pulling"] = true,
  ["pushing"] = true,
  ["swimming"] = true,
  ["sword loading"] = true,
  ["sword spin attack"] = true,
  ["sword swinging"] = true,
  ["sword tapping"] = true,
}

function cactus:on_created()

  cactus:set_size(16, 16)
  cactus:set_origin(8, 13)
  cactus:set_traversable_by(false)
  cactus:set_drawn_in_y_order(false)

end

cactus:add_collision_test("touching", function(cactus, entity)

  if entity:get_type() ~= "hero" then
    return
  end

  local hero = entity

  if hero:is_invincible() then
    return
  end

  local current_state = hero:get_state()
  if not allowed_states[current_state] then
    return
  end

	entity:get_game():remove_life(3)
  hero:start_hurt(cactus, 1)
end)