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
m = Map("linknx_group", "Gruppen", "Gruppen")


s = m:section(TypedSection, "group", "Group")
s.addremove = true
s.anonymous = false
s.extedit   = luci.dispatcher.build_url("admin", "services", "linknxvarlist") .. "/%s"
s.template = "cbi/tblsection"
s.sortable = true

s:option(Flag, "disable", "Disable")
s:option(Value, "name", "Gruppename/Raumname")
s:option(Value, "groupexpr", "Gruppen/Raum Suchmuster")
s:option(Value, "pgroup", "Mitglied der Gruppe")
s:option(Value, "comment", "Anzeige Name")
s:option(Value, "url", "Web Addresse")
s:option(FileUpload, "img","/www/group.png")

return m
