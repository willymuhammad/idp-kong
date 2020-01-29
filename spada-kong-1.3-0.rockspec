package = "spada-kong"
version = "1.3-0"

source = {
        url = "git://github.com/willymuhammad/spada-kong"
}

description = {
  summary = "A Kong plugin, that let you use an external Oauth 2.0 provider to protect your API",
  license = "Apache 2.0"
}

dependencies = {
  "lua >= 5.1"
  -- If you depend on other rocks, add them here
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.spada-kong.handler"] = "src/handler.lua",
    ["kong.plugins.spada-kong.schema"] = "src/schema.lua",
    ["kong.plugins.spada-kong.access"] = "src/access.lua",
  }
}
