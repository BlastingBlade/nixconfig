${POLKIT_GNOME} &
dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY

# start support services
systemctl --user restart waybar
systemctl --user restart wlsunset
systemctl --user restart kanshi
systemctl --user restart oguri

mod="Mod4"

${RIVERCTL} map normal $mod+Shift Return spawn ${FOOT}
${RIVERCTL} map normal $mod P spawn ${FUZZEL}

# Mod+Q to close the focused view
${RIVERCTL} map normal $mod Q close

# Mod+Shift+E to exit river
${RIVERCTL} map normal $mod+Shift E exit

# Mod+J and Mod+K to focus the next/previous view in the layout stack
${RIVERCTL} map normal $mod J focus-view next
${RIVERCTL} map normal $mod K focus-view previous

# Mod+Shift+J and Mod+Shift+K to swap the focused view with the next/previous
# view in the layout stack
${RIVERCTL} map normal $mod+Shift J swap next
${RIVERCTL} map normal $mod+Shift K swap previous

# Mod+Period and Mod+Comma to focus the next/previous output
${RIVERCTL} map normal $mod Period focus-output next
${RIVERCTL} map normal $mod Comma focus-output previous

# Mod+Shift+{Period,Comma} to send the focused view to the next/previous output
${RIVERCTL} map normal $mod+Shift Period send-to-output next
${RIVERCTL} map normal $mod+Shift Comma send-to-output previous

# Mod+Return to bump the focused view to the top of the layout stack
${RIVERCTL} map normal $mod Return zoom

# Mod+H and Mod+L to decrease/increase the main ratio of rivertile(1)
${RIVERCTL} map normal $mod H send-layout-cmd rivertile "main-ratio -0.05"
${RIVERCTL} map normal $mod L send-layout-cmd rivertile "main-ratio +0.05"

# Mod+Shift+H and Mod+Shift+L to increment/decrement the main count of rivertile(1)
${RIVERCTL} map normal $mod+Shift H send-layout-cmd rivertile "main-count +1"
${RIVERCTL} map normal $mod+Shift L send-layout-cmd rivertile "main-count -1"

# Mod+Alt+{H,J,K,L} to move views
${RIVERCTL} map normal $mod+Mod1 H move left 100
${RIVERCTL} map normal $mod+Mod1 J move down 100
${RIVERCTL} map normal $mod+Mod1 K move up 100
${RIVERCTL} map normal $mod+Mod1 L move right 100

# Mod+Alt+Control+{H,J,K,L} to snap views to screen edges
${RIVERCTL} map normal $mod+Mod1+Control H snap left
${RIVERCTL} map normal $mod+Mod1+Control J snap down
${RIVERCTL} map normal $mod+Mod1+Control K snap up
${RIVERCTL} map normal $mod+Mod1+Control L snap right

# Mod+Alt+Shif+{H,J,K,L} to resize views
${RIVERCTL} map normal $mod+Mod1+Shift H resize horizontal -100
${RIVERCTL} map normal $mod+Mod1+Shift J resize vertical 100
${RIVERCTL} map normal $mod+Mod1+Shift K resize vertical -100
${RIVERCTL} map normal $mod+Mod1+Shift L resize horizontal 100

# Mod + Left Mouse Button to move views
${RIVERCTL} map-pointer normal $mod BTN_LEFT move-view

# Mod + Right Mouse Button to resize views
${RIVERCTL} map-pointer normal $mod BTN_RIGHT resize-view

for i in $(seq 1 9)
do
    tags=$((1 << ($i - 1)))

    # Mod+[1-9] to focus tag [0-8]
    ${RIVERCTL} map normal $mod $i set-focused-tags $tags

    # Mod+Shift+[1-9] to tag focused view with tag [0-8]
    ${RIVERCTL} map normal $mod+Shift $i set-view-tags $tags

    # Mod+Ctrl+[1-9] to toggle focus of tag [0-8]
    ${RIVERCTL} map normal $mod+Control $i toggle-focused-tags $tags

    # Mod+Shift+Ctrl+[1-9] to toggle tag [0-8] of focused view
    ${RIVERCTL} map normal $mod+Shift+Control $i toggle-view-tags $tags
done

# Mod+0 to focus all tags
# Mod+Shift+0 to tag focused view with all tags
all_tags=$(((1 << 32) - 1))
${RIVERCTL} map normal $mod 0 set-focused-tags $all_tags
${RIVERCTL} map normal $mod+Shift 0 set-view-tags $all_tags

# Mod+Space to toggle float
${RIVERCTL} map normal $mod Space toggle-float

# Mod+F to toggle fullscreen
${RIVERCTL} map normal $mod F toggle-fullscreen

# Mod+{Up,Right,Down,Left} to change layout orientation
${RIVERCTL} map normal $mod Up    send-layout-cmd rivertile "main-location top"
${RIVERCTL} map normal $mod Right send-layout-cmd rivertile "main-location right"
${RIVERCTL} map normal $mod Down  send-layout-cmd rivertile "main-location bottom"
${RIVERCTL} map normal $mod Left  send-layout-cmd rivertile "main-location left"

# Declare a passthrough mode. This mode has only a single mapping to return to
# normal mode. This makes it useful for testing a nested wayland compositor
${RIVERCTL} declare-mode passthrough

# Mod+F11 to enter passthrough mode
${RIVERCTL} map normal $mod F11 enter-mode passthrough

# Mod+F11 to return to normal mode
${RIVERCTL} map passthrough $mod F11 enter-mode normal

# Various media key mapping examples for both normal and locked mode which do
# not have a modifier
for mode in normal locked
do
    # Control pulse audio volume with pamixer
    ${RIVERCTL} map $mode None XF86AudioRaiseVolume  spawn "${PAMIXER} -i 5"
    ${RIVERCTL} map $mode None XF86AudioLowerVolume  spawn "${PAMIXER} -d 5"
    ${RIVERCTL} map $mode None XF86AudioMute         spawn "${PAMIXER} --toggle-mute"

    # Control MPRIS aware media players with playerctl (https://github.com/altdesktop/playerctl)
    ${RIVERCTL} map $mode None XF86AudioMedia spawn "${PLAYERCTL} play-pause"
    ${RIVERCTL} map $mode None XF86AudioPlay  spawn "${PLAYERCTL} play-pause"
    ${RIVERCTL} map $mode None XF86AudioPrev  spawn "${PLAYERCTL} previous"
    ${RIVERCTL} map $mode None XF86AudioNext  spawn "${PLAYERCTL} next"

    # Control screen backlight brighness with light (https://github.com/haikarainen/light)
    ${RIVERCTL} map $mode None XF86MonBrightnessUp   spawn "${LIGHT} -A 5"
    ${RIVERCTL} map $mode None XF86MonBrightnessDown spawn "${LIGHT} -U 5"
done

# Set background and border color
${RIVERCTL} background-color 0x002b36
${RIVERCTL} border-color-focused 0x93a1a1
${RIVERCTL} border-color-unfocused 0x586e75

# Set keyboard repeat rate
${RIVERCTL} set-repeat 50 300

# Make certain views start floating
${RIVERCTL} float-filter-add app-id float
${RIVERCTL} float-filter-add title "popup title with spaces"

# Set app-ids and titles of views which should use client side decorations
${RIVERCTL} csd-filter-add app-id "gedit"

# Set and exec into the default layout generator, rivertile.
# River will send the process group of the init executable SIGTERM on exit.
${RIVERCTL} default-layout rivertile
exec ${RIVERTILE} -view-padding 6 -outer-padding 6
