----------------------------------
--
-- Explosion allowing some additional properties.
--
-- Custom properties : strength, hurtable_type_[1 to 10]
--
----------------------------------

local explosion = ...
local sprite = explosion:create_sprite("entities/explosion")

-- Configuration variables.
local strength = tonumber(explosion:get_property("strength")) or 2
local hurtable_types = {}
for i = 1, 10 do
  local type = explosion:get_property("hurtable_type_" .. i)
  if not type then
    break
  end
  table.insert(hurtable_types, type)
end
if #hurtable_types == 0 then
  hurtable_types = {"enemy", "hero"}
end

-- Hurt colliding hero or enemies if needed.
explosion:add_collision_test("sprite", function(explosion, entity)

  for _, type in pairs(hurtable_types) do
    if entity:get_type() == type then
      if entity:get_type() == "enemy" then
        entity:receive_attack_consequence("explosion", entity:get_attack_consequence("explosion"))
      elseif entity:get_type() == "hero" and not entity:is_invincible()then
        entity:start_hurt(explosion, strength)
      end
    end
  end
end)

-- Explode at creation.
explosion:register_event("on_created", function(explosion)

  sprite:set_animation("explosion", function()
    explosion:remove()
  end)
end)