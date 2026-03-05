# Add this to your ~/.zshrc

# Commands that require sudo
SUDO_COMMANDS=(pkg apt pacman)

# Check if command needs sudo
needs_sudo() {
    local cmd="$1"
    shift
    local args=("$@")
    
    # Check if it's a protected command
    for protected in "${SUDO_COMMANDS[@]}"; do
        if [ "$cmd" = "$protected" ]; then
            return 0
        fi
    done
    
    # Check if command modifies $PREFIX
    case "$cmd" in
        cp|mv|rm|rmdir|mkdir|touch|chmod|chown|ln)
            # Check if any argument starts with $PREFIX
            for arg in "${args[@]}"; do
                # Expand the path
                local expanded=$(eval echo "$arg")
                case "$expanded" in
                    $PREFIX*|/data/data/com.termux/files/usr*)
                        return 0
                        ;;
                esac
            done
            ;;
    esac
    
    return 1
}

# Preexec hook - runs before each command
preexec() {
    local cmd_line="$1"
    
    # Parse the command
    local cmd_array=("${(z)cmd_line}")
    local cmd="${cmd_array[1]}"
    
    # Skip if already using sudo
    if [ "$cmd" = "sudo" ]; then
        return 0
    fi
    
    # Check if command needs sudo
    if needs_sudo "$cmd" "${cmd_array[@]:2}"; then
        echo "Permission denied: '$cmd' requires sudo privileges" >&2
        echo "Run: sudo $cmd_line" >&2
        
        # Kill the command before it executes
        kill -INT $$
        return 1
    fi
}

# Enable preexec hook
autoload -Uz add-zsh-hook
add-zsh-hook preexec preexec

# Optional: Add visual indicator to prompt when sudo session is active
# update_sudo_prompt() {
#     if [ -f "$HOME/.termux-sudo/session" ]; then
#         local timestamp=$(cat "$HOME/.termux-sudo/session" 2>/dev/null | tr -cd '0-9')
#         local current=$(date +%s)
#         if [ -n "$timestamp" ] && [ "$timestamp" -gt 0 ] 2>/dev/null && [ $((current - timestamp)) -lt 900 ] 2>/dev/null; then
#             SUDO_INDICATOR="%F{red}[sudo]%f "
#         else
#             SUDO_INDICATOR=""
#         fi
#     else
#         SUDO_INDICATOR=""
#     fi
# }
#
# # Update prompt before each command
# autoload -Uz add-zsh-hook
# add-zsh-hook precmd update_sudo_prompt

# Add to your PS1 if you want the indicator (not needed for oh-my-posh)
# Example: PS1="${SUDO_INDICATOR}%~ %# "
# For oh-my-posh users: you can check $SUDO_INDICATOR variable in your theme if needed
