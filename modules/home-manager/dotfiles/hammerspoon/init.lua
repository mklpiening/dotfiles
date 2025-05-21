local hyper = { "cmd", "shift" }

-- We use 0 to reload the configuration
hs.hotkey.bind(hyper, "0", function()
	hs.reload()
end)

-- Notify about the config reload
hs.notify.new({ title = "Hammerspoon", informativeText = "Config loaded" }):send()

local applicationHotkeys = {
	e = { launchName = "Visual Studio Code", processName = "Code" },
	a = { launchName = "Arc", processName = "Arc" },
	r = { launchName = "Lichtblick", processName = "Lichtblick" },
	s = { launchName = "Spotify", processName = "Spotify" },
	n = { launchName = "Obsidian", processName = "Obsidian" },
	g = { launchName = "ChatGPT", processName = "ChatGPT" },
}

local function launchOrFocusOrCycle(appInfo)
	hs.application.launchOrFocus(appInfo.launchName)
	return

	-- local app = hs.application.get(appInfo.processName)
	-- print("processName:", appInfo.processName, "app:", app)
	-- if not app or not app:isRunning() then
	-- 	print("not running")
	-- 	hs.application.launchOrFocus(appInfo.launchName)
	-- 	return
	-- end

	-- -- Only require isStandard, and include all windows (even on other Spaces)
	-- local windows = hs.window.filter.new(false):setAppFilter(appInfo.processName, { currentSpace = nil }):getWindows()

	-- -- Try to focus windows on other Spaces if needed
	-- -- If the window is not on the current Space, use :focus() and :raise() to bring it forward

	-- if #windows == 0 then
	-- 	print("no windows")
	-- 	hs.application.launchOrFocus(appInfo.launchName)
	-- 	return
	-- end

	-- local frontmostApp = hs.application.frontmostApplication()
	-- if frontmostApp:bundleID() ~= app:bundleID() then
	-- 	print("not focused")
	-- 	hs.application.launchOrFocus(appInfo.launchName)
	-- 	return
	-- end

	-- if #windows > 1 then
	-- 	print("selecting next window")
	-- 	-- Sort, but handle missing lastFocusedTime
	-- 	table.sort(windows, function(a, b)
	-- 		local aTime = (a.lastFocusedTime and a:lastFocusedTime()) or 0
	-- 		local bTime = (b.lastFocusedTime and b:lastFocusedTime()) or 0
	-- 		return aTime < bTime
	-- 	end)
	-- 	local focused = app:focusedWindow()
	-- 	local idx = hs.fnutils.indexOf(windows, focused) or 0
	-- 	local nextIdx = (idx % #windows) + 1
	-- 	windows[nextIdx]:raise()
	-- 	windows[nextIdx]:focus()
	-- end
end

for key, appInfo in pairs(applicationHotkeys) do
	hs.hotkey.bind(hyper, key, function()
		launchOrFocusOrCycle(appInfo)
	end)
end

-- launch iterm
hs.hotkey.bind(hyper, "d", function()
	-- local app = hs.application.get("iTerm")
	-- if app then
	-- 	print("found")
	-- 	app:selectMenuItem({ "Shell", "New Window" })
	-- else
	-- 	print("not found")
	launchOrFocusOrCycle({ launchName = "Ghostty", processName = "Ghostty" })
	-- end
end)

-----------------------
-- window management --
-----------------------

local GRID_SIZE = 3
local GAPS = 8
local PRIMARY_WINDOW_RATIOS = { 0.6666, 0.5 }

local per_space_ratios = {}

-- configure grid
hs.grid.setGrid(GRID_SIZE .. "x" .. GRID_SIZE)
hs.grid.setMargins({ GAPS, GAPS })
hs.window.animationDuration = 0.5

-- tile on key-press
hs.hotkey.bind(hyper, "return", function()
	local f_application = hs.application.frontmostApplication()
	local f_window = f_application:focusedWindow()
	local f_screen = f_window:screen()
	local f_space = hs.spaces.activeSpaceOnScreen(f_screen)
	local o_windows_raw = f_window:otherWindowsSameScreen()

	-- filter other windows
	local o_windows = {}
	for i = 1, #o_windows_raw do
		if o_windows_raw[i] ~= hs.window.desktop() then
			if not o_windows_raw[i]:isMinimized() then
				o_windows[#o_windows + 1] = o_windows_raw[i]
			end
		end
	end

	-- determine split behavior
	local ver_split = false -- split vertiaclly - so up/down rather than left/right
	local inv_split = true -- invert split? no inversion means primary window left or above dependent on horizontal or vertical split

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

	if #o_windows == 0 then
		-- maximize if this is the only window
		hs.grid.maximizeWindow(f_window)
	else
		-- handle the ratio we want to use
		if per_space_ratios[f_space] == nil then
			per_space_ratios[f_space] = { ratio_id = 1, primary_window = -1, num_minor_windows = -1 }
		end
		if
			per_space_ratios[f_space].primary_window ~= f_window:id()
			or per_space_ratios[f_space].num_minor_windows ~= #o_windows
		then
			-- keep ratio, but change entry for last used primary window to currently focused window
			per_space_ratios[f_space].primary_window = f_window:id()
			per_space_ratios[f_space].num_minor_windows = #o_windows
		else
			-- switch to next ratio if we focus the same window as last time
			per_space_ratios[f_space].ratio_id = per_space_ratios[f_space].ratio_id + 1

			if per_space_ratios[f_space].ratio_id > #PRIMARY_WINDOW_RATIOS then
				per_space_ratios[f_space].ratio_id = 1
			end
		end

		-- select size of primary window - Tile sizes wont stick to grid cell sizes
		local primary_window_size = GRID_SIZE * PRIMARY_WINDOW_RATIOS[per_space_ratios[f_space].ratio_id]

		-- configure tile sizes
		local o_window_rect = { x = 0, y = 0, w = 1, h = 1 }
		local d_o_window_pos = { x = 0, y = 0 }
		local f_window_rect = { x = 0, y = 0, w = 1, h = 1 }
		if ver_split then
			if inv_split then
				o_window_rect = { x = 0, y = 0, w = GRID_SIZE / #o_windows, h = GRID_SIZE - primary_window_size }
				f_window_rect = { x = 0, y = GRID_SIZE - primary_window_size, w = GRID_SIZE, h = primary_window_size }
			else
				o_window_rect = {
					x = 0,
					y = primary_window_size,
					w = GRID_SIZE / #o_windows,
					h = GRID_SIZE - primary_window_size,
				}
				f_window_rect = { x = 0, y = 0, w = GRID_SIZE, h = primary_window_size }
			end
			d_o_window_pos = { x = GRID_SIZE / #o_windows, y = 0 }
		else
			if inv_split then
				o_window_rect = { x = 0, y = 0, w = GRID_SIZE - primary_window_size, h = GRID_SIZE / #o_windows }
				f_window_rect = { x = GRID_SIZE - primary_window_size, y = 0, w = primary_window_size, h = GRID_SIZE }
			else
				o_window_rect = {
					x = primary_window_size,
					y = 0,
					w = GRID_SIZE - primary_window_size,
					h = GRID_SIZE / #o_windows,
				}
				f_window_rect = { x = 0, y = 0, w = primary_window_size, h = GRID_SIZE }
			end
			d_o_window_pos = { x = 0, y = GRID_SIZE / #o_windows }
		end

		-- print(o_window_rect.x, o_window_rect.y, o_window_rect.w, o_window_rect.h)
		-- print(d_o_window_pos.x, d_o_window_pos.y)
		-- print(f_window_rect.x, f_window_rect.y, f_window_rect.w, f_window_rect.h)

		-- move primay window
		hs.grid.set(f_window, f_window_rect, f_screen)

		-- stack other windows
		for i = 1, #o_windows do
			hs.grid.set(o_windows[i], o_window_rect, f_screen)

			-- move window rect to next position
			o_window_rect.x = d_o_window_pos.x + o_window_rect.x
			o_window_rect.y = d_o_window_pos.y + o_window_rect.y
		end
	end
end)

-- toggle gaps
hs.hotkey.bind(hyper, "g", function()
	if GAPS == 0 then
		GAPS = 8
	else
		GAPS = 0
	end
	hs.grid.setMargins({ GAPS, GAPS })
end)

-- scan focussed window to grid
hs.hotkey.bind(hyper, "f", function()
	local f_application = hs.application.frontmostApplication()
	local f_window = f_application:focusedWindow()

	-- snap window
	f_window:toggleFullScreen()
end)

-- snap all windows on current screen to grid
hs.hotkey.bind(hyper, "i", function()
	local f_application = hs.application.frontmostApplication()
	local f_window = f_application:focusedWindow()
	local o_windows_raw = f_window:otherWindowsSameScreen()

	-- filter other windows
	local windows = { f_window }
	for i = 1, #o_windows_raw do
		if o_windows_raw[i] ~= hs.window.desktop() then
			if not o_windows_raw[i]:isMinimized() then
				windows[#windows + 1] = o_windows_raw[i]
			end
		end
	end

	-- snap windows
	for i = 1, #windows do
		hs.grid.snap(windows[i])
	end
end)

-- scan focussed window to grid
hs.hotkey.bind(hyper, "o", function()
	local f_application = hs.application.frontmostApplication()
	local f_window = f_application:focusedWindow()

	-- snap window
	hs.grid.snap(f_window)
end)

local dark_mode_active = true
hs.hotkey.bind(hyper, "o", function()
	dark_mode_active = not dark_mode_active
	hs.osascript.javascript(
		string.format("Application('System Events').appearancePreferences.darkMode.set(%s)", dark_mode_active)
	)
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
