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

m = Map("knxd", "KNX Router", "KNX is a very common building automation protocol which runs on dedicated 9600-baud wire as well as IP multicast.")
m.on_after_commit = function() luci.sys.call("/etc/init.d/knxd restart") end

s = m:section(NamedSection, "router", "main section", "The main section controls configuration of the whole of knxd. Its name defaults to main. An alternate main section may be named on the command line.")
svc = s:option(Value, "name", "The name of this server. This name will be used in logging/trace output. It's also the default name used to announce knxd on multicast.")
svc.placeholder = "OpenWrt"
svc.datatype = "string"

svc = s:option(Value, "addr", "KNX device address", "The KNX address of knxd itself. Used e.g. for requests originating at the group cache.")
svc.optional = true
svc.placeholder = "0.0.1"
svc.datatype = "string"
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

svc = s:option(Value, "client_addrs", "KNX device address plus length", "Address range to be distributed to client connections. Note that the length parameter indicates the number of addresses to be allocated.")
svc.optional = true
svc.placeholder = "2.2.20:10"
svc.datatype = "string"
function svc.validate(self, value, section)
	local err
	Area,Line,Device,length = string.match(value, "(%d+).(%d+).(%d+):(%d+)")
	if not Device or tonumber(Device) > 255 or tonumber(Device) < 0 then
		err = "Wrong eib addr length is out of range [1-255] , "
	end
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
		err = "Use the form [0-15].[0-15].[1-255]:[1-255] , "..err
		return nil, err
	else
		return value
	end
end

svc = s:option(Value, "connections", "list of section names", "Comma-separated list of section names. Each named section describes either a device to exchange KNX packets with, or a server which a remote device or program may connect to. Mandatory, as knxd is useless without any connections.")
svc.optional = false
svc.placeholder = "A,B,C"
svc.datatype = "string"

svc = s:option(Value, "cache", "group cache section name", "Section name for the group cache. See the group cache section at the end of this document for details. Optional; mostly-required if you have a GUI that accesses KNX.")
svc.optional = true
svc.placeholder = "cache_D"
svc.datatype = "string"

svc = s:option(Flag, "force_broadcast", "force-broadcast", "Packets have a \"hop count\", which determines how many routers they may traverse until they're discarded. This mitigates the problems caused by bus loops (routers reachable by more than one path). A maximum hop count is specified to (a) never be decremented, (b) such packets are broadcast to every interface instead of just those their destination address says they should go to. knxd ignores this requirement unless you set this option, because it's almost never useful and escalates configuration errors from \"minor annoyance\" to \"absolute disaster if such a packet ever gets tramsmitted\".")
svc.optional = true

svc = s:option(Flag, "background", "background", "Instructs knxd to fork itself to the background.")
svc.optional = true

svc = s:option(Value, "logfile", "logfile", "Tells knxd to write its output to this file instead of stderr.")
svc.optional = true
svc.placeholder = "/var/log/knxd.log"
svc.datatype = "string"

svc = s:option(Value, "debug", "debug section name", "This option, available in all sections, names the config file section where specific debugging options for this section can be configured.")
svc.optional = true
svc.placeholder = "debug_E"
svc.datatype = "string"

drv = m:section(TypedSection, "driver", 'Driver section name', "A driver is a link to a KNX interface or router which knxd establishes when it starts up.")
drv.addremove = true
drv.anonymous = false
svc = drv:option(ListValue, "driver", "driver name")
svc:value('ip',"multicast IP")
svc:value('ipt',"tunnel client")
svc:value('iptn',"tunnel client NAT")
svc:value('usb',"")
svc:value('tpuart',"")
svc:value('tpuarttcp',"")
svc:value('ft12',"")
svc:value('ft12tcp',"")
svc:value('ft12cemi',"")
svc:value('ft12cemitcp',"")
svc:value('ncn5120',"")
svc:value('ncn5120tcp',"")
svc.datatype = "string"

svc = drv:option(DummyValue, "dv1", nil,"This driver attaches to the multicast system. It is a minimal version of the \"router\" server's routing code (no tunnel server, no discovery).")
svc:depends("driver","ip")
svc = drv:option(DummyValue, "dv1", nil,"This driver is a tunnel client, i.e. it attaches to a remote tunnel server. Hardware IP interfaces frequently use this feature.")
svc:depends("driver","ipt")
svc:depends("driver","iptn")
svc = drv:option(DummyValue, "dv1", nil,"This driver talks to \"standard\" KNX interfaces with USB.")
svc:depends("driver","usb")

srv = m:section(TypedSection, "server", 'Server section name', "A server is a point of connection which knxd establishes so that other interfaces, routers or clients may connect to it.")
srv.addremove = true
srv.anonymous = false
svc = srv:option(ListValue, "server", "server name")
svc:value('ets_router',"tunneling or routing")
svc:value('knxd_unix',"Unix-domain socket")
svc:value('knxd_tcp',"TCP socket")
svc.datatype = "string"

svc = srv:option(DummyValue, "dv1", nil,"Allow local knxd-specific clients to connect using a Unix-domain socket.")
svc:depends("server","knxd_unix")

return m
