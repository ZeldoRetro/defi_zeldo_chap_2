-- This script gives access to information about heroic_mode
-- independently of current savegames.

local heroic_mode_manager = {}

local heroic_mode = {}

-- Loads and returns a table of quest heroic_mode with the following optional keys:
-- - Heroic mode unlocked (boolean): Enable the heroic mode for this quest
function heroic_mode_manager:load()

  local file = sol.file.open("heroic_mode.dat")
  if file == nil then 
    return
  end

  heroic_mode.heroic_mode_enabled = file:read("*n") == 1

  return heroic_mode
end

-- Saves the heroic_mode into their file.
function heroic_mode_manager:save()

  local file, error_message = sol.file.open("heroic_mode.dat", "w")
  if file == nil then
    error("Cannot save heroic_mode file: " .. error_message)
  end

  file:write(heroic_mode.heroic_mode_enabled and 1 or 0)
  file:write(" ")

  file:close()
end

function heroic_mode_manager:set_heroic_mode_enabled()
  heroic_mode.heroic_mode_enabled = true
end

function heroic_mode_manager:get_heroic_mode_enabled()
  return heroic_mode.heroic_mode_enabled
end

return heroic_mode_manager