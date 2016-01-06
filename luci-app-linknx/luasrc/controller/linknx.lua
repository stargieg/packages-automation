--[[
LuCI - Lua Configuration Interface

Copyright 2012 Patrick Grimm <patrick@lunatiki.de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

module("luci.controller.linknx", package.seeall)

function index()
--	require("luci.i18n")
--	luci.i18n.loadc("linknx")
	if not nixio.fs.access("/etc/config/linknx") then
		return
	end

	local page = entry({"admin", "services", "linknx"}, cbi("linknx"), "linknx", 11)
--	page.i18n = "linknx"
	page.dependent = true
end
