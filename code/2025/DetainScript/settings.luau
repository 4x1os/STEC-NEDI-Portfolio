local config_settings = {}

-- default jail time if left out. Numbers 0 and below will hold the player indefinitely.
config_settings.DEFAULT_TIMEOUT = 120

-- position where player is teleported once unjailed.
config_settings.UNJAIL_TELEPORT = Vector3.new(288.578, 11.204, -339.649)


-- place userids (NOT USERNAMES) to automatically give them a detain tool on spawn
config_settings.ALLOWED_PEOPLE = { 
	["TOOL"] = {
	},
	["CMD"] = {
	}	
}

-- place userids (NOT USERNAMES) of people to be undetainable
config_settings.IGNORE_ARRESTS = {

}

-- place groupids and minimum rank power to give tool or commands
config_settings.ALLOWED_RANKS = {
	["TOOL"] = {
	},
	["CMD"] = {
	}
}
return config_settings
