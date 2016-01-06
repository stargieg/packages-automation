--[[
LuCI - Lua Configuration Interface

Copyright 2012 Patrick Grimm <patrick@lunatiki.de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

module("luci.controller.knxd", package.seeall)

function index()
--	require("luci.i18n")
--	luci.i18n.loadc("knxd")
	if not nixio.fs.access("/etc/config/knxd") then
		return
	end

	local page = entry({"admin", "services", "knxd"}, cbi("knxd"), "knxd")
--	page.i18n = "knxd"
	page.dependent = true
	page.order = 10

end
