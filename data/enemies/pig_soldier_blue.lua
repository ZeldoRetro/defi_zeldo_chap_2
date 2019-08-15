local enemy = ...

--Pig soldier blue

sol.main.load_file("enemies/generic_soldier")(enemy)
enemy:set_properties({
  main_sprite = "enemies/pig_soldier_blue",
  sword_sprite = "enemies/pig_soldier_weapon",
  life = 12,
  damage = 12,
  play_hero_seen_sound = true,
  normal_speed = 32,
  faster_speed = 64
})