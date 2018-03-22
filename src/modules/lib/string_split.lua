-- -*- coding: utf-8 -*-

local _M = {}

function _M.split(s,p)
    local rt= {}
    if s then
        string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
        return rt
    else
       return s
    end
    return
end

return _M
