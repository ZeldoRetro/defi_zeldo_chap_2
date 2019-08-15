local enemy = ...

--Soldier red

sol.main.load_file("enemies/generic_soldier")(enemy)
enemy:set_properties({
  main_sprite = "enemies/soldier_red",
  sword_sprite = "enemies/soldier_weapon",
  life = 8,
  damage = 8,
  play_hero_seen_sound = true,
  normal_speed = 40,
  faster_speed = 64,
})
