-- -*- coding: utf-8 --

local _M = {}

function _M.Set()
    local reverse = {}
    local set = {}
    return setmetatable(set,{__index = {
          insert = function(set,value)
              if not reverse[value] then
                    table.insert(set,value)
                    reverse[value] = table.getn(set)
              end
          end,

          remove = function(set,value)
              local index = reverse[value]
              if index then
                    reverse[value] = nil
                    local top = table.remove(set)
                    if top ~= value then
                        reverse[top] = index
                        set[index] = top
                    end
              end
          end,

          find = function(set,value)
              local index = reverse[value]
              return (index and true or false)
          end,
    }})
end

return _M
