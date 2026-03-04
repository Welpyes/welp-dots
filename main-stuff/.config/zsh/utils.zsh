#compdef gowall
compdef _gowall gowall

# zsh completion for gowall                               -*- shell-script -*-

__gowall_debug()
{
    local file="$BASH_COMP_DEBUG_FILE"
    if [[ -n ${file} ]]; then
        echo "$*" >> "${file}"
    fi
}

_gowall()
{
    local shellCompDirectiveError=1
    local shellCompDirectiveNoSpace=2
    local shellCompDirectiveNoFileComp=4
    local shellCompDirectiveFilterFileExt=8
    local shellCompDirectiveFilterDirs=16
    local shellCompDirectiveKeepOrder=32

    local lastParam lastChar flagPrefix requestComp out directive comp lastComp noSpace keepOrder
    local -a completions

    __gowall_debug "\n========= starting completion logic =========="
    __gowall_debug "CURRENT: ${CURRENT}, words[*]: ${words[*]}"

    # The user could have moved the cursor backwards on the command-line.
    # We need to trigger completion from the $CURRENT location, so we need
    # to truncate the command-line ($words) up to the $CURRENT location.
    # (We cannot use $CURSOR as its value does not work when a command is an alias.)
    words=("${=words[1,CURRENT]}")
    __gowall_debug "Truncated words[*]: ${words[*]},"

    lastParam=${words[-1]}
    lastChar=${lastParam[-1]}
    __gowall_debug "lastParam: ${lastParam}, lastChar: ${lastChar}"

    # For zsh, when completing a flag with an = (e.g., gowall -n=<TAB>)
    # completions must be prefixed with the flag
    setopt local_options BASH_REMATCH
    if [[ "${lastParam}" =~ '-.*=' ]]; then
        # We are dealing with a flag with an =
        flagPrefix="-P ${BASH_REMATCH}"
    fi

    # Prepare the command to obtain completions
    requestComp="${words[1]} __complete ${words[2,-1]}"
    if [ "${lastChar}" = "" ]; then
        # If the last parameter is complete (there is a space following it)
        # We add an extra empty parameter so we can indicate this to the go completion code.
        __gowall_debug "Adding extra empty parameter"
        requestComp="${requestComp} \"\""
    fi

    __gowall_debug "About to call: eval ${requestComp}"

    # Use eval to handle any environment variables and such
    out=$(eval ${requestComp} 2>/dev/null)
    __gowall_debug "completion output: ${out}"

    # Extract the directive integer following a : from the last line
    local lastLine
    while IFS='\n' read -r line; do
        lastLine=${line}
    done < <(printf "%s\n" "${out[@]}")
    __gowall_debug "last line: ${lastLine}"

    if [ "${lastLine[1]}" = : ]; then
        directive=${lastLine[2,-1]}
        # Remove the directive including the : and the newline
        local suffix
        (( suffix=${#lastLine}+2))
        out=${out[1,-$suffix]}
    else
        # There is no directive specified.  Leave $out as is.
        __gowall_debug "No directive found.  Setting do default"
        directive=0
    fi

    __gowall_debug "directive: ${directive}"
    __gowall_debug "completions: ${out}"
    __gowall_debug "flagPrefix: ${flagPrefix}"

    if [ $((directive & shellCompDirectiveError)) -ne 0 ]; then
        __gowall_debug "Completion received error. Ignoring completions."
        return
    fi

    local activeHelpMarker="_activeHelp_ "
    local endIndex=${#activeHelpMarker}
    local startIndex=$((${#activeHelpMarker}+1))
    local hasActiveHelp=0
    while IFS='\n' read -r comp; do
        # Check if this is an activeHelp statement (i.e., prefixed with $activeHelpMarker)
        if [ "${comp[1,$endIndex]}" = "$activeHelpMarker" ];then
            __gowall_debug "ActiveHelp found: $comp"
            comp="${comp[$startIndex,-1]}"
            if [ -n "$comp" ]; then
                compadd -x "${comp}"
                __gowall_debug "ActiveHelp will need delimiter"
                hasActiveHelp=1
            fi

            continue
        fi

        if [ -n "$comp" ]; then
            # If requested, completions are returned with a description.
            # The description is preceded by a TAB character.
            # For zsh's _describe, we need to use a : instead of a TAB.
            # We first need to escape any : as part of the completion itself.
            comp=${comp//:/\\:}

            local tab="$(printf '\t')"
            comp=${comp//$tab/:}

            __gowall_debug "Adding completion: ${comp}"
            completions+=${comp}
            lastComp=$comp
        fi
    done < <(printf "%s\n" "${out[@]}")

    # Add a delimiter after the activeHelp statements, but only if:
    # - there are completions following the activeHelp statements, or
    # - file completion will be performed (so there will be choices after the activeHelp)
    if [ $hasActiveHelp -eq 1 ]; then
        if [ ${#completions} -ne 0 ] || [ $((directive & shellCompDirectiveNoFileComp)) -eq 0 ]; then
            __gowall_debug "Adding activeHelp delimiter"
            compadd -x "--"
            hasActiveHelp=0
        fi
    fi

    if [ $((directive & shellCompDirectiveNoSpace)) -ne 0 ]; then
        __gowall_debug "Activating nospace."
        noSpace="-S ''"
    fi

    if [ $((directive & shellCompDirectiveKeepOrder)) -ne 0 ]; then
        __gowall_debug "Activating keep order."
        keepOrder="-V"
    fi

    if [ $((directive & shellCompDirectiveFilterFileExt)) -ne 0 ]; then
        # File extension filtering
        local filteringCmd
        filteringCmd='_files'
        for filter in ${completions[@]}; do
            if [ ${filter[1]} != '*' ]; then
                # zsh requires a glob pattern to do file filtering
                filter="\*.$filter"
            fi
            filteringCmd+=" -g $filter"
        done
        filteringCmd+=" ${flagPrefix}"

        __gowall_debug "File filtering command: $filteringCmd"
        _arguments '*:filename:'"$filteringCmd"
    elif [ $((directive & shellCompDirectiveFilterDirs)) -ne 0 ]; then
        # File completion for directories only
        local subdir
        subdir="${completions[1]}"
        if [ -n "$subdir" ]; then
            __gowall_debug "Listing directories in $subdir"
            pushd "${subdir}" >/dev/null 2>&1
        else
            __gowall_debug "Listing directories in ."
        fi

        local result
        _arguments '*:dirname:_files -/'" ${flagPrefix}"
        result=$?
        if [ -n "$subdir" ]; then
            popd >/dev/null 2>&1
        fi
        return $result
    else
        __gowall_debug "Calling _describe"
        if eval _describe $keepOrder "completions" completions $flagPrefix $noSpace; then
            __gowall_debug "_describe found some completions"

            # Return the success of having called _describe
            return 0
        else
            __gowall_debug "_describe did not find completions."
            __gowall_debug "Checking if we should do file completion."
            if [ $((directive & shellCompDirectiveNoFileComp)) -ne 0 ]; then
                __gowall_debug "deactivating file completion"

                # We must return an error code here to let zsh know that there were no
                # completions found by _describe; this is what will trigger other
                # matching algorithms to attempt to find completions.
                # For example zsh can match letters in the middle of words.
                return 1
            else
                # Perform file completion
                __gowall_debug "Activating file completion"

                # We must return the result of this command, so it must be the
                # last command, or else we must store its result to return it.
                _arguments '*:filename:_files'" ${flagPrefix}"
            fi
        fi
    fi
}

# don't run the completion function when being source-ed or eval-ed
if [ "$funcstack[1]" = "_gowall" ]; then
    _gowall
fi

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
  killall pulseaudio
  pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
  export PULSE_SERVER=127.0.0.1
}

function _smooth_fzf() {
  local fname
  local current_dir="$PWD"
  cd "${XDG_CONFIG_HOME:-~/.config}"
  fname="$(fzf)" || return
  $EDITOR "$fname"
  cd "$current_dir"
}

function _sudo_replace_buffer() {
  local old=$1 new=$2 space=${2:+ }

  # if the cursor is positioned in the $old part of the text, make
  # the substitution and leave the cursor after the $new text
  if [[ $CURSOR -le ${#old} ]]; then
    BUFFER="${new}${space}${BUFFER#$old }"
    CURSOR=${#new}
  # otherwise just replace $old with $new in the text before the cursor
  else
    LBUFFER="${new}${space}${LBUFFER#$old }"
  fi
}

function _sudo_command_line() {
  # If line is empty, get the last run command from history
  [[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"

  # Save beginning space
  local WHITESPACE=""
  if [[ ${LBUFFER:0:1} = " " ]]; then
    WHITESPACE=" "
    LBUFFER="${LBUFFER:1}"
  fi

  {
    # If $SUDO_EDITOR or $VISUAL are defined, then use that as $EDITOR
    # Else use the default $EDITOR
    local EDITOR=${SUDO_EDITOR:-${VISUAL:-$EDITOR}}

    # If $EDITOR is not set, just toggle the sudo prefix on and off
    if [[ -z "$EDITOR" ]]; then
      case "$BUFFER" in
        sudo\ -e\ *) _sudo_replace_buffer "sudo -e" "" ;;
        sudo\ *) _sudo_replace_buffer "sudo" "" ;;
        *) LBUFFER="sudo $LBUFFER" ;;
      esac
      return
    fi

    # Check if the typed command is really an alias to $EDITOR

    # Get the first part of the typed command
    local cmd="${${(Az)BUFFER}[1]}"
    # Get the first part of the alias of the same name as $cmd, or $cmd if no alias matches
    local realcmd="${${(Az)aliases[$cmd]}[1]:-$cmd}"
    # Get the first part of the $EDITOR command ($EDITOR may have arguments after it)
    local editorcmd="${${(Az)EDITOR}[1]}"

    # Note: ${var:c} makes a $PATH search and expands $var to the full path
    # The if condition is met when:
    # - $realcmd is '$EDITOR'
    # - $realcmd is "cmd" and $EDITOR is "cmd"
    # - $realcmd is "cmd" and $EDITOR is "cmd --with --arguments"
    # - $realcmd is "/path/to/cmd" and $EDITOR is "cmd"
    # - $realcmd is "/path/to/cmd" and $EDITOR is "/path/to/cmd"
    # or
    # - $realcmd is "cmd" and $EDITOR is "cmd"
    # - $realcmd is "cmd" and $EDITOR is "/path/to/cmd"
    # or
    # - $realcmd is "cmd" and $EDITOR is /alternative/path/to/cmd that appears in $PATH
    if [[ "$realcmd" = (\$EDITOR|$editorcmd|${editorcmd:c}) \
      || "${realcmd:c}" = ($editorcmd|${editorcmd:c}) ]] \
      || builtin which -a "$realcmd" | command grep -Fx -q "$editorcmd"; then
      _sudo_replace_buffer "$cmd" "sudo -e"
      return
    fi

    # Check for editor commands in the typed command and replace accordingly
    case "$BUFFER" in
      $editorcmd\ *) _sudo_replace_buffer "$editorcmd" "sudo -e" ;;
      \$EDITOR\ *) _sudo_replace_buffer '$EDITOR' "sudo -e" ;;
      sudo\ -e\ *) _sudo_replace_buffer "sudo -e" "$EDITOR" ;;
      sudo\ *) _sudo_replace_buffer "sudo" "" ;;
      *) LBUFFER="sudo $LBUFFER" ;;
    esac
  } always {
    # Preserve beginning space
    LBUFFER="${WHITESPACE}${LBUFFER}"

    # Redisplay edit buffer (compatibility with zsh-syntax-highlighting)
    zle redisplay
  }
}

function _vi_search_fix() {
  zle vi-cmd-mode
  zle .vi-history-search-backward
}

function toppy() {
    history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n 21
}

function cd() {
	z "$@" && ls --group-directories-first --color=auto -F
}

function git-svn(){
  if [[ ! -z "$1" && ! -z "$2" ]]; then
          echo "Starting clone/copy ..."
          repo=$(echo $1 | sed 's/\/$\|.git$//')
          svn export "$repo/trunk/$2"
  else
          echo "Use: git-svn <repository> <subdirectory>"
  fi  
}

function zle-keymap-select {
if [[ $KEYMAP == vicmd ]]; then
  echo -ne '\e[1 q'  # Blinking block in normal mode
else
  echo -ne '\e[5 q'  # Blinking bar in insert mode
fi
}
zle -N zle-keymap-select

function zle-line-init {
echo -ne '\e[5 q'  # Bar cursor when shell starts
}
zle -N zle-line-init

termux_sudo(){
  if [[ -f "$TMPDIR/sudo_trap" ]]; then
    tudo $@
    return 1
  fi
  read -s "passwd?password: "
  echo ""
  if [[ "${passwd}" == "welp" ]]; then
    touch $TMPDIR/sudo_trap
    tudo $@
  else
    echo "password incorrect"
    return 1
  fi
}

sudo(){
  if [[ -f "/bin/sudo" ]]; then
    command sudo
  elif [[ -f "$PREFIX/bin/tudo" ]]; then
    termux_sudo $@
  else
    command sudo
  fi
}

# vim:ft=sh
