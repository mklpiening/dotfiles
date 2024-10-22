local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

sbar.add("event", "aerospace_workspace_change")

sbar.add("item", "space.begin_pad", { 
  position = "right",
  width = 6,
  background = {
    padding_left = 0,
    padding_right = 0
  },
  label = {
    padding_left = 0,
    padding_right = 0
  },
  icon = {
    padding_left = 0,
    padding_right = 0
  },
 })

local spaces = {}

for i = 10, 1, -1 do
  local space = sbar.add("item", "space." .. i, {
    position = "right",
    icon = { drawing = false },
    label = {
      color = colors.white,
      string = i == 10 and 0 or i,
      font = {
        style = settings.font.style_map["Semibold"]
      },
      width = 7, 
      color = colors.transparent,
      padding_left = 0,
      padding_right = 0
    },
    background = {
      height = 7, 
      color = colors.with_alpha(colors.white, 0.1)
    },
  })

  spaces[i] = space


  space:subscribe("mouse.clicked", function(env)
    sbar.exec("aerospace workspace " .. i)
  end)
end

sbar.add("item", "space.end_pad", { 
  position = "right",
  width = 6,
  background = {
    padding_left = 0,
    padding_right = 0
  },
  label = {
    padding_left = 0,
    padding_right = 0
  },
  icon = {
    padding_left = 0,
    padding_right = 0
  },
 })

local space_bracket = sbar.add("bracket", { '/space\\..*/' }, {
  background = { 
    color = colors.bg1,
    padding_left = 0,
    padding_right = 0
  }
})

local function update_spaces(env)
  sbar.exec("aerospace list-workspaces --monitor all --visible", function(result, exit_code)
    local visible_workspaces = result
    sbar.exec("aerospace list-workspaces --monitor all --empty no", function(result, exit_code)
      local non_empty_workspaces = result
      for i = 1, #spaces do
        local is_visible = string.find(visible_workspaces, tostring(i))
        local is_not_empty = string.find(non_empty_workspaces, tostring(i))
        local is_selected = env.FOCUSED_WORKSPACE == tostring(i)

        local color = is_selected and colors.transparent
        local bg_color = colors.with_alpha(colors.white, 0.1)
        local width = 7
        local height = 7

        -- AI
        if is_selected then
          width = 18
          height = 9
          bg_color = colors.white
        elseif is_visible then
          bg_color = colors.white
        elseif is_not_empty then
          bg_color = colors.with_alpha(colors.white, 0.4)
        end

        spaces[i]:set({
          label = {
            color = color,
            width = width,
          },
          background = {
            color = bg_color,
            height = height
          },
        })
      end  
    end)
  end)
end

space_bracket:subscribe("aerospace_workspace_change", update_spaces)
update_spaces({})