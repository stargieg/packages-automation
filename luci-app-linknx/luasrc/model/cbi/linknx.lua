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

m = Map("linknx", "linknx Server", "high level functionalities to EIB/KNX installation")

s = m:section(NamedSection, "args", "KNX Interface")

svc = s:option(Value, "conf", "read configuration from xml file")
svc.optional = true
svc.datatype = "file"

s:option(DummyValue, "op1", nil, "-d, --daemon[=FILE] start the program as daemon, the output will be written to FILE, if the argument present")
s:option(DummyValue, "op2", nil, "-p, --pid-file=FILE write the PID of the process to FILE")
s:option(DummyValue, "op3", nil, "-w, --write[=FILE] write configuration to file (if no FILE specified, the config file is overwritten)")

svc = s:option(Value, "options", "Options")
svc.optional = true
svc.datatype = "string"

return m
