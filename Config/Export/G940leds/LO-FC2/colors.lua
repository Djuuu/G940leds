--[[
	Available colors : 
	
	"off"
	"green"
	"amber"
	"red"
	"blink_green"
	"blink_red"
	"blink_amber"
	
--]]
	
G940colors = 
{
	EngineLeft = 
	{
		failure     = "blink_red",
		afterburner = "amber",
		on          = "green",
		starting    = "blink_green",
		off         = "off",
	},	
	
	EngineRight = 
	{
		failure     = "blink_red",
		afterburner = "amber",
		on          = "green",
		starting    = "blink_green",
		off         = "off",
	},

	-- Engines : not configurable
	--           like EngineLeft if both engines are the same
	--           red if one is red
	--           amber if different but none is red
	
	Flaps = 
	{
		flaps_out     = "green",
		flaps_landing = "amber",
		flaps_in      = "off",
	},
	
	Gear = 
	{
		failure   = "blink_red",
		gear_down = "green",
		gear_up   = "off",
	},
	
	Radar = 
	{	
		failure   = "red", 
		radar_on  = "green",
		radar_off = "off",
	},
	
	Irst = 
	{
		irst_on  = "green",
		irst_off = "red",
	},
	
	RadarOrIrst = 
	{
		radar_failure = "red",
		radar_on      = "green",
		irst_on       = "amber",
		all_off       = "off",
	},
	
	Ecm = 
	{
		failure = "red",
		ecm_on  = "green",
		ecm_off = "off",
	},
	
	MasterWarning = 
	{
		warning = "blink_red",
		alright = "off",
	},
	
	Rws = 
	{
		failure = "red",
		missile = "blink_red",
		locked  = "amber",
		scanned = "green",
		clear   = "off",
	},
	
	LaunchAuthorized = 
	{
		yes           = "green",
		no            = "red",
		not_pertinent = "off",
	},
	
	AutoPilot = 
	{
		on  = "green",
		off = "off",
	},
	
	AutoThrust = 
	{
		on  = "green",
		off = "off",
	},
	
	AutoPilotOrThrust = 
	{
		both       = "green",
		autopilot  = "green",
		autothrust = "green",
		off        = "off",
	},
	
	SimpleMode = 
	{
		NAV = "green",
		BVR = "amber",
		CAC = "blink_amber",
		LNG = "blink_amber",
		A2G = "red",
		OFF = "off",
	},
	
	NAVMode = 
	{
		ROUTE   = "green",
		ARRIVAL = "amber",
		LANDING = "red",
		OFF     = "green",
	},
	
	A2AMode = 
	{
		BVR = 
		{
			GUN = "green",
			RWS = "green",
			TWS = "blink_green",
			STT = "red",
			OFF = "green",
		},
		CAC = 
		{
			GUN           = "amber",
			VERTICAL_SCAN = "amber",
			BORE          = "amber",
			HELMET        = "amber",
			STT           = "blink_red",
			OFF           = "amber",
		},
		LNG = 
		{
			GUN   = "amber",
			FLOOD = "amber",
			OFF   = "amber",
		},
	},
	
	A2GMode = 
	{
		GUN      = "red",
		ETS      = "blink_red",
		PINPOINT = "green",
		UNGUIDED = "green",
		OFF      = "red",
	},
	
	Mode = 
	{
		NAV = 
		{
			ROUTE   = "green",
			ARRIVAL = "green",
			LANDING = "blink_green",
			OFF     = "green",
		},
		BVR = 
		{
			GUN = "amber",
			RWS = "amber",
			TWS = "amber",
			STT = "blink_amber",
			OFF = "amber",
		},
		CAC = 
		{
			GUN           = "amber",
			VERTICAL_SCAN = "amber",
			BORE          = "amber",
			HELMET        = "amber",
			STT           = "blink_amber",
			OFF           = "amber",
		},
		LNG = 
		{
			GUN   = "amber",
			FLOOD = "amber",
			OFF   = "amber",
		},
		A2G = 
		{
			GUN      = "red",
			ETS      = "blink_red",
			PINPOINT = "red",
			UNGUIDED = "red",
			OFF      = "red",
		},
		OFF = "off",
	},
}