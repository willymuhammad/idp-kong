local access = require "kong.plugins.idp-kong.access"
local IDPKongHandler = {
    VERSION  = "3.6.1",
    PRIORITY = 1000,
}

function IDPKongHandler:new()
    IDPKongHandler.super.new(self, "idp-kong")
end

function IDPKongHandler:access(conf)
    access.run(conf)
end

return IDPKongHandler