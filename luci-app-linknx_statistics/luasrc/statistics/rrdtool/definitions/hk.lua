--[[

Luci statistics - irq plugin diagram definition
(c) 2008 Freifunk Leipzig / Jo-Philipp Wich <xm@leipzig.freifunk.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0
$Id: irq.lua 2276 2008-06-03 23:18:37Z jow $
]]--

module("luci.statistics.rrdtool.definitions.hk", package.seeall)
                                             
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
	-- Ventil diagram
	--
	g[#g+1] = {
		title = "Ventil",
		vlabel = "%",
		number_format = "%5.1lf",
		data = {
			sources = {
				hk_valve = { "rv_y" }
			},
			options = {
				hk_valve__rv_y = {overlay = true, color = FullRed, title = "Heizung"}
			}
		}
	}

	--
	-- Temperatur diagram
	--
	g[#g+1] = {
		title = "Temperatur",
		vlabel = "Grad C",
		number_format = "%5.1lf",
		data = {
			sources = {
				hk_temperature = { "rt_x", "vl_xb", "vlpr_x", "rlpr_x", "vlse_x", "rlse_x"}
			},
			options = {
				hk_temperature__rt_x = {noarea = true, overlay = true, color = FullGreen, title = "Raum Temperatur"},
				hk_temperature__vl_xb = {noarea = true, overlay = true, color = FullCyan, title = "Sollwert"},
				hk_temperature__vlpr_x = {noarea = true, overlay = true, color = FullBlue, title = "Vorlauf Prim."},
				hk_temperature__rlpr_x = {noarea = true, overlay = true, color = HalfBlue, title = "Ruecklauf Prim."},
				hk_temperature__vlse_x = {noarea = true, overlay = true, color = FullRed, title = "Vorlauf Sek."},
				hk_temperature__rlse_x = {noarea = true, overlay = true, color = FullRed, title = "Ruecklauf Sek."}
			}
		}
	}
	
	return g
end

