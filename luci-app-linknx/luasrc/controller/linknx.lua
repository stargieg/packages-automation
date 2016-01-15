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
	if not nixio.fs.access("/etc/config/linknx") then
		return
	end

	local page = entry({"admin", "services", "linknx"}, cbi("linknx"))
	page.dependent = true
	page.title  = _("linknx")
	page.order = 12

	local page = entry({"admin", "services", "linknx_xml"}, form("linknx_xml"))
	page.dependent = true
	page.title  = _("linknx xml config")
	page.order = 13

	page = node("admin", "services", "linknx_diag")
	page.target = template("linknx_diag")
	page.title  = _("linknx Diagnostics")
	page.order  = 14

	page = entry({"admin", "services", "linknx_diag_read"}, call("linknx_diag_read"), nil)
	page.leaf = true

	page = entry({"admin", "services", "linknx_diag_write"}, call("linknx_diag_write"), nil)
	page.leaf = true

	page = entry({"admin", "services", "linknx_diag_proto"}, call("linknx_diag_proto"), nil)
	page.leaf = true

end

function linknx_diag_read()
	local addr = luci.http.formvalue("addr")
	if not addr then
		luci.http.prepare_content("text/plain")
		luci.http.write("Keine Adresse")
		luci.http.write("\n")
		return
	end
	if not nixio.fs.access("/var/run/linknx") then
		luci.http.prepare_content("text/plain")
		luci.http.write("linknx is not listen on unix:/var/run/linknx")
		luci.http.write("\n")
		return
	end
	local nixio	= require "nixio"
	local s		= nixio.socket('unix', 'stream', none)
	s:connect('/var/run/linknx')
	s:send("<read><object id="..addr.."/></read>\r\n\4")
	local ret = s:recv(8192) or ''
	luci.http.prepare_content("text/plain")
	luci.http.write(addr)
	luci.http.write(" ret: ")
	luci.http.write(ret)
	luci.http.write("\n")
	return
end

function linknx_diag_write()
	local addr = luci.http.formvalue("addr")
	local value = luci.http.formvalue("value")
	if not addr then
		luci.http.prepare_content("text/plain")
		luci.http.write("Keine Adresse")
		luci.http.write("\n")
		return
	end
	if not value then
		luci.http.prepare_content("text/plain")
		luci.http.write("Keine Wert")
		luci.http.write("\n")
		return
	end
	if not nixio.fs.access("/var/run/linknx") then
		luci.http.prepare_content("text/plain")
		luci.http.write("linknx is not listen on unix:/var/run/linknx")
		luci.http.write("\n")
		return
	end
	local nixio	= require "nixio"
	local s		= nixio.socket('unix', 'stream', none)
	s:connect('/var/run/linknx')
	s:send("<write><object id="..addr.." value="..value.."/></write>\r\n\4")
	local ret = s:recv(8192) or ''
	luci.http.prepare_content("text/plain")
	luci.http.write(addr)
	luci.http.write(" ret: ")
	luci.http.write(ret)
	luci.http.write("\n")
	return
end

function linknx_diag_proto()
	local cmd = "cat /var/log/linknx.log"
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
