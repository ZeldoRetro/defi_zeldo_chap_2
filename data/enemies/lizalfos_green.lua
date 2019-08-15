local enemy = ...

-- Lizalfos green

sol.main.load_file("enemies/generic_soldier")(enemy)
enemy:set_properties({
  main_sprite = "enemies/lizalfos_green",
  sword_sprite = "enemies/lizalfos_weapon",
  life = 4,
  damage = 2,
  play_hero_seen_sound = true,
  hurt_style = "monster",
  normal_speed = 40,
  faster_speed = 64,
})

