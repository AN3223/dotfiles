-- Creates a socket for every mpv instance. The sockets are named "mpvctl"
-- followed by a number, i.e. mpvctl5. The highest number is the most recent
-- instance, the lowest is the oldest.

local i = 0
while true do
	local filename = "/tmp/mpvctl" .. i
	local file, _, err = io.open(filename)
	if file == nil and err ~= 6 then -- 6 = socket (maybe not portable?)
		break
	else
		local i = i + 1
	end
end

mp.set_property("input-ipc-server", filename)
mp.register_event("shutdown", function() os.remove(filename) end)

