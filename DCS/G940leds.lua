--------------------------------------------------------
-- Functions for use with G940leds udp listening program
--------------------------------------------------------


-- Return a string, rounded to 1 decimal and the absolute value to avoid the problem with -0.0
function get_argument_str(panel,value)
	return string.format("%.1f",math.abs(panel:get_argument_value(value)))
end

-- Set up the socket, changing port is supported here, but not yet in
-- g940leds.exe, so don't do it...
function g940socketsetup()
	package.path  = package.path..";.\\LuaSocket\\?.lua"
	package.cpath = package.cpath..";.\\LuaSocket\\?.dll"
	socket = require("socket")
	host = "localhost"
	dstport = "33331"
	
	c = socket.udp()
	c:setpeername(host,dstport)
	
	return c
end


-- *******************************
-- This is an example function that reads alot of arguments
-- and showcases some special DCS commands.
-- You should comment out the parts that you do not use to
-- speed up execution.

-- Note also that since this is a coroutine that will be
-- executed on set intervals, blinking lights (like master
-- caution) will not blink the same on the leds. To fix that
-- move the needed parts from everyframe.lua into 
-- LuaExportAfterNextFrame() and LuaExportStart()
-- ********************************
function g940leds_example(t)
	local tNext = t
	
	local c = g940socketsetup()
	
	c:send("hello=DCS Ka-50 is running and starting to send data!")
	
	local MainPanel = GetDevice(0)
	
	while true do
	    
		-- MainPanel:update_arguments() -- Uncomment if you want the leds to update while outside of the cockpit
	
		-- Lit button returns 0.1 when active. 0.2 when depressed but not active. 0.3 when depressed and active
		-- Indicators returns between 0.0 to 1.0, mostly only 0.0 and 1.0 but for example gear_handle moves between them
		-- 		Indicators with continous values are marked as such)
	
		-- Auto-pilot buttons and switches
		local bankhold = get_argument_str(MainPanel,330) -- Lit button
		local pitchhold = get_argument_str(MainPanel,331) -- Lit button
		local headinghold = get_argument_str(MainPanel,332) -- Lit button
		local altitudehold = get_argument_str(MainPanel,333) -- Lit button
		local flightdirector = get_argument_str(MainPanel,334) -- Lit button
		local ap_headingtrack = get_argument_str(MainPanel,336) -- 0.0 heading, 0.5 nothing (hold current course), 1.0 for track
		local ap_baroralt = get_argument_str(MainPanel,335) -- 0.0 barometric, 0.5 nothing, 1.0 radar
		
		-- Target mode
		local autoturn = get_argument_str(MainPanel,437) -- Lit button
		local airborne = get_argument_str(MainPanel,438) -- Lit button
		local forwardhemisphere = get_argument_str(MainPanel,439) -- Lit button
		local groundmoving = get_argument_str(MainPanel,440) -- Lit button
		
		-- Pushable warning lights
		local master_caution = get_argument_str(MainPanel,44) -- Indicator
		local engine_rpm_warning = get_argument_str(MainPanel,46) -- Indicator
		
		-- Misc
		local gear_handle = get_argument_str(MainPanel,65) -- Indicator (continous values)
		local navigation_lights = get_argument_str(MainPanel,146) -- 0.0 off, 0.1 10%, 0.2 50%, 0.3 100%
		local hover_lamp = get_argument_str(MainPanel,175) -- Indicator
		local ralt_lamp = get_argument_str(MainPanel,170) -- Indicator
		
		-- Weapons switches
		local master_arm = get_argument_str(MainPanel,387) -- Indicator
		local rate_of_fire = get_argument_str(MainPanel,398) -- Indicator
		local cannon_round = get_argument_str(MainPanel,399) -- Indicator
		local burst_length = get_argument_str(MainPanel,400) -- 0.0 for short. 0.1 for medium, 0.2 for long
		local manualautomode = get_argument_str(MainPanel,403) -- Indicator 1.0 for auto, 0.0 for manual
		local trainingmode = get_argument_str(MainPanel,432) -- Indicator 1.0 for traning mode, 0.0 for manual
		local tracking_gunsight = get_argument_str(MainPanel,436) -- Indicator 1.0 for tracking, 0.0 for gunsight
		local laser_standby = get_argument_str(MainPanel,435) -- Indicator
		
		-- PVI
		local nav_waypoints = get_argument_str(MainPanel,315) -- Lit button
		local nav_fixpoints = get_argument_str(MainPanel,316) -- Lit button
		local nav_airfields = get_argument_str(MainPanel,317) -- Lit button
		local nav_targets =   get_argument_str(MainPanel,318) -- Lit button
		local nav_initialnavpos =   get_argument_str(MainPanel,522) -- Lit button
		local nav_selfpos =   get_argument_str(MainPanel,319) -- Lit button
		local nav_course =   get_argument_str(MainPanel,320) -- Lit button
		local nav_wind =   get_argument_str(MainPanel,321) -- Lit button
		local nav_trueheading =   get_argument_str(MainPanel,322) -- Lit button
		
		-- Datalink
		local dlink_toall = get_argument_str(MainPanel,16) -- Lit button
		local dlink_wingman1 = get_argument_str(MainPanel,17) -- Lit button
		local dlink_wingman2 = get_argument_str(MainPanel,18) -- Lit button
		local dlink_wingman3 = get_argument_str(MainPanel,19) -- Lit button
		local dlink_wingman4 = get_argument_str(MainPanel,20) -- Lit button
		local dlink_vehicle = get_argument_str(MainPanel,21) -- Lit button
		local dlink_sam = get_argument_str(MainPanel,22) -- Lit button
		local dlink_other = get_argument_str(MainPanel,23) -- Lit buttons
		local dlink_ingress = get_argument_str(MainPanel,50) -- Lit buttons
		local dlink_send = get_argument_str(MainPanel,159) -- Lit buttons
		local dlink_ingresstotarget = get_argument_str(MainPanel,150) -- Lit buttons
		local dlink_erase = get_argument_str(MainPanel,161) -- Lit buttons

		
		-- Gear  (0.0 not, 1.0 yes)
		local lg_up = get_argument_str(MainPanel,59)
		local lg_down = get_argument_str(MainPanel,60)
		local rg_up = get_argument_str(MainPanel,61)
		local rg_down = get_argument_str(MainPanel,62)
		local ng_up = get_argument_str(MainPanel,63)
		local ng_down = get_argument_str(MainPanel,64)

		
		
		
		-- ****************************
		-- Here is the interesting part
		-- See the readme and command.txt for usage of the different commands
		-- ****************************
		
		-- This only needs to be sent once (ie, before this while loop), i have it here in this example so that you dont miss it
		c:send("DisableAutoUpdate=;") 
		-- P4 is set to red if laser is on standby, off is laser off
		c:send("ClearOne=4;DCSSetOneRed=4"..laser_standby..";")
		-- P5 is amber for low cannon rate of fire, Red for high
		c:send("SetOneRed=5;DCSSetOneAmber=5"..rate_of_fire..";") -- Set red first, but replace with amber if rate_of_fire == 1.0 (low rate)
		-- P6 is green for HE, red for AP
		c:send("SetOneRed=6;DCSSetOneGreen=6"..cannon_round..";") -- Set red first,but replace it with green if cannon_round = HE (1.0)
		
		-- Special DCS commands
		c:send("DCSNavigationLights=1"..navigation_lights..";") -- Navigation lights on P1
		c:send("DCSBurstLength=2"..burst_length..";") -- Weapon burst length on P2
		c:send("DCSGear=3"..lg_up..lg_down..rg_up..rg_down..ng_up..ng_down..";") -- Gear indicators on P3
		c:send("DCSBaroRalt=7"..ap_baroralt..";") -- Autopilot altitude mode (baro/ralt) on P7
		c:send("DCSApHeadingTrack=8"..ap_headingtrack..";") -- Autopilot course mode (heading/current course/track) on P8

		-- Need to update the buttons if autoenable is disabled
		c:send("set=;") -- Update the buttons
		
		tNext = coroutine.yield();
	end
	
	c:send("bye=DCS Ka-50 is running and starting to send data!")
	c:close()
end



--------------------------
-- This is what i use
-- It will show the autopilot holds on the four right buttons
-- and targeting modes on the left four. The autopilot buttons
-- will get amber if flight director is activated.
function g940leds_AutopilotTargetingMode()
	local tNext = t
	
	local c = g940socketsetup()
	
	c:send("hello=DCS Ka-50 is running and starting to send data!")
	
	local MainPanel = GetDevice(0)
	
	while true do
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
		
		tNext = coroutine.yield();
	end
	
end