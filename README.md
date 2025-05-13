# Hammerspoon Workspace Launcher

A lightweight utility to save, restore, and launch **workspaces** on macOS using [Hammerspoon](http://www.hammerspoon.org).  
A **workspace**, in this context, is a collection of applications (with custom context) and a specific layout of their windows across your screens.

## Features

- Save current window positions and sizes under a workspace name
- Restore window layouts at any time
- Launch applications with:
  - Specific browser profiles and URLs
  - VSCode profiles and workspaces
  - Obsidian vaults and files
  - iTerm2 tabs with profiles and commands
  - Finder tabs with specific folders
- One hotkey (`⌘ + ⌥ + ⌃ + \``) for all commands
- Fully customizable and scriptable

## Installation

```bash
cd ~/.hammerspoon
git clone https://github.com/ajallooe/Hammerspoon-workspace-launcher.git
cd hammerspoon-workspace-launcher
chmod +x install.sh
./install.sh
```

Then reload your Hammerspoon config from the menu bar.

## Usage

Press `⌘ + ⌥ + ⌃ + \`` to open the command prompt and type:

| Command           | Description                            |
|------------------|----------------------------------------|
| `d`              | Dump all window positions to Console    |
| `s <name>`       | Save current layout as `<name>`         |
| `r <name>`       | Restore layout from `<name>`            |
| `l <name>`       | Launch apps for workspace `<name>`      |
| `p <name>`       | Launch apps and restore layout          |
| `e`              | Open your workspaces folder in Terminal |

## Your Workspaces

User-defined workspace configs live in:

```
~/.hammerspoon/workspaces/
```

Each workspace consists of:

- `<name>.apps.lua`: defines what to launch and how
- `<name>.placement.lua`: defines window positions


### Sample Workspace

A complete example workspace is available in:

```
workspaces_sample/sample.apps.lua
```

You can copy this file into your `~/.hammerspoon/workspaces/` directory and rename it to get started.

The sample demonstrates usage for:
- Chrome
- Safari
- VSCode
- iTerm
- Finder
- Obsidian
- A generic macOS app (here we gave an example for Calibre)


## Notes & Limitations

- If you launch Chrome or Safari without any URLs, the launcher will automatically open a fallback HTML file that prompts you to manually restore the appropriate tab group. This is intentional: tab groups are the best way to maintain consistent workspace-specific browser contexts, but macOS browsers do not currently support programmatic tab group restoration.

- The current system supports launching only one instance of each application per workspace. For example, you cannot launch two different Chrome profiles as part of the same workspace without extending the underlying logic.

- You can add support for other apps or more complex workflows by editing `launcher.lua`. This is a modular, scriptable system designed to grow with your needs.

## License

MIT License with attribution. See `LICENSE` file for details.