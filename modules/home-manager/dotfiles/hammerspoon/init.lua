local hyper = { "cmd", "shift" }

-- We use 0 to reload the configuration
hs.hotkey.bind(hyper, "0", function()
	hs.reload()
end)

-- Notify about the config reload
hs.notify.new({ title = "Hammerspoon", informativeText = "Config loaded" }):send()

local applicationHotkeys = {
	--------------------
	-- LEFT HAND
	d = "iTerm",
	e = "Visual Studio Code",
	a = "Arc",
	r = "Foxglove Studio",
	f = "Finder",
	g = "Gather",
	s = "Spotify",

	--------------------
	-- RIGHT HAND
	n = "Obsidian",
	k = "FreeCAD",
}

local iTermHotkeys = {
	--------------------
	-- LEFT HAND
	-- p = "test",

	--------------------
	-- RIGHT HAND
}

for key, app in pairs(applicationHotkeys) do
	-- bind application
	hs.hotkey.bind(hyper, key, function()
		hs.application.launchOrFocus(app)
	end)
end

local function find_or_start_app(app)
	-- search for app
	local result = { hs.application.find(app) }
	if result[1] ~= nil then
		return result[1]
	end
	-- app does not exist

	-- start app
	hs.application.open(app)
	result = { hs.application.find(app) }
	return result[1]
end

for key, title in pairs(iTermHotkeys) do
	-- find or launch iTerm window
	hs.hotkey.bind(hyper, key, function()
		local iterm = find_or_start_app("iTerm")
		local clicked_menu_item = iterm:selectMenuItem({ "Window" })
		print(clicked_menu_item)
		local windows = { iterm:findWindow(title) }
		for k, v in pairs(windows) do
			if v == nil then
				print("nil")
			else
				print(k, v:title())
			end
		end
	end)
end

-- remap hjkl to arrow keys

local function pressFn(mods, key)
	if key == nil then
		key = mods
		mods = {}
	end

	return function()
		hs.eventtap.keyStroke(mods, key, 1000)
	end
end

hs.hotkey.bind(hyper, "h", pressFn("left"), nil, pressFn("left"))
hs.hotkey.bind(hyper, "j", pressFn("down"), nil, pressFn("down"))
hs.hotkey.bind(hyper, "k", pressFn("up"), nil, pressFn("up"))
hs.hotkey.bind(hyper, "l", pressFn("right"), nil, pressFn("right"))
