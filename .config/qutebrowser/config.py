# pylint: skip-file

# Source autoconfig.yml
config.load_autoconfig()

#
# Theme
#
c.fonts.monospace = '"Fira Mono", Monospace'
bg = "#31363b"
c.colors.statusbar.normal.bg =\
    c.colors.statusbar.command.bg =\
    c.colors.tabs.selected.odd.bg =\
    c.colors.tabs.selected.even.bg =\
    c.colors.tabs.pinned.selected.odd.bg =\
    c.colors.tabs.pinned.selected.even.bg =\
    bg

c.scrolling.smooth = True
c.new_instance_open_target = 'window'
c.session.lazy_restore = True
c.content.autoplay = False
c.content.host_blocking.enabled = False

# Dark theme toggle
stylesheets = [
    '~/.config/qutebrowser/solarized-dark-all-sites.css',
    "''"
]
config.bind('tt', f"config-cycle content.user_stylesheets {' '.join(stylesheets)}")

# Think "m for media"
config.unbind('m')
config.unbind('M')
config.bind('mm', 'hint links spawn mpv {hint-url}')
config.bind('mf', 'hint links spawn mpv --fs {hint-url}')
config.bind('mc', 'spawn mpv {url}')
config.bind('md', 'hint -r links spawn youtube-dl {hint-url} -o ~/Downloads/%(title)s')

config.bind('ab', 'bookmark-add')
config.bind('aB', 'bookmark-del')

# Bash-like ^u
config.bind('<Ctrl-u>', 'fake-key <Shift-Home><Backspace>', 'insert')

