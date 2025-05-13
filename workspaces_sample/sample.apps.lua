return {
  title = "Sample Workspace",

  -- Example: Chrome with fallback (no URLs)
  chrome = {
    profile = "Profile 1",
    urls = {}
  },

  -- -- Example: Chrome with URLs (second window - requires launcher modification to support multiple launches for the same app)
  -- chrome = {
  --   profile = "Profile 2",
  --   urls = {
  --     "https://news.ycombinator.com",
  --     "https://github.com"
  --   }
  -- },

  safari = {
    urls = {
      "https://apple.com",
      "https://developer.apple.com",
      "https://www.icloud.com"
    }
  },

  code = {
    profile = "Web Dev",
    workspace = "~/Projects/sample.code-workspace"
  },

  finder = {
    locations = {
      "~/Projects",
      "~/Documents/Reference"
    }
  },

  iterm = {
    tabs = {
      { profile = "Default", command = "cd ~/Projects && clear" },
      { profile = "Default", command = "cd ~/Projects/sample && npm run dev" }
    }
  },

  obsidian = {
    vault = "MyVault",
    file = "Notes%2FGetting%20Started"
  },

  generic = {
    apps = {
      { name = "Calibre" }
    }
  }
}