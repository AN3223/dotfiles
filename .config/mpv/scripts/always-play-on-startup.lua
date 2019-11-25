-- Why? --pause=no seems to work just fine from the CLI but not from mpv.conf
mp.register_event(
    "file-loaded", function() mp.set_property_bool("pause", false) end
)

