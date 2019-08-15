--Blue Bokoblin

local enemy = ...

sol.main.load_file("enemies/generic_soldier")(enemy)
enemy:set_properties({
  main_sprite = "enemies/bokoblin_blue",
  sword_sprite = "enemies/bokoblin_weapon",
  life = 3,
  damage = 2,
  play_hero_seen_sound = false,
  normal_speed = 32,
  faster_speed = 48,
})