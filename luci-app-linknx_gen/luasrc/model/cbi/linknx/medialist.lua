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
m = Map("linknx_medialist", "EIB Regeln", "Media Listen")

s = m:section(TypedSection, "radio", "name")
s.addremove = true
s.anonymous = true
s.template = "cbi/tblsection"

var = s:option(Value, "name", "Eindeutieger Name")
val = s:option(Value, "addr", "URL des Senders")
co = s:option(Value, "comment", "Comment")

return m
