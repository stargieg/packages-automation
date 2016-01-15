-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Copyright 2008-2013 Jo-Philipp Wich <jow@openwrt.org>
-- Licensed to the public under the Apache License 2.0.

local fs = require "nixio.fs"
local uci = require("luci.model.uci").cursor()
local conffile = uci:get( "linknx", "args", "conf" )

f = SimpleForm("linknx_xml", "linknx xml config file", "linknx xml config file")

t = f:field(TextValue, "linknx_xml")
t.rmempty = true
t.rows = 10
function t.cfgvalue()
	return fs.readfile(conffile) or ""
end

function f.handle(self, state, data)
	if state == FORM_VALID then
		if data.crons then
			fs.writefile(conffile, data.crons:gsub("\r\n", "\n"))
			--TODO reload linkx
		end
	end
	return true
end

return f
