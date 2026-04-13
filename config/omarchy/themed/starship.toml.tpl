# Generated from the omarchy-supplement Starship template.
"$schema" = "https://starship.rs/config-schema.json"

format = """
$username\
$hostname\
$directory\
$git_branch\
$git_state\
$git_status\
$cmd_duration\
$line_break\
$python\
$character"""

[directory]
style = "{{ color4 }}"

[character]
success_symbol = "[❯]({{ accent }})"
error_symbol = "[❯]({{ color1 }})"
vimcmd_symbol = "[❮]({{ color2 }})"

[git_branch]
format = "[$branch]($style)"
style = "{{ color8 }}"

[git_status]
format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)]({{ accent }}) ($ahead_behind$stashed)]($style)"
style = "{{ color6 }}"
conflicted = "​"
untracked = "​"
modified = "​"
staged = "​"
renamed = "​"
deleted = "​"
stashed = "≡"

[git_state]
format = '\([$state( $progress_current/$progress_total)]($style)\) '
style = "{{ color8 }}"

[cmd_duration]
format = "[$duration]($style) "
style = "{{ color3 }}"

[python]
format = "[$virtualenv]($style) "
style = "{{ color8 }}"
detect_extensions = []
detect_files = []
