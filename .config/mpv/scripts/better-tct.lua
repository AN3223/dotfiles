-- This script makes tct slightly more bearable.
--

-- hack to clear the screen
function reset()
	mp.command("cycle video up ; cycle video down")
end

function main()
	if mp.get_property("current-vo") == "tct" then
		mp.set_property("really-quiet", "yes")
		-- even with this hack, zooming/panning is still bunk
		mp.observe_property("video-zoom", number, reset)
		mp.observe_property("video-pan-x", number, reset)
		mp.observe_property("video-pan-y", number, reset)
	end
end

mp.register_event("file-loaded", main)

