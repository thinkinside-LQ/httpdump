-- -*- coding: utf-8 -*-

local _M = {}

_M.logfd = '/openresty-logs/collector/ngx.log.filter'

_M.whitelist = {
    ["regular"] = {
        ['/v1/ad/request'] = true
    },
    ["regex"] = {
        -- '\\/v1\\/game\\/ad\\/request$',
    }
}

_M.blacklist = {
    ["BothRequestAndResponse"] = {
        ["regular"] = {
            ["/"] = true,
            ["/favicon.ico"] = true,
            ["/ngx_status/"] = true
        },
        ["regex"] = {
        }
    },
    ["BlockResponse"] = {
        ["regular"] = {
            -- ["/v2/game/baseinfo"] = true,
            -- ["/v2/game/latest"] = true,
            -- ["/v2/game/startup"] = true
        },
        ["regex"] = {
            -- '\\/list$'
        }
    },
    ["BlockRequest"] = {
        ["regular"] = {},
        ["regex"] = {}
    }
}

return _M
