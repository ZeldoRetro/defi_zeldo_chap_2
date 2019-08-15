local bari_mixin = {}

function bari_mixin.mixin(enemy)

    local game = enemy:get_game()

    function enemy:set_shocking(shocking)
        if shocking then
            self:get_sprite():set_animation("shaking")
            self:set_pushed_back_when_hurt(false)
        else
            self:get_sprite():set_animation("walking")
            self:set_pushed_back_when_hurt(true)
        end
    end

    function enemy:is_shocking()
        return self:get_sprite():get_animation() == "shaking"
    end

    function enemy:shock()
        self:stop_movement()
        self:set_shocking(true)
        sol.timer.start(self, 1000 + 1500 * math.random(), function()
            self:set_shocking(false)
            self:restart()
        end)
    end

    function enemy:on_restarted()
        shocking = false
        self:set_default_attack_consequences()
        local m = sol.movement.create("path_finding")
        m:set_speed(16)
        m:start(self)
        sol.timer.start(enemy, 2000 + 8000 * math.random(), function()
            self:shock()
        end)
    end

    function enemy:on_immobilized()
        self:set_shocking(false)
        self:get_sprite():set_animation("immobilized")
    end

    function enemy:on_hurt_by_sword(hero, enemy_sprite)
        if self:is_shocking() then
        	enemy:get_game():remove_life(3)
          hero:start_hurt(enemy, 1)
          hero:freeze()
        	hero:set_animation("electrocuted")
          sol.audio.play_sound("hero_hurt")
          sol.timer.start(1000, function () hero:unfreeze() enemy:set_pushed_back_when_hurt(true) end)
        else
            -- Why doesn't hurt() remove life?
            self:hurt(game:get_ability('sword'))
            self:remove_life(game:get_ability('sword'))
        end
    end

    function enemy:on_attacking_hero(hero, enemy_sprite)
        if self:is_shocking() then
        	enemy:get_game():remove_life(3)
          hero:start_hurt(enemy, 1)
          hero:freeze()
        	hero:set_animation("electrocuted")
          sol.audio.play_sound("hero_hurt")
          sol.timer.start(1000, function () hero:unfreeze() end)
        else
            hero:start_hurt(enemy, self:get_damage())
        end
    end
end

return bari_mixin