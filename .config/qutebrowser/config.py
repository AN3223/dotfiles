# pylint: skip-file

# Source autoconfig.yml
config.load_autoconfig()

c.scrolling.smooth = True
c.new_instance_open_target = 'window'
c.session.lazy_restore = False
c.auto_save.session = True
c.content.autoplay = False
#c.content.blocking.enabled = False
c.content.host_blocking.enabled = False
c.qt.force_software_rendering = "qt-quick"
c.downloads.remove_finished = 0
#c.content.notifications.enabled = False
c.content.notifications = False

c.url.start_pages = "about:blank"
c.url.default_page = "about:blank"

# Think "m for media"
config.unbind('m')
config.unbind('M')
config.bind('mm', 'hint links spawn mpv --force-window=immediate {hint-url}')
config.bind('mcm', 'spawn mpv --force-window=immediate {url}')
config.bind('md', 'hint -r links spawn youtube-dl {hint-url} -o ~/Downloads/%(title)s')
config.bind('mcd', 'spawn youtube-dl {url} -o ~/Downloads/%(title)s')

config.bind('ab', 'bookmark-add')
config.bind('aB', 'bookmark-del')

# readline shortcuts
config.bind('<Ctrl-d>', 'fake-key <Delete>', 'insert')
config.bind('<Ctrl-d>', 'fake-key -g <Delete>', 'command')
config.bind('<Ctrl-a>', 'fake-key <Home>', 'insert')
config.bind('<Ctrl-e>', 'fake-key <End>', 'insert')
config.bind('<Ctrl-f>', 'fake-key <Right>', 'insert')
config.bind('<Ctrl-b>', 'fake-key <Left>', 'insert')
config.bind('<Ctrl-p>', 'fake-key <Up>', 'insert')
config.bind('<Ctrl-n>', 'fake-key <Down>', 'insert')
config.bind('<Ctrl-w>', 'fake-key <Ctrl-backspace>', 'insert')
config.bind('<Ctrl-k>', 'fake-key <Shift-End><Delete>', 'insert')
config.bind('<Ctrl-u>', 'fake-key <Shift-Home><Backspace>', 'insert')

# Think ";i for image"
config.unbind(';I')
config.unbind(';i')
config.bind(';ii', 'hint images')
config.bind(';iI', 'hint images tab')
config.bind(';id', 'hint images download')
config.bind(';iy', 'hint images yank')

# Gruvbox stylesheet, written myself

stylesheet = "./gruvbox.css"
c.content.user_stylesheets = stylesheet
config.bind('tt',
        'config-cycle -p -t content.user_stylesheets "' +
        stylesheet + '" ""'
)

# Gruvbox theme, taken from https://github.com/theova/base16-qutebrowser and
# slightly modified (stripped comments, swapped some colors around)

base00 = "#282828"
base01 = "#3c3836"
base02 = "#504945"
base03 = "#665c54"
base04 = "#bdae93"
base05 = "#d5c4a1"
base06 = "#ebdbb2"
base07 = "#fbf1c7"
base08 = "#fb4934"
base09 = "#fe8019"
base0A = "#fabd2f"
base0B = "#b8bb26"
base0C = "#8ec07c"
base0D = "#83a598"
base0E = "#d3869b"
base0F = "#d65d0e"
c.colors.completion.fg = base05
c.colors.completion.odd.bg = base00
c.colors.completion.even.bg = base00
c.colors.completion.category.fg = base0D
c.colors.completion.category.bg = base00
c.colors.completion.category.border.top = base00
c.colors.completion.category.border.bottom = base00
c.colors.completion.item.selected.fg = base00
c.colors.completion.item.selected.bg = base0D
c.colors.completion.item.selected.border.top = base0D
c.colors.completion.item.selected.border.bottom = base0D
c.colors.completion.item.selected.match.fg = base00
c.colors.completion.match.fg = base09
c.colors.completion.scrollbar.fg = base05
c.colors.completion.scrollbar.bg = base00
c.colors.contextmenu.menu.bg = base00
c.colors.contextmenu.menu.fg =  base05
c.colors.contextmenu.selected.bg = base0D
c.colors.contextmenu.selected.fg = base00
c.colors.downloads.bar.bg = base00
c.colors.downloads.start.fg = base00
c.colors.downloads.start.bg = base0D
c.colors.downloads.stop.fg = base00
c.colors.downloads.stop.bg = base0C
c.colors.downloads.error.fg = base08
c.colors.hints.fg = base00
c.colors.hints.bg = base0A
c.colors.hints.match.fg = base05
c.colors.keyhint.fg = base05
c.colors.keyhint.suffix.fg = base05
c.colors.keyhint.bg = base00
c.colors.messages.error.fg = base00
c.colors.messages.error.bg = base08
c.colors.messages.error.border = base08
c.colors.messages.warning.fg = base00
c.colors.messages.warning.bg = base0E
c.colors.messages.warning.border = base0E
c.colors.messages.info.fg = base05
c.colors.messages.info.bg = base00
c.colors.messages.info.border = base00
c.colors.prompts.fg = base05
c.colors.prompts.border = base00
c.colors.prompts.bg = base00
c.colors.prompts.selected.bg = base0A
c.colors.statusbar.normal.fg = base05
c.colors.statusbar.normal.bg = base00
c.colors.statusbar.insert.fg = base0C
c.colors.statusbar.insert.bg = base00
c.colors.statusbar.passthrough.fg = base0A
c.colors.statusbar.passthrough.bg = base00
c.colors.statusbar.private.fg = base0E
c.colors.statusbar.private.bg = base00
c.colors.statusbar.command.fg = base04
c.colors.statusbar.command.bg = base01
c.colors.statusbar.command.private.fg = base0E
c.colors.statusbar.command.private.bg = base01
c.colors.statusbar.caret.fg = base0D
c.colors.statusbar.caret.bg = base00
c.colors.statusbar.caret.selection.fg = base0D
c.colors.statusbar.caret.selection.bg = base00
c.colors.statusbar.progress.bg = base0D
c.colors.statusbar.url.fg = base05
c.colors.statusbar.url.error.fg = base08
c.colors.statusbar.url.hover.fg = base09
c.colors.statusbar.url.success.http.fg = base0B
c.colors.statusbar.url.success.https.fg = base0B
c.colors.statusbar.url.warn.fg = base0E
c.colors.tabs.bar.bg = base00
c.colors.tabs.indicator.start = base0D
c.colors.tabs.indicator.stop = base0C
c.colors.tabs.indicator.error = base08
c.colors.tabs.odd.fg = base00
c.colors.tabs.odd.bg = base0D
c.colors.tabs.even.fg = base00
c.colors.tabs.even.bg = base0D
c.colors.tabs.pinned.even.bg = base0B
c.colors.tabs.pinned.even.fg = base00
c.colors.tabs.pinned.odd.bg = base0B
c.colors.tabs.pinned.odd.fg = base00
c.colors.tabs.pinned.selected.even.bg = base0D
c.colors.tabs.pinned.selected.even.fg = base00
c.colors.tabs.pinned.selected.odd.bg = base0D
c.colors.tabs.pinned.selected.odd.fg = base00
c.colors.tabs.selected.odd.fg = base05
c.colors.tabs.selected.odd.bg = base00
c.colors.tabs.selected.even.fg = base05
c.colors.tabs.selected.even.bg = base00
c.colors.webpage.bg = base00
