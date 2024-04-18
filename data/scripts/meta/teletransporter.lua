local teletransporter_meta=sol.main.get_metatable("teletransporter")

teletransporter_meta:register_event("on_activated", function(teletransporter)
    local game=teletransporter:get_game()
    local hero=game:get_hero()
    local ground=hero:get_ground_below()
    game:set_value("tp_destination", teletransporter:get_destination_name())
    game:set_value("tp_ground", ground) --save last ground for the ceiling drop manager

end)