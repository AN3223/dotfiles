-- Runs write-watch-later-config periodically

local utils = require 'mp.utils'
local options = require 'mp.options'
local msg = require 'mp.msg'
local o = { save_interval = 60 }
options.read_options(o)

local function save()
	mp.command("write-watch-later-config")
end

local function save_if_pause(_, pause)
	if pause then save() end
end

local function pause_timer_while_paused(_, pause)
	if pause then
		timer:stop()
	else
		timer:resume()
	end
end

-- This function is called on file-loaded instead of end-file because
-- the next file in the playlist would likely be loaded by the time the
-- end-file event runs.
local function delete_watch_later(event)
	function end_file(path)
		return function(event)
			mp.unregister_event(end_file(path))
			if event["reason"] == "eof" or event["reason"] == "stop" then
				mp.commandv("delete-watch-later-config", path)
			end
		end
	end

	mp.register_event("end-file", end_file(mp.get_property("path")))
end

timer = mp.add_periodic_timer(o.save_interval, save)
mp.observe_property("pause", "bool", pause_timer_while_paused)
mp.observe_property("pause", "bool", save_if_pause)
mp.register_event("file-loaded", delete_watch_later)
