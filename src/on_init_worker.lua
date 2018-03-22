-- -*- coding: utf-8 -*-

local uuid = require "modules.lib.jit-uuid"
local ngxtimer = require "modules.ngx_timer"

uuid.seed()
ngxtimer:rotate_log_file()
