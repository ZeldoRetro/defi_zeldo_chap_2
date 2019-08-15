-- This script provides configuration information about text and languages.
--
-- Usage:
-- local language_manager = require("scripts/language_manager")

local language_manager = {}

local default_language = "fr"

-- Returns the id of the default language.
function language_manager:get_default_language()
  return default_language
end

-- Returns the font and font size to be used for dialogs
-- depending on the specified language (the current one by default).
function language_manager:get_dialog_font(language)

  -- No font differences between languages (for now).
  return "dialog", 11
end

-- Returns the font and font size to be used to display text in menus
-- depending on the specified language (the current one by default).
function language_manager:get_menu_font(language)

  -- No font differences between languages (for now).
  return "minecraftia", 8
end

return language_manager
