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
m = Map("linknx_exp", "EIB AppServer", "EIB/KNX AppServer for logic timeshedule and IO API")

s = m:section(TypedSection, "daemon", "Daemon")
s.addremove = true
s.anonymous = true

s:option(Flag, "disable", "Disable")
s:option(Flag, "log", "Log info and error to ")
s:option(Value, "tagname", "Linknx Name e.g. ISP1-LINKNX")
s:option(FileUpload, "esf", "/etc/linknx/linknximport.esf")

return m
