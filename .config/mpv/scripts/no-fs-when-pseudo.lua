-- pseudo-gui is used by the default .desktop file, pseudo-gui sets
-- force-window, I set fullscreen=yes, I get fullscreen for every file opened
-- via the .desktop file, I write this plugin.

if mp.get_property("force-window") == "yes" then
	mp.set_property("fullscreen", "no")
end

