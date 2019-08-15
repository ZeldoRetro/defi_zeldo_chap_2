local enemy = ...

-- Blue Hardhat Beetle.
sol.main.load_file("enemies/generic_towards_hero")(enemy)
enemy:set_properties({
  sprite = "enemies/hardhat_beetle_green",
  life = 3,
  damage = 2,
  normal_speed = 32,
  faster_speed = 32,
  hurt_style = "monster",
  push_hero_on_sword = true,
  movement_create = function()
    local m = sol.movement.create("random")
    m:set_smooth(true)
    return m
  end
})

