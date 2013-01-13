-- The contents of those functions can be copied into your export.lua
-- if you want the leds to be updated every frame.


function LuaExportStart()
	package.path  = package.path..";.\\LuaSocket\\?.lua"
	package.cpath = package.cpath..";.\\LuaSocket\\?.dll"
	socket = require("socket")
	host = "localhost"
	dstport = "33331"
	
	c = socket.udp()
	c:setpeername(host,dstport)
	
	c:send("hello=DCS Ka-50 is running and starting to send data!")
end

function LuaExportAfterNextFrame()

	local MainPanel = GetDevice(0)
	
	local bankhold = get_argument_str(MainPanel,330) -- Lit button
	local pitchhold = get_argument_str(MainPanel,331) -- Lit button
	local headinghold = get_argument_str(MainPanel,332) -- Lit button
	local altitudehold = get_argument_str(MainPanel,333) -- Lit button
	local flightdirector = get_argument_str(MainPanel,334) -- Lit button
	
	local autoturn = get_argument_str(MainPanel,437) -- Lit button
	local airborne = get_argument_str(MainPanel,438) -- Lit button
	local forwardhemisphere = get_argument_str(MainPanel,439) -- Lit button
	local groundmoving = get_argument_str(MainPanel,440) -- Lit button
	
	-- Create a string with flightdirector on the autopilot buttons for use with DCSAddRedIfGreen
	local fdstring = "0.00.0" .. flightdirector .. flightdirector .. "0.00.0" .. flightdirector .. flightdirector
		
	c:send("DCSSetGreen=" ..autoturn..forwardhemisphere..bankhold..pitchhold..airborne..groundmoving..headinghold..altitudehold..";DCSAddRedIfGreen=" .. fdstring..";")
		
end