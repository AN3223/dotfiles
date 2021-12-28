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

function A()
	user_seek = false
	timer:kill()
	if mp.get_property_number("duration") ~= nil then
		upper = mp.get_property_number("duration") - o.duration - 1
	else
		upper = 0
	end
	if upper > 1 then
		pos = math.random(upper)
	else
		pos = 0
	end

	internal_seek = true
	mp.commandv("seek", pos, "absolute")

	timer:resume()
end

function B(_, pause)
	if user_seek then
		return
	end

	if pause then timer:stop() else timer:resume() end
end

function C()
	if internal_seek then
		internal_seek = false
	else
		user_seek = true
		timer:stop()
	end
end


function latson()
	mp.set_property("resume-playback", "no")
	if o.shuffle then
		mp.command("playlist-shuffle")
		mp.set_property("shuffle", "yes")
	end
	if o.loop    then mp.set_property("loop-playlist", "inf") end
	mp.add_key_binding("f5", "latsoff", latsoff)
	mp.osd_message("Lats On")

	timer = mp.add_periodic_timer(o.duration,
		function() mp.command("playlist-next force")
	end)
	-- timer:kill()

-- -- when file loads, seek to random position and start timer
	mp.register_event("file-loaded", A)

-- -- don't skip around while player is paused
	mp.observe_property("pause", "bool", B)

-- -- stop skipping around if the user seeks
	mp.register_event("seek", C)

end

function latsoff()
	mp.set_property("resume-playback", "yes")
	if o.shuffle then
		mp.command("playlist-unshuffle")
		mp.set_property("shuffle", "no")
	end
	if o.loop    then mp.set_property("loop-playlist", "no") end
	timer:kill()
	mp.unregister_event(A)
	mp.unobserve_property(B)
	mp.unregister_event(C)
	mp.remove_key_binding("latsoff")
	mp.osd_message("Lats Off")
end

mp.add_key_binding("f4", "latson", latson)
