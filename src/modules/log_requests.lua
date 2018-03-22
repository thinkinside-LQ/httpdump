-- -*- coding: utf-8 --

local _M = {}

--[=[

Debug Format:
Reason :: Action :: Result

]=]

-- module import.
local json = require "cjson"
local xstring = require "modules.lib.string_split"
local ngx_re_match = ngx.re.match

function _M.GenerateRequestBody()

    local req_uri = ngx.var.uri or ''

    -- define access log body table.
    local request_body = {}

    -- define req/resp tables.
    request_body.request = {}

    -- add basic request fields.
    request_body.timestamp = ngx.var.time_iso8601 or json.null
    request_body.scheme = ngx.var.scheme or json.null
    request_body.protocol = ngx.var.server_protocol or json.null
    request_body.httpmethod = ngx.var.request_method or json.null
    request_body.httpcode = tonumber(ngx.var.status) or json.null
    request_body.response_time = tonumber(ngx.var.request_time) or json.null
    request_body.uri = req_uri or json.null
    request_body.content_type = ngx.var.content_type or json.null
    request_body.content_length = tonumber(ngx.var.content_length)  or json.null
    request_body.http_user_agent = ngx.var.http_user_agent  or json.null
    request_body.x_forward_for = json.empty_array
    request_body.hostname = ngx.var.hostname or json.null
    request_body.x_request_id = ngx.var.http_x_request_id or json.null

    -- define pre-parse data from ngx.
    local req_http_x_forwarded_for = ngx.var.http_x_forwarded_for
    local req_uri_args = ngx.var.args
    local req_headers = ngx.req.get_headers(0)

    -- parse x_forward_for field.
    local x_forward_ip = xstring.split(req_http_x_forwarded_for,',')
    if type(x_forward_ip) == 'string' then
        request_body.x_forward_for = {x_forward_ip}
    elseif type(x_forward_ip) == 'table' then
        local ip_list = {}
        for k,v in pairs(x_forward_ip) do
            local str, n, err = ngx.re.gsub(v,[=[^\s*(.*?)\s*?$]=],"$1","jo")
            if str then
                table.insert(ip_list,str)
            else
                table.insert(ip_list,v)
            end
        end
        request_body.x_forward_for = ip_list
    end

    -- parse url params for GET method.
    if req_uri_args then
        request_body.request = ngx.decode_args(req_uri_args,0)
    end

    -- parse post body for POST method.

    if request_body.httpmethod == 'POST' then
        local from, to, finderr = ngx.re.find(request_body.content_type, "application\\/json", "jo")
        if from then
            local req_body = ngx.req.get_body_data() or json.null
            local json_val
            local ok, decodeerr = pcall(function(str) json_val = json.decode(str) end, req_body)
            if ok then
                request_body.request = json_val
            else
                local errs = string.format("json strings is not a standard format :: decode request json body :: decode fail :: %s",decodeerr)
                dump(errs)
            end
        request_body.content_type = "application/json"
        end
    end

    if request_body.httpmethod == 'POST' then
        local from, to, err = ngx.re.find(request_body.content_type, "application\\/x-www-form-urlencoded", "jo")
        if from then
            local req_post_args,err = ngx.req.get_post_args() or json.null
            if req_post_args then
                request_body.request = req_post_args
            end
        request_body.content_type = "application/x-www-form-urlencoded"
        end
    end

    if request_body.httpmethod == 'POST' then
        local from, to, err = ngx.re.find(request_body.content_type, "multipart\\/form-data", "jo")

        if from then
            local req_body = ngx.var.request_body

            if req_body then
                local function restruct ( _str,seperator )
                    local pos, arr = 0, {}
                    for start, stop in function() return string.find( _str, seperator, pos, true ) end do
                        table.insert( arr, string.sub( _str, pos, start-1 ) )
                        pos = stop + 1
                    end
                    table.insert( arr, string.sub( _str, pos ) )
                    return arr
                end

                local boundary = "--" .. string.sub(request_body.content_type,31)
                local body_data_table = restruct(tostring(req_body),boundary)
                local remove_first_item = table.remove(body_data_table,1)
                local remove_last_item = table.remove(body_data_table)

                for index,val in ipairs(body_data_table) do
                    local start_pos,end_pos,capture,capture2 = ngx.re.find(val,'Content\\-Disposition: form\\-data; name="(.+)"; filename="(.*)"',"jo")
                    if not start_pos then
                        local params_body = restruct(val,"\r\n\r\n")

                        local keyname, err = ngx_re_match(params_body[1], '.*Content\\-Disposition: form\\-data; name="(.+)".*',"jo")
                        if keyname then
                            local param_key = keyname[1]
                            local param_value = string.sub(params_body[2],1,-3)
                            request_body.request[param_key] = param_value
                        else
                            dump("regex match form-data key-value failed!")
                        end
                    end
                end
            req_body = nil
            end
        request_body.content_type = "multipart/form-data"
        end
    end
    return request_body
end

return _M
