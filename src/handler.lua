local access = require "kong.plugins.idp-kong.access"
local TokenHandler = {
    VERSION  = "3.6.1",
    PRIORITY = 10,
}

function TokenHandler:new()
    TokenHandler.super.new(self, "idp-kong")
end

function TokenHandler:access(conf)
    TokenHandler.super.access(self)
    access.run(conf)
end

return TokenHandler