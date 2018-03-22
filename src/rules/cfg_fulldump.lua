-- -*- coding: utf-8 -*-

local _M = {}

_M.logfd = '/openresty-logs/collector/ngx.log.full'

_M.whitelist = {
    ["regular"] = {},
    ["regex"] = {}
}

_M.blacklist = {
    ["BothRequestAndResponse"] = {
        ["regular"] = {
            ["/"] = true,
            ["/favicon.ico"] = true,
            ["/ngx_status/"] = true
        },
        ["regex"] = {}
    },
    ["BlockResponse"] = {
        ["regular"] = {},
        ["regex"] = {}
    },
    ["BlockRequest"] = {
        ["regular"] = {},
        ["regex"] = {}
    }
}

return _M
