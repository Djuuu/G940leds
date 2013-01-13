-- Data export script for Lock On version 1.2.
-- Copyright (C) 2006, Eagle Dynamics.
-- See http://www.lua.org for Lua script system info 
-- We recommend to use the LuaSocket addon (http://www.tecgraf.puc-rio.br/luasocket) 
-- to use standard network protocols in Lua scripts.
-- LuaSocket 2.0 files (*.dll and *.lua) are supplied in the Scripts/LuaSocket folder
-- and in the installation folder of the Lock On version 1.2. 

-- Please, set EnableExportScript = true in the Config/Export/Config.lua file
-- to activate this script!

-- Expand the functionality of following functions for your external application needs.
-- Look into ./Temp/Error.log for this script errors, please.

-- Uncomment if using Vector class from the Config/Export/Vector.lua file 
--[[	
LUA_PATH = "?;?.lua;./Config/Export/?.lua"
require 'Vector'
-- See the Config/Export/Vector.lua file for Vector class details, please.
--]]

function LuaExportStart()
-- Works once just before mission start.

-- Make initializations of your files or connections here.
-- For example:
-- 1) File
--	local file = io.open("./Temp/Export.log", "w")
--	if file then
--		io.output(file)
--	end
-- 2) Socket
--  package.path  = package.path..";.\\LuaSocket\\?.lua"
--  package.cpath = package.cpath..";.\\LuaSocket\\?.dll"
--  socket = require("socket")
--  host = host or "localhost"
--  port = port or 8080
--  c = socket.try(socket.connect(host, port)) -- connect to the listener socket
--  c:setoption("tcp-nodelay",true) -- set immediate transmission mode
end

function LuaExportBeforeNextFrame()
-- Works just before every simulation frame.

-- Call Lo*() functions to set data to Lock On here
-- For example:
--	LoSetCommand(3, 25) -- rudder 25 right 
--	LoSetCommand(64) -- increase thrust

end

function LuaExportAfterNextFrame()
-- Works just after every simulation frame.

-- Call Lo*() functions to get data from Lock On here.
-- For example:
--	local t = LoGetModelTime()
--	local name = LoGetPilotName()
--	local altBar = LoGetAltitudeAboveSeaLevel()
--	local altRad = LoGetAltitudeAboveGroundLevel()
--	local pitch, bank, yaw = LoGetADIPitchBankYaw()
--	local engine = LoGetEngineInfo()
--	local HSI    = LoGetControlPanel_HSI()
-- Then send data to your file or to your receiving program:
-- 1) File
	--io.write(string.format("t = %.2f, name = %s, altBar = %.2f, altRad = %.2f, pitch = %.2f, bank = %.2f, yaw = %.2f\n", t, name, altBar, altRad, 57.3*pitch, 57.3*bank, 57.3*yaw))
--	io.write(string.format("t = %.2f ,RPM left = %f  fuel_internal = %f \n",t,engine.RPM.left,engine.fuel_internal))
	--io.write(string.format("ADF = %f  RMI = %f\n ",57.3*HSI.ADF,57.3*HSI.RMI))
-- 2) Socket
--	socket.try(c:send(string.format("t = %.2f, name = %s, altBar = %.2f, alrRad = %.2f, pitch = %.2f, bank = %.2f, yaw = %.2f\n", t, name, altRad, altBar, pitch, bank, yaw)))

end

function LuaExportStop()
-- Works once just after mission stop.

-- Close files and/or connections here.
-- For example:
-- 1) File
	--io.close()
-- 2) Socket
--	socket.try(c:send("quit")) -- to close the listener socket
--	c:close()

end

function LuaExportActivityNextEvent(t)
	local tNext = t

-- Put your event code here and increase tNext for the next event
-- so this function will be called automatically at your custom
-- model times. 
-- If tNext == t then the activity will be terminated.

-- For example:
-- 1) File
--	local o = LoGetWorldObjects()
--	for k,v in pairs(o) do
--		io.write(string.format("t = %.2f, ID = %d, name = %s, country = %s(%s), LatLongAlt = (%f, %f, %f), heading = %f\n", t, k, v.Name, v.Country, v.Coalition, v.LatLongAlt.Lat, v.LatLongAlt.Long, v.LatLongAlt.Alt, v.Heading))
--	end
--	local trg = LoGetLockedTargetInformation()
--  io.write(string.format("locked targets ,time = %.2f\n",t))
--	for i,cur in pairs(trg) do
--	  io.write(string.format("ID = %d, position = (%f,%f,%f) , V = (%f,%f,%f),flags = 0x%x\n",cur.ID,cur.position.p.x,cur.position.p.y,cur.position.p.z,cur.velocity.x,cur.velocity.y,cur.velocity.z,cur.flags))
--	end
--	local route = LoGetRoute()
--	io.write(string.format("t = %f\n",t))
--	if route then
--		  io.write(string.format("Goto_point :\n point_num = %d ,wpt_pos = (%f, %f ,%f) ,next %d\n",route.goto_point.this_point_num,route.goto_point.world_point.x,route.goto_point.world_point.y,route.goto_point.world_point.z,route.goto_point.next_point_num))
--		  io.write(string.format("Route points:\n"))
--		for num,wpt in pairs(route.route) do
--		  io.write(string.format("point_num = %d ,wpt_pos = (%f, %f ,%f) ,next %d\n",wpt.this_point_num,wpt.world_point.x,wpt.world_point.y,wpt.world_point.z,wpt.next_point_num))
--		end
--	end

--	local stations = LoGetPayloadInfo()
--	if stations then
--		io.write(string.format("Current = %d \n",stations.CurrentStation))

--		for i_st,st in pairs (stations.Stations) do
--			local name = LoGetNameByType(st.weapon.level1,st.weapon.level2,st.weapon.level3,st.weapon.level4);
--			if name then
--			io.write(string.format("weapon = %s ,count = %d \n",name,st.count))
--			else
--			io.write(string.format("weapon = {%d,%d,%d,%d} ,count = %d \n", st.weapon.level1,st.weapon.level2,st.weapon.level3,st.weapon.level4,st.count))
--			end
--		end
--	end 

--	local Nav = LoGetNavigationInfo()
--	if Nav then
--		io.write(string.format("%s ,%s  ,ACS: %s\n",Nav.SystemMode.master,Nav.SystemMode.submode,Nav.ACS.mode))
--		io.write(string.format("Requirements :\n\t  roll %d\n\t pitch %d\n\t speed %d\n",Nav.Requirements.roll,Nav.Requirements.pitch,Nav.Requirements.speed))
--	end



--	tNext = tNext + 1.0
-- 2) Socket
--	local o = LoGetWorldObjects()
--	for k,v in pairs(o) do
--      socket.try(c:send(string.format("t = %.2f, ID = %d, name = %s, country = %s(%s), LatLongAlt = (%f, %f, %f), heading = %f\n", t, k, v.Name, v.Country, v.Coalition, v.LatLongAlt.x, v.LatLongAlt.Long, v.LatLongAlt.Alt, v.Heading)))
--	end
--	tNext = tNext + 1.0

	return tNext
end



-- Lock On supports Lua coroutines using internal LoCreateCoroutineActivity() and
-- external CoroutineResume() functions. Here is an example of using scripted coroutine.

Coroutines = {}	-- global coroutines table
CoroutineIndex = 0	-- global last created coroutine index

-- This function will be called by Lock On model timer for every coroutine to resume it
function CoroutineResume(index, tCurrent)
	-- Resume coroutine and give it current model time value
	coroutine.resume(Coroutines[index], tCurrent)
	return coroutine.status(Coroutines[index]) ~= "dead"
	-- If status == "dead" then Lock On activity for this coroutine dies too 
end


dofile("./Config/Export/G940leds.lua")

CoroutineIndex = CoroutineIndex + 1
Coroutines[CoroutineIndex] = coroutine.create(g940leds_example) 
--Coroutines[CoroutineIndex] = coroutine.create(g940leds_AutopilotTargetingMode)
LoCreateCoroutineActivity(CoroutineIndex, 0, 0.1) -- start directly and run every 0.1 seconds