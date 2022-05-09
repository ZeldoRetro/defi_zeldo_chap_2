--Basic Ganon: just a simple enemy who targets you

local enemy = ...
local game = enemy:get_game()

local hits = 0
local phase = 1
local disappear_time = 1500
local close_torches_trigger = false
local phase_2_trigger = false
local i = 0

function enemy:on_created()

  enemy:set_life(400)
  enemy:set_damage(24)
  enemy:set_hurt_style("boss")
  enemy:create_sprite("enemies/boss/ganon")
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_push_hero_on_sword(true)
  enemy:set_invincible()
  enemy:set_attack_consequence("sword", 1)
end

function enemy:on_movement_changed(movement)

  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end

function enemy:shoot()
  local sprite = enemy:get_sprite()
  sprite:set_animation("spell")
  sol.timer.start(enemy, 350, function()
    sprite:set_animation("stopped")
    sol.audio.play_sound("boss_fireball")
    if phase == 1 then
      enemy:create_enemy({
        breed = "boss/ganon_keese_fire",
        layer = 3
      })
    elseif hits == 6 then
      enemy:create_enemy({
        breed = "boss/mothula",
        name = "minion",
        layer = 1
      })
    elseif hits == 7 then
      enemy:create_enemy({
        breed = "boss/kholdstare",
        name = "minion",
        layer = 1
      })
    elseif hits == 8 then
      enemy:create_enemy({
        breed = "boss/moltres",
        name = "minion",
        layer = 1
      })
    else
      enemy:create_enemy({
        breed = "boss/ganon_keese_shadow",
        layer = 3
      })
    end
    sol.timer.start(enemy,1000,function() enemy:disappear() end)
  end)
end

function enemy:appear()

  local sprite = enemy:get_sprite()
  enemy:set_visible(true)
  sprite:set_animation("warping")
  sol.timer.start(enemy, 500, function()
      enemy:set_can_attack(true)
      enemy:set_attack_consequence("sword", 1)
      sprite:set_animation("stopped")
      sol.timer.start(enemy,200, function() enemy:shoot() end)
  end)

end

function enemy:disappear()

  if phase == 4 then phase = 3 end

  local hero = enemy:get_map():get_hero()
  local sprite = enemy:get_sprite()
  local direction = enemy:get_direction4_to(hero)
  sprite:set_direction(direction)
  enemy:set_invincible()
  enemy:set_can_attack(false)
  sol.audio.play_sound("ganon_tp")
  sprite:set_animation("warping")
  local m = sol.movement.create("random")
  m:set_speed(144)
  m:start(self)
  sol.timer.start(enemy, 500, function()
      enemy:set_visible(false)
      sol.timer.start(enemy,disappear_time,function()
        local direction = enemy:get_direction4_to(hero)
        local sprite = enemy:get_sprite()
        sprite:set_direction(direction)
        m:stop(self)
        enemy:appear()
      end)  
  end)

end

function enemy:jump()
  phase_2_trigger = false
  sol.timer.start(enemy,200,function()
    game:get_map():get_hero():freeze()
    enemy:get_sprite():set_animation("jumping",function()
      enemy:get_sprite():set_animation("stopped")
        local camera = enemy:get_map():get_camera()
        local shake_config = {
          count = 28,
          amplitude = 2,
        }
        camera:shake(shake_config)
        sol.timer.start(enemy,70,function()
          sol.audio.play_sound("hero_pushes")
          i = i + 1
          if i < 16 then return true end
          game:get_map():get_hero():unfreeze()
          enemy:get_map():get_entity("falling_tiles_sensor_1"):set_enabled(true)
          game:start_dialog("ganon.2",function()
            enemy:disappear()
          end)
        end)
    end)
  end)
end

function enemy:close_torches()
    close_torches_trigger = false
    sol.timer.start(enemy,500,function()
      enemy:get_map():get_entity("torch_1"):set_enabled(false)
      enemy:get_map():get_entity("timed_torch_1"):set_enabled(true)
      enemy:get_map():get_entity("darkness_2"):set_enabled(true)
      sol.timer.start(enemy,250,function()
        enemy:get_map():get_entity("torch_2"):set_enabled(false)
        enemy:get_map():get_entity("timed_torch_2"):set_enabled(true)
        enemy:get_map():get_entity("darkness_1"):set_enabled(true)
      end)
    end)
end

function enemy:on_restarted()
  if phase == 3 then
    if close_torches_trigger then enemy:close_torches() end
    phase = 4
    enemy:get_sprite():set_animation("immobilized")
    enemy:set_invincible()
    if game:has_item("inventory/bow_light") then enemy:set_arrow_reaction(90) else enemy:set_arrow_reaction("protected") end
    sol.timer.start(enemy,3000,function()
      enemy:get_sprite():set_animation("spell")
      enemy:set_invincible()
      enemy:set_attack_consequence("sword",10)
      sol.timer.start(enemy,100,function()
        phase = 3
        enemy:set_invincible()
        enemy:disappear()
      end)
    end)
  elseif phase == 2 then
    if phase_2_trigger then enemy:jump() else enemy:disappear() end
  else enemy:disappear() end
end

function enemy:on_hurt()
  hits = hits + 1
  enemy:add_life(3)
  if hits == 6 then
    phase = 2
    disappear_time = 5000
    phase_2_trigger = true
  elseif hits == 9 then
    game:start_dialog("ganon.3")
    phase = 3
    disappear_time = 2000
    close_torches_trigger = true
  end
end

function enemy:on_dead()
    game:get_map():get_hero():freeze()
    game:set_pause_allowed(false)
    game:set_life(game:get_max_life())
    game:set_magic(game:get_max_magic())
    sol.audio.play_music("victory")
    sol.timer.start(9500,function() 
       game:get_map():get_hero():start_victory()
       sol.timer.start(1000,function()
    	  game:set_pause_allowed(true)
        sol.audio.play_sound("ganon_door_open")
        enemy:get_map():open_doors("final_door")
       end)     
    end) 
end