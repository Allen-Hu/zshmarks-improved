# ------------------------------------------------------------------------------
#          FILE:  zshmarks.plugin.zsh
#   DESCRIPTION:  oh-my-zsh plugin file.
#        AUTHOR:  Jocelyn Mallon
#       VERSION:  1.7.0
# ------------------------------------------------------------------------------

# Set BOOKMARKS_FILE if it doesn't exist to the default.
# Allows for a user-configured BOOKMARKS_FILE.
if [[ -z $BOOKMARKS_FILE ]] ; then
	export BOOKMARKS_FILE="$HOME/.bookmarks"
fi

# Check if $BOOKMARKS_FILE is a symlink.
if [[ -L $BOOKMARKS_FILE ]]; then
  BOOKMARKS_FILE=$(readlink $BOOKMARKS_FILE)
fi

# Create bookmarks_file it if it doesn't exist
if [[ ! -f $BOOKMARKS_FILE ]]; then
	touch $BOOKMARKS_FILE
fi

__zshmarks_move_to_trash() {
  if [[ $(uname) == "Linux"* || $(uname) == "FreeBSD"*  ]]; then
    label=`date +%s`
    mkdir -p ~/.local/share/Trash/info ~/.local/share/Trash/files
    \mv "${BOOKMARKS_FILE}.bak" ~/.local/share/Trash/files/bookmarks-$label
    echo "[Trash Info]
Path=/home/"$USER"/.bookmarks
DeletionDate="`date +"%Y-%m-%dT%H:%M:%S"`"
">~/.local/share/Trash/info/bookmarks-$label.trashinfo
  elif [[ $(uname) = "Darwin" ]]; then
    \mv "${BOOKMARKS_FILE}.bak" ~/.Trash/"bookmarks"$(date +%H-%M-%S)
  else
    \rm -f "${BOOKMARKS_FILE}.bak"
  fi
}

function bookmark() {
	local bookmark_name=$1
	if [[ -z $bookmark_name ]]; then
    bookmark_name="${PWD##*/}"
  fi
  cur_dir="$(pwd)"
  # Replace /home/uname with $HOME
  if [[ "$cur_dir" =~ ^"$HOME"(/|$) ]]; then
    cur_dir="\$HOME${cur_dir#$HOME}"
  fi
  # Store the bookmark as folder|name
  bookmark="$cur_dir|$bookmark_name"
  if ! __zshmarks_zgrep foo "\\|$bookmark_name\$" "$BOOKMARKS_FILE"; then
    echo $bookmark >> $BOOKMARKS_FILE
    echo "Bookmark '$bookmark_name' saved"
  else
    echo "Bookmark already existed"
    return 1
  fi
}

__zshmarks_zgrep() {
	local outvar="$1"; shift
	local pattern="$1"
	local filename="$2"
  local result=$(cat $filename | grep -e $pattern)
  eval "$outvar=\"$result\""
  if [ -z "$result" ]; then
	  return 1
  fi
  return 0
}

function jump() {
	local bookmark_name=$1
	local bookmark
	if ! __zshmarks_zgrep bookmark "\|$bookmark_name\$" "$BOOKMARKS_FILE"; then
		echo "Invalid name, please provide a valid bookmark name. For example:"
		echo "  jump foo"
		echo
		echo "To bookmark a folder, go to the folder then do this (naming the bookmark 'foo'):"
		echo "  bookmark foo"
		return 1
	else
		local dir="${bookmark%%|*}"
		eval "cd \"${dir}\""
	fi
}

# Show a list of the bookmarks
function showmarks() {
  local bookmark_name bookmark_path bookmark_line buf
  while read bookmark_line; do
    bookmark_path="${bookmark_line%%|*}"
    bookmark_path="${bookmark_path/\$HOME/~}"
    bookmark_name="${bookmark_line#*|}"
    buf+="$(printf '%s\t\t%s' $bookmark_name $bookmark_path)\n"
  done < $BOOKMARKS_FILE
  echo "$buf" | sort | column -t
}

# Delete a bookmark
function deletemark() {
  local bookmark_name=$1
  if [[ -z $bookmark_name ]]; then
    printf "%s \n" "Please provide a name for your bookmark to delete. For example:"
    printf "\t%s \n" "deletemark foo"
    return 1
  else
    local bookmark_line bookmark_search
    if ! __zshmarks_zgrep bookmark "\\|$bookmark_name\$" "$BOOKMARKS_FILE"; then
      eval "printf '%s\n' \"'${bookmark_name}' not found, skipping.\""
    else
      cp "${BOOKMARKS_FILE}" "${BOOKMARKS_FILE}.bak"
      grep -v \|"${bookmark_name}"$ "${BOOKMARKS_FILE}.bak" > "${BOOKMARKS_FILE}"
      __zshmarks_move_to_trash
      echo "Bookmark '$bookmark_name' deleted"
    fi
	fi
}

