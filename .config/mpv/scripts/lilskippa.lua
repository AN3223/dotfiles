-- This script defines the following keybinds:
--
-- % skip2scene
-- ^ skip2black
-- & skip2silence
--
-- skip2scene fast forwards to the next scene change
-- skip2black fast forwards to the next black video segment
-- skip2silence fast forwards to the next silent audio segment
--
-- skip2scene is useful but not always reliable. It won't budge on high-motion 
-- scenes and, although the default threshold is low, it might still miss some 
-- cuts.
--
-- skip2silence doesn't appear to work with hwdec.
--
-- Any of these skips can be reverted with revert-seek (bound to Shift+BS by 
-- default), useful for when it hurtles past the desired point.
--
-- This script will apply a "fastforward" profile while fast forwarding and 
-- restore it after the fast forward completes. This way the user can define a 
-- fastforward profile in their mpv.conf where they can, for example, tweak 
-- mpv's options for performance. An example:
--
-- [fastforward]
-- profile-restore=copy-equal
-- scale=bilinear
-- dscale=bilinear
-- cscale=bilinear
-- vd-lavc-skiploopfilter=all
-- vd-lavc-skipframe=all
--
-- This script accepts the following options:
--
-- scdet_args: arguments for the scdet filter, defaults to "6.0"
-- blackdetect_args: arguments for the blackdetect filter, defaults to "0.1"
-- silencedetect_args: arguments for the silencedetect filter, defaults to "d=0.5"
--
-- This script reimplements some of the functionality of the two scripts below. 
-- Thank you to their authors for creating them and making them open source:
--
-- https://gist.github.com/bossen/3cfe86a6cdd61452dbb96865128fb327
-- https://github.com/detuur/mpv-scripts/blob/master/skiptosilence.lua
--

local options = require 'mp.options'
local o = {
	scdet_args = "6.0",
	blackdetect_args = "0.1",
	silencedetect_args = "d=0.5"
}
options.read_options(o)

function restore(f, label)
	mp.set_property("speed", restore_speed)
	mp.set_property("video-sync", restore_sync)
	mp.set_property("pause", restore_paused)
	mp.commandv("seek", mp.get_property("time-pos"), "absolute+exact")
	mp.commandv("change-list", f, "remove", label)
	mp.commandv("apply-profile", "fastforward", "restore")
end

function fastforward()
	restore_paused = mp.get_property("pause")
	restore_speed = mp.get_property("speed")
	restore_sync = mp.get_property("video-sync")

	mp.commandv("apply-profile", "fastforward")

	mp.commandv("revert-seek", "mark")
	mp.set_property_bool("pause", false)
	mp.set_property("video-sync", "desync")
	mp.set_property("speed", "100")
end

function skip2black()
	if not skipping2black then
		mp.commandv("show-text", "Skipping to black...")
		skipping2black = true
		fastforward()
		mp.command("no-osd change-list vf add @skip2black:blackdetect=" .. o.blackdetect_args)
	else
		mp.commandv("show-text", "Cancelled skip to black")
		skipping2black = false
		restore("vf", "@skip2black")
	end
end

mp.observe_property("vf-metadata/skip2black", "native", function(_, metadata)
	if skipping2black and metadata and metadata["lavfi.black_end"] then
		mp.commandv("show-text", "Skip to black complete")
		skipping2black = false
		restore("vf", "@skip2black")
	end
end)

function skip2silence()
	if not skipping2silence then
		mp.commandv("show-text", "Skipping to silence...")
		fastforward()
		skipping2silence = true
		mp.command("no-osd change-list af add @skip2silence:silencedetect=" .. o.silencedetect_args)
	else
		mp.commandv("show-text", "Cancelled skip to silence")
		skipping2silence = false
		restore("af", "@skip2silence")
	end
end

mp.observe_property("af-metadata/skip2silence", "native", function(_, metadata)
	if skipping2silence and metadata and metadata["lavfi.silence_end"] then
		mp.commandv("show-text", "Skip to silence complete")
		skipping2silence = false
		mp.commandv("seek", metadata["lavfi.silence_end"], "absolute+exact")
		restore("af", "@skip2silence")
	end
end)

function skip2scene()
	if not skipping2scene then
		mp.commandv("show-text", "Skipping to scene...")
		fastforward()
		skipping2scene = true
		mp.command("no-osd change-list vf add @skip2scene:scdet=" .. o.scdet_args)
	else
		mp.commandv("show-text", "Cancelled skip to scene")
		skipping2scene = false; scd_time = nil;
		restore("vf", "@skip2scene")
	end
end

mp.observe_property("vf-metadata/skip2scene", "native", function(_, metadata)
	if skipping2scene and metadata then
		if not scd_time then
			scd_time = metadata["lavfi.scd.time"]
		elseif metadata["lavfi.scd.time"] > scd_time then
			mp.commandv("show-text", "Skip to scene complete")
			skipping2scene = false; scd_time = nil;
			restore("vf", "@skip2scene")
		end
	end
end)

mp.add_key_binding("%", "skip2scene", skip2scene)
mp.add_key_binding("^", "skip2black", skip2black)
mp.add_key_binding("&", "skip2silence", skip2silence)

