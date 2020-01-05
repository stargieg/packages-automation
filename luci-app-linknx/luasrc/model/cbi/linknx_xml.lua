-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Copyright 2008-2013 Jo-Philipp Wich <jow@openwrt.org>
-- Licensed to the public under the Apache License 2.0.

local fs = require "nixio.fs"
local conffile = "/etc/luci-uploads/ets5export.xml"

f = SimpleForm("linknx_xml", "linknx import ets5export.xml file", nil)
t = f:field(TextValue, "import_xml")
t.rmempty = true
t.rows = 20
function t.cfgvalue()
	return fs.readfile(conffile) or ""
end

function f.handle(self, state, data)
	if state == FORM_VALID then
		if data.import_xml then
			fs.writefile(conffile, data.import_xml:gsub("\r\n", "\n"))
			io.popen("/usr/bin/ets5xml2uci.lua "..conffile)
			io.popen("/etc/init.d/linknx-uci restart")
		end
	end
	return true
end

return f
