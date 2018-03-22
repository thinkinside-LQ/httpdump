-- -*- coding: utf-8 --

local _M = {}

--[=[

Debug Format:
Reason :: Action :: Result

]=]

-- module import.
local request = require "modules.log_requests"
local json = require "cjson"
local ngx_re_find = ngx.re.find
local ngx_re_gsub = ngx.re.gsub
local cfg = require "config"
local next = next

function _M.LogDumper()

    local req_uri = ngx.var.uri or ''

    for mod, cfg_instance in pairs(cfg.modules) do

        local logbody = request:GenerateRequestBody()

        -- Append response body on request body.
        local resp_content_type = ngx.var.response_content_type or json.null
        local resp_body = ngx.var.response_body or {}

        if resp_body == "" then
            resp_body = {}
        end

        local from, to, err = ngx_re_find(resp_content_type, "application\\/json", "jo")
        if from then
            local json_val
            local ok, err = pcall(function(str) json_val = json.decode(str) end, resp_body)
            if ok then
                logbody.response = json_val
            end
        else
            logbody.response = resp_body
        end
        resp_body = nil


        -- Logging dump.
        local is_block_skip = false

        local is_wl_exist = false
        local is_wl_cfg_exist = false
        local is_bl_both_exist = false
        local is_bl_req_exist =  false
        local is_bl_resp_exist =  false

        local is_wl_matched = false
        local is_bl_both_matched = false
        local is_bl_req_matched = false
        local is_bl_resp_matched = false

        local need_clear_request = false
        local need_clear_response = false

        -- dump("Apply rule: " .. mod)
        -- dump("Catch Url: " .. req_uri)

        is_wl_exist = cfg_instance.whitelist.regular[req_uri]
        is_wl_matched = is_wl_exist

        if next(cfg_instance.whitelist.regular) ~= nil then
            is_wl_cfg_exist = true
        end

        if next(cfg_instance.whitelist.regex) ~= nil then
            is_wl_exist = true
            is_wl_cfg_exist = true
        end

        if is_wl_exist then
            for index, val in ipairs(cfg_instance.whitelist.regex) do
                local from, to, finderr = ngx_re_find(req_uri, val, "jo")
                if from then
                    -- dump(mod .. "/wl::Matched uri: " .. req_uri)
                    is_wl_matched =  true
                end
            end
        end

        if is_wl_matched then
            is_bl_both_exist = cfg_instance.blacklist.BothRequestAndResponse.regular[req_uri]
            is_bl_both_matched = is_bl_both_exist

            is_bl_req_exist = cfg_instance.blacklist.BlockRequest.regular[req_uri]
            is_bl_req_matched = is_bl_req_exist

            is_bl_resp_exist = cfg_instance.blacklist.BlockResponse.regular[req_uri]
            is_bl_resp_matched = is_bl_resp_exist

            if next(cfg_instance.blacklist.BothRequestAndResponse.regex) ~= nil then
                is_bl_both_exist = true
            end

            if next(cfg_instance.blacklist.BlockRequest.regex) ~= nil then
                is_bl_req_exist = true
            end

            if next(cfg_instance.blacklist.BlockResponse.regex) ~= nil then
                is_bl_resp_exist = true
            end

            if is_bl_both_exist then
                for index, val in ipairs(cfg_instance.blacklist.BothRequestAndResponse.regex) do
                    local from, to, finderr = ngx_re_find(req_uri, val, "jo")
                    if from then
                        -- dump(mod .. "/bl_both::Matched uri: " .. req_uri)
                        is_bl_both_matched =  true
                    end
                end
            end

            if is_bl_resp_exist then
                for index, val in ipairs(cfg_instance.blacklist.BlockResponse.regex) do
                    local from, to, finderr = ngx_re_find(req_uri, val, "jo")
                    if from then
                        -- dump(mod .. "/bl_resp::Matched uri: " .. req_uri)
                        is_bl_resp_matched =  true
                    end
                end
            end

            if is_bl_req_exist then
                for index, val in ipairs(cfg_instance.blacklist.BlockRequest.regex) do
                    local from, to, finderr = ngx_re_find(req_uri, val, "jo")
                    if from then
                        -- dump(mod .. "/bl_req::Matched uri: " .. req_uri)
                        is_bl_req_matched =  true
                    end
                end
            end

            if is_bl_resp_matched and is_bl_req_matched then
                is_block_skip = true
            elseif is_bl_both_matched then
                is_block_skip = true
            elseif is_bl_resp_matched then
                need_clear_response = true
            elseif is_bl_req_matched then
                need_clear_request = true
            else
                is_block_skip = true
            end

        else
            is_bl_both_exist = cfg_instance.blacklist.BothRequestAndResponse.regular[req_uri]
            is_bl_both_matched = is_bl_both_exist

            is_bl_req_exist = cfg_instance.blacklist.BlockRequest.regular[req_uri]
            is_bl_req_matched = is_bl_req_exist

            is_bl_resp_exist = cfg_instance.blacklist.BlockResponse.regular[req_uri]
            is_bl_resp_matched = is_bl_resp_exist

            if next(cfg_instance.blacklist.BothRequestAndResponse.regex) ~= nil then
                is_bl_both_exist = true
            end

            if next(cfg_instance.blacklist.BlockRequest.regex) ~= nil then
                is_bl_req_exist = true
            end

            if next(cfg_instance.blacklist.BlockResponse.regex) ~= nil then
                is_bl_resp_exist = true
            end

            if is_bl_both_exist then
                for index, val in ipairs(cfg_instance.blacklist.BothRequestAndResponse.regex) do
                    local from, to, finderr = ngx_re_find(req_uri, val, "jo")
                    if from then
                        -- dump(mod .. "/bl_both::Matched uri: " .. req_uri)
                        is_bl_both_matched =  true
                    end
                end
            end

            if is_bl_resp_exist then
                for index, val in ipairs(cfg_instance.blacklist.BlockResponse.regex) do
                    local from, to, finderr = ngx_re_find(req_uri, val, "jo")
                    if from then
                        -- dump(mod .. "/bl_resp::Matched uri: " .. req_uri)
                        is_bl_resp_matched =  true
                    end
                end
            end

            if is_bl_req_exist then
                for index, val in ipairs(cfg_instance.blacklist.BlockRequest.regex) do
                    local from, to, finderr = ngx_re_find(req_uri, val, "jo")
                    if from then
                        -- dump(mod .. "/bl_req::Matched uri: " .. req_uri)
                        is_bl_req_matched =  true
                    end
                end
            end
            if is_wl_cfg_exist then
                is_block_skip = false
            else
                if is_bl_resp_matched and is_bl_req_matched then
                    is_block_skip = false
                elseif is_bl_both_matched then
                    is_block_skip = false
                elseif is_bl_resp_matched then
                    need_clear_response = true
                elseif is_bl_req_matched then
                    need_clear_request = true
                else
                    is_block_skip = true
                end
            end
        end

        if is_block_skip then
            -- dump(mod .. "/output_req+resp::for uri: " .. req_uri)
            local json_object = json.encode(logbody)
            local json_dump, n, err = ngx_re_gsub(json_object,[=[\\\/]=],"/")
            if json_dump then
                put(cfg_instance.logfd, json_dump)
            end
        else
            if need_clear_response then
                -- dump(mod .. "/output_resp::for uri: " .. req_uri)
                logbody.response = nil
                logbody.response = {}

                local json_object = json.encode(logbody)
                local json_dump, n, err = ngx_re_gsub(json_object,[=[\\\/]=],"/")

                if json_dump then
                    put(cfg_instance.logfd, json_dump)
                end
            end

            if need_clear_request then
                -- dump(mod .. "/output_req::for uri: " .. req_uri)
                logbody.request = nil
                logbody.request = {}

                local json_object = json.encode(logbody)
                local json_dump, n, err = ngx_re_gsub(json_object,[=[\\\/]=],"/")

                if json_dump then
                    put(cfg_instance.logfd, json_dump)
                end
            end
        end
    end
    return
end
return _M
