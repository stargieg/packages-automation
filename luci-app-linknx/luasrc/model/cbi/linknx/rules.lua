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
m = Map("linknx_exp", "EIB Regeln", "EIB/KNX Regeln")

s = m:section(TypedSection, "rule", "Type")
s.addremove = true
s.anonymous = true
s.template = "cbi/tblsection"

en = s:option(Flag, "disable", "Disable")
en.optional = true
id = s:option(Value, "id", "Rule ID")
var = s:option(Value, "varname", "EIB Variable")
val = s:option(Value, "value", "Wert")
co = s:option(Value, "comment", "Comment")

s = m:section(TypedSection, "mail", "Type")
s.addremove = true
s.anonymous = true
s.template = "cbi/tblsection"

en = s:option(Flag, "disable", "Disable")
en.optional = true
id = s:option(Value, "id", "Mail ID")
var = s:option(Value, "varname", "EIB Variable")
val = s:option(Value, "value", "Wert")
co = s:option(Value, "comment", "Comment")

return m,n
