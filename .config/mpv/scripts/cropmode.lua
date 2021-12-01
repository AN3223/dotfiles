-- This script aids the user in creating a crop filter suitable for ffmpeg(1)
--
-- Shift+C to enter crop mode. Use the arrow keys or hjkl to alter the crop
-- size. Hold control while pressing the aforementioned keys to pan the crop
-- window around. Use a/z to increase or decrease the precision of the
-- aforementioned actions.
--
-- Once your crop looks good, Shift+C again to exit crop mode. Your crop filter
-- will be shown on screen and printed to the terminal. If mpv is not attached
-- to a terminal, you can still find the filter in the console by typing `
-- (backtick).
--
-- All keys may be rebound via the script-binding. The naming schemes go like this:
--
-- C:          cropmode
-- A/Z:        (add|sub)step
-- Arrow keys: (add|sub)[xywh]
-- HJKL:       (add|sub)[xywh]vi
--
-- For example, if you wanted to rebind C as F in input.conf:
-- 	F script-binding cropmode
--
-- If you use an hwdec, it will need to be of the copy variety, e.g.,
-- 	hwdec=auto-copy-safe
--

require 'mp.options'
local o = { step = 50 }
read_options(o)
step = o.step

local function filter() return "crop="..w..":"..h..":"..x..":"..y end
local function update() mp.commandv("vf", "add", "@crop:"..filter()) end

local function height() return mp.get_property_native("height", 2) end
local function width()  return mp.get_property_native("width", 2)  end

local function addw() iw=width();  w=w+step; if w>iw then w=iw end; update() end
local function subw()              w=w-step; if w<2 then w=2 end;   update() end
local function addh() ih=height(); h=h+step; if h>ih then h=ih end; update() end
local function subh()              h=h-step; if h<2 then h=2 end;   update() end
local function addx() iw=width();  x=x+step; if x>iw then x=iw end; update() end
local function subx()              x=x-step; if x<0 then x=0 end;   update() end
local function addy() ih=height(); y=y+step; if y>ih then y=ih end; update() end
local function suby()              y=y-step; if y<0 then y=0 end;   update() end
local function addstep() step=step+1; mp.commandv("show-text", "step: "..step) end
local function substep() step=step-1; mp.commandv("show-text", "step: "..step) end

local function cropmode()
	if not mode_on then
		mode_on = true
		mp.commandv("show-text", "Crop mode enabled")
		h = height(); w = width(); x = 0; y = 0;
		update()

		mp.add_forced_key_binding("h",      "subwvi",  subw)
		mp.add_forced_key_binding("j",      "addhvi",  addh)
		mp.add_forced_key_binding("k",      "subhvi",  subh)
		mp.add_forced_key_binding("l",      "addwvi",  addw)
		mp.add_forced_key_binding("LEFT",   "subw",    subw)
		mp.add_forced_key_binding("DOWN",   "addh",    addh)
		mp.add_forced_key_binding("UP",     "subh",    subh)
		mp.add_forced_key_binding("RIGHT",  "addw",    addw)
		mp.add_forced_key_binding("Ctrl+h", "subxvi",  subx)
		mp.add_forced_key_binding("Ctrl+j", "addyvi",  addy)
		mp.add_forced_key_binding("Ctrl+k", "subyvi",  suby)
		mp.add_forced_key_binding("Ctrl+l", "addxvi",  addx)
		mp.add_forced_key_binding("LEFT",   "subx",    subx)
		mp.add_forced_key_binding("DOWN",   "addy",    addy)
		mp.add_forced_key_binding("UP",     "suby",    suby)
		mp.add_forced_key_binding("RIGHT",  "addx",    addx)
		mp.add_forced_key_binding("a",      "addstep", addstep, { repeatable = true })
		mp.add_forced_key_binding("z",      "substep", substep, { repeatable = true })
	else
		mode_on = false
		print(filter()); mp.commandv("show-text", filter());
		mp.commandv("vf", "remove", "@crop")

		local c = { 'x', 'y', 'w', 'h' }
		for i = 1, 4 do
			mp.remove_key_binding("sub"..c[i])
			mp.remove_key_binding("sub"..c[i].."vi")
			mp.remove_key_binding("add"..c[i])
			mp.remove_key_binding("add"..c[i].."vi")
		end
		mp.remove_key_binding("addstep")
		mp.remove_key_binding("substep")
	end
end

mode_on = false
mp.add_key_binding("C", "cropmode", cropmode)

