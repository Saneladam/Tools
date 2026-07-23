# set -g status-style fg=black,bg=white
set -g pane-border-style fg=#cccccc
set -g pane-active-border-style fg=#4c7dff

set -g status-style fg=black,bg=green
set -g status-left "#[fg=black,bg=red] < #S > #[fg=black,bold,bg=green] "
set -g status-right "#[fg=blue,bold,bg=white]  %H:%M  #[fg=black,bold]%d/%m/%Y #[fg=red] #(cat /sys/class/power_supply/BAT0/capacity)%% "

# set -g status-style fg=#444444,bg=#f7f4ef
#
# set -g pane-border-style fg=#d0d0d0
# set -g pane-active-border-style fg=#b48ead
#
# setw -g window-status-style fg=#888888,bg=#f7f4ef
# setw -g window-status-current-style fg=#222222,bg=#ece7df,bold
#
# setw -g window-status-format " #W "
setw -g window-status-current-format " ◈ #W "
#
# set -g status-left "#[fg=#b48ead,bold]#S "
# set -g status-right "#[fg=#666666]%H:%M #[fg=#999999]%d/%m"
# set -g status-right "#(basename #{pane_current_path})  %H:%M"
