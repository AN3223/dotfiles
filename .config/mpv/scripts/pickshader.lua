-- This script provides an easy interface for setting/appending to 
-- --glsl-shaders.
--
-- Ctrl+r is the default keybind, but if desired this can be changed in 
-- input.conf, for example:
--
-- Ctrl+t script-binding pickshader
--
-- The interface is similar to ^R from Unix shells. Once it's open, simply type 
-- a query to narrow down the results.
--
-- These keybinds can be used within the interface:
--
-- ESC or Ctrl+c will close the interface
--
-- ENTER will ADD the selected shader to --glsl-shaders
--
-- Ctrl+ENTER will SET --glsl-shaders to the selected shader
--
-- UP, DOWN, Ctrl+n, Ctrl+p will move the cursor up/down
--
-- This script assumes shaders are installed under ~~/shaders/ (~~ being the 
-- directory where mpv.conf is). If they aren't located there, either relocate 
-- them or make a symlink.

local utils = require 'mp.utils'
local options = require 'mp.options'

-- If you really don't want to use ~~/shaders for some reason this can be 
-- changed in ~~/script-opts/pickshader.conf
local o = {
	shader_dir = "~~/shaders"
}
options.read_options(o)

local function recursive_ls(dir)
	local result = {}
	local ls = utils.readdir(dir)
	for i,child in pairs(ls) do
		local info = utils.file_info(dir.."/"..child);
		if info.is_dir then
			for _,grandchild in pairs(recursive_ls(dir.."/"..child)) do
				result[#result + 1] = grandchild
			end
		elseif string.match(child, "%.glsl$") or string.match(child, "%.hook$") then
			result[#result + 1] = dir.."/"..child
		end
	end
	return result
end

shaders = nil
local function init_shaders()
	if shaders ~= nil then
		return
	end
	local shader_dir = mp.command_native({"expand-path", o.shader_dir})
	shaders = recursive_ls(shader_dir)
	for i,shader in pairs(shaders) do -- basename
		shaders[i] = shaders[i]:sub(shader_dir:len() + 2)
	end
	table.sort(shaders)
end

grepped_arr = {}
grepped_pattern = ""
cursor = 1
local function draw()
	if current_pattern == "" then
		grepped_arr = shaders
		grepped_pattern = current_pattern
	elseif grepped_pattern ~= current_pattern then
		grepped_arr = {}
		grepped_pattern = current_pattern
		cursor = 1
		for i,shader in pairs(shaders) do
			-- XXX maybe split by space and interpret each part as a separate pattern
			local e, match = pcall(string.match, shader:lower(), current_pattern:lower())
			if match and e then
				grepped_arr[#grepped_arr + 1] = shader
			elseif not e then
				break
			end
		end
	end

	local results_str = ""
	for i,shader in pairs(grepped_arr) do
		if i == cursor then
			results_str = results_str .. "\n> " .. shader
		elseif math.abs(i - cursor) < 3 then
			results_str = results_str .. "\n" .. shader
		end
	end
	results_str = results_str:sub(2) -- trim leading newline

	-- lazy underlining, lua doesn't support case insensitive matching
	if current_pattern ~= "" then
		local e, underlined = pcall(string.gsub, results_str, current_pattern, "{\\u1}%0{\\u0}")
		if e then results_str = underlined end
		local e, underlined = pcall(string.gsub, results_str, current_pattern:upper(), "{\\u1}%0{\\u0}")
		if e then results_str = underlined end
	end

	if results_str == "" then
		results_str = "> " .. current_pattern
	end

	overlay.data = results_str
	overlay:update()
end

local function incr_cursor()
	cursor = math.min(cursor + 1, #grepped_arr)
	draw()
end

local function decr_cursor()
	cursor = math.max(cursor - 1, 1)
	draw()
end

local function mode_off()
	mode_on = false
	grepped_arr = {}
	cursor = 1
	grepped_pattern = ""
	current_pattern = ""
	overlay.data = ""
	overlay:remove()
	overlay:update()
	local binds = { "mode_off1", "mode_off2", "mode_off3", "incr1", "decr1", "incr2", "decr2", "backspace", "clear", "pick_add", "pick_set", "handle_input" }
	for k,v in pairs(binds) do
		mp.remove_key_binding(v)
	end
end

local function backspace()
	current_pattern = current_pattern:sub(1, -2)
	draw()
end

local function clear()
	current_pattern = ""
	draw()
end

local function pick(op)
	local shader = grepped_arr[cursor]
	if op == nil then op = "add" end

	mp.commandv("change-list", "glsl-shaders", op, o.shader_dir.."/"..shader)
	mode_off()
	mp.commandv("show-text", op.." "..shader)
end

current_pattern = ""
local function handle_input(input)
	if input.event == "press"
	or input.event == "down"
	or input.event == "repeat" then
		current_pattern = current_pattern .. input.key_text
		draw()
	end
end

mode_on = false
local function pickshader()
	if not mode_on then
		mode_on = true
		overlay = mp.create_osd_overlay("ass-events")
		init_shaders()

		mp.add_forced_key_binding("ESC", "mode_off1", mode_off)
		mp.add_forced_key_binding("Ctrl+[", "mode_off2", mode_off)
		mp.add_forced_key_binding("Ctrl+c", "mode_off3", mode_off)
		mp.add_forced_key_binding("Ctrl+n", "incr1", incr_cursor,
		                          { repeatable = true })
		mp.add_forced_key_binding("Ctrl+p", "decr1", decr_cursor,
		                          { repeatable = true })
		mp.add_forced_key_binding("DOWN", "incr2", incr_cursor,
		                          { repeatable = true })
		mp.add_forced_key_binding("UP", "decr2", decr_cursor,
		                          { repeatable = true })
		mp.add_forced_key_binding("BS", "backspace", backspace,
		                          { repeatable = true })
		mp.add_forced_key_binding("Ctrl+u", "clear", clear)
		mp.add_forced_key_binding("ENTER", "pick_add", pick)
		mp.add_forced_key_binding("Ctrl+ENTER", "pick_set", function() pick("set") end)
		mp.add_forced_key_binding("any_unicode", "handle_input", handle_input,
		                          { repeatable = true, complex = true })
		draw()
	else
		incr_cursor()
	end
end

mp.add_key_binding("Ctrl+r", "pickshader", pickshader,
                   { repeatable = true })

