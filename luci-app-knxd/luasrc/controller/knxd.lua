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
	local uci = require("luci.model.uci").cursor()
	local fs = require("nixio.fs")

	if not fs.access("/etc/config/knxd") then
		return
	end

	local page
	page = entry({"admin", "services", "knxd"}, cbi("knxd"), "knxd")
	page.dependent = true
	page.order = 10

	page = node("admin", "services", "knxd_diag")
	page.target = template("knxd_diag")
	page.title  = _("KNX Diagnostics")
	page.order  = 11

	--page = entry({"admin", "services", "knxd_diag_vbusmonitor"}, post("knxd_diag_vbusmonitor"), nil)
	--page.leaf = true

	--page = entry({"admin", "services", "knxd_diag_groupsocketlisten"}, post("knxd_diag_groupsocketlisten"), nil)
	--page.leaf = true

	--page = entry({"admin", "services", "knxd_diag_groupswrite"}, post("knxd_diag_groupswrite"), nil)
	--page.leaf = true
end

function knxd_diag_vbusmonitor()
	local cmd = "knxtool vbusmonitor1 ip:127.0.0.1 2>&1"
	luci.http.prepare_content("text/plain")
	luci.http.write(cmd)
	local util = io.popen(cmd)
	if util then
		while true do
			local ln = util:read("*l")
			if not ln then break end
			luci.http.write(ln)
			luci.http.write("\n")
		end
		util:close()
	end
	return
end

function knxd_diag_groupsocketlisten()
	local cmd = "knxtool groupsocketlisten ip:127.0.0.1 2>&1"
	luci.http.prepare_content("text/plain")
	luci.http.write(cmd)
	local util = io.popen(cmd)
	if util then
		while true do
			local ln = util:read("*l")
			if not ln then break end
			luci.http.write(ln)
			luci.http.write("\n")
		end
		util:close()
	end
	return
end

function knxd_diag_groupswrite(addr,value)
	local cmd = "knxtool groupswrite ip:127.0.0.1 "..addr.." "..value.." 2>&1"
	luci.http.prepare_content("text/plain")
	luci.http.write(cmd)
	local util = io.popen(cmd)
	if util then
		while true do
			local ln = util:read("*l")
			if not ln then break end
			luci.http.write(ln)
			luci.http.write("\n")
		end
		util:close()
	end
	return
end
