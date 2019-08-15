local enemy = ...

-- Lizalfos blue

sol.main.load_file("enemies/generic_soldier")(enemy)
enemy:set_properties({
  main_sprite = "enemies/lizalfos_blue",
  sword_sprite = "enemies/lizalfos_weapon",
  life = 6,
  damage = 4,
  play_hero_seen_sound = true,
  hurt_style = "monster",
  normal_speed = 48,
  faster_speed = 72,
})

