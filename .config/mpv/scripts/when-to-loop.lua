-- Sets loop-playlist=inf when a condition is true, conditions are kept in
-- $MPV_HOME/script-opts/when-to-loop.conf and the defaults go as follows:
--
-- shuffle=no    # (loop if shuffled)
-- duration_lt=0 # (loop if the file is longer than 0 seconds)
-- playlist_gt=0 # (loop if the playlist contains more than 0 files)
--
-- duration_lt and playlist_gt are checked every file-loaded event and shuffle
-- is only checked on launch.
--
-- A value of 0 for duration_lt or playlist_gt means they won't be used to
-- determine when to loop
--
-- duration_lt is ignored if the playlist contains more than 1 entry
--

require "mp.options"

o = {
	shuffle = false,
	duration_lt = 0,
	playlist_gt = 0
}
read_options(o, "when-to-loop")

if o.shuffle and mp.get_property("shuffle") == "yes" then
	mp.msg.info("shuffle=yes so loop-playlist=inf")
	mp.set_property("loop-playlist", "inf")
end

local function loop()
	-- use loop-file instead of loop-playlist if the playlist only contains 1
	-- file. should be practically equivalent to loop-playlist, but the cache
	-- won't be disposed of when the file ends, so this should prevent a delay
	-- when looping a video over a network
	if mp.get_property_number("playlist-count") == 1 then
		mp.set_property("loop-file", "inf")
	else
		mp.set_property("loop-playlist", "inf")
	end
end

local function file_loaded()
	local duration = mp.get_property_number("duration")
	local playlist_count = mp.get_property_number("playlist-count")
	if o.duration_lt > 0 and playlist_count == 1 and duration < o.duration_lt then
		mp.msg.info("duration of", duration, "less than",
			 o.duration_lt, "so we're going to loop")
		loop()
	end

	if o.playlist_gt > 0 and playlist_count > o.playlist_gt then
		mp.msg.info("playlist-count of", playlist_count, "greater than",
			 o.playlist_gt, "so we're going to loop")
		loop()
	end
end

mp.register_event("file-loaded", file_loaded)
