module("luci.controller.chat", package.seeall)

local sys 	= require "luci.sys"
local fs 	= require "nixio.fs"
local uci 	= require "luci.model.uci".cursor()
local http 	= require "luci.http"
local util 	= require "luci.util"


function index()

	local page  = node()
	page.lock   = true
	page.target = alias("chat")
	page.subindex = true
	page.index = false

	local page = node("chat")
	page.target = template("chat")
	page.title = "Chat"
	page.order = 100

end

