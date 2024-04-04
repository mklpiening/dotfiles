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

for key, app in pairs(applicationHotkeys) do
	-- bind application
	hs.hotkey.bind(hyper, key, function()
		hs.application.launchOrFocus(app)
	end)
end

-- local function find_or_start_app(app)
-- 	-- search for app
-- 	local result = { hs.application.find(app) }
-- 	if result[1] ~= nil then
-- 		return result[1]
-- 	end
-- 	-- app does not exist

-- 	-- start app
-- 	hs.application.open(app)
-- 	result = { hs.application.find(app) }
-- 	return result[1]
-- end

-- for key, title in pairs(iTermHotkeys) do
-- 	-- find or launch iTerm window
-- 	hs.hotkey.bind(hyper, key, function()
-- 		local iterm = find_or_start_app("iTerm")
-- 		local clicked_menu_item = iterm:selectMenuItem({ "Window" })
-- 		print(clicked_menu_item)
-- 		local windows = { iterm:findWindow(title) }
-- 		for k, v in pairs(windows) do
-- 			if v == nil then
-- 				print("nil")
-- 			else
-- 				print(k, v:title())
-- 			end
-- 		end
-- 	end)
-- end

-- To easily layout windows on the screen, we use hs.grid to create
-- a 4x4 grid. If you want to use a more detailed grid, simply 
-- change its dimension here
local GRID_SIZE = 100
local HALF_GRID_SIZE = GRID_SIZE / 2
-- Set the grid size and add a few pixels of margin
-- Also, don't animate window changes... That's too slow
hs.grid.setGrid(GRID_SIZE .. 'x' .. GRID_SIZE)
hs.grid.setMargins({0, 0})
hs.window.animationDuration = 0

hs.hotkey.bind(hyper, "return", function()
	local f_application = hs.application.frontmostApplication()
	local f_window = f_application:focusedWindow()
	local f_screen = f_window:screen()
	local o_windows_raw = f_window:otherWindowsSameScreen()

	-- filter other windows
	local o_windows = {}
	for i=1,#o_windows_raw do
		if o_windows_raw[i] ~= hs.window.desktop() then
			if not o_windows_raw[i]:isMinimized() then
				o_windows[#o_windows + 1] = o_windows_raw[i]
			end
		end
	end
	print ("num_windows", #o_windows)

	-- determine split behavior
	local ver_split = false -- split vertiaclly - so up/down rather than left/right
	local inv_split = false -- invert split? no inversion means primary window left or above dependent on horizontal or vertical split

	local f_screen_ratio = f_screen:frame().w / f_screen:frame().h
	if f_screen_ratio > 1 then
		-- horizontal screen

		-- split between left and right
		ver_split = false

		-- invert split when there is a screen right to the current one
		if f_screen:toEast() == nil then
			inv_split = false
		else
			inv_split = true
		end
	else
		-- vertical screen

		-- split between up and down
		ver_split = true
		-- primary window down by default
		inv_split = true
	end

	print (ver_split)
	print (inv_split)

	if #o_windows == 0 then
		-- maximize if this is the only window
		hs.grid.maximizeWindow(f_window)
	else
		local primary_window_size = 65

		local o_window_rect = {x=0, y=0, w=1, h=1}
		local d_o_window_pos = {x=0, y=0}
		local f_window_rect = {x=0, y=0, w=1, h=1}
		if ver_split then
			if inv_split then
				o_window_rect = {x=0, y=0, w=GRID_SIZE/(#o_windows), h=GRID_SIZE-primary_window_size}
				f_window_rect = {x=0, y=GRID_SIZE-primary_window_size, w=GRID_SIZE, h=primary_window_size}
			else
				o_window_rect = {x=0, y=primary_window_size, w=GRID_SIZE/(#o_windows), h=GRID_SIZE-primary_window_size}
				f_window_rect = {x=0, y=0, w=GRID_SIZE, h=primary_window_size}
			end
			d_o_window_pos = {x=GRID_SIZE/(#o_windows), y=0}
		else
			if inv_split then
				o_window_rect = {x=0, y=0, w=GRID_SIZE-primary_window_size, h=GRID_SIZE/(#o_windows)}
				f_window_rect = {x=GRID_SIZE-primary_window_size, y=0, w=primary_window_size, h=GRID_SIZE}
			else
				o_window_rect = {x=primary_window_size, y=0, w=GRID_SIZE-primary_window_size, h=GRID_SIZE/(#o_windows)}
				f_window_rect = {x=0, y=0, w=primary_window_size, h=GRID_SIZE}
			end
			 d_o_window_pos = {x=0, y=GRID_SIZE/(#o_windows)}
		end

		print(o_window_rect.x, o_window_rect.y, o_window_rect.w, o_window_rect.h)
		print(d_o_window_pos.x, d_o_window_pos.y)
		print(f_window_rect.x, f_window_rect.y, f_window_rect.w, f_window_rect.h)

		-- move primay window
		hs.grid.set(f_window, f_window_rect, f_screen)

		-- stack other windows
		local minor = 0
		for i=1,#o_windows do
			hs.grid.set(o_windows[i], o_window_rect, f_screen)
			o_window_rect.x = d_o_window_pos.x + o_window_rect.x
			o_window_rect.y = d_o_window_pos.y + o_window_rect.y
		end
	end
end)

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
