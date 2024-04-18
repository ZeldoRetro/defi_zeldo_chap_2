local link_voice_manager = {}

local link_voice = {}

function link_voice_manager:load()

  local file = sol.file.open("link_voice.dat")
  if file == nil then 
    return
  end

  link_voice.link_voice_enabled = file:read("*n") == 1

  return link_voice
end

function link_voice_manager:save()

  local file, error_message = sol.file.open("link_voice.dat", "w")
  if file == nil then
    error("Cannot save link_voice file: " .. error_message)
  end

  file:write(link_voice.link_voice_enabled and 1 or 0)
  file:write(" ")

  file:close()
end

function link_voice_manager:set_link_voice_enabled()
  print("1")
  link_voice.link_voice_enabled = true
end

function link_voice_manager:set_link_voice_disabled()
  print("0")
  link_voice.link_voice_enabled = false
end

function link_voice_manager:get_link_voice_enabled()
  return link_voice.link_voice_enabled
end

return link_voice_manager