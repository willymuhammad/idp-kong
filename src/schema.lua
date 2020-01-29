local typedefs = require "kong.db.schema.typedefs"

return {
    name = "spada-kong",
    fields = {
        {
            config = {
                type = "record",
                fields = {
                    { endpoint = typedefs.url{required = true}, },
                    { bearer = {type = "string", required = true}, },
                    { scope = {type = "string"}, },
                    { token_cache_time = {type = "integer", default = 6000}, },
                },
            },
        },
    },
}