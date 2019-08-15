local enemy = ...

-- Lizalfos red

sol.main.load_file("enemies/generic_soldier")(enemy)
enemy:set_properties({
  main_sprite = "enemies/lizalfos_red",
  sword_sprite = "enemies/lizalfos_weapon",
  life = 8,
  damage = 6,
  play_hero_seen_sound = true,
  hurt_style = "monster",
  normal_speed = 56,
  faster_speed = 80,
})

