-- pseudo-gui (which sets force-window) is used by the default .desktop
-- file. That's fine, but I think mpv should behave different when
-- force-window is set.

-- 1. Fullscreen doesn't make much sense when the window is going to
-- be entirely black or a still image.

-- 2. If you're going to have a window you might as well put some kind
-- of graphic in it when possible, so audio-display should be yes.

-- There may be more options that don't make sense during --force-window
-- which haven't occurred to me, so I've implemented this as a profile so
-- it may be extended in the users config file.

if mp.get_property("force-window") == "yes" then
	mp.command("apply-profile force-window")
end

