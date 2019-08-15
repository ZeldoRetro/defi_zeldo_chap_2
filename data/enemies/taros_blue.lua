local enemy = ...

--Taros blue

sol.main.load_file("enemies/generic_soldier")(enemy)
enemy:set_properties({
  main_sprite = "enemies/taros_blue",
  sword_sprite = "enemies/taros_blue_weapon",
  life = 8,
  damage = 6,
  play_hero_seen_sound = true,
  normal_speed = 32,
  faster_speed = 64,
})