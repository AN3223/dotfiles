-- This script uses a profile to change mpv's behavior when force-window is set
-- (i.e. by pseudo-gui in the .desktop file). This exists because:
--
-- 1. Fullscreen doesn't make much sense when the window is going to
-- be entirely black or a still image (fullscreen=no)
--
-- 2. If you're going to have a window you might as well put some kind
-- of graphic in it when possible (audio-display=attachment)
--
-- There may be more options that don't make sense during --force-window
-- which haven't occurred to me, so I've implemented this as a profile so
-- it may be extended in the users config file.
--
-- Example usage of this script in mpv.conf:
-- [force-window]
-- fullscreen=no
-- audio-display=attachment

if mp.get_property("force-window") ~= "no" then
	mp.command("apply-profile force-window")
end

