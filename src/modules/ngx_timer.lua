-- -*- coding: utf-8 --

local _M = {}


function _M.rotate_log_file()
    local cfg = require "config"
    local timer_at = ngx.timer.at
    local id = ngx.worker.id()
    local delay = 60 -- every 60 second to run.

    local function handler(premature)

        if premature then
            return
        end

        if id == 0 then
            for mod, cfg_instance in pairs(cfg.modules) do
                local fd = cfg_instance.logfd
                os.rename(fd, string.format("%s.%s",fd,os.date("%Y.%m.%d.%H.%M.%S")))
                local info = string.format("WorkerID:%d - rorate log file.",id)
                dump(info)
            end
        end

        local ok, err = timer_at(delay,handler)
        if not ok then
            dump("failed to create scheduled timer for rorate logfile.")
            dump(err)
            return
        end
    end

    local ok, err = timer_at(delay, handler)
    if not ok then
        dump("failed to create scheduled timer for rorate logfile.")
        dump(err)
        return
    end
    return
end

return _M
