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

local uci = require("luci.model.uci").cursor()

function index()
	local uci = require("luci.model.uci").cursor()
	local fs = require("nixio.fs")

	if not fs.access("/etc/config/knxd") then
		return
	end

	local page
	page = entry({"admin", "services", "knxd"}, cbi("knxd"))
	page.dependent = true
	page.title  = _("knxd")
	page.order = 10

	page = node("admin", "services", "knxd_diag")
	page.target = template("knxd_diag")
	page.title  = _("knxd Diagnostics")
	page.order  = 11

	page = entry({"admin", "services", "knxd_diag_vbusmonitor"}, call("knxd_diag_vbusmonitor"), nil)
	page.leaf = true

	page = entry({"admin", "services", "knxd_diag_groupsocketlisten"}, call("knxd_diag_groupsocketlisten"), nil)
	page.leaf = true

	page = entry({"admin", "services", "knxd_diag_groupswrite"}, call("knxd_diag_groupswrite"), nil)
	page.leaf = true
	
	page = entry({"admin", "services", "knxd_diag_proto"}, call("knxd_diag_proto"), nil)
	page.leaf = true

	page = entry({"admin", "services", "knxd_diag_ini"}, call("knxd_diag_ini"), nil)
	page.leaf = true
end

function knxd_diag_vbusmonitor()
	local listen_tcp = uci:get( "knxd", "args", "listen_tcp" )
	local listen_local = uci:get( "knxd", "args", "listen_local" )
	if listen_tcp then
		local cmd = "knxtool vbusmonitor1 ip:127.0.0.1:"..listen_tcp.." 2>&1"
	elseif listen_local then
		local cmd = "knxtool vbusmonitor1 local:"..listen_local.." 2>&1"
	else
		return
	end

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
	local listen_tcp = uci:get( "knxd", "args", "listen_tcp" )
	local listen_local = uci:get( "knxd", "args", "listen_local" )
	if listen_tcp then
		local cmd = "knxtool groupsocketlisten ip:127.0.0.1:"..listen_tcp.." 2>&1"
	elseif listen_local then
		local cmd = "knxtool groupsocketlisten local:"..listen_local.." 2>&1"
	else
		return
	end

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

function knxd_diag_groupswrite()
	local addr = luci.http.formvalue("addr")
	local value = luci.http.formvalue("value")
	if not value or not addr then
		--TODO err mesg
		return
	end
	local listen_tcp = uci:get( "knxd", "args", "listen_tcp" )
	local listen_local = uci:get( "knxd", "args", "listen_local" )
	local cmd
	if listen_tcp then
		cmd = "knxtool groupswrite ip:127.0.0.1:"..listen_tcp.." "..addr.." "..value
	elseif listen_local then
		cmd = "knxtool groupswrite local:"..listen_local.." "..addr.." "..value
	else
		cmd = "knx is not listen on 127.0.0.1 or local socket"
	end
	luci.http.prepare_content("text/plain")
	luci.http.write(cmd)
	luci.http.write("\n")
	luci.http.write(" ret: ")
	luci.http.write("\n")
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

function knxd_diag_proto()
	local cmd = "cat /var/log/knxd.log"
	luci.http.prepare_content("text/plain")
	luci.http.write(cmd)
	luci.http.write("\n")
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

function knxd_diag_ini()
	local cmd = "cat /tmp/etc/knxd.ini"
	luci.http.prepare_content("text/plain")
	luci.http.write(cmd)
	luci.http.write("\n")
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
