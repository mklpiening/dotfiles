local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

sbar.add("event", "aerospace_workspace_change")

local spaces = {}

for i = 1, 10, 1 do
  local space = sbar.add("item", "space." .. i, {
    icon = { drawing = false },
    label = {
      color = colors.white,
      string = i == 10 and 0 or i,
      font = {
        style = settings.font.style_map[i == 1 and "Heavy" or "Semibold"]
      },
      width = 15, 
    },
    position = "left",
    background = {
      height = 15, 
      color = colors.transparent,
    },
  })

  spaces[i] = space


  space:subscribe("mouse.clicked", function(env)
    sbar.exec("aerospace workspace " .. i)
  end)
end

local space_bracket = sbar.add("bracket", { '/space\\..*/' }, {
  background = { 
    color = colors.bg1,
  }
})

space_bracket:subscribe("aerospace_workspace_change", function(env)
  sbar.exec("aerospace list-workspaces --monitor all --visible", function(result, exit_code)
    for i = 1, #spaces do
      local is_visible = string.find(result, tostring(i))
      local is_selected = env.FOCUSED_WORKSPACE == tostring(i)

      local color = is_selected and colors.white or (is_visible and colors.white or colors.grey)
      local bg_color = colors.transparent
      local font_weight = is_selected and "Heavy" or "Regular"

      spaces[i]:set({
        label = {
          color = color,
          font = {
            style = settings.font.style_map[font_weight]
          },
        },
        background = {
          color = bg_color,
        },
      })
    end  
  end)
end)

-- space_bracket:subscribe("aerospace_workspace_change", function(env)
--   sbar.exec("aerospace list-workspaces --monitor all --visible", function(result, exit_code)
--     for i = 1, #spaces do
--       local is_visible = string.find(result, tostring(i))
--       local is_selected = env.FOCUSED_WORKSPACE == tostring(i)
-- 
--       local color = is_selected and colors.transparent
--       local bg_color = is_selected and colors.white or (is_visible and colors.white or colors.grey)
--       local width = is_selected and 20 or 10
--       local height = is_selected and 10 or 10
-- 
--       spaces[i]:set({
--         label = {
--           color = color,
--           width = width,
--         },
--         background = {
--           color = bg_color,
--           height = height
--         },
--       })
--     end  
--   end)
-- end)