

lnabs() {
    if [[ $# -ne 2 ]]; then
        echo "Usage: lnabs <relative_target> <link_name>"
        echo "Example: lnabs ./Dotfiles/config/zsh ./.config/zsh"
        return 1
    fi
    local target="$1"
    local link="$2"
    # Ensure target exists
    if [[ ! -e "$PWD/$target" ]]; then
        echo "Error: Target '$PWD/$target' does not exist."
        return 1
    fi
    # Create the symlink with absolute path
    ln -sf "$PWD/$target" "$link"
    echo "Created symlink: $link -> $PWD/$target"
}

headless() {
  unset PULSE_SERVER
  pkill pulse
  local IP=127.0.0.1
  sleep 1
  pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=$IP auth-anonymous=1 port=8080" --exit-idle-time=-1
  export PULSE_SERVER=$IP:8080
}

function _smooth_fzf() {
  local fname
  local current_dir="$PWD"
  cd "${XDG_CONFIG_HOME:-~/.config}"
  fname="$(fzf)" || return
  $EDITOR "$fname"
  cd "$current_dir"
}

function toppy() {
    history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n 21
}

function cd() {
	z "$@" && ls --group-directories-first --color=auto -F
}

function zle-line-init {
echo -ne '\e[5 q'  # Bar cursor when shell starts
}
zle -N zle-line-init

rmpc(){
  pgrep -x "mpd" || mpd

  local TERMINAL=$(ps -p $PPID -o comm=)

  if [[ "${TERMINAL}" == "st" ]]; then
    command rmpc $@
  elif [[ "${TERMINAL}" == "com.termux" ]]; then
    command rmpc -c $HOME/.config/rmpc/config-termux.ron $@
  elif [ "${TERMINAL}" == "foot" ] || [ "${TERMINAL}" == "alacritty" ]; then
    command rmpc -c $HOME/.config/rmpc/config-foot.ron $@
  else
    command rmpc -c $HOME/.config/rmpc/config-ueberzug.ron $@
  fi

  mpc --host 127.0.0.1 --port 8600 stop
}

vplay(){
    SDL_HINT_RENDER_DRIVER=opengl
    ffplay -vcodec $(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 $1)_mediacodec $1
}
