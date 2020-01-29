local typedefs = require "kong.db.schema.typedefs"

return {
    name = "spada-kong",
    fields = {
        { 
            endpoint = {
                type = "string",
                required = true 
            }
        },
        { 
            bearer = { 
                type = "string" ,
                required = true,
                default = "Authorization"
            }
        },
        {
            token_cache_time = {
                type = "number"
            }
        },
        {
            scope = { 
                type = "string", 
                default = "" 
            }
        }
    }
}