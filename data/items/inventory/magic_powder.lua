local item = ...
local game = item:get_game()

function item:on_created()

  -- Define the properties.
  self:set_savegame_variable("possession_magic_powder")
  self:set_assignable(true)
end

function item:on_using()
  local magic_needed = 4  -- Number of magic points required
  if self:get_game():get_magic() >= magic_needed then
     sol.audio.play_sound("magic_powder")
     game:remove_magic(magic_needed)
     item:create_powder()
  else
    sol.audio.play_sound("wrong")
    game:start_dialog("_need_magic")
  end
  self:set_finished()
end

-- Creates some powder on the map.
function item:create_powder()

  local map = item:get_map()
  local hero = map:get_hero()
  local direction = hero:get_direction()

  -- Enable collisions after a few frames.
  item.powder_active = false
  sol.timer.start(map, 150, function()
    item.powder_active = true
  end)
 
  -- Detect enemies with an invisible custom entity.
  local x, y, layer = hero:get_position()
  local direction4 = hero:get_direction()
  if direction4 == 0 then x = x + 12
  elseif direction4 == 1 then y = y - 12
  elseif direction4 == 2 then x = x - 12
  else y = y + 12
  end
  local dx, dy
  if direction == 0 then
    dx, dy = 14, -4
  elseif direction == 1 then
    dx, dy = 0, -20
  elseif direction == 2 then
    dx, dy = -16, -4
  else
    dx, dy = 0, 12
  end

  local x, y, layer = hero:get_position()
  local powder = map:create_custom_entity{
    x = x + dx,
    y = y + dy,
    layer = layer,
    width = 8,
    height = 8,
    direction = 0,
    sprite = "entities/magic_powder_effect",
  }
  --local powder_sprite = powder:get_sprite()
  --powder_sprite:set_ignore_suspend(true)
  local entities_touched = { }
  powder:set_origin(4, 5)
  powder:add_collision_test("overlapping", function(powder, entity)

    if not item:is_powder_active() then
      return
    end

    -- Hurt enemies.
    if entity:get_type() == "enemy" then
      local enemy = entity
      if entities_touched[enemy] then
        -- If protected we don't want to play the sound repeatedly.
        return
      end
      entities_touched[enemy] = true
      local reaction = enemy:get_powder_reaction(enemy_sprite)
      enemy:receive_attack_consequence("powder", reaction)
    end
  end)

  -- Start the animation.
  hero:freeze()
  hero:set_animation("magic_powder")
  sol.timer.start(400,function()
    powder:remove()
    hero:unfreeze()
  end)
end

function item:is_powder_active()
  return item.powder_active
end

-- Initialize the metatable of appropriate entities to work with the powder.
local function initialize_meta()

  -- Add Lua hammer properties to enemies.
  local enemy_meta = sol.main.get_metatable("enemy")
  if enemy_meta.get_powder_reaction ~= nil then
    -- Already done.
    return
  end

  enemy_meta.powder_reaction = "ignored"  -- ignored by default.
  enemy_meta.powder_reaction_sprite = {}
  function enemy_meta:get_powder_reaction(sprite)

    if sprite ~= nil and self.powder_reaction_sprite[sprite] ~= nil then
      return self.powder_reaction_sprite[sprite]
    end
    return self.powder_reaction
  end

  function enemy_meta:set_powder_reaction(reaction, sprite)

    self.powder_reaction = reaction
  end

  function enemy_meta:set_powder_reaction_sprite(sprite, reaction)

    self.powder_reaction_sprite[sprite] = reaction
  end

  -- Change the default enemy:set_invincible() to also
  -- take into account the powder.
  local previous_set_invincible = enemy_meta.set_invincible
  function enemy_meta:set_invincible()
    previous_set_invincible(self)
    self:set_powder_reaction("ignored")
  end
  local previous_set_invincible_sprite = enemy_meta.set_invincible_sprite
  function enemy_meta:set_invincible_sprite(sprite)
    previous_set_invincible_sprite(self, sprite)
    self:set_powder_reaction_sprite(sprite, "ignored")
  end

end
initialize_meta()