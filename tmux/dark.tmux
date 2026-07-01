# set -g status-style fg=black,bg=green
set -g pane-border-style fg=#3b4261
set -g pane-active-border-style fg=#7aa2f7

set -g status-style fg=black,bg=green
set -g status-left "#[fg=black,bg=magenta] < #S > #[fg=black,bold,bg=green] "
set -g status-right "#[fg=blue,bold,bg=black]  %H:%M  #[fg=white,bold]%d/%m/%Y #[fg=red] #(cat /sys/class/power_supply/BAT0/capacity)%% "


# set -g status-style fg=#c8ccd4,bg=#161616
#
# set -g pane-border-style fg=#2f3240
# set -g pane-active-border-style fg=#bb9af7
#
# setw -g window-status-style fg=#666666,bg=#161616
# setw -g window-status-current-style fg=#ffffff,bg=#202020,bold
#
# setw -g window-status-format " #W "
# setw -g window-status-current-format " ◈ #W "
#
# set -g status-left "#[fg=#bb9af7,bold]#S "
# set -g status-right "#[fg=#7aa2f7]%H:%M #[fg=#888888]%d/%m"
