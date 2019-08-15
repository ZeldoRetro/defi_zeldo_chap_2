local enemy = ...

--Knight blue

sol.main.load_file("enemies/generic_soldier")(enemy)
enemy:set_properties({
  main_sprite = "enemies/knight_blue",
  sword_sprite = "enemies/knight_weapon",
  life = 12,
  damage = 8,
  play_hero_seen_sound = true,
  normal_speed = 32,
  faster_speed = 64,
})