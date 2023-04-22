-- This script provides a user interface for making crop filters.
--
-- Shift+C to enter/exit crop mode. Filter will be printed to console on exit.
-- 
-- Arrow keys or hjkl to alter crop size, hold Ctrl to pan instead.
--
-- c to pan to center.
--
-- a/z to double/halve precision, hold Shift to increment/decrement instead.
--
-- Ctrl+a to crop height to aspect ratio, press again to cycle, also hold Shift to reverse.
-- Ctrl+z to crop width to aspect ratio, press again to cycle, also hold Shift to reverse.
--
-- All keys may be rebound via the script-binding. The naming schemes go like this:
--
-- C:           cropmode
-- a/z          (dbl|hlf)step
-- A/Z          (add|sub)step
-- Ctrl+a/z     aspect(height|width)
-- Ctrl+A/Z     aspect(height|width)rev
-- Arrows       (add|sub)[wh]
-- Shift+Arrows (add|sub)[xy]
-- hjkl         (add|sub)[wh]vi
-- HJKL         (add|sub)[xy]vi
--
-- For example, if you wanted to rebind C as F in input.conf:
-- 	F script-binding cropmode
--
-- If you use an hwdec, it will need to be of the copy variety, e.g.,
-- 	hwdec=auto-copy-safe
--
-- The default step and aspect ratios can be changed via script-opts, see options below.
--

local options = require 'mp.options'
local o = {
	step = 64,
	ars = {
		{ 16, 9 },
		{ 9, 16 },
		{ 1,  1 },
		{ 2,  3 },
		{ 4,  3 }
	}
}
options.read_options(o)
step,ars = o.step,o.ars

-- keep x/y/w/h in the bounds of the image & initialize them if not already
local function bound()
	iw,ih = mp.get_property_native("width", 2),mp.get_property_native("height", 2)
	x=((not x or x<0) and 0 or x)
	y=((not y or y<0) and 0 or y)
	w=((not w or w>iw) and iw or w)
	h=((not h or h>ih) and ih or h)
	w=(w<2 and 2 or w)
	h=(h<2 and 2 or h)
	x=(x+w>iw and iw-w or x)
	y=(y+h>ih and ih-h or y)
end

local function filter() return "crop="..w..":"..h..":"..x..":"..y end
local function update() bound(); mp.commandv("vf", "add", "@crop:"..filter()) end

local function addw() w=w+step; update() end
local function addh() h=h+step; update() end
local function addx() x=x+step; update() end
local function addy() y=y+step; update() end
local function subw() w=w-step; update() end
local function subh() h=h-step; update() end
local function subx() x=x-step; update() end
local function suby() y=y-step; update() end
local function center() bound(); x=(iw-w)/2; y=(ih-h)/2; update() end
local function addstep() step=step+1; mp.commandv("show-text", "step: "..step) end
local function substep() step=step-1; mp.commandv("show-text", "step: "..step) end
local function dblstep() step=step*2; mp.commandv("show-text", "step: "..step) end
local function hlfstep() step=step/2; mp.commandv("show-text", "step: "..step) end
local function incrari() ari=((not ari or ari==#ars) and 1 or ari+1) end
local function decrari() ari=((not ari or ari==1) and #ars or ari-1) end
local function showaspect() mp.commandv("show-text", ars[ari][1]..":"..ars[ari][2]) end
local function aspectheight() h=w/ars[ari][1]*ars[ari][2]; showaspect(); update() end
local function aspectwidth()  w=h/ars[ari][2]*ars[ari][1]; showaspect(); update() end

local function cropmode()
	if not mode_on then
		mode_on = true
		mp.commandv("show-text", "Crop mode enabled")
		x,y,w,h = nil; update();

		mp.add_forced_key_binding("h",           "subwvi",  subw)
		mp.add_forced_key_binding("j",           "addhvi",  addh)
		mp.add_forced_key_binding("k",           "subhvi",  subh)
		mp.add_forced_key_binding("l",           "addwvi",  addw)
		mp.add_forced_key_binding("LEFT",        "subw",    subw)
		mp.add_forced_key_binding("DOWN",        "addh",    addh)
		mp.add_forced_key_binding("UP",          "subh",    subh)
		mp.add_forced_key_binding("RIGHT",       "addw",    addw)
		mp.add_forced_key_binding("Ctrl+h",      "subxvi",  subx)
		mp.add_forced_key_binding("Ctrl+j",      "addyvi",  addy)
		mp.add_forced_key_binding("Ctrl+k",      "subyvi",  suby)
		mp.add_forced_key_binding("Ctrl+l",      "addxvi",  addx)
		mp.add_forced_key_binding("Ctrl+LEFT",   "subx",    subx)
		mp.add_forced_key_binding("Ctrl+DOWN",   "addy",    addy)
		mp.add_forced_key_binding("Ctrl+UP",     "suby",    suby)
		mp.add_forced_key_binding("Ctrl+RIGHT",  "addx",    addx)
		mp.add_forced_key_binding("c",           "center",  center)
		mp.add_forced_key_binding("a",           "dblstep", dblstep)
		mp.add_forced_key_binding("z",           "hlfstep", hlfstep)
		mp.add_forced_key_binding("A",           "addstep", addstep, { repeatable = true })
		mp.add_forced_key_binding("Z",           "substep", substep, { repeatable = true })
		mp.add_forced_key_binding("Ctrl+a",      "aspectheight", function() incrari(); aspectheight() end)
		mp.add_forced_key_binding("Ctrl+z",      "aspectwidth",  function() incrari(); aspectwidth()  end)
		mp.add_forced_key_binding("Ctrl+A",      "aspectheightrev", function() decrari(); aspectheight() end)
		mp.add_forced_key_binding("Ctrl+Z",      "aspectwidthrev",  function() decrari(); aspectwidth()  end)
	else
		mode_on = false
		print(filter()); mp.commandv("show-text", filter());
		mp.commandv("vf", "remove", "@crop")

		local binds = { "aspectwidthrev", "aspectheightrev", "aspectwidth", "aspectheight", "substep", "addstep", "hlfstep", "dblstep", "center", "addx", "suby", "addy", "subx", "addxvi", "subyvi", "addyvi", "subxvi", "addw", "subh", "addh", "subw", "addwvi", "subhvi", "addhvi", "subwvi" }
		for k,v in pairs(binds) do
			mp.remove_key_binding(v)
		end
	end
end

mode_on = false
mp.add_key_binding("C", "cropmode", cropmode)

