-- Runs write-watch-later-config every minute while the file is playing,
-- and every time the file is paused.

local options = require 'mp.options'
local o = { save_interval = 60 }
options.read_options(o)

local function save()
	mp.commandv("set", "msg-level", "cplayer=warn")
	mp.command("write-watch-later-config")
	-- FIXME this overwrites msg-level=cplayer=? original value
	mp.commandv("set", "msg-level", "cplayer=status")
end

local function save_if_pause(_, pause)
	if pause then save() end
end

local function periodically_save(_, pause)
	if pause then
		timer:stop()
	end

	if not pause and not timer:is_enabled() then
		timer:resume()
	end
end

timer = mp.add_periodic_timer(o.save_interval, save)
mp.observe_property("pause", "bool", periodically_save)
mp.observe_property("pause", "bool", save_if_pause)
mp.register_event("file-loaded", save)

