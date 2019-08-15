local enemy = ...

--Pig soldier red

sol.main.load_file("enemies/generic_soldier")(enemy)
enemy:set_properties({
  main_sprite = "enemies/pig_soldier_red",
  sword_sprite = "enemies/pig_soldier_weapon",
  life = 16,
  damage = 16,
  play_hero_seen_sound = true,
  normal_speed = 40,
  faster_speed = 72
})