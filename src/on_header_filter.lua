local uuid = require "modules.lib.jit-uuid"
local set_header = ngx.req.set_header
local uuidstr = uuid()

if ngx.var.http_x_request_id == nil then
    set_header('X-Request-ID', uuidstr)
end
