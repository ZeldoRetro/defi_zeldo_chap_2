-- This script handles all bottles (each bottle script runs it).

local item = ...

local link_voice_manager = require("scripts/link_voice_manager")

local function drink_potion(variant)

  local game = item:get_game()
  local map = item:get_map()
  local hero = map:get_hero()

  hero:freeze()
  sol.audio.play_sound("link_drinking")
  hero:set_animation("drinking")
  local hero_x, hero_y, hero_layer = hero:get_position()
  local potion = map:create_custom_entity({
    direction = 0,
    x = hero_x,
    y = hero_y,
    layer = map:get_max_layer(),
    width = 16,
    height = 16,
  })
  potion:set_drawn_in_y_order(true)
  local potion_sprite = potion:create_sprite("entities/drinking_potion")
  potion_sprite:set_animation(variant)

  function potion_sprite:on_animation_finished()

    if variant == 3 or variant == 5 then
      game:add_life(game:get_max_life())
    end
    if variant == 4 or variant == 5 then
      game:add_magic(game:get_max_magic())
    end
    item:set_variant(1)
    potion:remove()
    if link_voice_manager:get_link_voice_enabled() then sol.audio.play_sound("link_drinking_end") end
    hero:unfreeze()
  end
end

function item:on_using()

  local variant = self:get_variant()
  local game = self:get_game()
  local map = self:get_map()

  -- empty bottle
  if variant == 1 then
    sol.audio.play_sound("wrong")
    self:set_finished()

    -- water
  elseif variant == 2 then
  	-- empty the water
  	self:set_variant(1) -- make the bottle empty
  	sol.audio.play_sound("item_in_water")
    self:set_finished()

    -- red potion
  elseif variant == 3 then
    drink_potion(variant)
    self:set_finished()

    -- green potion
  elseif variant == 4 then
    drink_potion(variant)
    self:set_finished()

    -- blue potion
  elseif variant == 5 then
    drink_potion(variant)
    self:set_finished()

    -- fairy
  elseif variant == 6 then

    -- release the fairy
    local x, y, layer = map:get_entity("hero"):get_position()
    map:create_pickable{
      treasure_name = "pickable/fairy",
      treasure_variant = 1,
      x = x,
      y = y,
      layer = layer
    }
    self:set_variant(1) -- make the bottle empty
    self:set_finished()
  end
end

function item:on_npc_interaction(npc)

  if npc:get_name():find("^water_for_bottle") then
    local game = self:get_game()
    local map = self:get_map()
    -- The hero interacts with a place where he can get some water.
    if game:has_bottle() then
      local first_empty_bottle = game:get_first_empty_bottle()
      if first_empty_bottle ~= nil then
        game:start_dialog("found_water", function(answer)
  	      if answer == 1 then
              local hero = map:get_entity("hero")
              hero:start_treasure(first_empty_bottle:get_name(), 2, nil)
  	      end
	      end)
      else
        sol.audio.play_sound("wrong")
        game:start_dialog("found_water.no_empty_bottle")
      end
    else
      sol.audio.play_sound("wrong")
      game:start_dialog("found_water.no_bottle")
    end
  end
end

function item:on_npc_interaction_item(npc, item_used)

  if item_used:get_name():find("^bottle")
      and npc:get_name():find("^water_for_bottle") then
    -- the hero interacts with a place where he can get some water:
    -- no matter whether he pressed the action key or the item key of a bottle, we do the same thing
    self:on_npc_interaction(npc)
    return true
  end

  return false
end