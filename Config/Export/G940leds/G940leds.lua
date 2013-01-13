
--------------------------------------------------------
-- Functions for use with G940leds udp listening program
--------------------------------------------------------

dofile("./Config/Export/G940leds/config.lua") ;

function sleep(sec)
    socket.select(nil, nil, sec)
end

G940leds = 
{
	-- listener socket
	c, 
	
	-- log file --
	f, 
	
	-- color codes --
	["off"]         = 0, -- off
	
	["green"]       = 1, -- green
	["red"]         = 2, -- red
	["amber"]       = 3, -- amber
	
	["blink_green"] = 10,
	["blink_red"]   = 20,
	["blink_amber"] = 30,
	
	["blink_state"] = false,
	
	-- button functions (filled in profile) --
	button = { [1] = "", [2] = "", [3] = "", [4] = "", [5] = "", [6] = "", [7] = "", [8] = "", },
	
	-- button leds states --
	led     = { [1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0, [6] = 0, [7] = 0, [8] = 0, }, -- current
	led_old = { [1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0, [6] = 0, [7] = 0, [8] = 0, }, -- previous

	-- currently blinking leds
	blink =  { [1] = false, [2] = false, [3] = false, [4] = false, [5] = false, [6] = false, [7] = false, [8] = false, } , 


	
	
	Init = function(self)
		-- open log file
		self.f = io.open("./Temp/G940leds.log", "w");
		io.output(self.f);
		self:Log("g940leds started\n");
		
		-- open socket
		self:OpenSocket();

		self.running = true;
		
		if G940leds_config_do_intro_kitt 
		then self:led_kitt(); end
		
		if G940leds_config_do_intro_kitt and G940leds_config_do_intro_check 
		then sleep(0.6); end
		
		if G940leds_config_do_intro_check 
		then self:led_check(); end
			
		self.c:send("SetAll=o;"); -- just to be sure
	end,
	
	Finish = function(self)	
		
		if G940leds_config_do_outro 
		then self:led_outro(); end
		
		self.c:send("SetAll=o;"); -- just to be sure
		
		self.running = false;
		
		self:CloseSocket();
		
		self:Log("g940leds finished \n");
		io.close();
	end,
	
	-- Set up the socket, changing port is supported here, but not yet in
	-- g940leds.exe, so don't do it...
	OpenSocket = function(self)
		package.path  = package.path..";.\\LuaSocket\\?.lua";
		package.cpath = package.cpath..";.\\LuaSocket\\?.dll";
		socket = require("socket");
		
		local host = "localhost";
		local dstport = "33331";
		
		self.c = socket.udp();
		self.c:setpeername(host,dstport);
		
		self:Hello("Starting export for G940 leds");
	end,
	
	-- Close the socket
	CloseSocket = function(self)
		
		self:Bye("Stopping export for G940 leds");
		self:Bye("");
		self.c:close();
	end, 
	

	
	-- fun stuff
	
	led_kitt = function(self)
		self.c:send("SetAll=o;");
		
		self.c:send("Leds=aoooaooo;"); sleep(0.05); 
		self.c:send("Leds=rooorooo;"); sleep(0.05); 
		self.c:send("Leds=arooaroo;"); sleep(0.05); 
		self.c:send("Leds=oarooaro;"); sleep(0.05); 
		self.c:send("Leds=ooarooar;"); sleep(0.05); 
		self.c:send("Leds=oooaoooa;"); sleep(0.05); 

		self.c:send("Leds=oooaoooa;"); sleep(0.05);
		self.c:send("Leds=ooorooor;"); sleep(0.05);
		self.c:send("Leds=ooraoora;"); sleep(0.05);
		self.c:send("Leds=oraoorao;"); sleep(0.05);
		self.c:send("Leds=raooraoo;"); sleep(0.05);
		self.c:send("Leds=aoooaooo;"); sleep(0.05);
		
		self.c:send("Leds=aoooaooo;"); sleep(0.05); 
		self.c:send("Leds=rooorooo;"); sleep(0.05); 
		self.c:send("Leds=arooaroo;"); sleep(0.05); 
		self.c:send("Leds=oarooaro;"); sleep(0.05); 
		self.c:send("Leds=ooarooar;"); sleep(0.05); 
		self.c:send("Leds=oooaoooa;"); sleep(0.05); 
		
		self.c:send("Leds=oooaoooa;"); sleep(0.05);
		self.c:send("Leds=ooorooor;"); sleep(0.05);
		self.c:send("Leds=ooraoora;"); sleep(0.05);
		self.c:send("Leds=oraoorao;"); sleep(0.05);
		self.c:send("Leds=raooraoo;"); sleep(0.05);
		self.c:send("Leds=aoooaooo;"); sleep(0.05);
		
		self.c:send("SetAll=o;");
	end, 

	led_check = function(self)
		self.c:send("SetAll=o;");
		self.c:send("SetLed=1g;SetLed=5g;"); sleep(0.2);
		self.c:send("SetLed=2g;SetLed=6g;"); sleep(0.2);
		self.c:send("SetLed=3g;SetLed=7g;"); sleep(0.2);
		self.c:send("SetLed=4g;SetLed=8g;"); sleep(0.6);
		self.c:send("SetAll=o;");
	end, 
	
	led_outro = function(self)
		self.c:send("SetLed=4r;SetLed=8r;"); sleep(0.06);
		self.c:send("SetLed=3r;SetLed=7r;"); sleep(0.06);
		self.c:send("SetLed=3r;SetLed=7r;"); sleep(0.06);
		self.c:send("SetLed=2r;SetLed=6r;SetLed=4a;SetLed=8a;"); sleep(0.06);
		self.c:send("Leds=rragrrag;"); sleep(0.06);
		self.c:send("Leds=raggragg;"); sleep(0.06);
		self.c:send("Leds=agggaggg;"); sleep(0.06);
		self.c:send("Leds=gggogggo;"); sleep(0.06);
		self.c:send("SetLed=3o;SetLed=7o;"); sleep(0.06);
		self.c:send("SetLed=2o;SetLed=6o;"); sleep(0.06);
		self.c:send("SetLed=1o;SetLed=5o;"); 		
	end, 

	
	
	-- Sends the commands to update the leds
	UpdateAll = function(self)
		local command = "";
		local changed = false;

		for i=1,8 do
				
			if self.button[i] then
			
				if G940export[self.button[i]] then
							
					-- executes the function				
					-- we pass the table G940export itself to the function in the arguments, 
					-- since we can't use the syntax with the colon here, ie G940export:func_name()
					self.led[i] = G940export[self.button[i]](G940export);
					
					if self.led[i] then
						local different = self.led_old[i] ~= self.led[i];
						local blinking  = self.blink[i];
						
						-- update the leds only if changed or blinking
						if different or blinking then
							
							if different then self:Log(self.button[i] .. " changed\n"); end
							
							changed = true;
							
							local value = self.led[i];
							
							-- update blinking status
							if value > 3 
								then self.blink[i] = true; 
								else self.blink[i] = false;
							end;
							if self.blink[i] then
								if self.blink_state 
									then value = value/10;
									else value = 0;
								end
							end
							
							command = command .. "SetLed=" .. i .. value .. ";";
							self.led_old[i] = self.led[i];
						end;
						
					else self:Log("ERROR : Button "..i.." : no result for function \""..  self.button[i] .. "\" \n");
					end;
					
				else self:Log("ERROR : Button "..i.." : function \""..self.button[i].."\" doesn't exist \n");
				end
				
			else self:Log("ERROR : Button "..i.." : no function assigned \n");
			end
		end
		
		if changed then 
			self:Log(command .. "\n");
			self.c:send(command); -- update leds
		end;
	end, 
	
	
	
	-- Executed by the coroutine
	Run = function(self)
	
		-- for blinking to blink 
		self.blink_state = not self.blink_state;
		
		--self:Log("Run.  \n");
		
		-- reset previous exported data
		G940export:reset();
		
		-- get led colors according to profile and game data
--		self:RunProfile();
		
		-- update the led colors
		self:UpdateAll();
	end, 

	
	
	-- Logging functions
	Log   = function(self, txt) io.write(txt); end,
	Hello = function(self, txt) if self.c then self.c:send("hello=" .. txt); end end,
	Bye   = function(self, txt) if self.c then self.c:send("bye="   .. txt); end end,
}

--------------------------------------------------------
--------------------------------------------------------

-- Loads Export functions

dofile("./Config/Export/G940leds/" .. G940leds_config_game .. "/G940export.lua") ;


-- Loads user profile

dofile("./Config/Export/G940leds/" .. G940leds_config_game .. "/profile.lua") ;

	
--------------------------------------------------------
-- Hooks
--------------------------------------------------------

--
-- (Hook) Works once just before mission start.
do
	local PrevLuaExportStart=LuaExportStart;
	LuaExportStart = function()
		if PrevLuaExportStart then PrevLuaExportStart(); end
		
		G940leds:Init();
		G940_coroutines_init();
	end
end

-- (Hook) Works once just after mission stop.
do
	local PrevLuaExportStop=LuaExportStop;
	LuaExportStop = function()
		if PrevLuaExportStop then PrevLuaExportStop(); end
		
		G940leds:Finish();
	end
end
--


--[[ (Hook) LuaExportActivityNextEvent

-- alternative to coroutines

do
	local PrevLuaExportActivityNextEvent = LuaExportActivityNextEvent;

	LuaExportActivityNextEvent = function(t)
		local tNext = t
		
		if PrevLuaExportActivityNextEvent then PrevLuaExportActivityNextEvent(tNext); end

		G940leds:Run();
		
		tNext = tNext + G940leds_config_interval		
		return tNext
	end
end
--]]




--------------------------------------------------------
--                   Coroutines 
--------------------------------------------------------

-- Coroutine
function G940_coroutine(t)
	local tNext = t;
	while true do
		G940leds:Run();
		tNext = coroutine.yield();
	end
end


-- coroutine prep and launch
function G940_coroutines_init()

	-- prepare coroutine handling, as commented in default Export.lua, with improved debug
	
	Coroutines      = Coroutines     or {}; -- global coroutines table
	CoroutineIndex  = CoroutineIndex or 0;  -- global last created coroutine index
	CoroutineResume = CoroutineResume or function(index, tCurrent)
		
		local result; local txterror; -- added to improve debug
		
		-- Resume coroutine and give it current model time value
		result,txterror = coroutine.resume(Coroutines[index], tCurrent);
		
		-- debug coroutine errors 
		if not result then G940leds:Log("Coroutine error : ") 
			if txterror then G940leds:Log(txterror) end;
			G940leds:Log("\n");
		end;
		
		return coroutine.status(Coroutines[index]) ~= "dead";
		-- If status == "dead" then Lock On activity for this coroutine dies too 
	end

	-- create and launch our coroutine
	
	CoroutineIndex = CoroutineIndex + 1; 
	Coroutines[CoroutineIndex] = coroutine.create(G940_coroutine);  
	
	LoCreateCoroutineActivity(CoroutineIndex, 0.123, G940leds_config_interval);
end
