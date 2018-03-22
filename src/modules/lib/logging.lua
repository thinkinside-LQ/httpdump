-- -*- coding: utf-8 -*-

local _M = {}

function _M.put(fd, str)
    local current_fname = fd
    if type(str) == "string" then
        local data_fd = io.open(current_fname,"a")
        data_fd:setvbuf("no")
        data_fd:write(str .. '\n')
        data_fd:flush()
        data_fd:close()
    end

    return
end

function _M.debug(str)
    local time_str = ngx.localtime()
    local debug_fd = io.open(string.format("/tmp/openresty_debug_%s",os.date("%Y%m%d")), "a")
    debug_fd:write(time_str .. "  ")
    debug_fd:write(str)
    debug_fd:write('\n')
    debug_fd:flush()
    debug_fd:close()
    return
end

return _M
