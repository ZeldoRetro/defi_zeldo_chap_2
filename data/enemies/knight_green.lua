local enemy = ...

--Knight green

sol.main.load_file("enemies/generic_soldier")(enemy)
enemy:set_properties({
  main_sprite = "enemies/knight_green",
  sword_sprite = "enemies/knight_weapon",
  life = 8,
  damage = 8,
  play_hero_seen_sound = true,
  normal_speed = 32,
  faster_speed = 64,
})

