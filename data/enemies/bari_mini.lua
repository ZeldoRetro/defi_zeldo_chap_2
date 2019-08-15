--Bari mini

local enemy = ...

local bari_mixin = require 'enemies/bari_mixin'

function enemy:on_created()
  self:set_life(1)
  self:set_damage(1)
  self:set_attack_consequence("boomerang",1)
  self:set_hookshot_reaction(1)
  self:create_sprite("enemies/" .. enemy:get_breed())
  self:set_size(8, 8)
  self:set_origin(4, 6)
  self:set_obstacle_behavior("flying")
  bari_mixin.mixin(self)
end