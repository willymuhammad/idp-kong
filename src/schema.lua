local typedefs = require "kong.db.schema.typedefs"

return {
    name = "idp-kong",
    fields = {
        {
            config = {
                type = "record",
                fields = {
                    { introspect_endpoint = typedefs.url{ required = true }},
                    { client_id = { type = "string", required = true }},
                    { bearer_type = { type = "string", required = true }},
                    { token_cache_time = { type = "integer", default = 6000 }}
                }
            }
        }
    }
}