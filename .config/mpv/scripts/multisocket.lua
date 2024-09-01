-- Creates a socket for every mpv instance. The sockets are named "mpvctl"
-- followed by a number, i.e. mpvctl5.

filename = ''

function remove_socket()
	print("Socket " .. filename .. " removed")
	mp.set_property("input-ipc-server", "")
	os.remove(filename)
end

function add_socket()
	if mp.get_property("input-ipc-server") == "" then
		i = 0
		while true do
			filename = "/tmp/mpvctl" .. i
			local file, msg, err = io.open(filename)
			if file == nil and err ~= 6 then -- 6 = socket (maybe not portable?)
				break
			else
				i = i + 1
			end
		end

		mp.set_property("input-ipc-server", filename)
		mp.register_event("shutdown", remove_socket)
	end
end

add_socket()
mp.register_script_message("add-socket", add_socket)
mp.register_script_message("remove-socket", remove_socket)

