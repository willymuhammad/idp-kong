local _M = { conf = {} }
local http = require "resty.http"
local pl_stringx = require "pl.stringx"
local cjson = require "cjson.safe"
local jwt_parser = require "kong.plugins.jwt.jwt_parser"

local function decode_jwt(encoded_jwt)
    local jwt, err = jwt_parser:new(encoded_jwt)
    if not jwt then
        return nil, err
    end

    local claims = jwt.claims

    return claims
end

local function replace_string(input, pattern, replacement)
    return input:gsub(pattern, replacement)
end

function _M.error_response(message, status)
    local jsonStr = '{"data":[],"error":{"code":' .. status .. ',"message":"' .. message .. '"}}'
    ngx.header['Content-Type'] = 'application/json'
    ngx.status = status
    ngx.say(jsonStr)
    ngx.exit(status)
end

function _M.introspect_access_token_req(access_token)
    local httpc = http:new()
    local res, err = httpc:request_uri(_M.conf.introspect_endpoint, {
        method = "POST",
        ssl_verify = false,
        headers = { ["Authorization"] = access_token, }
    })

    if not res then
        return { status = 0 }
    end
    if res.status ~= 200 then
        return { status = res.status }
    end
    return { status = res.status, body = res.body }
end

function _M.introspect_access_token(access_token)
    if _M.conf.token_cache_time > 0 then
        local cache_id = "at:" .. access_token
        local res, err = kong.cache:get(cache_id, { ttl = _M.conf.token_cache_time },
                _M.introspect_access_token_req, access_token)
        if err then
            _M.error_response("Unexpected error: " .. err, ngx.HTTP_INTERNAL_SERVER_ERROR)
        end

        if res.status ~= 200 then
            kong.cache:invalidate(cache_id)
        end

        return res
    end

    return _M.introspect_access_token_req(access_token)
end

function _M.is_scope_authorized(scope)
    if _M.conf.scope == nil then
        return true
    end
    local needed_scope = pl_stringx.strip(_M.conf.scope)
    if string.len(needed_scope) == 0 then
        return true
    end
    scope = pl_stringx.strip(scope)
    if string.find(scope, '*', 1, true) or string.find(scope, needed_scope, 1, true) then
        return true
    end

    return false
end

function _M.run(conf)
    _M.conf = conf
    local access_token = ngx.req.get_headers()[_M.conf.bearer_type]
    if not access_token then
        _M.error_response("Unauthenticated.", ngx.HTTP_UNAUTHORIZED)
    end

    local res = _M.introspect_access_token(access_token)
    if not res then
        _M.error_response("Authorization server error.", ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
    if res.status ~= 200 then
        _M.error_response("The resource owner or authorization server denied the request.", res.status)
    end

    local cleanToken = replace_string(access_token, "Bearer ", "")
    local claims, err = decode_jwt(cleanToken)
    if not claims then
        return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

    ngx.req.set_header("idp_clientid", _M.conf.client_id)
    ngx.req.set_header("idp_sub", claims["sub"])
    ngx.req.set_header("idp_token", access_token)
    ngx.req.set_header("idp_exp", claims["exp"])
    ngx.req.set_header("idp_role", claims["role"])
    ngx.req.set_header("idp_org", claims["org"])

end

return _M