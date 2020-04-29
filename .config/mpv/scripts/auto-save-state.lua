-- Runs write-watch-later-config periodically

local utils = require 'mp.utils'
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

local function pause_timer_while_paused(_, pause)
	if pause then
		timer:stop()
	end

	if not pause and not timer:is_enabled() then
		timer:resume()
	end
end

-- This function:
-- 1. Locates the watch_later entry for the current file
-- 2. Registers a callback function for the end-file event
-- And then the callback function:
-- 1. Unregisters itself, so it doesn't run again
-- 2. Deletes the current watch_later entry IF mpv exited as a
--    result of EOF or "stop" (stop is not the same as a normal "quit")
--
-- This function is called on file-loaded instead of end-file because
-- the next file in the playlist would likely be loaded by the time the
-- end-file event runs.
local function clean_watch_later(event)
	-- The hashing used to generate the watch_later entries needs
	-- to be replicated here since mpv doesn't provide an API for this. This
	-- should work with GNU coreutils and busybox, I haven't tested with
	-- anything else.
	local path = mp.get_property("path")
	local cwd = utils.getcwd()
	if path == nil or cwd == nil then
		do return end
	end

	local abs_path = utils.join_path(cwd, path)
	local tmpname = os.tmpname()
	local tmp = io.open(tmpname, "w")
	tmp:write(abs_path)
	tmp:flush()
	local hash = io.popen("md5sum "..tmpname):read():match("^%w+"):upper()
	os.remove(tmpname)

	local watch_later = mp.find_config_file("watch_later")
	if hash == nil or watch_later == nil then
		do return end
	end

	-- Here we finally get the path to the watch_later entry
	local hashfile = utils.join_path(watch_later, hash)

	-- We use currying to pass the watch_later entry to the callback
	function rm_hashfile(hashfile)
		return function(event)
			mp.unregister_event(rm_hashfile(hashfile))
			if event["reason"] == "eof" or event["reason"] == "stop" then
				os.remove(hashfile)
			end
		end
	end
	mp.register_event("end-file", rm_hashfile(hashfile))
end

timer = mp.add_periodic_timer(o.save_interval, save)
mp.observe_property("pause", "bool", pause_timer_while_paused)
mp.observe_property("pause", "bool", save_if_pause)

-- save is called prior to clean_watch_later to ensure the watch_later
-- directory is created first, otherwise clean_watch_later would fail
mp.register_event("file-loaded", function() save(); clean_watch_later() end)

