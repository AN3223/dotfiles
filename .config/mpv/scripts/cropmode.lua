-- This script provides a user interface for making crop filters.
--
-- Shift+C to enter/exit crop mode. Filter will be printed to console on exit.
-- 
-- Arrow keys, numpad, or hjklyubn to crop. Hold Ctrl to pan instead.
--
-- c to pan to center.
--
-- a/z to double/halve precision, hold Shift to increment/decrement instead.
--
-- Ctrl+a/Ctrl+z to cycle through aspect ratios, Ctrl+s to apply
--
-- All keys may be rebound via script-binding, the names of the keybinds can be 
-- found near the bottom of this script. For example, if you wanted to rebind C 
-- as F in input.conf:
--
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
		{ 1,  1 },
		{ 16, 9 },
		{ 9, 16 },
		{ 4,  3 },
		{ 2,  3 }
	}
}
options.read_options(o)
step,ars = o.step,o.ars
ari = 1

-- keep x/y/w/h in the bounds of the image & initialize them if not already
local function bound()
	iw,ih = mp.get_property_native("width", 2),mp.get_property_native("height", 2)
	x=math.floor(((not x or x<0) and 0 or x))
	y=math.floor(((not y or y<0) and 0 or y))
	w=math.floor(((not w or w>iw) and iw or w))
	h=math.floor(((not h or h>ih) and ih or h))
	w=(w<2 and 2 or w)
	h=(h<2 and 2 or h)
	x=(x+w>iw and iw-w or x)
	y=(y+h>ih and ih-h or y)
end

local function filter() return "crop="..w..":"..h..":"..x..":"..y end
local function update() bound(); mp.commandv("vf", "add", "@crop:"..filter()) end

local function addw() w=w+step; x=x-step/2; update() end
local function addh() h=h+step; y=y-step/2; update() end
local function addx() x=x+step; update() end
local function addy() y=y+step; update() end
local function subw() w=w-step; x=x+step/2; update() end
local function subh() h=h-step; y=y+step/2; update() end
local function subx() x=x-step; update() end
local function suby() y=y-step; update() end
local function center() bound(); x=(iw-w)/2; y=(ih-h)/2; update() end
local function addstep() step=step+1; mp.commandv("show-text", "step: "..step) end
local function substep() step=step-1; mp.commandv("show-text", "step: "..step) end
local function dblstep() step=step*2; mp.commandv("show-text", "step: "..step) end
local function hlfstep() step=step/2; mp.commandv("show-text", "step: "..step) end
local function showaspect() mp.commandv("show-text", ars[ari][1]..":"..ars[ari][2]) end
local function incrari() ari=(ari==#ars and 1 or ari+1); showaspect() end
local function decrari() ari=(ari==1 and #ars or ari-1); showaspect() end
local function applyaspect()
	local w_ = h/ars[ari][2]*ars[ari][1]
	local h_ = w/ars[ari][1]*ars[ari][2]
	if w_ <= w then
		x = x + (w - w_)/2
		w = w_
	else
		y = y + (h - h_)/2
		h = h_
	end
	showaspect()
	update()
end

local function cropmode()
	if not mode_on then
		mode_on = true
		mp.commandv("show-text", "Crop mode enabled")
		x,y,w,h = nil; update();

		mp.add_forced_key_binding("c",           "center",  center)
		mp.add_forced_key_binding("a",           "dblstep", dblstep)
		mp.add_forced_key_binding("z",           "hlfstep", hlfstep)
		mp.add_forced_key_binding("A",           "addstep", addstep, { repeatable = true })
		mp.add_forced_key_binding("Z",           "substep", substep, { repeatable = true })
		mp.add_forced_key_binding("Ctrl+a",      "incrari", incrari)
		mp.add_forced_key_binding("Ctrl+z",      "decrari", decrari)
		mp.add_forced_key_binding("Ctrl+s",      "applyaspect", function() applyaspect() end)
		mp.add_forced_key_binding("h",           "subwvi",  subw)
		mp.add_forced_key_binding("j",           "addhvi",  addh)
		mp.add_forced_key_binding("k",           "subhvi",  subh)
		mp.add_forced_key_binding("l",           "addwvi",  addw)
		mp.add_forced_key_binding("y",           "subwsubhvi",  function() subw(); subh(); end)
		mp.add_forced_key_binding("u",           "addwsubhvi",  function() addw(); subh(); end)
		mp.add_forced_key_binding("b",           "subwaddhvi",  function() subw(); addh(); end)
		mp.add_forced_key_binding("n",           "addwaddhvi",  function() addw(); addh(); end)
		mp.add_forced_key_binding("1",           "subwaddhnp", function() subw(); addh(); end)
		mp.add_forced_key_binding("2",           "addhnp",  addh)
		mp.add_forced_key_binding("3",           "addwaddhnp", function() addw(); addh(); end)
		mp.add_forced_key_binding("4",           "subwnp",  subw)
		mp.add_forced_key_binding("5",           "applyaspectnp", applyaspect)
		mp.add_forced_key_binding("6",           "addwnp",  addw)
		mp.add_forced_key_binding("7",           "subwsubhnp", function() subw(); subh(); end)
		mp.add_forced_key_binding("8",           "subhnp",  subh)
		mp.add_forced_key_binding("9",           "addwsubhnp", function() addw(); subh(); end)
		mp.add_forced_key_binding("LEFT",        "subw",    subw)
		mp.add_forced_key_binding("DOWN",        "addh",    addh)
		mp.add_forced_key_binding("UP",          "subh",    subh)
		mp.add_forced_key_binding("RIGHT",       "addw",    addw)
		mp.add_forced_key_binding("Ctrl+h",      "subxvi",  subx)
		mp.add_forced_key_binding("Ctrl+j",      "addyvi",  addy)
		mp.add_forced_key_binding("Ctrl+k",      "subyvi",  suby)
		mp.add_forced_key_binding("Ctrl+l",      "addxvi",  addx)
		mp.add_forced_key_binding("Ctrl+y",      "subxsubyvi", function() subx(); suby(); end)
		mp.add_forced_key_binding("Ctrl+u",      "addxsubyvi", function() addx(); suby(); end)
		mp.add_forced_key_binding("Ctrl+b",      "subxaddyvi", function() subx(); addy(); end)
		mp.add_forced_key_binding("Ctrl+n",      "addxaddyvi", function() addx(); addy(); end)
		mp.add_forced_key_binding("Ctrl+1",      "subxaddynp", function() subx(); addy(); end)
		mp.add_forced_key_binding("Ctrl+2",      "addynp",  addy)
		mp.add_forced_key_binding("Ctrl+3",      "addxaddynp", function() addx(); addy(); end)
		mp.add_forced_key_binding("Ctrl+4",      "subxnp",  subx)
		mp.add_forced_key_binding("Ctrl+5",      "centernp",  center)
		mp.add_forced_key_binding("Ctrl+6",      "addxnp",  addx)
		mp.add_forced_key_binding("Ctrl+7",      "subxsubynp", function() subx(); suby(); end)
		mp.add_forced_key_binding("Ctrl+8",      "subynp",  suby)
		mp.add_forced_key_binding("Ctrl+9",      "addxsubynp", function() addx(); suby(); end)
		mp.add_forced_key_binding("Ctrl+LEFT",   "subx",    subx)
		mp.add_forced_key_binding("Ctrl+DOWN",   "addy",    addy)
		mp.add_forced_key_binding("Ctrl+UP",     "suby",    suby)
		mp.add_forced_key_binding("Ctrl+RIGHT",  "addx",    addx)
	else
		mode_on = false
		print(filter()); mp.commandv("show-text", filter());
		mp.commandv("vf", "remove", "@crop")

		local binds = { "center", "dblstep", "hlfstep", "addstep", "substep", "incrari", "decrari", "applyaspect", "subwvi", "addhvi", "subhvi", "addwvi", "subwsubhvi", "addwsubhvi", "subwaddhvi", "addwaddhvi", "subwaddhnp", "addhnp", "addwaddhnp", "subwnp", "applyaspectnp", "addwnp", "subwsubhnp", "subhnp", "addwsubhnp", "subw", "addh", "subh", "addw", "subxvi", "addyvi", "subyvi", "addxvi", "subxsubyvi", "addxsubyvi", "subxaddyvi", "addxaddyvi", "subxaddynp", "addynp", "addxaddynp", "subxnp", "centernp", "addxnp", "subxsubynp", "subynp", "addxsubynp", "subx", "addy", "suby", "addx" }
		for k,v in pairs(binds) do
			mp.remove_key_binding(v)
		end
	end
end

mode_on = false
mp.add_key_binding("C", "cropmode", cropmode)

