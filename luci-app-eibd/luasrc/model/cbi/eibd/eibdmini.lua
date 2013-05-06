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
m = Map("eibd", "EIB Server", "EIB/KNX Server for RS232 USB EIB/IP Routing EIB/IP Tunnelling")

s = m:section(TypedSection, "eibinterface", "EIB Interface")
s.addremove = true
s.anonymous = true

s:option(Flag, "disable", "Disable").optional = true

svc = s:option(Value, "url", "Interface name")
svc:value("usb")
svc:value("ip")
svc:value("tpuarts:/dev/ttyACM0")

s:option(Value, "eibaddr", "EIB HW Addr").optional = true

return m
