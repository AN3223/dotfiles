/*
This plugin will set mpv's "quiet" option when stdout/stderr is NOT
pointing to a terminal.

gcc -o shutup.so shutup.c `pkg-config --cflags mpv` -shared -fPIC
*/

#include <stdio.h>
#include <unistd.h>

#include <mpv/client.h>

int
mpv_open_cplugin(mpv_handle *handle)
{
	if (!isatty(STDOUT_FILENO) || !isatty(STDERR_FILENO)) {
		printf("shutup: setting --quiet\n");
		mpv_set_property_string(handle, "quiet", "yes");
	}
	return 0;
}

