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
	w = "iTerm",
	e = "Visual Studio Code",
	a = "Arc",
	r = "Foxglove Studio",
	f = "Finder",
	c = "FreeCAD",
	g = "Gather",

	--------------------
	-- RIGHT HAND
	n = "Obsidian",
	m = "Spotify",
}

for key, app in pairs(applicationHotkeys) do
	hs.hotkey.bind(hyper, key, function()
		hs.application.launchOrFocus(app)
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
