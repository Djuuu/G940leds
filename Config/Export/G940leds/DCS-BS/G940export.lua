
-------------------------------------------------------
-- Export data from DCS to get light statuses
-------------------------------------------------------

dofile("./Config/Export/G940leds/DCS-BS/colors.lua");


function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end


-- Return a string, rounded to 1 decimal and the absolute value to avoid the problem with -0.0
function get_argument_str(panel,value)
	return string.format("%.1f",math.abs(panel:get_argument_value(value)))
end


-- Return a number, rounded to 1 decimal and the absolute value to avoid the problem with -0.0
function get_argument_num(panel,value)
	return round(math.abs(panel:get_argument_value(value)), 1);
end


-- Returns wether the button is active (boolean) according to the value
function is_lit_button_active(value)
	return value == 0.1 or value == 0.3;
end


G940export = 
{

	MainPanel = GetDevice(0), 
	
	-- reset data for a new export
	reset = function(self)
	
		-- self.MainPanel:update_arguments() -- Uncomment if you want the leds to update while outside of the cockpit

		-- Lit button returns 0.1 when active. 0.2 when depressed but not active. 0.3 when depressed and active
		-- Indicators returns between 0.0 to 1.0, mostly only 0.0 and 1.0 but for example gear_handle moves between them
		-- 		Indicators with continous values are marked as such)
		

		-- Auto-pilot buttons and switches
		self.bankhold        = get_argument_num(MainPanel,330) -- Lit button
		self.pitchhold       = get_argument_num(MainPanel,331) -- Lit button
		self.headinghold     = get_argument_num(MainPanel,332) -- Lit button
		self.altitudehold    = get_argument_num(MainPanel,333) -- Lit button
		self.flightdirector  = get_argument_num(MainPanel,334) -- Lit button
		self.ap_headingtrack = get_argument_num(MainPanel,336) -- 0.0 heading, 0.5 nothing (hold current course), 1.0 for track
		self.ap_baroralt     = get_argument_num(MainPanel,335) -- 0.0 barometric, 0.5 nothing, 1.0 radar
		
		-- Target mode
		self.autoturn          = get_argument_num(MainPanel,437) -- Lit button
		self.airborne          = get_argument_num(MainPanel,438) -- Lit button
		self.forwardhemisphere = get_argument_num(MainPanel,439) -- Lit button
		self.groundmoving      = get_argument_num(MainPanel,440) -- Lit button
		
		-- Pushable warning lights
		self.master_caution     = get_argument_num(MainPanel,44) -- Indicator
		self.engine_rpm_warning = get_argument_num(MainPanel,46) -- Indicator
		
		-- Misc
		self.gear_handle       = get_argument_num(MainPanel,65) -- Indicator (continous values)
		self.navigation_lights = get_argument_num(MainPanel,146) -- 0.0 off, 0.1 10%, 0.2 50%, 0.3 100%
		self.hover_lamp        = get_argument_num(MainPanel,175) -- Indicator
		self.ralt_lamp         = get_argument_num(MainPanel,170) -- Indicator
		
		-- Weapons switches
		self.master_arm        = get_argument_num(MainPanel,387) -- Indicator
		self.rate_of_fire      = get_argument_num(MainPanel,398) -- Indicator
		self.cannon_round      = get_argument_num(MainPanel,399) -- Indicator
		self.burst_length      = get_argument_num(MainPanel,400) -- 0.0 for short. 0.1 for medium, 0.2 for long
		self.manualautomode    = get_argument_num(MainPanel,403) -- Indicator 1.0 for auto, 0.0 for manual
		self.trainingmode      = get_argument_num(MainPanel,432) -- Indicator 1.0 for traning mode, 0.0 for manual
		self.tracking_gunsight = get_argument_num(MainPanel,436) -- Indicator 1.0 for tracking, 0.0 for gunsight
		self.laser_standby     = get_argument_num(MainPanel,435) -- Indicator
		
		-- PVI
		self.nav_waypoints     = get_argument_num(MainPanel,315) -- Lit button
		self.nav_fixpoints     = get_argument_num(MainPanel,316) -- Lit button
		self.nav_airfields     = get_argument_num(MainPanel,317) -- Lit button
		self.nav_targets       = get_argument_num(MainPanel,318) -- Lit button
		self.nav_initialnavpos = get_argument_num(MainPanel,522) -- Lit button
		self.nav_selfpos       = get_argument_num(MainPanel,319) -- Lit button
		self.nav_course        = get_argument_num(MainPanel,320) -- Lit button
		self.nav_wind          = get_argument_num(MainPanel,321) -- Lit button
		self.nav_trueheading   = get_argument_num(MainPanel,322) -- Lit button
		
		-- Datalink
		self.dlink_toall           = get_argument_num(MainPanel,16) -- Lit button
		self.dlink_wingman1        = get_argument_num(MainPanel,17) -- Lit button
		self.dlink_wingman2        = get_argument_num(MainPanel,18) -- Lit button
		self.dlink_wingman3        = get_argument_num(MainPanel,19) -- Lit button
		self.dlink_wingman4        = get_argument_num(MainPanel,20) -- Lit button
		self.dlink_vehicle         = get_argument_num(MainPanel,21) -- Lit button
		self.dlink_sam             = get_argument_num(MainPanel,22) -- Lit button
		self.dlink_other           = get_argument_num(MainPanel,23) -- Lit buttons
		self.dlink_ingress         = get_argument_num(MainPanel,50) -- Lit buttons
		self.dlink_send            = get_argument_num(MainPanel,159) -- Lit buttons
		self.dlink_ingresstotarget = get_argument_num(MainPanel,150) -- Lit buttons
		self.dlink_erase           = get_argument_num(MainPanel,161) -- Lit buttons

		
		-- Gear  (0.0 not, 1.0 yes)
		self.lg_up   = get_argument_num(MainPanel,59)
		self.lg_down = get_argument_num(MainPanel,60)
		self.rg_up   = get_argument_num(MainPanel,61)
		self.rg_down = get_argument_num(MainPanel,62)
		self.ng_up   = get_argument_num(MainPanel,63)
		self.ng_down = get_argument_num(MainPanel,64)
	
	
		
	end,


	
	-------------------------------------------------------------------------------------
	-- export functions
	
	--[[
	
	
	["FunctionName"] = function(self)
		
		
		self:get_export_thing(); -- only what is needed for the function

		-- It's important to test data existence : may be absent during recovery
		if self.export_thing then 
		
			...
			
			if a then 
				return G940leds[G940colors.FunctionName.state_1]
			else 
				return G940leds[G940colors.FunctionName.state_2]
			end
			
		else  return G940leds["off"]; -- default 
		-- It's important to return something in any case

	end,
	
	
	--]]
	

	
	
	["BankHold_FlightDirector"] = function(self)
		if is_lit_button_active(self.bankhold) then
			if is_lit_button_active(self.flightdirector) then
				return G940colors.BankHold_FlightDirector.FlightDirector;
			else
				return G940colors.BankHold_FlightDirector.on;
			end
		else
			return G940colors.BankHold_FlightDirector.off;
		end
	end,
	
	["PitchHold_FlightDirector"] = function(self)
		if is_lit_button_active(self.pitchhold) then
			if is_lit_button_active(self.flightdirector) then
				return G940colors.PitchHold_FlightDirector.FlightDirector;
			else
				return G940colors.PitchHold_FlightDirector.on;
			end
		else
			return G940colors.PitchHold_FlightDirector.off;
		end
	end,
	
	["HeadingHold_FlightDirector"] = function(self)
		if is_lit_button_active(self.headinghold) then
			if is_lit_button_active(self.flightdirector) then
				return G940colors.HeadingHold_FlightDirector.FlightDirector;
			else
				return G940colors.HeadingHold_FlightDirector.on;
			end
		else
			return G940colors.HeadingHold_FlightDirector.off;
		end
	end,
	
	["AltitudeHold_FlightDirector"] = function(self)
		if is_lit_button_active(self.altitudehold) then
			if is_lit_button_active(self.flightdirector) then
				return G940colors.AltitudeHold_FlightDirector.FlightDirector;
			else
				return G940colors.AltitudeHold_FlightDirector.on;
			end
		else
			return G940colors.AltitudeHold_FlightDirector.off;
		end
	end,
	
	
	["AutoTurn"] = function(self)
		if is_lit_button_active(self.autoturn) then
			return G940colors.AutoTurn.on;
		else
			return G940colors.AutoTurn.off;
		end
	end,
	
	["Airborne"] = function(self)
		if is_lit_button_active(self.airborne) then
			return G940colors.Airborne.on;
		else
			return G940colors.Airborne.off;
		end
	end,
	
	["ForwardHemisphere"] = function(self)
		if is_lit_button_active(self.forwardhemisphere) then
			return G940colors.ForwardHemisphere.on;
		else
			return G940colors.ForwardHemisphere.off;
		end
	end,
	
	["GroundMoving"] = function(self)
		if is_lit_button_active(self.groundmoving) then
			return G940colors.GroundMoving.on;
		else
			return G940colors.GroundMoving.off;
		end
	end,
	

	-------------------------------------------------------------------------------------
	-- fixed colors 
	
	["off"]         = function(self) return G940leds["off"]   end,
	["green"]       = function(self) return G940leds["green"] end,
	["amber"]       = function(self) return G940leds["amber"] end,
	["red"]         = function(self) return G940leds["red"]   end,
	["blink_green"] = function(self) return G940leds["blink_green"] end,
	["blink_amber"] = function(self) return G940leds["blink_amber"] end,
	["blink_red"]   = function(self) return G940leds["blink_red"]   end,
	
}

	
	
	
