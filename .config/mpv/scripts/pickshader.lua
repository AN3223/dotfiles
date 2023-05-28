-- XXX summarize & document keybinds & stuff

local utils = require 'mp.utils'
local options = require 'mp.options'

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
shader_dir = mp.command_native({"expand-path", o.shader_dir})
shaders = recursive_ls(shader_dir)
for i,shader in pairs(shaders) do -- basename
	shaders[i] = shaders[i]:sub(shader_dir:len() + 2)
end
table.sort(shaders)

grepped_arr = {}
grepped_pattern = ""
cursor = 1
local function draw()
	if current_pattern == "" then
		grepped_arr = shaders
	elseif grepped_pattern ~= current_pattern then
		grepped_arr = {}
		grepped_pattern = current_pattern
		cursor = 1
		for i,shader in pairs(shaders) do
			-- XXX maybe split by space and interpret each part as a separate pattern
			if string.match(shader:lower(), current_pattern:lower()) then
				grepped_arr[#grepped_arr + 1] = shader
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

	if results_str == "" then
		results_str = "> " .. current_pattern
	end

	-- XXX highlight the "current_pattern" part
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
	if op == nil then op = "add" end
	mp.commandv("no-osd", "change-list", "glsl-shaders",
	            op, o.shader_dir.."/"..grepped_arr[cursor])
	mode_off()
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

