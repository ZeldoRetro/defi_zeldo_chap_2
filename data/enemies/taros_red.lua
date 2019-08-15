local enemy = ...

--Taros red

sol.main.load_file("enemies/generic_soldier")(enemy)
enemy:set_properties({
  main_sprite = "enemies/taros_red",
  sword_sprite = "enemies/taros_red_weapon",
  life = 12,
  damage = 8,
  play_hero_seen_sound = true,
  normal_speed = 40,
  faster_speed = 72,
})