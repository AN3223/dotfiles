-- lats, the Low ATtention Span mpv script
--
-- This script will tell mpv to skip to the next playlist entry after a
-- fixed time (default: 10 seconds). LATS also enables shuffling and
-- looping by default.
--
-- This allows for a viewing experience similar to flipping through a
-- bunch of channels or tuning into different radio stations. The original
-- purpose for this was to have a fun way to re-watch a long series, quickly
-- reliving many moments, but this may also be useful for trying to locate a
-- scene/moment in one or more files.
--
-- You almost certainly don't want this behavior all of the time, so you almost
-- certainly should not install this script into your ~~/scripts/ directory.
-- Instead, place it into mpv's configuration directory (e.g., ~/.config/mpv)
-- and when you want to enable it, pass the option --script='~~/lats.lua' to
-- mpv.
--
-- Options recognized by this script:
--
-- duration: seconds until skip (default 10)
-- shuffle:  sets --shuffle (default true)
-- loop:     sets --loop-playlist=inf (default true)
--

require "mp.options"

o = { duration = 10, shuffle = true, loop = true }
read_options(o, "lats")

mp.set_property("resume-playback", "no")
if o.shuffle then mp.set_property("shuffle", "yes")       end
if o.loop    then mp.set_property("loop-playlist", "inf") end

timer = mp.add_periodic_timer(o.duration, function()
	mp.commandv("playlist-next", "force")
end)
timer:kill()

-- when file loads, seek to random position and start timer
mp.register_event("file-loaded", function()
	timer:kill()

	dur = mp.get_property_number("duration")
	if dur == nil then
		return
	end

	upper = dur - o.duration
	if upper >= 1 then
		internal_seek = 1
		mp.commandv("seek", math.random(upper), "absolute+keyframes")
		timer:resume()
	else
		internal_seek = -1
	end
end)

-- don't skip around while player is paused
mp.observe_property("pause", "bool", function(_, pause)
	if internal_seek == -1 then
		return
	end

	if pause then timer:stop() else timer:resume() end
end)

-- stop skipping around if the user seeks
mp.register_event("seek", function()
	if internal_seek == 1 then
		internal_seek = 0
	else
		internal_seek = -1
		timer:stop()
	end
end)

