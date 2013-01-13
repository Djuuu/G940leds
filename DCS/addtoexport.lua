-- Add the following to your export.lua file, something that looks very similar
-- is probably already there but commented. So search for that and you will place
-- this at the correct place.
-- Also make sure to remove the comment before the following two lines in export.lua:
-- 		Coroutines = {}	-- global coroutines table
--		CoroutineIndex = 0	-- global last created coroutine index
-- They are located before the example coroutine in the original export.lua

dofile("./Config/Export/G940leds.lua")

CoroutineIndex = CoroutineIndex + 1
Coroutines[CoroutineIndex] = coroutine.create(g940leds_example)
LoCreateCoroutineActivity(CoroutineIndex, 0, 0.1) -- start directly and run every 0.1 seconds