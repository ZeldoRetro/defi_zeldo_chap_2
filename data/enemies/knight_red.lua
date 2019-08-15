local enemy = ...

--Knight red

sol.main.load_file("enemies/generic_soldier")(enemy)
enemy:set_properties({
  main_sprite = "enemies/knight_red",
  sword_sprite = "enemies/knight_weapon",
  life = 16,
  damage = 12,
  play_hero_seen_sound = true,
  normal_speed = 40,
  faster_speed = 72,
})