# Comprehensive Modular Widget & UI Guide

This guide explains how to build and integrate UI components within this modular AwesomeWM configuration. It follows the principles of **separation of concerns**, **declarative layouts**, and **signal-driven updates**.

---

## 1. The Declarative Layout System
AwesomeWM uses a "declarative" syntax (nested Lua tables) to build UI hierarchies. 

### Basic Widget Template
Every widget should be wrapped in a function. This allows for easy instantiation and screen-specific logic.

```lua
local wibox = require('wibox')

return function()
    return wibox.widget {
        { -- The actual content
            text   = "My Widget",
            align  = "center",
            widget = wibox.widget.textbox,
        },
        -- The container/wrapper properties
        bg     = "#ff0000",
        widget = wibox.container.background,
    }
end
```

---

## 2. Creating Stylized Buttons
Buttons are not a single widget; they are a combination of a **Container** (for styling) and **Signals** (for logic).

### Step 1: Define the Button Module (`ui/wibar/module/my_button.lua`)
```lua
local awful     = require('awful')
local wibox     = require('wibox')
local beautiful = require('beautiful')
local gears     = require('gears')

return function()
    local btn = wibox.widget {
        {
            {
                text   = "Click Me",
                font   = "Sans 10",
                widget = wibox.widget.textbox,
            },
            margins = 10,
            widget  = wibox.container.margin,
        },
        bg     = beautiful.bg_normal,
        shape  = gears.shape.rounded_rect,
        widget = wibox.container.background,
    }

    -- Add interactivity
    btn:buttons(gears.table.join(
        awful.button({}, 1, function() 
            awful.spawn("alacritty") 
        end)
    ))

    -- Add visual feedback (Hover effects)
    btn:connect_signal("mouse::enter", function() btn.bg = beautiful.bg_focus end)
    btn:connect_signal("mouse::leave", function() btn.bg = beautiful.bg_normal end)

    return btn
end
```

---

## 3. Specialized Widgets: The Calendar
AwesomeWM provides built-in widgets like `wibox.widget.calendar`. In a modular system, you should wrap these to handle logic like "current date" and "styling".

```lua
local wibox = require('wibox')

return function()
    local cal = wibox.widget {
        date     = os.date('*t'),
        font     = "Monospace 10",
        spacing  = 5,
        widget   = wibox.widget.calendar.month
    }
    
    -- You can update the date dynamically
    -- cal:set_date(os.date('*t'))

    return cal
end
```

---

## 4. Popups and Floating "Windows"
In AwesomeWM, a "Window" that isn't a managed application is usually an `awful.popup`. These are ideal for dashboards, volume sliders, or calendars that appear on click.

### Example: A Floating Calendar Window
```lua
local awful = require('awful')
local wibox = require('wibox')

local my_popup = awful.popup {
    widget = {
        {
            require('ui.wibar.module.calendar')(), -- Reuse your calendar widget
            margins = 20,
            widget  = wibox.container.margin,
        },
        bg     = "#222222",
        widget = wibox.container.background,
    },
    ontop        = true,
    visible      = false, -- Hidden by default
    placement    = awful.placement.centered,
    shape        = gears.shape.rounded_rect,
}

-- Toggle visibility function
function toggle_calendar()
    my_popup.visible = not my_popup.visible
end
```

---

## 5. Signal-Driven Architecture (Updates)
**CRITICAL:** Avoid global variables for updates. Instead, use AwesomeWM's signal system to tell widgets when to redraw.

### The Logic (in `signal/my_data.lua`)
```lua
-- Emit a signal every 5 seconds with new data
gears.timer {
    timeout   = 5,
    call_now  = true,
    autostart = true,
    callback  = function()
        local value = io.popen("cat /proc/loadavg"):read("*all")
        awesome.emit_signal("data::cpu_load", value)
    end
}
```

### The UI (in `ui/wibar/module/cpu.lua`)
```lua
return function()
    local text_widget = wibox.widget.textbox("Loading...")

    -- Listen for the signal
    awesome.connect_signal("data::cpu_load", function(value)
        text_widget.text = "CPU: " .. value
    end)

    return text_widget
end
```

---

## 6. Integration and Theming
1. **Define values in `theme/theme.lua`**:
   `theme.widget_padding = 10`
2. **Access them in your widget**:
   `local beautiful = require('beautiful')`
   `padding = beautiful.widget_padding`
3. **Add to Wibar**:
   Open `ui/wibar/init.lua` and add `module.your_widget_name()` to the `widget` table.

---

## 7. Performance Tips
- **Reuse Widgets:** Don't recreate the same widget every time a signal fires; update the existing widget's properties (like `.text` or `.bg`).
- **Use `gears.timer`:** Never use `os.execute` or blocking calls directly in the main UI thread. Use `awful.spawn.easy_async`.
- **DPI Scaling:** Always wrap pixel values in `dpi()` (from `beautiful.xresources.apply_dpi`) to support high-resolution screens.
