local enemy = ...

--Soldier green

sol.main.load_file("enemies/generic_soldier")(enemy)
enemy:set_properties({
  main_sprite = "enemies/soldier_green",
  sword_sprite = "enemies/soldier_weapon",
  life = 4,
  damage = 4,
  play_hero_seen_sound = true,
  normal_speed = 32,
  faster_speed = 56,
})