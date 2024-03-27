package = "idp-kong"
version = "1.4-0"

source = {
        url = "git://github.com/willymuhammad/idp-kong"
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
    ["kong.plugins.idp-kong.handler"] = "src/handler.lua",
    ["kong.plugins.idp-kong.schema"] = "src/schema.lua",
    ["kong.plugins.idp-kong.access"] = "src/access.lua",
  }
}
