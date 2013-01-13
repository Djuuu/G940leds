
-------------------------------------------------------
-- Export data from Lock On FC2 to get light statuses
-------------------------------------------------------

dofile("./Config/Export/G940leds/LO-FC2/colors.lua");

G940export = 
{
	
	planes = {
	
		-- plane names case don't seem consistent beteen LO/FC versions
		["a-10a"]=1,  ["A-10A"]=1, 
		["F-15C"]=2,  ["F-15C"]=2, 
		["mig-29"]=3, ["Mig-29"]=3, ["mig-29c"]=3, ["Mig-29C"]=3, 
		["su-27"]=4,  ["Su-27"]=4, 
		["su-33"]=5,  ["Su-33"]=5, 
		["su-25"]=6,  ["Su-25"]=6,  
		["su-25t"]=7, ["su-25T"]=7, ["Su-25T"]=7, 
		
		other=9,
	},
	
	planes_engine_ready = {
		[1] = 67, -- A-10A
		[2] = 67, -- F-15C
		[3] = 67, -- MiG-29(C)
		[4] = 67, -- Su-27
		[5] = 67, -- Su-33
		[6] = 37, -- Su-25
		[7] = 34, -- Su-25T
		
		[9] = 50, -- other
	},
	
	plane_type, 
	
	has_two_level_flaps,


	-- data will be loaded only if needed
	get_export_engine   = function(self) if not self.export_engine   then self.export_engine   = LoGetEngineInfo() end end,
	get_export_sighting = function(self) if not self.export_sighting then self.export_sighting = LoGetSightingSystemInfo() end end,
	get_export_mech     = function(self) if not self.export_mech     then self.export_mech     = LoGetMechInfo() end end,
	get_export_mcp      = function(self) if not self.export_mcp      then self.export_mcp      = LoGetMCPState() end end,
	get_export_rws      = function(self) if not self.export_rws      then self.export_rws      = LoGetTWSInfo() end end,
	get_export_nav      = function(self) if not self.export_nav      then self.export_nav      = LoGetNavigationInfo() end end,
	
	
	-- Aircraft specific initializations
	
	get_export_plane  = function(self) 
		if not self.plane_type  then 
			local plane_id;
			local playerplane;
			local plane_name;
			--local plane_label;
			plane_id = LoGetPlayerPlaneId();
			if plane_id    then playerplane = LoGetObjectById(plane_id) end;
			if playerplane then plane_name  = LoGetObjectById(LoGetPlayerPlaneId()).Name; end
			--if plane_name  then plane_label = string.gsub(string.sub(plane_name,1,5),"-",""); end
			--if self.planes[plane_label] 

			if self.planes[plane_name] 
				--then self.plane_type = self.planes[plane_label]
				then self.plane_type = self.planes[plane_name]
				else self.plane_type = self.planes.other 
			end;
		
			if self.plane_type == self.planes["A-10A"] or self.plane_type == self.planes["Su-25"] or self.plane_type == self.planes["Su-25T"]
				then self.has_two_level_flaps = true;
				else self.has_two_level_flaps = false;
			end
		end 
	end,

	-- reset data before a new export
	reset = function(self)
		self.export_engine   = nil;
		self.export_sighting = nil;
		self.export_mech     = nil;
		self.export_mcp      = nil;
		self.export_rws      = nil;
		self.export_nav      = nil;
	end,

	-------------------------------------------------------------------------------------
	

	-------------------------------------------------------------------------------------
	-- export functions
	
	["EngineLeft"] = function(self)
		self:get_export_mcp();
		self:get_export_engine();
		self:get_export_plane();
		
		if self.export_mcp and self.export_engine then
			if     self.export_mcp.LeftEngineFailure then return G940leds[G940colors.EngineLeft.failure];   -- failure
			elseif self.export_engine.RPM.left > 100 then return G940leds[G940colors.EngineLeft.afterburner]; -- afterburner
			elseif self.export_engine.RPM.left > 0   then 
				if self.export_engine.RPM.left > self.planes_engine_ready[self.plane_type] 
					then return G940leds[G940colors.EngineLeft.on];  								 -- on
					else return G940leds[G940colors.EngineLeft.starting]; 							 -- starting / stopping
				end
			else   return G940leds[G940colors.EngineLeft.off] end; 									 -- off
		else  return G940leds["off"] end; 									         -- default
	end,
	
	["EngineRight"] = function(self)
		self:get_export_mcp();
		self:get_export_engine();
		self:get_export_plane();
		
		if self.export_mcp and self.export_engine then
			if     self.export_mcp.RightEngineFailure then return G940leds[G940colors.EngineRight.failure]   ; -- failure
			elseif self.export_engine.RPM.right > 100 then return G940leds[G940colors.EngineRight.afterburner] ; -- afterburner
			elseif self.export_engine.RPM.right > 0   then 
				if self.export_engine.RPM.right > self.planes_engine_ready[self.plane_type] 
					then return G940leds[G940colors.EngineRight.on];  								 -- on
					else return G940leds[G940colors.EngineRight.starting]; 								 -- starting / stopping
				end
			else   return G940leds[G940colors.EngineRight.off] end;										 -- off
		else   return G940leds["off"] end;										 -- default
	end,
	
	["Engines"] = function(self)
		local left  = self:EngineLeft();
		local right = self:EngineRight();
		
		if     left == right then return left;
		elseif left == G940leds["red"] or right == G940leds["red"] then return G940leds["red"];
		else   return G940leds["amber"] end;
	end,
	
	["Flaps"] = function(self)
		self:get_export_plane();
		self:get_export_mech();
		
		local landing_flaps_color;
		if self.has_two_level_flaps then landing_flaps_color = G940colors.Flaps.flaps_landing;
		else landing_flaps_color = G940colors.Flaps.flaps_out; end
		
		if self.export_mech then
			if     self.export_mech.flaps.status == 2 then return G940leds[landing_flaps_color]       ; -- landing
			elseif self.export_mech.flaps.status == 1 then return G940leds[G940colors.Flaps.flaps_out] ; -- out
			else   return G940leds[G940colors.Flaps.flaps_in] end;										-- in
		else   return G940leds["off"] end;										        -- default
	end, 
	
	["Gear"] = function(self)
		self:get_export_mcp();
		self:get_export_mech();
		if self.export_mcp and self.export_mech then
			if     self.export_mcp.GearFailure       then return G940leds[G940colors.Gear.failure]   ; -- failure
			elseif self.export_mech.gear.status == 1 then return G940leds[G940colors.Gear.gear_down] ; -- down
			else   return G940leds[G940colors.Gear.gear_up] end;  									  -- up
		else   return G940leds["off"] end;  										-- default
	end, 
	
	["Radar"] = function(self)
		self:get_export_mcp();
		self:get_export_sighting();
		
		if self.export_mcp and self.export_sighting then
			if     self.export_mcp.RadarFailure  then return G940leds[G940colors.Radar.failure]   ; -- failure
			elseif self.export_sighting.radar_on then return G940leds[G940colors.Radar.radar_on] ; -- on
			else   return G940leds[G940colors.Radar.radar_off] end;  								  -- off
		else   return G940leds["off"] end;  								  -- default
	end, 

	["Irst"] = function(self)
		self:get_export_sighting();
		
		if self.export_sighting then
			if self.export_sighting.optical_system_on then return G940leds[G940colors.Irst.irst_on]; -- on
			else return G940leds[G940colors.Irst.irst_off] end;  									   -- off
		else return G940leds["off"] end;  									      -- default
	end, 
	
	["RadarOrIrst"] = function(self)
		self:get_export_mcp();
		self:get_export_sighting();
		
		if self.export_mcp and self.export_sighting then
			if     self.export_mcp.RadarFailure           then return G940leds[G940colors.RadarOrIrst.radar_failure]   ; -- RADAR failure
			elseif self.export_sighting.optical_system_on then return G940leds[G940colors.RadarOrIrst.irst_on] ; -- IRST on
			elseif self.export_sighting.radar_on          then return G940leds[G940colors.RadarOrIrst.radar_on] ; -- RADAR on
			else   return G940leds[G940colors.RadarOrIrst.all_off] end;											   -- all off
		else   return G940leds["off"] end;											   -- default
	end, 
	
	["Ecm"] = function(self)
		self:get_export_mcp();
		self:get_export_sighting();
		
		if self.export_mcp and self.export_sighting then
			if     self.export_mcp.ECMFailure  then return G940leds[G940colors.Ecm.failure]   ; -- failure
			elseif self.export_sighting.ECM_on then return G940leds[G940colors.Ecm.ecm_on] ; -- music on
			else   return G940leds[G940colors.Ecm.ecm_off] end;									-- intermission
		else   return G940leds["off"] end;									    -- default
	end, 
	
	["MasterWarning"] = function(self)
		self:get_export_mcp();
		
		if self.export_mcp then
			if self.export_mcp.MasterWarning then return G940leds[G940colors.MasterWarning.warning]; -- MAMA ! (...ster warning)
			else return G940leds[G940colors.MasterWarning.alright] end;							   -- cool
		else return G940leds["off"] end;							       -- default
		
	end, 
	
	["Rws"] = function(self)
		self:get_export_mcp();
		self:get_export_rws();
		
		if self.export_mcp and self.export_mcp.RWSFailure then return G940leds[G940colors.Rws.failure];  -- failure
		else 
			if self.export_rws then
				if self.export_rws.Emitters then
					local launch = false;
					local lock = false;
					local scan = false;
					
					-- scan emitters for the most dangerous threat
					for i, v in ipairs( self.export_rws.Emitters ) do 
						if v.SignalType then
							if     v.SignalType == "missile_radio_guided" then launch = true; break;
							elseif v.SignalType == "lock"                 then lock   = true; 
							elseif v.SignalType == "scan"                 then scan   = true; 
							elseif v.SignalType == "track_while_scan"     then scan   = true; end;
						end
					end
					
					if     launch then return G940leds[G940colors.Rws.missile];  -- pray
					elseif lock   then return G940leds[G940colors.Rws.locked];      -- gtfo
					elseif scan   then return G940leds[G940colors.Rws.scanned];
					else   return G940leds[G940colors.Rws.clear] end;				 -- default
					
				else return G940leds["off"] end;					 -- default
			else return G940leds["off"] end;						 -- default
		end
	end,
	
	["LaunchAuthorized"] = function(self)
		self:get_export_nav();
		self:get_export_sighting();
		
		if self.export_sighting and self.export_nav and self.export_nav.SystemMode then
			local master  = self.export_nav.SystemMode.master;
			local submode = self.export_nav.SystemMode.submode;
			if master == "BVR" or master == "CAC" or master == "LNG" or master == "A2G" then
				if self.export_sighting.LaunchAuthorized 
					then return G940leds[G940colors.LaunchAuthorized.yes]; -- Launch Authorized
					else return G940leds[G940colors.LaunchAuthorized.no];  -- Launch NOT Authorized
				end
				
			else return G940leds[G940colors.LaunchAuthorized.not_pertinent]; end;	-- not pertinent
				
		else return G940leds["off"] end;						 -- default
	end,
	
	
	["AutoPilot"] = function(self)
		self:get_export_nav();
		
		if self.export_nav then
		
			local mode = self.export_nav.ACS.mode;
			if mode then
		
				if mode ~= "OFF" 
					then return G940leds[G940colors.AutoPilot.on];
					else return G940leds[G940colors.AutoPilot.off];
				end

			else return G940leds["off"] end;						 -- default
		else return G940leds["off"] end;						 -- default
	end,
	
	["AutoThrust"] = function(self)
		self:get_export_nav();
		
		if self.export_nav.ACS then
			local autothrust = self.export_nav.ACS.autothrust;
			
			if autothrust == true 
				then return G940leds[G940colors.AutoThrust.on];
				else return G940leds[G940colors.AutoThrust.off];
			end
		else return G940leds["off"] end;						 -- default
	end,
	
	["AutoPilotOrThrust"] = function(self)
		self:get_export_nav();
		
		if self.export_nav.ACS then
		
			local mode       = self.export_nav.ACS.mode;
			local autothrust = self.export_nav.ACS.autothrust;
			
			if mode then
				if     mode ~= "OFF" and autothrust == true  then return G940leds[G940colors.AutoPilotOrThrust.both];
				elseif mode ~= "OFF" and autothrust == false then return G940leds[G940colors.AutoPilotOrThrust.autopilot];
				elseif mode == "OFF" and autothrust == true  then return G940leds[G940colors.AutoPilotOrThrust.autothrust];
				elseif mode == "OFF" and autothrust == false then return G940leds[G940colors.AutoPilotOrThrust.off];
				else return G940leds["off"] end;						 -- default
			else return G940leds["off"] end;						 -- default
			
		else return G940leds["off"] end;						 -- default
	end,

	
	["SimpleMode"] = function(self)
		self:get_export_nav();
		
		if self.export_nav then
		
			if self.export_nav.SystemMode then
				local master  = self.export_nav.SystemMode.master;
				local submode = self.export_nav.SystemMode.submode;
				if master and submode then 
				
					if     master == "NAV" then return G940leds[G940colors.SimpleMode.NAV]; 
					elseif master == "BVR" then return G940leds[G940colors.SimpleMode.BVR]; 
					elseif master == "CAC" then return G940leds[G940colors.SimpleMode.CAC]; 
					elseif master == "LNG" then return G940leds[G940colors.SimpleMode.LNG]; 
					elseif master == "A2G" then return G940leds[G940colors.SimpleMode.A2G]; 
					elseif master == "OFF" then return G940leds[G940colors.SimpleMode.OFF]; 
			
					else return G940leds["off"] end;						 -- default
				
				else return G940leds["off"] end;						 -- default
			else return G940leds["off"] end;						 -- default
		else return G940leds["off"] end;						 -- default
		
	end,
	
	["NAVMode"] = function(self)
		self:get_export_nav();
		
		if self.export_nav then
		
			if self.export_nav.SystemMode then
				local master  = self.export_nav.SystemMode.master;
				local submode = self.export_nav.SystemMode.submode;
				if master and submode then 
				
					if     master == "NAV" then
						if     submode == "ROUTE"   then return G940leds[G940colors.NAVMode.ROUTE]; 
						elseif submode == "ARRIVAL" then return G940leds[G940colors.NAVMode.ARRIVAL]; 
						elseif submode == "LANDING" then return G940leds[G940colors.NAVMode.LANDING]; 
						elseif submode == "OFF"     then return G940leds[G940colors.NAVMode.OFF]; 
						else return G940leds["off"] end;						 -- default
									
					else return G940leds["off"] end;						 -- default
					
				else return G940leds["off"] end;						 -- default
			else return G940leds["off"] end;						 -- default
		else return G940leds["off"] end;						 -- default
	end,
	
	["A2AMode"] = function(self)
		self:get_export_nav();
		
		if self.export_nav then
		
			if self.export_nav.SystemMode then
				local master  = self.export_nav.SystemMode.master;
				local submode = self.export_nav.SystemMode.submode;
				if master and submode then 
				
					if master == "BVR" then
						if     submode == "GUN" then return G940leds[G940colors.A2AMode.BVR.GUN]; 
						elseif submode == "RWS" then return G940leds[G940colors.A2AMode.BVR.RWS]; 
						elseif submode == "TWS" then return G940leds[G940colors.A2AMode.BVR.TWS]; 
						elseif submode == "STT" then return G940leds[G940colors.A2AMode.BVR.STT]; 
						elseif submode == "OFF" then return G940leds[G940colors.A2AMode.BVR.OFF]; 
						else return G940leds["off"] end;						 -- default

					elseif master == "CAC" then
						if     submode == "GUN"           then return G940leds[G940colors.A2AMode.CAC.GUN]; 
						elseif submode == "VERTICAL_SCAN" then return G940leds[G940colors.A2AMode.CAC.VERTICAL_SCAN]; 
						elseif submode == "BORE"          then return G940leds[G940colors.A2AMode.CAC.BORE]; 
						elseif submode == "HELMET"        then return G940leds[G940colors.A2AMode.CAC.HELMET]; 
						elseif submode == "STT"           then return G940leds[G940colors.A2AMode.CAC.STT]; 
						elseif submode == "OFF"           then return G940leds[G940colors.A2AMode.CAC.OFF]; 
						else return G940leds["off"] end;						 -- default

					elseif master == "LNG" then
						if     submode == "GUN"   then return G940leds[G940colors.A2AMode.LNG.GUN]; 
						elseif submode == "FLOOD" then return G940leds[G940colors.A2AMode.LNG.FLOOD]; 
						elseif submode == "OFF"   then return G940leds[G940colors.A2AMode.LNG.OFF]; 
						else return G940leds["off"] end;						 -- default
			
					else return G940leds["off"] end;						 -- default
				
				else return G940leds["off"] end;						 -- default
			else return G940leds["off"] end;						 -- default
		else return G940leds["off"] end;						 -- default
	end,
	
	["A2GMode"] = function(self)
		self:get_export_nav();
		
		if self.export_nav then
		
			if self.export_nav.SystemMode then
				local master  = self.export_nav.SystemMode.master;
				local submode = self.export_nav.SystemMode.submode;
				if master and submode then 
				
					if master == "A2G" then
						if     submode == "GUN"      then return G940leds[G940colors.A2GMode.GUN]; 
						elseif submode == "ETS"      then return G940leds[G940colors.A2GMode.ETS]; 
						elseif submode == "PINPOINT" then return G940leds[G940colors.A2GMode.PINPOINT]; 
						elseif submode == "UNGUIDED" then return G940leds[G940colors.A2GMode.UNGUIDED]; 
						elseif submode == "OFF"      then return G940leds[G940colors.A2GMode.OFF]; 
						else return G940leds["off"] end;						 -- default
					else return G940leds["off"] end;						 -- default
				
				else return G940leds["off"] end;						 -- default
			else return G940leds["off"] end;						 -- default
		else return G940leds["off"] end;						 -- default
	end,
	
	["Mode"] = function(self)
		self:get_export_nav();
		
		if self.export_nav then
		
			if self.export_nav.SystemMode then
				local master  = self.export_nav.SystemMode.master;
				local submode = self.export_nav.SystemMode.submode;
				if master and submode then 
				
					if     master == "NAV" then
						if     submode == "ROUTE"   then return G940leds[G940colors.Mode.NAV.ROUTE]; 
						elseif submode == "ARRIVAL" then return G940leds[G940colors.Mode.NAV.ARRIVAL]; 
						elseif submode == "LANDING" then return G940leds[G940colors.Mode.NAV.LANDING]; 
						elseif submode == "OFF"     then return G940leds[G940colors.Mode.NAV.OFF]; 
						else return G940leds["off"] end;						 -- default
						
					elseif master == "BVR" then
						if     submode == "GUN" then return G940leds[G940colors.Mode.BVR.GUN]; 
						elseif submode == "RWS" then return G940leds[G940colors.Mode.BVR.RWS]; 
						elseif submode == "TWS" then return G940leds[G940colors.Mode.BVR.TWS]; 
						elseif submode == "STT" then return G940leds[G940colors.Mode.BVR.STT]; 
						elseif submode == "OFF" then return G940leds[G940colors.Mode.BVR.OFF]; 
						else return G940leds["off"] end;						 -- default

					elseif master == "CAC" then
						if     submode == "GUN"           then return G940leds[G940colors.Mode.CAC.GUN]; 
						elseif submode == "VERTICAL_SCAN" then return G940leds[G940colors.Mode.CAC.VERTICAL_SCAN]; 
						elseif submode == "BORE"          then return G940leds[G940colors.Mode.CAC.BORE]; 
						elseif submode == "HELMET"        then return G940leds[G940colors.Mode.CAC.HELMET]; 
						elseif submode == "STT"           then return G940leds[G940colors.Mode.CAC.STT]; 
						elseif submode == "OFF"           then return G940leds[G940colors.Mode.CAC.OFF]; 
						else return G940leds["off"] end;						 -- default

					elseif master == "LNG" then
						if     submode == "GUN"   then return G940leds[G940colors.Mode.LNG.GUN]; 
						elseif submode == "FLOOD" then return G940leds[G940colors.Mode.LNG.FLOOD]; 
						elseif submode == "OFF"   then return G940leds[G940colors.Mode.LNG.OFF]; 
						else return G940leds["off"] end;						 -- default

					elseif master == "A2G" then
						if     submode == "GUN"      then return G940leds[G940colors.Mode.A2G.GUN]; 
						elseif submode == "ETS"      then return G940leds[G940colors.Mode.A2G.ETS]; 
						elseif submode == "PINPOINT" then return G940leds[G940colors.Mode.A2G.PINPOINT]; 
						elseif submode == "UNGUIDED" then return G940leds[G940colors.Mode.A2G.UNGUIDED]; 
						elseif submode == "OFF"      then return G940leds[G940colors.Mode.A2G.OFF]; 
						else return G940leds["off"] end;						 -- default

					elseif master == "OFF" then return G940leds[G940colors.Mode.OFF]; 
			
					else return G940leds["off"] end;						 -- default
				
				else return G940leds["off"] end;						 -- default
			else return G940leds["off"] end;						 -- default
		else return G940leds["off"] end;						 -- default
	end,
	

	-- fixed colors 
	["off"]         = function(self) return G940leds["off"]   end,
	["green"]       = function(self) return G940leds["green"] end,
	["amber"]       = function(self) return G940leds["amber"] end,
	["red"]         = function(self) return G940leds["red"]   end,
	["blink_green"] = function(self) return G940leds["blink_green"] end,
	["blink_amber"] = function(self) return G940leds["blink_amber"] end,
	["blink_red"]   = function(self) return G940leds["blink_red"]   end,
	
}

	
------------------------------------------------------
-- Documentation from default Export.lua file (FC2) : 
------------------------------------------------------

--[[ You can use registered Lock On internal data exporting functions in this script
and in your scripts called from this script.

Note: following functions are implemented for exporting technology experiments only,
so they may be changed or removed in the future by developers.

All returned values are Lua numbers if not pointed other type.

Output:
LoGetModelTime() -- returns current model time (args - 0, results - 1 (sec))
LoGetMissionStartTime() -- returns mission start time (args - 0, results - 1 (sec))
LoGetPilotName() -- (args - 0, results - 1 (text string))
LoGetPlayerPlaneId() -- (args - 0, results - 1 (number))
LoGetIndicatedAirSpeed() -- (args - 0, results - 1 (m/s))
LoGetTrueAirSpeed() -- (args - 0, results - 1 (m/s))
LoGetAltitudeAboveSeaLevel() -- (args - 0, results - 1 (meters))
LoGetAltitudeAboveGroundLevel() -- (args - 0, results - 1 (meterst))
LoGetAngleOfAttack() -- (args - 0, results - 1 (rad))
LoGetAccelerationUnits() -- (args - 0, results - table {x = Nx,y = NY,z = NZ} 1 (G))
LoGetVerticalVelocity()  -- (args - 0, results - 1(m/s))
LoGetMachNumber()        -- (args - 0, results - 1)
LoGetADIPitchBankYaw()   -- (args - 0, results - 3 (rad))
LoGetMagneticYaw()       -- (args - 0, results - 1 (rad)
LoGetGlideDeviation()    -- (args - 0,results - 1)( -1 < result < 1)
LoGetSideDeviation()     -- (args - 0,results - 1)( -1 < result < 1)
LoGetSlipBallPosition()  -- (args - 0,results - 1)( -1 < result < 1)
LoGetBasicAtmospherePressure() -- (args - 0,results - 1) (mm hg)
LoGetControlPanel_HSI()  -- (args - 0,results - table)
result = 
{
	ADF , (rad)
	RMI , (rad)
	Compass,(rad)
}
LoGetEngineInfo() -- (args - 0 ,results = table)
engineinfo =
{
	RPM = {left, right},(%)
	Temperature = { left, right}, (Celcium degrees)
	HydraulicPressure = {left ,right},kg per square centimeter
	FuelConsumption   = {left ,right},kg per sec
    fuel_internal      -- fuel quantity internal tanks	kg
	fuel_external      -- fuel quantity external tanks	kg
			
}

LoGetRoute()  -- (args - 0,results = table)
get_route_result =
{
	goto_point, -- next waypoint
	route       -- all waypoints of route (or approach route if arrival or landing)
}
waypoint_table =
{
	this_point_num,        -- number of point ( >= 0)
	world_point = {x,y,z}, -- world position in meters
	speed_req,             -- speed at point m/s 
	estimated_time,        -- sec
	next_point_num,		   -- if -1 that's the end of route
	point_action           -- name of action "ATTACKPOINT","TURNPOINT","LANDING","TAKEOFF"
}
LoGetNavigationInfo() (args - 0,results - 1( table )) -- information about ACS
get_navigation_info_result =
{
	SystemMode = {master,submode}, -- (string,string) current mode and submode 
--[=[
	master values (depend of plane type)
				"NAV"  -- navigation
			    "BVR"  -- beyond visual range AA mode
				"CAC"  -- close air combat				
				"LNG"  -- longitudinal mode
				"A2G"  -- air to ground
				"OFF"  -- mode is absent
	submode values (depend of plane type and master mode)
	"NAV" submodes
	{
		"ROUTE"
		"ARRIVAL"
		"LANDING"
		"OFF" 
	}
	"BVR" submodes
	{ 
		"GUN"   -- Gunmode
		"RWS"   -- RangeWhileSearch
		"TWS"   -- TrackWhileSearch
		"STT"   -- SingleTrackTarget (Attack submode)
		"OFF" 
	}
	"CAC" submodes
	{
		"GUN"
		"VERTICAL_SCAN"
		"BORE"
		"HELMET"  
		"STT"
		"OFF"
	}
	"LNG" submodes
	{
		"GUN"
		"OFF"
		"FLOOD"  -- F-15 only
	}
	"A2G" submodes
	{
		"GUN"
		"ETS"       -- Emitter Targeting System On
		"PINPOINT"  
		"UNGUIDED"  -- unguided weapon (free fall bombs, dispensers , rockets) 
		"OFF"
	}
--]=]
	Requirements =  -- required parameters of flight
	{
		roll,	   -- required roll,pitch.. , etc.
		pitch,	   
		speed,	
		vertical_speed, 
		altitude,
	}
	ACS =   -- current state of the Automatic Control System
	{
		mode = string , 
		--[=[
			mode values  are : 	
					"FOLLOW_ROUTE",
					"BARO_HOLD",          
					"RADIO_HOLD",       
					"BARO_ROLL_HOLD",     
					"HORIZON_HOLD",   
					"PITCH_BANK_HOLD",
					"OFF"
		--]=]
		autothrust , -- 1(true) if autothrust mode is on or 0(false) when not;  
	}
}
LoGetMCPState() -- (args - 0, results - 1 (table of key(string).value(boolean))
	returned table keys for LoGetMCPState():
		"LeftEngineFailure"
		"RightEngineFailure"
		"HydraulicsFailure"
		"ACSFailure"
		"AutopilotFailure"
		"AutopilotOn"
		"MasterWarning"
		"LeftTailPlaneFailure"
		"RightTailPlaneFailure"
		"LeftAileronFailure"
		"RightAileronFailure"
		"CanopyOpen"
		"CannonFailure"
		"StallSignalization"
		"LeftMainPumpFailure"
		"RightMainPumpFailure"
		"LeftWingPumpFailure"
		"RightWingPumpFailure"
		"RadarFailure"
		"EOSFailure"
		"MLWSFailure"
		"RWSFailure"
		"ECMFailure"
		"GearFailure"
		"MFDFailure"
		"HUDFailure"
		"HelmetFailure"
		"FuelTankDamage"
LoGetObjectById() -- (args - 1 (number), results - 1 (table))
 Returned object table structure:
 { 
	Name = 
	Type =  {level1,level2,level3,level4},  ( see Scripts/database/wsTypes.lua) Subtype is absent  now
	Country   =   number ( see Scripts/database/db_countries.lua
	Coalition = 
	CoalitionID = number ( 1 or 2 )
	LatLongAlt = { Lat = , Long = , Alt = }
	Heading =   radians
	Pitch      =   radians
	Bank      =  radians
	Position = {x,y,z} -- in internal DCS coordinate system ( see convertion routnes below)
	-- only for units ( Planes,Hellicopters,Tanks etc)
	UnitName    = unit name from mission (UTF8)  
	GroupName = unit name from mission (UTF8)	
	(  convertion utils are binded as     iconv_LocalFromUTF8(string)     and    iconv_UTF8FromLocal(string) )
 }


LoGetWorldObjects() -- (args - 0- 1, results - 1 (table of object tables))  arg can be "units" (default) or "ballistic" , ballistic - for different type of unguided munition ()bombs,shells,rockets)
 Returned table index = object identificator
 Returned object table structure (see LoGetObjectById())

LoGetSelfData return the same result as LoGetObjectById but only for your aircraft and not depended on anti-cheat setting in Export/Config.lua
 
LoGetAltitude(x, z) -- (args - 2 : meters, results - 1 : altitude above terrain surface, meters)

LoGetCameraPosition() -- (args - 0, results - 1 : view camera current position table:
	{
		x = {x = ..., y = ..., z = ...},	-- orientation x-vector
		y = (x = ..., y = ..., z = ...},	-- orientation y-vector
		z = {x = ..., y = ..., z = ...},	-- orientation z-vector
		p = {x = ..., y = ..., z = ...}		-- point vector 
    }
    all coordinates are in meters. You can use Vector class for position vectors.
    
-- Weapon Control System
LoGetNameByType () -- args 4 (number : level1,level2,level3,level4), result string

LoGetTargetInformation()       -- (args - 0, results - 1 (table of current targets tables)) 
 this function return the table of the next target data
 target =
 {
	ID ,                                  -- world ID (may be 0 ,when ground point track)
	type = {level1,level2,level3,level4}, -- world database classification
	country = ,                           -- object country
	position = {x = {x,y,z},   -- orientation X ort  
	            y = {x,y,z},   -- orientation Y ort
				z = {x,y,z},   -- orientation Z ort
				p = {x,y,z}}   -- position of the center  
	velocity =        {x,y,z}, -- world velocity vector m/s
	distance = ,               -- distance in meters
	convergence_velocity = ,   -- closing speed in m/s
	mach = ,                   -- M number
	delta_psi = ,              -- aspect angle rad
	fim = ,                    -- viewing angle horizontal (in your body axis) rad
	fin = ,                    -- viewing angle vertical   (in your body axis) rad
	flags = ,				   -- field with constants detemining  method of the tracking 
								--	whTargetRadarView		= 0x0002;	-- Radar review (BVR) 
								--	whTargetEOSView			= 0x0004;	-- EOS   review (BVR)
								--	whTargetRadarLock		= 0x0008;	-- Radar lock (STT)  == whStaticObjectLock (pinpoint) (static objects,buildings lock)
								--	whTargetEOSLock			= 0x0010;	-- EOS   lock (STT)  == whWorldObjectLock (pinpoint)  (ground units lock)
								--	whTargetRadarTrack		= 0x0020;	-- Radar lock (TWS)
								--	whTargetEOSTrack		= 0x0040;	-- Radar lock (TWS)  == whImpactPointTrack (pinpoint) (ground point track)
								--	whTargetNetHumanPlane	= 0x0200;	-- net HumanPlane
								--	whTargetAutoLockOn  	= 0x0400;	-- EasyRadar  autolockon
								--	whTargetLockOnJammer  	= 0x0800;	-- HOJ   mode

	reflection = ,             -- target cross section square meters
	course = ,                 -- target course rad
	isjamming = ,              -- target ECM on or not
	start_of_lock = ,          -- time of the beginning of lock
	forces = { x,y,z},         -- vector of the acceleration units 
	updates_number = ,         -- number of the radar updates
	
	jammer_burned = true/false -- indicates that jammer are burned
 }
 
LoGetLockedTargetInformation() -- (args - 0, results - 1 (table of current locked targets tables)) 
result is table of targets with Dynamic Launch Zone for each target
sample:
  local tbl_ = LoGetLockedTargetInformation()
  for i=1,#tbl_ do
      local item = tbl_[i]

	  item.target  -- the same table as in result of LoGetTargetInformation() 
	  item.DLZ -- table of distances RAERO,RPI,RTR,RMIN
	  print(item.DLZ.RAERO,item.DLZ.RPI,item.DLZ.RTR,RMIN) 
  end
  
LoGetF15_TWS_Contacts() -- the same information but only for F-15 in TWS mode

LoGetSightingSystemInfo() -- sight system info
{
	Manufacturer  = "RUS"/"USA"
	LaunchAuthorized  = true/false
	ScanZone =
		{
				position
				{
					azimuth
					elevation
					if Manufacturer  == "RUS" then
					        distance_manual
					       exceeding_manual
					end
				   }
				coverage_H
				{
					min
					max
				}
				size
				{
					azimuth
					elevation
				}
		}
		scale
		{
			distance					
			azimuth
		}
		TDC 
		{
				x
				y
		}
	
		radar_on   = true/false
		optical_system_on= true/false
		ECM_on= true/false
		laser_on= true/false
		
		PRF = 
		{
			current ,    -- current PRF value ( changed in ILV mode ) , values are "MED" or "HI"
			selection ,  -- selection value can be  "MED"  "HI" or "ILV"
		}

}
LoGetTWSInfo() -- return Threat Warning System status (result  the table )
result_of_LoGetTWSInfo =
{
	Mode = , -- current mode (0 - all ,1 - lock only,2 - launch only
	Emitters = {table of emitters}
}
emitter_table =
{
	ID =, -- world ID
	Type = {level1,level2,level3,level4}, -- world database classification of emitter
	Power =, -- power of signal
	Azimuth =,
	Priority =,-- priority of emitter (int)
	SignalType =, -- string with vlues: "scan" ,"lock", "missile_radio_guided","track_while_scan";
}
LoGetPayloadInfo() -- return weapon stations
result_of_LoGetPayloadInfo 
{
	CurrentStation = , -- number of current station (0 if no station selected)
	Stations = {},-- table of stations
	Cannon =
	{
		shells -- current shells count 
	}
}
station 
{
	container = true/false , -- is station container
	weapon    = {level1,level2,level3,level4} , -- world database classification of weapon
	count = ,
}
LoGetMechInfo() -- mechanization info
result_is =
{
	gear          = {status,value,main = {left = {rod},right = {rod},nose =  {rod}}}
	flaps		  = {status,value}  
	speedbrakes   = {status,value}
	refuelingboom = {status,value}
	airintake     = {status,value}
	noseflap      = {status,value}
	parachute     = {status,value}
	wheelbrakes   = {status,value}
	hook          = {status,value}
	wing          = {status,value}
	canopy        = {status,value}
	controlsurfaces = {elevator = {left,right},eleron = {left,right},rudder = {left,right}} -- relative vlues (-1,1) (min /max) (sorry:(
} 

LoGetRadioBeaconsStatus() -- beacons lock
{
	airfield_near	,
	airfield_far,
	course_deviation_beacon_lock	,
	glideslope_deviation_beacon_lock
}

LoGetWingInfo() -- your wingmens info result is vector of wingmens with value:
wingmen_is =
{
	wingmen_id   -- world id of wingmen
	wingmen_position -- world position {x = {x,y,z},   -- orientation X ort  
										y = {x,y,z},   -- orientation Y ort
										z = {x,y,z},   -- orientation Z ort
										p = {x,y,z}}   -- position of the center  
	current_target -- world id of target
	ordered_target -- world id of target 
	current_task   -- name of task
	ordered_task   -- name of task 
	--[=[
	name can be :
			"NOTHING"
			"ROUTE"
			"DEPARTURE"
			"ARRIVAL"
			"REFUELING"
			"SOS"    -- Save Soul of your Wingmen :) 
			"ROUTE"
			"INTERCEPT"
			"PATROL"
			"AIR_ATTACK"
			"REFUELING"
			"AWACS"
			"OBSERVATION"
			"RECON"
			"ESCORT"
			"PINPOINT"
			"CAS"
			"MISSILE_EVASION"
			"ENEMY_EVASION"
			"SEAD"
			"ANTISHIP"
			"RUNWAY_ATTACK"
			"TRANSPORT"
			"LANDING"
			"TAKEOFF"
			"TAXIING"
	--]=]

}

Coordinates convertion :
{x,y,z}				  = LoGeoCoordinatesToLoCoordinates(longitude_degrees,latitude_degrees)
{latitude,longitude}  = LoLoCoordinatesToGeoCoordinates(x,z);

LoGetVectorVelocity		  =  {x,y,z} -- vector of self velocity (world axis)
LoGetAngularVelocity	  =  {x,y,z} -- angular velocity euler angles , rad per sec 
LoGetVectorWindVelocity   =  {x,y,z} -- vector of wind velocity (world axis)
LoGetWingTargets		  =   table of {x,y,z}
LoGetSnares               =   {chaff,flare}
Input:
LoSetCameraPosition(pos) -- (args - 1: view camera current position table, results - 0)
	pos table structure: 
	{
		x = {x = ..., y = ..., z = ...},	-- orientation x-vector
		y = (x = ..., y = ..., z = ...},	-- orientation y-vector
		z = {x = ..., y = ..., z = ...},	-- orientation z-vector
		p = {x = ..., y = ..., z = ...}		-- point vector 
    }
    all coordinates are in meters. You can use Vector class for position vectors.

LoSetCommand(command, value) -- (args - 2, results - 0)
-1.0 <= value <= 1.0

Some analogous joystick/mouse input commands:
command = 2001 - joystick pitch
command = 2002 - joystick roll
command = 2003 - joystick rudder
-- Thrust values are inverted for some internal reasons, sorry.
command = 2004 - joystick thrust (both engines)
command = 2005 - joystick left engine thrust
command = 2006 - joystick right engine thrust
command = 2007 - mouse camera rotate left/right  
command = 2008 - mouse camera rotate up/down
command = 2009 - mouse camera zoom 
command = 2010 - joystick camera rotate left/right
command = 2011 - joystick camera rotate up/down
command = 2012 - joystick camera zoom 
command = 2013 - mouse pitch
command = 2014 - mouse roll
command = 2015 - mouse rudder
-- Thrust values are inverted for some internal reasons, sorry.
command = 2016 - mouse thrust (both engines)
command = 2017 - mouse left engine thrust
command = 2018 - mouse right engine thrust
command = 2019 - mouse trim pitch
command = 2020 - mouse trim roll
command = 2021 - mouse trim rudder
command = 2022 - joystick trim pitch
command = 2023 - joystick trim roll
command = 2024 - trim rudder
command = 2025 - mouse rotate radar antenna left/right
command = 2026 - mouse rotate radar antenna up/down
command = 2027 - joystick rotate radar antenna left/right
command = 2028 - joystick rotate radar antenna up/down
command = 2029 - mouse MFD zoom
command = 2030 - joystick MFD zoom
command = 2031 - mouse move selecter left/right
command = 2032 - mouse move selecter up/down
command = 2033 - joystick move selecter left/right
command = 2034 - joystick move selecter up/down

Some discrete keyboard input commands (value is absent):
command = 7	-- Cockpit view				
command = 8	-- External view						
command = 9	-- Fly-by view						
command = 10 -- Ground units view				
command = 11 -- Civilian transport view 						
command = 12 -- Chase view						
command = 13 -- Navy view						
command = 14 -- Close air combat view						
command = 15 -- Theater view						
command = 16 -- Airfield (free camera) view						
command = 17 --	Instruments panel view on				
command = 18 -- Instruments panel view off				
command = 19 -- Padlock toggle						
command = 20 --	Stop padlock (in cockpit only)				
command = 21 --	External view for my plane 							
command = 22 --	Automatic chase mode for launched weapon						
command = 23 --	View allies only filter 					
command = 24 --	View enemies only filter 				
command = 26 -- View allies & enemies filter 					
command = 28 -- Rotate the camera left fast 						
command = 29 -- Rotate the camera right fast 						
command = 30 -- Rotate the camera up fast 					
command = 31 -- Rotate the camera down fast 						
command = 32 -- Rotate the camera left slow 					
command = 33 -- Rotate the camera right slow 					
command = 34 -- Rotate the camera up slow						
command = 35 -- Rotate the camera down slow					
command = 36 -- Return the camera to default position 						
command = 37 --	View zoom in fast 					
command = 38 -- View zoom out fast 						
command = 39 -- View zoom in slow 				
command = 40 -- View zoom out slow				
command = 41 -- Pan the camera left 					
command = 42 -- Pan the camera right 				
command = 43 -- Pan the camera up 					
command = 44 -- Pan the camera down 					
command = 45 -- Pan the camera left slow 				
command = 46 -- Pan the camera right slow 			
command = 47 -- Pan the camera up slow 				
command = 48 -- Pan the camera down slow 				
command = 49 -- Disable panning the camera 				
command = 50 -- Allies chat 				
command = 51 -- Mission quit 							
command = 52 -- Suspend/resume model time 						
command = 53 -- Accelerate model time 						
command = 54 -- Step by step simulation when model time is suspended 						
command = 55 --	Take control in the track 					
command = 57 -- Common chat						
command = 59 -- Altitude stabilization 			
command = 62 -- Autopilot 					
command = 63 -- Auto-thrust 					
command = 64 -- Power up 				
command = 65 -- Power down 			
command = 68 -- Gear 					
command = 69 -- Hook 						
command = 70 -- Pack wings				
command = 71 -- Canopy 						
command = 72 -- Flaps 						
command = 73 -- Air brake 					
command = 74 -- Wheel brakes on 				
command = 75 -- Wheel brakes off 				
command = 76 -- Release drogue chute 					
command = 77 -- Drop snar 					
command = 78 -- Wingtip smoke 			
command = 79 -- Refuel on 					
command = 80 -- Refuel off 				
command = 81 -- Salvo 				
command = 82 -- Jettison weapons 			
command = 83 -- Eject 						
command = 84 -- Fire on 						
command = 85 -- Fire off 					
command = 86 -- Radar 				
command = 87 -- EOS 					
command = 88 -- Rotate the radar antenna left 					
command = 89 -- Rotate the radar antenna right 				
command = 90 -- Rotate the radar antenna up 				
command = 91 -- Rotate the radar antenna down 					
command = 92 -- Center the radar antenna 				
command = 93 -- Trim left 					
command = 94 -- Trim right 					
command = 95 -- Trim up 					
command = 96 -- Trim down 					
command = 97 -- Cancel trimming 				
command = 98 -- Trim the rudder left 			
command = 99 -- Trim the rudder right 			
command = 100 -- Lock the target 			
command = 101 -- Change weapon 				
command = 102 -- Change target 				
command = 103 -- MFD zoom in 					
command = 104 -- MFD zoom out 					
command = 105 -- Navigation mode   (value 1, 2, 3, 4 for navmode_none, navmode_route, navmode_arrival ,navmode_landing	)
command = 106 -- BVR mode 					
command = 107 -- VS	mode 					
command = 108 -- Bore mode 					
command = 109 -- Helmet mode 				
command = 110 -- FI0 mode 				
command = 111 -- A2G mode 				
command = 112 -- Grid mode 					
command = 113 -- Cannon 				
command = 114 -- Dispatch wingman - complete mission and RTB					
command = 115 -- Dispatch wingman - complete mission and rejoin 					
command = 116 -- Dispatch wingman - toggle formation 					
command = 117 -- Dispatch wingman - join up formation 					
command = 118 -- Dispatch wingman - attack my target 			
command = 119 -- Dispatch wingman - cover my six 				
command = 120 -- Take off from ship			
command = 121 -- Cobra 						
command = 122 -- Sound on/off                      
command = 123 -- Sound recording on 						
command = 124 -- Sound recording off 					
command = 125 -- View right mirror on 				
command = 126 -- View right mirror off 				
command = 127 -- View left mirror on 				
command = 128 -- View left mirror off 				
command = 129 -- Natural head movement view		
command = 131 -- LSO view			
command = 135 -- Weapon to target view 		
command = 136 -- Active jamming 
command = 137 -- Increase details level 			
command = 138 -- Decrease details level 			
command = 139 -- Scan zone left 				    
command = 140 -- Scan zone right 			
command = 141 -- Scan zone up 					    
command = 142 -- Scan zone down 					
command = 143 -- Unlock target 						
command = 144 -- Reset master warning 
command = 145 -- Flaps on 
command = 146 -- Flaps off 
command = 147 -- Air brake on 
command = 148 -- Air brake off 
command = 149 -- Weapons view 				
command = 150 -- Static objects view			
command = 151 -- Mission targets view 				
command = 152 -- Info bar details 				
command = 155 -- Refueling boom 			
command = 156 -- HUD color selection			
command = 158 -- Jump to terrain view 			
command = 159 -- Starts moving F11 camera forward 				
command = 160 -- Starts moving F11 camera backward			
command = 161 -- Power up left engine 
command = 162 -- Power down left engine 
command = 163 -- Power up right engine 
command = 164 -- Power down right engine 
command = 169 -- Immortal mode 			
command = 175 -- On-board lights 			
command = 176 -- Drop snar once 			
command = 177 -- Default cockpit angle of view 			
command = 178 -- Jettison fuel tanks 		
command = 179 -- Wingmen commands panel		
command = 180 -- Reverse objects switching in views	
command = 181 -- Forward objects switching in views 			
command = 182 -- Ignore current object in views 			
command = 183 -- View all ignored objects in views again 				
command = 184 -- Padlock terrain point 			
command = 185 -- Reverse the camera 					
command = 186 -- Plane up 					
command = 187 -- Plane down 
command = 188 -- Bank left 
command = 189 -- Bank right
command = 190 -- Local camera rotation mode 			
command = 191 -- Decelerate model time 					
command = 192 -- Jump into the other plane       			
command = 193 -- Nose down 
command = 194 -- Nose down end 
command = 195 -- Nose up 
command = 196 -- Nose up end 
command = 197 -- Bank left 
command = 198 -- Bank left end 
command = 199 -- Bank right 
command = 200 -- Bank right end 
command = 201 -- Rudder left 
command = 202 -- Rudder left end 
command = 203 -- Rudder right 
command = 204 -- Rudder right end 
command = 205 -- View up right 					
command = 206 -- View down right 					
command = 207 -- View down left 					
command = 208 -- View up left 						
command = 209 -- View stop 						
command = 210 -- View up right slow 			
command = 211 -- View down right slow 				
command = 212 -- View down left slow 				
command = 213 -- View up left slow 					
command = 214 -- View stop slow 					
command = 215 -- Stop trimming 
command = 226 -- Scan zone up right
command = 227 -- Scan zone down right 
command = 228 -- Scan zone down left 
command = 229 -- Scan zone up left 
command = 230 -- Scan zone stop 
command = 231 -- Radar antenna up right 
command = 232 -- Radar antenna down right
command = 233 -- Radar antenna down left 
command = 234 -- Radar antenna up left
command = 235 -- Radar antenna stop
command = 236 -- Save snap view angles 				
command = 237 -- Cockpit panel view toggle 	
command = 245 -- Coordinates units toggle
command = 246 -- Disable model time acceleration 			
command = 252 -- Automatic spin recovery 
command = 253 -- Speed retention 
command = 254 -- Easy landing 
command = 258 -- Threat missile padlock 
command = 259 -- All missiles padlock
command = 261 -- Marker state 				
command = 262 -- Decrease radar scan area 
command = 263 -- Increase radar scan area 
command = 264 -- Marker state plane 				
command = 265 -- Marker state rocket 				
command = 266 -- Marker state plane ship 				
command = 267 -- Ask AWACS home airbase 
command = 268 -- Ask AWACS available tanker
command = 269 -- Ask AWACS nearest target 
command = 270 -- Ask AWACS declare target 
command = 271 -- Easy radar 
command = 272 -- Auto lock on nearest aircraft 
command = 273 -- Auto lock on center aircraft 
command = 274 -- Auto lock on next aircraft 
command = 275 -- Auto lock on previous aircraft 
command = 276 -- Auto lock on nearest surface target 
command = 277 -- Auto lock on center surface target 
command = 278 -- Auto lock on next surface target 
command = 279 -- Auto lock on previous surface target 
command = 280 -- Change cannon rate of fire
command = 281 -- Change ripple quantity 
command = 282 -- Change ripple interval 
command = 283 -- Switch master arm 
command = 284 -- Change release mode 
command = 285 -- Change radar mode RWS/TWS 
command = 286 -- Change RWR/SPO mode
command = 288 -- Flight clock reset 
command = 289 -- Zoom in slow stop 			
command = 290 -- Zoom out slow stop			
command = 291 -- Zoom in stop 				
command = 292 -- Zoom out stop 					
command = 295 -- View horizontal stop 					
command = 296 -- View vertical stop 				
command = 298 -- Jump to fly-by view 			
command = 299 -- Camera jiggle 				
command = 300 -- Cockpit illumination 
command = 308 -- Change ripple interval down 		
command = 309 -- Engines start 				
command = 310 -- Engines stop 			
command = 311 -- Left engine start 			
command = 312 -- Right engine start 			
command = 313 -- Left engine stop 				
command = 314 -- Right engine stop 			
command = 315 -- Power on/off 					
command = 316 -- Altimeter pressure increase 	
command = 317 -- Altimeter pressure decrease 	
command = 318 -- Altimeter pressure stop 
command = 321 -- Fast mouse in views 				
command = 322 -- Slow mouse in views				
command = 323 -- Normal mouse in views 			
command = 326 -- HUD only view 			
command = 327 -- Recover my plane 				
command = 328 -- Toggle gear light Near/Far/Off 		
command = 331 -- Fast keyboard in views			
command = 332 -- Slow keyboard in views 			
command = 333 -- Normal keyboard in views 			
command = 334 -- Zoom in for external views 			
command = 335 -- Stop zoom in for external views 
command = 336 -- Zoom out for external views 
command = 337 -- Stop zoom out for external views 
command = 338 -- Default zoom in external views 
command = 341 -- A2G combat view 			
command = 342 -- Camera view up-left			
command = 343 -- Camera view up-right			
command = 344 -- Camera view down-left		
command = 345 -- Camera view down right	
command = 346 -- Camera pan mode toggle				
command = 347 -- Return the camera			
command = 348 -- Trains/cars toggle		
command = 349 -- Launch permission override	
command = 350 -- Release weapon		
command = 351 -- Stop release weapon
command = 352 -- Return camera base		
command = 353 -- Camera view up-left slow		
command = 354 -- Camera view up-right slow	
command = 355 -- Camera view down-left slow		
command = 356 -- Camera view down-right slow	
command = 357 -- Drop flare once			
command = 358 -- Drop chaff once			
command = 359 -- Rear view					
command = 360 -- Scores window
command = 386 -- PlaneStabPitchBank
command = 387 -- PlaneStabHbarBank
command = 388 -- PlaneStabHorizont
command = 389 -- PlaneStabHbar
command = 390 -- PlaneStabHrad
command = 391 -- Active IR jamming on/off
command = 392 -- Laser range-finder on/off
command = 393 -- Night TV on/off(IR or LLTV) 
command = 394 -- Change radar PRF       
command = 395 -- Keep F11 camera altitude over terrain
command = 396 -- SnapView0
command = 397 -- SnapView1
command = 398 -- SnapView2
command = 399 -- SnapView3
command = 400 -- SnapView4
command = 401 -- SnapView5
command = 402 -- SnapView6
command = 403 -- SnapView7
command = 404 -- SnapView8
command = 405 -- SnapView9
command = 406 -- SnapViewStop
command = 407 -- F11 view binocular mode
command = 408 -- PlaneStabCancel
command = 409 -- ThreatWarnSoundVolumeDown
command = 410 -- ThreatWarnSoundVolumeUp
command = 411 -- F11 binocular view laser range-finder on/off
command = 412 -- PlaneIncreaseBase_Distance
command = 413 -- PlaneDecreaseBase_Distance
command = 414 -- PlaneStopBase_Distance
command = 425 -- F11 binocular view IR mode on/off
command = 426 -- F8 view player targets / all targets
command = 427 -- Plane autopilot override on
command = 428 -- Plane autopilot override off
command = 429 -- Plane route autopilot on/off
command = 430 -- Gear up
command = 431 -- Gear down

To be continued...
--]]

--[[

--	LoEnableExternalFlightModel()   call one time in start
--	LoUpdateExternalFlightModel(binary_data)   update function


--LoGetHelicopterFMData()
-- return table with fm data 
--{
--G_factor = {x,y,z }    in cockpit
--speed = {x,y,z}   center of mass ,body axis 
--acceleration= {x,y,z}   center of mass ,body axis 
--angular_speed= {x,y,z}   rad/s
--angular_acceleration= {x,y,z}   rad/s^2
--yaw    radians
--pitch    radians
--roll    radians
--}

--#ifndef  _EXTERNAL_FM_DATA_H
--#define  _EXTERNAL_FM_DATA_H

--struct external_FM_data  
--{
--	double orientation_X[3];
--	double orientation_Y[3];
--	double orientation_Z[3];
--	double pos[3];

--	//

--	double velocity[3];
--	double acceleration[3];
--	double omega[3];
--};
-- #endif  _EXTERNAL_FM_DATA_H


-- you can export render targets via shared memory interface 
-- using next functions  
--        LoSetSharedTexture(name)          -- register texture with name "name"  to export
--        LoRemoveSharedTexture(name)   -- copy texture with name "name"  to named shared memory area "name"
--        LoUpdateSharedTexture(name)    -- unregister texture
--       texture exported like Windows BMP file 
--      --------------------------------
--      |BITMAPFILEHEADER   |
--      |BITMAPINFOHEADER |
--      |bits                                  |
--      --------------------------------
--      sample textures   :  "mfd0"    -  full  SHKVAL screen
--                                      "mfd1"     -  ABRIS map screen
--                                      "mfd2"    - not used
--                                      "mfd3"    - not used
--                                      "mirrors" - mirrors
 
 --]]
 