--[[
LuCI - Lua Configuration Interface

Copyright 2012 Patrick Grimm <patrick@lunatiki.de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

module("luci.controller.eibd", package.seeall)

function index()
--	require("luci.i18n")
--	luci.i18n.loadc("eibd")
	if not nixio.fs.access("/etc/config/eibd") then
		return
	end
	
	local page = entry({"admin", "services", "eibd"}, cbi("eibd/eibd"), "EIBD", 10)
--	page.i18n = "eibd"
	page.dependent = true
	
	
	local page = entry({"mini", "network", "eibd"}, cbi("eibd/eibdmini", {autoapply=true}), "EIBD", 10)
--	page.i18n = "eibd"
	page.dependent = true
end
