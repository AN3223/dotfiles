-- Runs write-watch-later-config every minute while the file is playing,
-- and every time the file is paused.

function write_watch_later()
	mp.command("write-watch-later-config")
end

function save_if_pause(_, pause)
	if pause then
		write_watch_later()
	end
end

function periodically_save(_, pause)
	if pause then
		timer:stop()
	end

	if not pause and not timer:is_enabled() then
		timer:resume()
	end
end

mp.observe_property("pause", "bool", save_if_pause)

timer = mp.add_periodic_timer(60, write_watch_later)
mp.observe_property("pause", "bool", periodically_save)

