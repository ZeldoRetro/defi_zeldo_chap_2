local enemy = ...

-- Zoura rouge

sol.main.load_file("enemies/generic_soldier")(enemy)
enemy:set_properties({
  main_sprite = "enemies/zoura_red",
  sword_sprite = "enemies/zoura_weapon",
  life = 18,
  damage = 4,
  play_hero_seen_sound = true,
  hurt_style = "monster",
  normal_speed = 32,
  faster_speed = 64,
  fire_reaction = 4,
})

