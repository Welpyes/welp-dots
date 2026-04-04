# AwesomeWM Modular Configuration Template

This project is a highly modularized configuration for the Awesome Window Manager (AwesomeWM), designed for API level 4. It focuses on maintainability, avoiding global variables, and using a signal-driven architecture.

## Project Overview

- **Core Technology:** Lua (AwesomeWM API v4).
- **Architecture:** Modular separation of concerns. Instead of a monolithic `rc.lua`, functionality is split into logical directories.
- **Key Feature:** Includes a custom `awesome-bsp` module that provides bspwm-style binary tree tiling.

## Directory Structure

- `rc.lua`: The entry point. Initializes errors and loads core modules (`theme`, `signal`, `binds`, etc.).
- `config/`: User-specific settings.
    - `user.lua`: Modkey, default tags, and active layouts.
    - `apps.lua`: Default terminal, editor, and autostart applications.
    - `rules.lua`: Window rules (floating, tag assignment, titlebars).
- `binds/`: Key and mouse bindings.
    - `global/`: Window manager level bindings.
    - `client/`: Individual window (client) level bindings.
- `signal/`: Event-driven logic using AwesomeWM's signal system.
    - `client.lua`: Handles window focus, titlebars, and property changes.
    - `screen.lua`: Handles wallpaper, status bar initialization, and screen changes.
    - `tag.lua`: Handles tag creation and layout assignment.
    - `naughty.lua`: Notification configuration.
- `ui/`: User interface components (status bar, menus, titlebars).
- `module/`: Custom or community-developed modules.
    - `awesome-bsp/`: A binary space partitioning tiling layout.
- `theme/`: Visual styling (colors, fonts, icons, wallpapers).

## Building and Running

AwesomeWM configuration is dynamic and doesn't require compilation.

### Testing Changes
To test the configuration safely without affecting your current session, use `Xephyr`:
```bash
# Start Xephyr
Xephyr -br -ac -noreset -screen 1024x768 :1 &
sleep 1
# Launch AwesomeWM in Xephyr
DISPLAY=:1 awesome -c /path/to/this/repo/rc.lua
```

### Applying Changes
To apply changes to your live AwesomeWM session:
1. Ensure the files are in `~/.config/awesome/`.
2. Press `Mod4 + Control + r` (default restart binding) to reload AwesomeWM.

## Development Conventions

- **No Global Variables:** All modules export their functionality via `return` and are consumed via `require`.
- **Signal-Driven:** Prefer `client.connect_signal` or `tag.connect_signal` for behavior that reacts to events, keeping UI and logic decoupled.
- **Modular Imports:** Directories use `init.lua` to manage their sub-modules and provide a clean interface for `require`.
- **Relative Requires:** Internal module requires often use `require(... .. '.submodule')` for flexibility.

## Key Files

- `rc.lua`: The high-level orchestrator.
- `config/user.lua`: Primary location for changing modkey, tags, and layouts.
- `config/apps.lua`: Primary location for changing default applications.
- `module/awesome-bsp/README.md`: Documentation for the custom tiling layout.
