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

local m = Map("knxd", "KNX Router", "KNX is a very common building automation protocol which runs on dedicated 9600-baud wire as well as IP multicast.")
m.on_after_commit = function() luci.sys.call("/etc/init.d/knxd restart") end

local mainsec = m:section(NamedSection, "router", "main section", "The main section controls configuration of the whole of knxd. Its name defaults to main. An alternate main section may be named on the command line.")
local svc = mainsec:option(Value, "name","The name of this server", "The name of this server. This name will be used in logging/trace output. It's also the default name used to announce knxd on multicast.")
svc.placeholder = "OpenWrt"
svc.datatype = "string"

local svc = mainsec:option(Value, "addr", "KNX device address", "The KNX address of knxd itself. Used e.g. for requests originating at the group cache.")
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

local svc = mainsec:option(Value, "client_addrs", "KNX device address plus length", "Address range to be distributed to client connections. Note that the length parameter indicates the number of addresses to be allocated.")
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

local svc = mainsec:option(Value, "connections", "list of section names", "Comma-separated list of section names. Each named section describes either a device to exchange KNX packets with, or a server which a remote device or program may connect to. Mandatory, as knxd is useless without any connections.")
svc.optional = false
svc.placeholder = "A,B,C"
svc.datatype = "string"

local svc = mainsec:option(Value, "cache", "group cache section name", "Section name for the group cache. See the group cache section at the end of this document for details. Optional; mostly-required if you have a GUI that accesses KNX.")
svc.optional = true
svc.placeholder = "cache_D"
svc.datatype = "string"

local svc = mainsec:option(Flag, "force_broadcast", "force-broadcast", "Packets have a \"hop count\", which determines how many routers they may traverse until they're discarded. This mitigates the problems caused by bus loops (routers reachable by more than one path). A maximum hop count is specified to (a) never be decremented, (b) such packets are broadcast to every interface instead of just those their destination address says they should go to. knxd ignores this requirement unless you set this option, because it's almost never useful and escalates configuration errors from \"minor annoyance\" to \"absolute disaster if such a packet ever gets tramsmitted\".")
svc.optional = true

local svc = mainsec:option(Flag, "background", "background", "Instructs knxd to fork itself to the background.")
svc.optional = true

local svc = mainsec:option(Value, "logfile", "logfile", "Tells knxd to write its output to this file instead of stderr.")
svc.optional = true
svc.placeholder = "/var/log/knxd.log"
svc.datatype = "string"

local svc = mainsec:option(Value, "debug", "debug section name", "This option, available in all sections, names the config file section where specific debugging options for this section can be configured.")
svc.optional = true
svc.placeholder = "debug_E"
svc.datatype = "string"

local dbg = m:section(TypedSection, "debug", 'Debugging and logging')
dbg.addremove = true
dbg.anonymous = false
svc = dbg:option(ListValue, "error_level", "error-level","The minimum severity level of error messages to be printed. Possible values are 0…6, corresponding to none fatal error warning note info debug.")
svc:value('0',"0, none")
svc:value('1',"1, fatal")
svc:value('2',"2, error")
svc:value('3',"3, warning")
svc:value('4',"4, note")
svc:value('5',"5, info")
svc:value('6',"6, debug")
svc.datatype = "range(0, 6)"
svc.optional = true
local svc = dbg:option(ListValue, "trace_mask", "trace-mask","A bitmask corresponding to various types of loggable messages to help tracking down problems in knxd or one of its devices.")
svc:value('0',"0, byte-level tracing")
svc:value('1',"1, Packet-level tracing")
svc:value('2',"2, Driver state transitions")
svc:value('3',"3, Dispatcher state transitions")
svc:value('4',"4, Anything that's not a driver and talks directly to the dispatcher")
svc:value('6',"6, Debugging of flow control issues")
svc.datatype = "range(0, 6)"
svc.optional = true
local svc = dbg:option(Flag, "timestamps", "timestamps","Flag whether messages should include timestamps (since the start of knxd).")
svc.rmempty = false

local drv = m:section(TypedSection, "driver", 'Driver section name', "A driver is a link to a KNX interface or router which knxd establishes when it starts up.")
drv.addremove = true
drv.anonymous = false
local svc = drv:option(ListValue, "driver", "driver name")
svc:value('ip',"ip, multicast IP")
svc:value('ipt',"ipt, tunnel client")
svc:value('iptn',"iptn, tunnel client NAT")
svc:value('usb',"usb, USB interface")
svc:value('tpuart',"tpuart, A TPUART or TPUART-2 interface IC")
svc:value('tpuarttcp',"tpuarttcp, TPUART over TCP")
svc:value('ft12',"ft12, EMI1 protocol in serial")
svc:value('ft12tcp',"ft12tcp, EMI1 protocol in serial over TCP")
svc:value('ft12cemi',"ft12cemi, serial interface to KNX")
svc:value('ft12cemitcp',"ft12cemitcp, serial interface to KNX over TCP")
svc:value('ncn5120',"ncn5120, TPUART2-compatible")
svc:value('ncn5120tcp',"ncn5120tcp, TPUART2-compatible over TCP")
svc.datatype = "string"

local svc = drv:option(DummyValue, "dv1", nil,"This driver attaches to the multicast system. It is a minimal version of the \"router\" server's routing code (no tunnel server, no discovery).")
svc:depends("driver","ip")
local svc = drv:option(DummyValue, "dv2", nil,"This driver is a tunnel client, i.e. it attaches to a remote tunnel server. Hardware IP interfaces frequently use this feature.")
svc:depends("driver","ipt")
local svc = drv:option(DummyValue, "dv3", nil,"This driver is a tunnel client, i.e. it attaches to a remote tunnel server behind NAT. Hardware IP interfaces frequently use this feature.")
svc:depends("driver","iptn")
local svc = drv:option(DummyValue, "dv4", nil,"This driver talks to \"standard\" KNX interfaces with USB.")
svc:depends("driver","usb")
local svc = drv:option(DummyValue, "dv5", nil,"A TPUART or TPUART-2 interface IC. These are typically connected using either USB or (on Raspberry Pi-style computers) a built-in 3.3V serial port.")
svc:depends("driver","tpuart")
local svc = drv:option(DummyValue, "dv6", nil,"A TPUART or TPUART-2 interface IC over TCP. These are typically connected using either USB or (on Raspberry Pi-style computers) a built-in 3.3V serial port.")
svc:depends("driver","tpuarttcp")
local svc = drv:option(DummyValue, "dv7", nil,"An older serial interface to KNX which wraps the EMI1 protocol in serial framing.")
svc:depends("driver","ft12")
local svc = drv:option(DummyValue, "dv8", nil,"An older serial interface to KNX which wraps the EMI1 protocol in serial over TCP framing.")
svc:depends("driver","ft12tcp")
local svc = drv:option(DummyValue, "dv9", nil,"A newer serial interface to KNX.")
svc:depends("driver","ft12cemi")
local svc = drv:option(DummyValue, "dv10", nil,"A newer serial interface to KNX over TCP.")
svc:depends("driver","ft12cemitcp")
local svc = drv:option(DummyValue, "dv11", nil,"A mostly-TPUART2-compatible KNX interface IC.")
svc:depends("driver","ncn5120")
local svc = drv:option(DummyValue, "dv12", nil,"A mostly-TPUART2-compatible KNX interface IC over TCP.")
svc:depends("driver","ncn5120tcp")
svc.optional = false

local svc = drv:option(Flag, "ignore", "ignore","The driver is configured, but not started up automatically. Note: Starting up knxd still fails if there is a configuration error.")
svc.rmempty = true
svc.optional = true
local svc = drv:option(Flag, "may_fail", "may-fail","If the driver doesn't initially start up, knxd will continue anyway instead of terminating with an error.")
svc.rmempty = true
svc.optional = true
local svc = drv:option(Value, "retry_delay", "retry-delay","If the driver fails to start (or dies), knxd will restart it after this many seconds.")
svc.optional = true
svc.placeholder = 0
svc.datatype = "portrange"
local svc = drv:option(Value, "max_retry", "max-retry","The maximum number of retries before giving up.")
svc.optional = true
svc.placeholder = 0
svc.datatype = "portrange"
local svc = drv:option(Value, "send-timeout", "send-timeout","Transmission timeout. If a driver does not indicate that it's ready for the next transmission after this many seconds, it will be marked as failing. Note that this value is ineffective when using the \"queue\" filter.")
svc.optional = true
svc.placeholder = 10
svc.datatype = "portrange"

local srv = m:section(TypedSection, "server", 'Server section name', "A server is a point of connection which knxd establishes so that other interfaces, routers or clients may connect to it.")
srv.addremove = true
srv.anonymous = false
local svc = srv:option(ListValue, "server", "server name")
svc:value('ets_router',"ets_router, tunneling or routing")
svc:value('knxd_unix',"knxd_unix, Unix-domain socket")
svc:value('knxd_tcp',"knxd_tcp, TCP socket")
svc.datatype = "string"
svc.optional = false

local svc = srv:option(DummyValue, "dv13", nil,"The \"ets_router\" server allows clients to discover knxd and to connect to it with the standardized KNX tunneling or routing protocols.")
svc:depends("server","ets_router")
local svc = srv:option(DummyValue, "dv14", nil,"Allow local knxd-specific clients to connect using a Unix-domain socket.")
svc:depends("server","knxd_unix")
local svc = srv:option(DummyValue, "dv15", nil,"Allow remote knxd-specific clients to connect using a TCP socket.")
svc:depends("server","knxd_tcp")


return m
