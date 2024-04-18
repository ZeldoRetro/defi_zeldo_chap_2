-- Initialize enemy behavior specific to this quest.

require("scripts/multi_events")
local entity_manager= require("scripts/entity_manager") 

local enemy_meta = sol.main.get_metatable("enemy")

function enemy_meta:on_created()

  local name = self:get_name()
  if name == nil then
    return
  end
  if name:match("^invisible_enemy") then
    self:set_visible(false)
  end

end

-- Redefine how to calculate the damage inflicted by the sword.
function enemy_meta:on_hurt_by_sword(hero, enemy_sprite)

  local force = hero:get_game():get_value("force")
  local reaction = self:get_attack_consequence_sprite(enemy_sprite, "sword")
  -- Multiply the sword consequence by the force of the hero.
  local life_lost = reaction * force
  if hero:get_state() == "sword spin attack" then
    -- And multiply this by 2 during a spin attack.
    life_lost = life_lost * 2
  end
  self:remove_life(life_lost)
end

-- Helper function to inflict an explicit reaction from a scripted weapon.
-- TODO this should be in the Solarus API one day
function enemy_meta:receive_attack_consequence(attack, reaction)

  if type(reaction) == "number" then
    self:hurt(reaction)
  elseif reaction == "immobilized" then
    self:immobilize()
  elseif reaction == "protected" then
    sol.audio.play_sound("sword_tapping")
  elseif reaction == "custom" then
    if self.on_custom_attack_received ~= nil then
      self:on_custom_attack_received(attack)
    end
  end

end

--Miniboss
function enemy_meta:on_dead()
  local game = self:get_game()
  local name = self:get_name()
  local hero = game:get_hero()
  local map = game:get_map()
  local music_map = map:get_music()

  if name == nil then
    return
  end

  if name:match("^miniboss") then
    if not map:has_entities("miniboss") then
      local door_x, door_y = map:get_entity("door_miniboss_2"):get_position()
      sol.audio.play_sound("correct")
      map:move_camera(door_x,door_y,256,function() 
        map:open_doors("door_miniboss") 
        map:set_entities_enabled("telep_miniboss",true)
        game:set_value("miniboss_"..game:get_dungeon_index(),true)
        sol.audio.play_music(music_map)
      end)
    end
  end
end

--Boss: freeze le jeu pendant sa mort et fait apparaitre un réceptacle au milieu de la pièce
function enemy_meta:on_dying()
  local game = self:get_game()
  local name = self:get_name()
  local hero = game:get_hero()
  local map = game:get_map()

  if name == nil then
    return
  end

  if name:match("^boss") then
    local door_x, door_y = map:get_entity("door_boss_2"):get_position()
    hero:freeze()
    game:set_pause_allowed(false)
    sol.audio.play_music("none")
    sol.timer.start(6000,function()
      sol.audio.play_sound("correct")
      map:move_camera(door_x,door_y,256,function()  
        map:open_doors("door_boss_2") 
        game:set_pause_allowed(true)
        hero:unfreeze()
        sol.audio.play_music("after_boss")
        map:set_entities_enabled("after_boss",true)
        local x, y = map:get_entity("heart_container_spot"):get_position()
        self:get_map():create_pickable{
          treasure_name = "quest_items/heart_container",
          treasure_variant = 1,
          treasure_savegame_variable = "heart_container_"..game:get_dungeon_index(),
          x = x,
          y = y,
          layer = 1
        }
      end)
    end)
  end
end

enemy_meta:register_event("on_removed", function(enemy)

    local game = enemy:get_game()
    local map = game:get_map()
    if enemy:get_ground_below()== "hole" and enemy:get_obstacle_behavior()=="normal" then
      entity_manager:create_falling_entity(enemy)
    elseif enemy:get_ground_below()== "deep_water" and enemy:get_obstacle_behavior()=="normal" then
      entity_manager:create_drowning_entity(enemy)
    elseif enemy:get_ground_below()== "lava" and enemy:get_obstacle_behavior()=="normal" then
      entity_manager:create_burning_entity(enemy)
    end
end)

return true