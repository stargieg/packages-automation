--[[

Luci statistics - irq plugin diagram definition
(c) 2008 Freifunk Leipzig / Jo-Philipp Wich <xm@leipzig.freifunk.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0
$Id: irq.lua 2276 2008-06-03 23:18:37Z jow $
]]--

module("luci.statistics.rrdtool.definitions.ezr", package.seeall)

function rrdargs( graph, plugin, plugin_instance, dtype )

		Canvas		= "FFFFFF"
		FullRed		= "FF0000"
		FullGreen	= "00E000"
		FullBlue	= "0000FF"
		FullYellow	= "F0A000"
		FullCyan	= "00A0FF"
		FullMagenta	= "A000FF"
		HalfRed		= "F7B7B7"
		HalfGreen	= "B7EFB7"
		HalfBlue	= "B7B7F7"
		HalfYellow	= "F3DFB7"
		HalfCyan	= "B7DFF7"
		HalfMagenta	= "DFB7F7"
		HalfBlueGreen	= "89B3C9"
	--
	-- Temperature diagram
	--
	local g = { }
	g[#g+1] = {
		title = "Temperaturen",
		vlabel = "Grad",
		number_format = "%5.1lf",
		data = {
			sources = {
				ezr_temperature = { "rt_x", "rt_xs", "a_x" }
			},
			options = {
				ezr_temperature__rt_x = {noarea = true, overlay = true, color = FullGreen, title = "Raum"},
				ezr_temperature__rt_xs = {noarea = true, overlay = true, color = FullCyan, title = "Sollwert"},
				ezr_temperature__a_x = {noarea = true, overlay = true, color = FullRed, title = "Aussen"}
			}
		}
	}
	--
	-- Ventil diagram
	--
	g[#g+1] = {
		title = "Ventile",
		vlabel = "%",
		number_format = "%5.1lf",
		data = {
			sources = {
				ezr_valve = { "ve_y", "lk_y" }
			},
			options = {
				ezr_valve__ve_y = {overlay = true, color = FullRed, title = "Heizung"},
				ezr_valve__lk_y = {flip  = true, overlay = true, color = FullBlue, title = "Kühlung"}
			}
		}
	}

	return g
end

