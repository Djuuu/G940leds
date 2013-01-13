G940leds
========

G940leds version 1.1 bis

This is a total redesign of the .LUA part that works with the program of Martin Larsson (Morg) 
to control the leds on the Logitech G940 throttle stick with exported data from Lock On / Digital Combat Simulator.

My purposes were : 

   - to make it work with Flaming Cliffs 2 
   - to make the configuration easier
   - to implement blinking lights
   - to minimize the impact on Lock On original Export.lua
   
I have tried to reproduce morg's profile for DCS, but I can't test it. This part needs work from DCS users ;-)
My implementation may not be very pertinent for DCS though : there is a lot more code than in Morg's

-- Installation : 

As you may have noticed, this is la ModMan package. Install with ModMan ;-)
Then you have to add the following line at the end of your /Config/Export/Export.lua file : 

dofile("./Config/Export/G940leds/G940leds.lua") 

and make sure EnableExportScript is set to true in /Config/Export/Config.lua

-- Configuration

If you want to try this version with DCS, you have to change the game in :
/Config/Export/G940leds/config.lua

To choose the functions displayed by each button : /Config/Export/G940leds/[game-specific folder]/profile.lua
To tweak the colors correspondig to each status  : /Config/Export/G940leds/[game-specific folder]/colors.lua

-- Running

Launch G940leds.exe before launching the game, and that's it.

-- Forum thread

http://forum.lockon.ru/showthread.php?t=45895

-----------------------------------------------------------------------------------------------------------------------
Original Readme.txt : 
-----------------------------------------------------------------------------------------------------------------------

G940leds version 1.1

-- Disclaimer

The program is written by me, Martin Larsson (nickname morg at forums.eagle.ru and morg@borgeby.se), and i take no
responsibility for anything. Please don't redistribute it without my knowledge, simply because i don't want outdated
version roaming around. If you notify me first i can make sure you are noted when i have a new version.

The executable links with Logitechs SDK for the G940 and there are probably some copyright and legal stuff regarding to
that. The lua files for DCS are totally free i guess.


-- Overview

G940 leds is a program that listens on a UDP port for information about how to light the LEDs on a G940 throttle.

At the moment it has special functions for DCS Ka-50 to minimize conditionals in the LUA code in the game. Upon request,
it is easy to add more functions, both for DCS and other games.

udp_sender.exe is a small program that can be used to test g940leds.exe. It's just a simple console program where you can
type "a packet" and send it to G940leds.exe. Useful to test the different commands.

-- Installation

The program itself is just a executable, nothing to install, just put it where you want it. When it is started you
 might have to confirm with your firewall that you want to allow the program to use the network. 

-- DCS Ka-50 installation

Note: Don't use notepad.exe to edit .lua files. Notepad++ (freely available on the net) is a good alternative.

Here is a short guide to setting it up and there are more instructions/comments in the .lua files.

* First, take a backup of your export.lua file located in "Ka-50/config/"
* Open config.lua in the same directory and change the export enabled variable to true.
* Copy the four .lua files that comes with the program to that directory as well.
* If you haven't made any changes to your export.lua, you can rename "example_export.lua" to "export.lua" and use that.
* If you have made changes to export.lua, i assume you know how to edit it and can copy everything from addtoexport.lua
	to your export.lua file. There are some more instructions in that file.
	
* DCS will now export autopilot status(bankhold, pitchhold etc) and targeting mode (autoturn, groundmoving etc) to the
	G940 and it is a good idea to test that everything works before configuring it to show what you want it to. Just start
	G940leds.exe and fire up BlackShark. If you run into problems, first check "Ka-50/Temp/error.log" at the bottom, it
	might say something about what's wrong and then ask for help in the thread for this program at forums.eagle.ru.
	
* I use coroutines, which means that the leds will be updated onset intervals, instead of every frame. I find this
	enough for most purposes, but it might cause problems. See the last step if it bothers you.
	
* To configure it to your taste, you will have to create a coroutine (a special type of function in lua) in G940leds.lua.
	There are a few examples to get you started and at forums.eagle.ru you can find alot of threads related to lua exporting,
	there is also a thread for this program and don't be afraid to ask for help. Hopefully people can also send in their 
	own configuration so that others can be inspired.
	A tips is to start with the G940leds_example function and remove the parts you dont want.
	
* In export.lua, specify which function that should be run and at which interval. It looks like the following:
	----------------
	CoroutineIndex = CoroutineIndex + 1
	Coroutines[CoroutineIndex] = coroutine.create(g940leds_example) 
	LoCreateCoroutineActivity(CoroutineIndex, 0, 0.1) -- start directly and run every 0.1 seconds
	----------------
	You should not have more than one coroutine that deals with the G940 (it won't work) but you can ofcourse have more
	coroutines if you also export/import to other devices.
	
* If you want to use lights that blink (for example master caution light) using a coroutine that runs on set intervals
	doesn't work that great and you will have to use the functions from everyframe.lua.
	In that file you will find two functions, LuaExportStart() and LuaExportAfterNextFrame(). In export.lua you will also
	find those two functions, however they are empty except some comments. Copy the contents of those functions into the
	ones in export.lua and configure those instead of the functions in G940leds.lua. When using this approach also remember
	to comment (using "--") the lines from the previous step (coroutine.create(..) and LoCreateCoroutineActivity)


-- Feature request

Please send in feature/command request!! I want the program to be usable and as good as possible for everyone and without
knowing what others want, that's impossible. If you are specific about what you want, adding commands is simple, but of
 course I can't promise anything...


-- Release the source code?

When i feel i am finished with the program and don't want/have the time to update it regularly i will release it as as
free code.
	

-- Known issues

* Sometimes it won't work after the computer has been in suspend or hibernation. It can be fixed by simply removing
	the throttle from the joystick and put it back in again.
* The leds will look like they are when the program is shut down, which looks silly if you want to play another game later
	that doesn't update them... I hope to find a solution to this.
* It doesn't seem to work to use the recovery function in DCS. The arguments won't get updated after using it.
	If someone knows how to fix this, please contact me on mail or forums.eagle.ru.
* It would be very nice if the program can read the mode switch and show different lights depending on it and it is something
	i will work on when i have the time.


-- Commands
All the commands are documented in the command.txt file, but some general things can be said.

Commands are just ascii strings sent as an UDP packet and are in the form:
command=arguments;

I have no seperators between arguments so the most basic command can look like this:
leds=grao1230;
Which will set buttons 1 and 5 green, 2 and 6 red, etc

Even if the command doesn't take arguments it still needs the '='. Most commands can also be "chained" togheter to avoid sending alot of packets, for example:
command1=;command2=arg2;command3=arg3;

When chained, the leds will not be updated until the whole packet has been parsed, so you won't get flickering lights if sending 
many commands in the same packet. If you think the script looks too ugly with everything in one packet, use DisableAutoUpdate to
avoid flickering.

Commands are not case sensitive, but arguments are!

All the normal commands uses:
g or 1 for green
r or 2 for red
a or 3 for amber
o or 0 for off

I haven't been really consistent with command names and what arguments they need, so please read command.txt carefully.
