local awful     = require('awful')
local wibox     = require('wibox')
local beautiful = require('beautiful')
local gears     = require('gears')

local module = require(... .. '.module')

return function(s)
   s.mypromptbox = awful.widget.prompt() -- Create a promptbox.

   -- Create the wibox
   s.mywibox = awful.wibar({
      position = 'left',
      width    = 40,
      height   = s.geometry.height - 40,
      stretch  = false,
      ontop    = false,
      screen   = s,
      bg       = beautiful.wibar_bg,
      fg       = beautiful.wibar_fg,
      shape    = function(cr, w, h)
         gears.shape.rounded_rect(cr, w, h, beautiful.wibar_radius)
      end,
      widget   = {
         layout = wibox.layout.align.vertical,
         -- Top widgets
         {
            layout = wibox.layout.fixed.vertical,
            {
               module.launcher(),
               bg     = beautiful.launcher_bg,
               fg     = beautiful.launcher_fg,
               widget = wibox.container.background,
            },
            s.mypromptbox
         },
         -- Middle widgets
         module.tasklist(s),
         -- Bottom widgets
         {
            layout = wibox.layout.fixed.vertical,
            wibox.widget.systray(),
            {
               {
                  {
                     format = '%I\n%M',
                     font   = beautiful.clock_font,
                     widget = wibox.widget.textclock
                  },
                  margins = 5,
                  widget  = wibox.container.margin,
               },
               bg     = beautiful.clock_bg,
               fg     = beautiful.clock_fg,
               widget = wibox.container.background,
            },
            {
               {
                  module.layoutbox(s),
                  margins = 8,
                  widget  = wibox.container.margin,
               },
               bg     = beautiful.layoutbox_bg,
               fg     = beautiful.layoutbox_fg,
               widget = wibox.container.background,
            }
         }
      }
   })

   -- Place the wibar on the left with margins
   awful.placement.left(s.mywibox, {
      margins = { left = 10 },
      parent  = s
   })

   -- Set manual struts to reserve space for the floating bar
   -- 40 (width) + 10 (margin) + 20 (extra) = 70
   s.mywibox:struts({
      left = 70
   })
end
