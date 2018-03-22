-- -*- coding: utf-8 -*-

-- require `opm get spacewander/luafilesystem`
local lfs = require "lfs_ffi"
local debug = require "debug"
local abs_path = debug.getinfo(1,'S').source:match("@?(.*/)")

local cfgpath = abs_path .. "rules"

local _M = {}

_M.modules = {}

for file in lfs.dir(cfgpath) do
    if file ~= "." and file ~= ".." then
        local idx = file:match(".+()%.%w+$")
        if(idx) then
            _M.modules[file:sub(1, idx-1)] = require("rules." .. file:sub(1, idx-1))
        else
            _M.modules[file] = require("rules." .. file)
        end
    end
end

return _M
