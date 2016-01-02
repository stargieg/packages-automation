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

m = Map("knxd", "KNX Server", "KNX Server for RS232 USB EIB/IP Routing EIB/IP Tunnelling")

s = m:section(TypedSection, "eibinterface", "KNX Interface")
s.addremove = true
s.anonymous = true
s:option(DummyValue, "dv1", "info", "Supported Hardware: http://sourceforge.net/apps/trac/bcusdk/wiki/SupportedHardware")
s:option(DummyValue, "dv1", "info", "FAQ: http://sourceforge.net/apps/trac/bcusdk/wiki/FAQ")

s:option(DummyValue, "dv1", "supported URLs are:")
s:option(DummyValue, "dv1", "ft12:/dev/ttySx", "FT1.2 Protocol to a BCU 2")
s:option(DummyValue, "dv1", "bcu1:/dev/eib", "(using a kernel driver) opkg install kmod-bcu1driver")
s:option(DummyValue, "dv1", "tpuart24:/dev/tpuartX", "(using the TPUART driver, Linux Kernel 2.4) no opkg")
s:option(DummyValue, "dv1", "tpuart:/dev/tpuartX", "(using the TPUART driver, Linux Kernel 2.6) no opkg")
s:option(DummyValue, "dv1", "ip:[multicast_addr[:port]]", "connects with the EIBnet/IP Routing protocol")
s:option(DummyValue, "dv1", "ipt:router_ip[:dest_port[:src_port[:nat_ip[:data_port]]]]]", "connects with the EIBnet/IP Tunneling protocol")
s:option(DummyValue, "dv1", "iptn:router_ip[:dest_port[:src_port]]", "connects with the EIBnet/IP Tunneling protocol over an EIBnet/IP gateway using the NAT mode")
s:option(DummyValue, "dv1", "bcu1s:/dev/ttySx", "connects using the PEI16 Protocoll over a BCU experimental")
s:option(DummyValue, "dv1", "tpuarts:/dev/ttySx", "connects to the KNX bus over an TPUART experimental")
s:option(DummyValue, "dv1", "usb:[bus[:device[:config[:interface]]]]", "default is autodetect with findknxusb tool connects over a KNX USB interface autodetect with findknxusb tool")

svc = s:option(Value, "url", "URL")
svc:value("usb:")
svc:value("ip:")
svc:value("tpuarts:/dev/ttyACM0")

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
