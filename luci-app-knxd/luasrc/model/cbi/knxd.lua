--[[
LuCI - Lua Configuration Interface

Copyright 2012 Patrick Grimm <patrick@lunatiki.de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--


local util = require "luci.util"
local fs = require "nixio.fs"

require("luci.tools.webadmin")
local uci = luci.model.uci.cursor()

m = Map("knxd", "KNX Server", "KNX Server for RS232, USB, EIB/IP Routing and EIB/IP Tunnelling")
m.on_after_commit = function() luci.sys.call("/etc/init.d/knxd restart") end

s = m:section(NamedSection, "args", "KNX Interface")
s:option(DummyValue, "dv1", nil,"Supported Hardware: https://web.archive.org/web/20140331121456/http://sourceforge.net/apps/trac/bcusdk/wiki/SupportedHardware")
s:option(DummyValue, "dv1", nil, "FAQ: https://web.archive.org/web/20120917203923/http://sourceforge.net/apps/trac/bcusdk/wiki/FAQ")

s:option(DummyValue, "dv1", nil, "supported URLs are:")
s:option(DummyValue, "dv1", nil, "ip:[multicast_addr[:port]] connects with the EIBnet/IP Routing protocol")
s:option(DummyValue, "dv1", nil, "ipt:router_ip[:dest_port[:src_port[:nat_ip[:data_port]]]]] connects with the EIBnet/IP Tunneling protocol")
s:option(DummyValue, "dv1", nil, "iptn:router_ip[:dest_port[:src_port]] connects with the EIBnet/IP Tunneling protocol over an EIBnet/IP gateway using the NAT mode")
s:option(DummyValue, "dv1", nil, "tpuarts:/dev/ttyACM0 connects to the KNX bus over a TPUART (using a serial interface)")
s:option(DummyValue, "dv1", nil, "usb:[bus[:device[:config[:interface]]]] connects over a KNX USB interface")

svc = s:option(Value, "url", "URL")
svc:value("ip:")
for line in util.execi("findknxusb 2>/dev/null") do
	if string.find(line, 'device:') then
		local split = util.split(line,"(%s+)",nil,true)
		if #split and split[2] then
			svc:value("usb:"..split[2])
		end
	end
end
for device in fs.glob("/dev/ttyACM[0-9]*") do
	svc:value("tpuarts:"..device)
end

function svc.validate(self, value, section)
	if string.find(value, 'ip:') then
		local mcast=string.match(value, "(%d+.%d+.%d+.%d+)") or "224.0.23.12"
		local route
		uci:foreach("network", "route", function(g)
			if g.target==mcast then
				route=true
			end
		end)
		if route then
			return value
		else
			uci:section("network", "route", nil, {
				gateway = "0.0.0.0",
				interface="lan",
				target=mcast
			})
			uci:save("network")
			return nil, "Save and Apply the Multicast Route "..mcast.." in the Networkconfig"
		end
	elseif string.find(value, 'ipt:') then
		--todo check ip and port
		return value
	elseif string.find(value, 'iptn:') then
		--todo check ip and port
		return value
	elseif string.find(value, 'tpuarts:') then
		--todo check dev file
		return value
	elseif string.find(value, 'usb:') then
		--todo check proc bus usb
		return value
	end
	return nil, "unknow KNX url: "..value
end

svc = s:option(Flag, "ServerEn", "ServerEn","Enable starts an EIBnet/IP multicast server")
svc.optional = true

svc = s:option(Value, "Server", "Server","starts an EIBnet/IP multicast server")
svc:depends("ServerEn",1)
svc.optional = true
svc.placeholder = "224.0.23.12"
svc.datatype = "ip4addr"

svc = s:option(Flag, "Discovery", "Discovery","enable the EIBnet/IP server to answer discovery and description requests (SEARCH, DESCRIPTION)")
svc:depends("ServerEn",1)
svc.optional = true

svc = s:option(Value, "Name", "Name for ETS Discover", "name of the EIBnet/IP server (default is 'knxd')")
svc:depends("Discovery",1)
svc.placeholder = "OpenWrt"
svc.datatype = "string"

svc = s:option(Flag, "Tunnelling", "Tunnelling for ETS", "enable EIBnet/IP Tunneling in the EIBnet/IP server")
svc:depends("ServerEn",1)
svc.optional = true

svc = s:option(Flag, "Routing", "EIBnet/IP Routing in the EIBnet/IP server")
svc:depends("ServerEn",1)
svc.optional = true
s:option(Flag, "GroupCache", "caching of group communication networkstate").optional = true

svc = s:option(Value, "listen_tcp", "Listen tcp port", "listen at TCP port PORT (default 6720)")
svc.optional = true
svc.placeholder = 6720
svc.datatype = "portrange"

svc = s:option(Value, "listen_local", "Socket File", "listen at Unix domain socket FILE (default /var/run/knxd)")
svc.optional = true
svc.placeholder = "/var/run/knxd"
svc.datatype = "string"

svc = s:option(Value, "eibaddr", "EIB HW Addr")
svc.optional = true
function svc.validate(self, value, section)
	local err
	Area,Line,Device = string.match(value, "(%d+).(%d+).(%d+)")
	if not Device or tonumber(Device) > 255 or tonumber(Device) < 0 then
		err = "Wrong eib addr Device is out of range [1-255] , "
	end
	if not Line or tonumber(Line) > 15 or tonumber(Line) < 0 then
		if not err then err = "" end
		err = "Wrong eib addr Line is out of range [0-15] , "..err
	end
	if not Area or tonumber(Area) > 15 or tonumber(Area) < 0 then
		if not err then err = "" end
		err = "Wrong eib addr Area is out of range [0-15] , "..err
	end
	if err then
		err = "Use the form [0-15].[0-15].[1-255] , "..err
		return nil, err
	else
		return value
	end
end

svc = s:option(Value, "daemon", "Logfile")
svc.optional = true
svc.datatype = "string"
svc.placeholder = "/var/log/knxd.log"

svc = s:option(Value, "trace", "set trace level")
svc.optional = true
svc.datatype = "portrange"
svc.placeholder = 7

svc = s:option(Value, "error", "set error level")
svc.optional = true
svc.datatype = "portrange"
svc.placeholder = 7

return m
