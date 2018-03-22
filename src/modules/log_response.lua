-- -*- coding: utf-8 --


local _M = {}

function _M.GenerateResponseBody()

    local resp_headers =  ngx.resp.get_headers()

    local chunk, eof = ngx.arg[1], ngx.arg[2]
    local buffered = ngx.ctx.buffered

    if not buffered then
       buffered = {}
       ngx.ctx.buffered = buffered
    end
    if  chunk ~= "" then
       buffered[#buffered + 1] = chunk
       ngx.arg[1] = nil
    end
    if eof then
       local whole = table.concat(buffered)
       ngx.ctx.buffered = nil
       ngx.arg[1] = whole
       ngx.var.response_body = whole
    else
      ngx.var.response_body = nil
    end
    ngx.var.response_content_type = resp_headers['Content-Type'] or ""

    return
end

return _M
