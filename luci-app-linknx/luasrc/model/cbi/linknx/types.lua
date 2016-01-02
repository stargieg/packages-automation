--[[
LuCI - Lua Configuration Interface

Copyright 2012 Patrick Grimm <patrick@lunatiki.de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

require("luci.sys")
require("luci.util")
require("luci.tools.webadmin")
m = Map("linknx_exp", "EIB Typen", "EIB/KNX Typen")

s = m:section(TypedSection, "typeexpr", "Type")
s.addremove = true
s.anonymous = true
s.template = "cbi/tblsection"
s.sortable = true

en = s:option(Flag, "disable", "Disable")
en.optional = true
tpex = s:option(Value, "typeexpr", "Expression/Ausdruck/Suchmuster")
svc = s:option(Value, "type", "EIB Typ")
svc.rmempty = true
svc:value("20.102","20.102 heating mode (comfort/standby/night/frost)")
svc:value("11.001","11.001 date (EIS4)")
svc:value("10.001","10.001 time (EIS3)")
svc:value("9.xxx","9.xxx 16 bit floating point number (EIS5)")
svc:value("8.xxx","8.xxx 16bit signed integer")
svc:value("7.xxx","7.xxx 16bit unsigned integer (EIS10)")
svc:value("6.xxx","6.xxx 8bit signed integer (EIS14)")
svc:value("5.003","5.003 angle (from 0 to 360°)")
svc:value("5.001","5.001 scaling (from 0 to 100%)")
svc:value("5.xxx","5.xxx 8bit unsigned integer (from 0 to 255) (EIS6)")
svc:value("3.007","3.007 dimming (control of dimmer using up/down/stop) (EIS2)")
svc:value("3.008","3.008 blinds (control of blinds using close/open/stop)")
svc:value("1.001","1.001 switching (on/off) (EIS1)")
co = s:option(Value, "comment", "Comment")
iv = s:option(Value, "init", "Initial Value")

return m
