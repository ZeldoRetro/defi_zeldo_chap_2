-- Initialize npcs behavior specific to this quest.

require("scripts/multi_events")

local npc_meta = sol.main.get_metatable("npc")

function npc_meta:on_interaction()
  local game = self:get_game()
  local name = self:get_name()
  local hero = game:get_hero()
  local map = game:get_map()

  if name == nil then
    return
  end

  --Stèles
  if name:match("^ts") then
    game:set_dialog_style("stone")
    game:start_dialog(name)
  end

  --Stèle à la fin du donjon: fais apparaitre un téléporteur vers l'entrée
  if name:match("^stele_telep_boss") then
    game:set_dialog_style("stone")
    game:start_dialog("ts.telep_boss",function()
      if not game:get_value("telep_boss_"..game:get_dungeon_index()) then
        local telep_x,telep_y = map:get_entity("telep_boss"):get_position()
        map:move_camera(telep_x,telep_y,256,function() 
          sol.audio.play_sound("secret")
          map:set_entities_enabled("telep_boss",true)
          game:set_value("telep_boss_"..game:get_dungeon_index(),true)  
        end)
      end
    end)
  end

  --Stèles en hylien
  if name:match("^hs") then
    game:set_dialog_style("stone")
    if not game:has_item("book_of_mudora") then
      sol.audio.play_sound("wrong")
      game:start_dialog("hs.need_book_of_mudora")
      return
    end
    game:start_dialog(name)
  end

  --Pancartes
  if name:match("^sign") then
    game:set_dialog_style("wood")
    game:start_dialog(name)
  end

  --Boites aux lettres
  if name:match("^mailbox") then
    game:set_dialog_style("wood")
    game:start_dialog(name)
  end

  --Soldats: disent un dialogue aléatoire
  if name:match("^soldier") then
    local i = math.random(5)
    game:start_dialog("takapa_village.soldiers."..i)
  end

  --Lit pour dormir: Passage jour/nuit + Restauration d'une partie de la santé
  if name:match("^bed") then
    game:start_dialog("inn.bed.rest",function(answer)
      if answer == 1 then
  			sol.audio.play_sound("day_night")
   			if game:get_value("night") or game:get_value("dawn") then
          game:set_value("daytime", 1)
          game:set_value("day",true)
          game:set_value("twilight",false) 
          game:set_value("night",false)
          game:set_value("dawn",false)			
  			else
          game:set_value("daytime", 4)
          game:set_value("day",false)
          game:set_value("twilight",false) 
          game:set_value("night",true)
          game:set_value("dawn",false)
   			end 
   			hero:teleport(game:get_map():get_id(),"sortie_lit","fade")  
        sol.timer.start(600,function()
          game:set_life(game:get_max_life())
          game:set_pause_allowed(false)
          game:get_map():get_entity("snores"):set_enabled(true)
          game:get_map():get_entity("snores"):get_sprite():set_ignore_suspend(true)
          game:get_map():get_entity("bed"):get_sprite():set_animation("hero_sleeping")
          game:get_map():get_entity("bed"):get_sprite():set_direction(game:get_ability("tunic") - 1)
          hero:freeze()
          hero:set_visible(false)
          sol.timer.start(map, 2000, function()
            -- Begin dialog
            game:get_map():set_entities_enabled("exit",false)
            sol.timer.start(map, 1000, function()
              -- Wake up.
              game:get_map():get_entity("snores"):set_enabled(false)
              game:get_map():get_entity("bed"):get_sprite():set_animation("hero_waking")
              game:get_map():get_entity("bed"):get_sprite():set_direction(game:get_ability("tunic") - 1)
              sol.timer.start(1000,function()
                -- Jump from the bed.
                hero:set_visible(true)
                hero:start_jumping(0, 24, true)
                game:set_pause_allowed(true)
                game:get_map():get_entity("bed"):get_sprite():set_animation("empty_open")
                sol.audio.play_sound("hero_lands")
              end)
            end)
          end)
       	end)
      end
    end)
  end
end

return true