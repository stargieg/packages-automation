--[[
LuCI - Lua Configuration Interface

Copyright 2012 Patrick Grimm <patrick@lunatiki.de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

require("luci.tools.webadmin")
local uci = luci.model.uci.cursor()

m = Map("knxd", "KNX Server", "KNX Server for RS232, USB, EIB/IP Routing and EIB/IP Tunnelling")

s = m:section(NamedSection, "args", "KNX Interface")
s:option(DummyValue, "dv1", "info", "Supported Hardware: https://web.archive.org/web/20140331121456/http://sourceforge.net/apps/trac/bcusdk/wiki/SupportedHardware")
s:option(DummyValue, "dv1", "info", "FAQ: https://web.archive.org/web/20120917203923/http://sourceforge.net/apps/trac/bcusdk/wiki/FAQ")

s:option(DummyValue, "dv1", "supported URLs are:")
s:option(DummyValue, "dv1", "ip:[multicast_addr[:port]]", "connects with the EIBnet/IP Routing protocol")
s:option(DummyValue, "dv1", "ipt:router_ip[:dest_port[:src_port[:nat_ip[:data_port]]]]]", "connects with the EIBnet/IP Tunneling protocol")
s:option(DummyValue, "dv1", "iptn:router_ip[:dest_port[:src_port]]", "connects with the EIBnet/IP Tunneling protocol over an EIBnet/IP gateway using the NAT mode")
s:option(DummyValue, "dv1", "tpuarts:/dev/ttyACM0", "connects to the KNX bus over a TPUART (using a serial interface)")
s:option(DummyValue, "dv1", "usb:[bus[:device[:config[:interface]]]]", "connects over a KNX USB interface")

svc = s:option(Value, "url", "URL")
svc:value("usb:")
svc:value("ip:")
svc:value("tpuarts:/dev/ttyACM0")
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
			return nil, "Save and Apply the Multicast Route "...mcast.." in the Networkconfig"
		end
	else
		return value
	end
end


s:option(Flag, "Discovery", "Discover for ETS").optional = true
s:option(Flag, "Server", "Server for ETS").optional = true
s:option(Flag, "Tunnelling", "Tunnelling for ETS").optional = true
s:option(Flag, "Routing", "EIBnet/IP Routing in the EIBnet/IP server").optional = true
s:option(Flag, "GroupCache", "caching of group communication networkstate").optional = true
s:option(Value, "listen_tcp", "Listen tcp port").optional = true
s:option(Value, "listen_local", "Socket File").optional = true
s:option(Value, "eibaddr", "EIB HW Addr").optional = true
s:option(Value, "daemon", "Logfile").optional = true
s:option(Value, "trace", "set trace level").optional = true
s:option(Value, "error", "set error level").optional = true

return m
