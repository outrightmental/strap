#!/usr/bin/env bash

# Copyright (C) 2015 Outright Mental Inc. <hiya@outright.io>. All Rights Reserved.
# This file is licensed under the GPLv2+. Please see COPYING for more information.

umask "${STRAP_UMASK:-077}"
set -o pipefail

PREFIX="${STRAP_DIR:-$HOME/.strap}"
X_SELECTION="${STRAP_X_SELECTION:-clipboard}"
CLIP_TIME="${STRAP_CLIP_TIME:-45}"

# Text Formatting
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
GOLD=$(tput setaf 3)
BLUE=$(tput setaf 4)
GRAY=$(tput setaf 7)
BULLET=" $GREEN•$NORMAL"
CHKBULLET=" $GREEN$BOLD✔$NORMAL"
WARNBULLET=" $GOLD•$NORMAL"
FAILBULLET=" $RED•$NORMAL"
SUBULLET=" $GRAY-$NORMAL"
NOBULLET="  "

# Default Configuration
strapconfig_begin_banner='        |\n   __|  __|   __|  _` |  __ \\\n \\__ \\  |    |    (   |  |   |\n ____/ \\__| _|   \__,_|  .__/\n                        _|'
strapconfig_complete_banner="                        --- \n                     -        -- \n                 --( /     \\ )\$\$\$\$\$\$\$\$\$\$\$\$\$ \n             --\$\$\$(   O   O  )\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$- \n            /\$\$\$(       U     )        \$\$\$\$\$\$\$\\ \n          /\$\$\$\$\$(              )--   \$\$\$\$\$\$\$\$\$\$\$\\ \n         /\$\$\$\$\$/ (      O     )   \$\$\$\$\$\$   \\\$\$\$\$\$\\ \n         \$\$\$\$\$/   /            \$\$\$\$\$\$   \\   \\\$\$\$\$\$---- \n         \$\$\$\$\$\$  /          \$\$\$\$\$\$         \\  ----  - \n ---     \$\$\$  /          \$\$\$\$\$\$      \\           --- \n   --  --  /      /\\  \$\$\$\$\$\$            /     ---= \n     -        /    \$\$\$\$\$\$              '--- \$\$\$\$\$\$ \n       --\\/\$\$\$\\ \$\$\$\$\$\$                      /\$\$\$\$\$ \n         \\\$\$\$\$\$\$\$\$\$                        /\$\$\$\$\$/ \n          \\\$\$\$\$\$\$                         /\$\$\$\$\$/ \n            \\\$\$\$\$\$--  /                -- \$\$\$\$/ \n             --\$\$\$\$\$\$\$---------------  \$\$\$\$\$-- \n                \\\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$- \n                  --\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$-    \n\n"

export GIT_DIR="${STRAP_GIT:-$PREFIX}/.git"
export GIT_WORK_TREE="${STRAP_GIT:-$PREFIX}"

#
# BEGIN helper functions
#

git_add_file() {
    [[ -d $GIT_DIR ]] || return
    git add "$1" || return
    [[ -n $(git status --porcelain "$1") ]] || return
    git_commit "$2"
}
git_commit() {
    local sign=""
    [[ -d $GIT_DIR ]] || return
    [[ $(git config --bool --get strap.signcommits) == "true" ]] && sign="-S"
    git commit $sign -m "$1"
}
yesno() {
    [[ -t 0 ]] || return 0
    local response
    read -r -p "$1 [y/N] " response
    [[ $response == [yY] ]] || exit 1
}
space() {
  printf '\n'
}
die() {
    echo "$@" >&2
    exit 1
}
check_sneaky_paths() {
    local path
    for path in "$@"; do
        [[ $path =~ /\.\.$ || $path =~ ^\.\./ || $path =~ /\.\./ || $path =~ ^\.\.$ ]] && die "Error: You've attempted to buckle a sneaky path to strap. Go home."
    done
}
parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}
repo_git() { # <targetPath> <moduleName> <repoUrl>
  REPODIR="$1/$2"
  if [ -d "$REPODIR" ]; then
    printf "$SUBULLET Syncing existing repository $REPODIR\n"
    [[ -n $(cd $REPODIR && git checkout master) ]] || error "Failed to checkout master branch of git repo $1"
    [[ -n $(cd $REPODIR && git pull) ]] || error "Failed to pull repository $1/$2"
  else
    printf "$SUBULLET Cloning new repository $1/$2\n"
    if [ ! -d "$1" ]; then
      printf "$SUBULLET Creating directory $1\n"
      mkdir -p $1 || error "Failed to create directory $1"
    fi
 #   cd $1 && git clone $3 $2 || error "Failed to clone $3 $2 into $1"
  fi
  space
}
error() {
  if (( $# >= 1 )); then MSG="$1"; else MSG=""; fi
  printf "$FAILBULLET Error! $MSG\n"
  space
  if (( $# >= 2 )); then exit $2; else exit 1; fi
}
#
# END helper functions
#

#
# BEGIN buckle functions
# buckle_widget <filepath> <bucklename>
#
prebuckle_whoami() {
  WHOAMI=$(whoami) || error "Must be logged in!"
  printf "$BULLET hello ${BOLD}$WHOAMI$NORMAL\n"
  sudo -v || error "Must be Sudoer!"
}
banner() {
  printf "\n$1\n"
}
buckleup() {
  local bfile="$1"
  local btype=$( cat $bfile | grep ^type: | sed -e 's/type:\s*\([a-z0-9]\+\)/\1/g' )
  local cmd="buckle_$btype $bfile $2"
  eval $cmd
}
buckle_dpkg() {
  eval $(parse_yaml $1 "buckledata_") || error "Could not open $BOLD$2$NORMAL"
  if [ -z $buckledata_name ]; then error "$BOLD$2$NORMAL must have a ${BOLD}name:$NORMAL"; fi
  local tmpfile=$(mktemp)
  local dpkg_name=$buckledata_name
  dpkg -s $dpkg_name > $tmpfile
  local dpkg_version=$(cat $tmpfile | grep -i ^version | sed -e 's/version: \(.*\)/\1/gi' )
  if grep -i -q '^status.*installed' $tmpfile; then
    printf "$NOBULLET $BLUE$dpkg_name$NORMAL $dpkg_version\n"
  else
    printf "$NOBULLET $GOLD$dpkg_name$NORMAL\n"
    sudo apt-get install $dpkg_name
  fi
  rm $tmpfile
}
buckle_pass() {
  eval $(parse_yaml $1 "buckledata_") || error "Could not open $BOLD$2$NORMAL"
  local tmpfile=$(mktemp)
  pass version > $tmpfile
  local pass_version=$(cat $tmpfile | grep -i ' v[0-9\.]* ' | sed -e 's/.* v\([0-9\.]\+\) .*/\1/gi')
  if grep -i -q ' v[0-9\.]* ' $tmpfile; then
    printf "$NOBULLET ${BLUE}pass$NORMAL v$pass_version\n"
  else
    printf "$NOBULLET ${RED}pass$NORMAL\n"
    error "Please manually install ${BOLD}pass$NORMAL"
  fi
  pass git pull
  pass git push
}
buckle_rbenv() {
  eval $(parse_yaml $1 "buckledata_") || error "Could not open $BOLD$2$NORMAL"
  local tmpfile=$(mktemp)
  rbenv version > $tmpfile
  local rbenv_version=$(cat $tmpfile | grep -i '^[0-9\.]* ' | sed -e 's/.* v\([0-9\.]\+\) .*/\1/gi')
  if grep -i -q '^[0-9\.]* ' $tmpfile; then
    printf "$NOBULLET ${BLUE}rbenv$NORMAL v$rbenv_version\n"
  elif [[ "$OSTYPE" == "linux"* ]]; then
    repo_git ~ .rbenv https://github.com/sstephenson/rbenv.git
    repo_git ~/.rbenv/plugins ruby-build https://github.com/sstephenson/ruby-build.git
  else
    printf "$NOBULLET ${RED}rbenv$NORMAL\n"
    error "Please manually install ${BOLD}rbenv$NORMAL"
  fi
}
buckle_repo() {
  eval $(parse_yaml $1 "buckledata_") || error "Could not open $BOLD$2$NORMAL"
  if [ -z $buckledata_vcs ]; then $buckledata_vcs='git'; fi
  if [ -z $buckledata_url ]; then error "$BOLD$2$NORMAL must have a ${BOLD}url:$NORMAL"; fi
  if [ -z $buckledata_clone_as ]; then error "$BOLD$2$NORMAL must have a ${BOLD}clone_as:$NORMAL"; fi
  if [ -z $buckledata_parent_path ]; then error "$BOLD$2$NORMAL must have a ${BOLD}parent_path:$NORMAL"; fi
  printf "$NOBULLET ${BLUE}$buckledata_url$NORMAL\n"
  if [ $buckledata_vcs == 'git' ]; then
    repo_git $buckledata_parent_path $buckledata_clone_as $buckledata_url
  else
    error "Strap does not support vcs $BOLD$buckledata_vcs"
  fi
}
#
# END buckle functions
#

#
# BEGIN platform definable
#
clip() {
    # This base64 business is because bash cannot store binary data in a shell
    # variable. Specifically, it cannot store nulls nor (non-trivally) store
    # trailing new lines.
    local sleep_argv0="strap sleep on display $DISPLAY"
    pkill -f "^$sleep_argv0" 2>/dev/null && sleep 0.5
    local before="$(xclip -o -selection "$X_SELECTION" 2>/dev/null | base64)"
    echo -n "$1" | xclip -selection "$X_SELECTION" || die "Error: Could not copy data to the clipboard"
    (
        ( exec -a "$sleep_argv0" sleep "$CLIP_TIME" )
        local now="$(xclip -o -selection "$X_SELECTION" | base64)"
        [[ $now != $(echo -n "$1" | base64) ]] && before="$now"

        # It might be nice to programatically check to see if klipper exists,
        # as well as checking for other common clipboard managers. But for now,
        # this works fine -- if qdbus isn't there or if klipper isn't running,
        # this essentially becomes a no-op.
        #
        # Clipboard managers frequently write their history out in plaintext,
        # so we axe it here:
        qdbus org.kde.klipper /klipper org.kde.klipper.klipper.clearClipboardHistory &>/dev/null

        echo "$before" | base64 -d | xclip -selection "$X_SELECTION"
    ) 2>/dev/null & disown
    echo "Copied $2 to clipboard. Will clear in $CLIP_TIME seconds."
}
tmpdir() {
    [[ -n $SECURE_TMPDIR ]] && return
    local warn=1
    [[ $1 == "nowarn" ]] && warn=0
    local template="$PROGRAM.XXXXXXXXXXXXX"
    if [[ -d /dev/shm && -w /dev/shm && -x /dev/shm ]]; then
        SECURE_TMPDIR="$(mktemp -d "/dev/shm/$template")"
        remove_tmpfile() {
            rm -rf "$SECURE_TMPDIR"
        }
        trap remove_tmpfile INT TERM EXIT
    else
        [[ $warn -eq 1 ]] && yesno "$(cat <<-_EOF
        Your system does not have /dev/shm, which means that it may
        be difficult to entirely erase the temporary non-encrypted
        strap file after editing.

        Are you sure you would like to continue?
_EOF
        )"
        SECURE_TMPDIR="$(mktemp -d "${TMPDIR:-/tmp}/$template")"
        shred_tmpfile() {
            find "$SECURE_TMPDIR" -type f -exec $SHRED {} +
            rm -rf "$SECURE_TMPDIR"
        }
        trap shred_tmpfile INT TERM EXIT
    fi

}
GETOPT="getopt"
SHRED="shred -f -z"

source "$(dirname "$0")/platform/$(uname | cut -d _ -f 1 | tr '[:upper:]' '[:lower:]').sh" 2>/dev/null # PLATFORM_FUNCTION_FILE

#
# END platform definable
#


#
# BEGIN subcommand functions
#

cmd_version() {
    cat <<-_EOF
    ============================================
    =   strap: one command to start your day   =
    =                                          =
    =                  v0.1.1                  =
    =                                          =
    =          by Outright Mental Inc.         =
    =             hiya@outright.io             =
    =                                          =
    =         http://strap.outright.io         =
    ============================================
_EOF
}

cmd_usage() {
    cmd_version
    echo
    cat <<-_EOF
    Usage:
        $PROGRAM init [--path=subfolder,-p subfolder]
            Initialize new buckle storage a.k.a. strap configuration.
        $PROGRAM [ls] [subfolder]
            List buckles.
        $PROGRAM [up] buckle-name
          Straps up a buckle named \fIbuckle-name\fP, or (if none specified) straps up all buckles.
        $PROGRAM [show] [--clip,-c] buckle-name
            Show existing buckle and optionally put it on the clipboard.
            If put on the clipboard, it will be cleared in $CLIP_TIME seconds.
        $PROGRAM find buckle-names...
          List buckles that match buckle-names.
        $PROGRAM grep search-string
            Search for buckle files containing search-string when decrypted.
        $PROGRAM insert [--echo,-e | --multiline,-m] [--force,-f] buckle-name
            Insert new buckle. Optionally, echo the buckle back to the console
            during entry. Or, optionally, the entry may be multiline. Prompt before
            overwriting existing buckle unless forced.
        $PROGRAM edit buckle-name
            Insert a new buckle or edit an existing buckle using ${EDITOR:-vi}.
        $PROGRAM rm [--recursive,-r] [--force,-f] buckle-name
            Remove existing buckle or directory, optionally forcefully.
        $PROGRAM mv [--force,-f] old-path new-path
            Renames or moves old-path to new-path, optionally forcefully, selectively reencrypting.
        $PROGRAM cp [--force,-f] old-path new-path
            Copies old-path to new-path, optionally forcefully, selectively reencrypting.
        $PROGRAM git git-command-args...
            If the strap configuration is a git repository, execute a git command
            specified by git-command-args.
        $PROGRAM help
            Show this text.
        $PROGRAM version
            Show version information.

    More information may be found in the strap(1) man page.
_EOF
}

cmd_init() {
    local opts id_path=""
    opts="$($GETOPT -o p: -l path: -n "$PROGRAM" --)"
    local err=$?
    eval set -- "$opts"
    while true; do case $1 in
        -p|--path) id_path="$2"; shift 2 ;;
        --) shift; break ;;
    esac done

    [[ $err -ne 0 ]] && die "Usage: $PROGRAM $COMMAND [--path=subfolder,-p subfolder]"
    [[ -n $id_path ]] && check_sneaky_paths "$id_path"
    [[ -n $id_path && ! -d $PREFIX/$id_path && -e $PREFIX/$id_path ]] && die "Error: $PREFIX/$id_path exists but is not a directory."

    local config_file="$PREFIX/$id_path/config.sh.yml"

    if [[ $# -eq 1 && -z $1 ]]; then
        [[ ! -f "$config_file" ]] && die "Error: $config_file does not exist and so cannot be removed."
        rm -v -f "$config_file" || exit 1
        if [[ -d $GIT_DIR ]]; then
            git rm -qr "$config_file"
            git_commit "Deinitialize ${config_file}."
        fi
        rmdir -p "${config_file%/*}" 2>/dev/null
    else
        mkdir -v -p "$PREFIX/$id_path"
        printf "%s\n" "$@" > "$config_file"
        echo "Strap initialized."
        git_add_file "$config_file" "Added strap config_file file."
    fi

    git_add_file "$PREFIX/$id_path" "Added new strap configuration."
}

cmd_up() {
  local opts clip=0
  opts="$($GETOPT -o c -l clip -n "$PROGRAM" -- "$@")"
  local err=$?
  eval set -- "$opts"
  while true; do case $1 in
    --) shift; break ;;
  esac done

  [[ $err -ne 0 ]] && error "Usage: $PROGRAM $COMMAND [buckle-name]"

  local configfile="$PREFIX/config.sh.yml"
  if [[ -f $configfile ]]; then
    # first parse the whole file
    eval $(parse_yaml $configfile "strapconfig_")
    # then we need to build the strap list, with its order preserved, straight from the file.
    allstraps=""
    local cfgregex="^(\s+)([a-zA-Z0-9_]+):";
    local step=1
    local addstrap
    while IFS='' read -r line || [[ -n $line ]]; do
      if [[ $step == 2 ]]; then
        #inside of straps block
        if [[ $line =~ $cfgregex ]]; then
          addstrap=$( echo $line | sed -e 's/\s*\([a-zA-Z0-9_]\+\):.*/\1/g' )
          allstraps="$allstraps $addstrap"
        else
          step=3
        fi
      elif [[ $step == 1 ]]; then
        #waiting to be inside of straps block
        if [[ $line =~ ^straps: ]]; then step=2; fi
      fi
    done < "$configfile"
    space
    banner "$strapconfig_begin_banner"
    space
    prebuckle_whoami
    space
    straplist=""
    for eachstrap in $allstraps
    do
      strapvalue="strapconfig_straps_$eachstrap"
      if eval ${!strapvalue} >> /dev/null; then
        printf "$CHKBULLET $BOLD$eachstrap$NORMAL\n"
        straplist="$straplist $eachstrap"
      else
        printf "$WARNBULLET no $eachstrap$NORMAL\n"
      fi
      space
    done
  else
    error "Strap configuration is empty. Try \"strap init\"."
  fi

  local path="$1"
  local bucklefile="$PREFIX/$path.sh.yml"
  local strapregex="";
  local bucklename="";
  local buckleregex="s/$( echo $PREFIX | sed -e 's/\//\\\//g' )\/\(.*\)\.sh\.yml/\1/g"
  check_sneaky_paths "$path"
  if [[ $bucklefile =~ config.sh.yml$ ]]; then
    error "$path is internal to Strap, and cannot be strapped."
  elif [[ -f $bucklefile ]]; then
    buckleup $bucklefile
  elif [[ -d $PREFIX/$path ]]; then
    for upstrap in $straplist
    do
      strapregex="^.*/$upstrap/.*$"
      printf "$BULLET Strap $BOLD$GREEN$upstrap$NORMAL...\n"
      for file in `find "$PREFIX/$path" -type f -path "$PREFIX/.git" -prune -o -name '*.sh.yml'`
      do
        if [[ $file =~ $strapregex ]]; then
          bucklename=`echo $file | sed -e $buckleregex`
          buckleup $file $bucklename
        fi
      done
      space
    done
    banner "$strapconfig_complete_banner"
    printf "$CHKBULLET ${BOLD}Strapped$NORMAL. Happy Coding!\n"
    space
  elif [[ -z $path ]]; then
    die "Error: strap configuration is empty. Try \"strap init\"."
  else
    die "Error: $path is not in the strap configuration."
  fi
}

cmd_show() {
  local opts clip=0
  opts="$($GETOPT -o c -l clip -n "$PROGRAM" -- "$@")"
  local err=$?
  eval set -- "$opts"
  while true; do case $1 in
    -c|--clip) clip=1; shift ;;
    --) shift; break ;;
  esac done

  [[ $err -ne 0 ]] && die "Usage: $PROGRAM $COMMAND [--clip,-c] [buckle-name]"

  local path="$1"
  local bucklefile="$PREFIX/$path.sh.yml"
  check_sneaky_paths "$path"
  if [[ -f $bucklefile ]]; then
    if [[ $clip -eq 0 ]]; then
      cat "$bucklefile" || exit $?
    else
      local strap="$(cat "$bucklefile" | head -n 1)"
      [[ -n $strap ]] || exit 1
      clip "$strap" "$path"
    fi
  elif [[ -d $PREFIX/$path ]]; then
    if [[ -z $path ]]; then
      echo "Strap"
    else
      echo "${path%\/}"
    fi
    tree -C -l --noreport "$PREFIX/$path" | tail -n +2 | sed -E 's/\.sh.yml(\x1B\[[0-9]+m)?( ->|$)/\1\2/g' # remove .sh.yml at end of line, but keep colors
  elif [[ -z $path ]]; then
    die "Error: strap configuration is empty. Try \"strap init\"."
  else
    die "Error: $path is not in the strap configuration."
  fi
}

cmd_find() {
  [[ -z "$@" ]] && die "Usage: $PROGRAM $COMMAND pass-names..."
  local terms=$(printf '%s' "$@")
  echo "Search Terms: $terms"
  local pattern="*$terms*"
  tree -C -l --noreport --prune -P "$pattern" "$PREFIX" | tail -n +2 | sed -E 's/\.sh.yml(\x1B\[[0-9]+m)?( ->|$)/\1\2/g' # remove .sh.yml at end of line, but keep colors
 }

cmd_grep() {
    [[ $# -ne 1 ]] && die "Usage: $PROGRAM $COMMAND search-string"
    local search="$1" bucklefile grepresults
    while read -r -d "" bucklefile; do
        grepresults="$(cat "$bucklefile" | grep --color=always "$search")"
        [ $? -ne 0 ] && continue
        bucklefile="${bucklefile%.sh.yml}"
        bucklefile="${bucklefile#$PREFIX/}"
        local bucklefile_dir="${bucklefile%/*}/"
        [[ $bucklefile_dir == "${bucklefile}/" ]] && bucklefile_dir=""
        bucklefile="${bucklefile##*/}"
        printf "\e[94m%s\e[1m%s\e[0m:\n" "$bucklefile_dir" "$bucklefile"
        echo "$grepresults"
    done < <(find -L "$PREFIX" -iname '*.sh.yml' -print0)
}

cmd_insert() {
  local opts multiline=0 noecho=1 force=0
  opts="$($GETOPT -o mef -l multiline,echo,force -n "$PROGRAM" -- "$@")"
  local err=$?
  eval set -- "$opts"
  while true; do case $1 in
      -m|--multiline) multiline=1; shift ;;
      -e|--echo) noecho=0; shift ;;
      -f|--force) force=1; shift ;;
      --) shift; break ;;
  esac done

  [[ $err -ne 0 || ( $multiline -eq 1 && $noecho -eq 0 ) || $# -ne 1 ]] && die "Usage: $PROGRAM $COMMAND [--echo,-e | --multiline,-m] [--force,-f] buckle-name"
  local path="$1"
  local bucklefile="$PREFIX/$path.sh.yml"
  check_sneaky_paths "$path"

  [[ $force -eq 0 && -e $bucklefile ]] && yesno "An entry already exists for $path. Overwrite it?"

  mkdir -p -v "$PREFIX/$(dirname "$path")"

  if [[ $multiline -eq 1 ]]; then
      echo "Enter buckle YAML for $path and press Ctrl+D when finished:"
      while IFS= read -r line; do
        printf '%s\n' "$line"
      done > "$bucklefile" || exit 1
  else
      local buckle
      read -r -p "Enter buckle YAML for $path: " -e buckle || exit 1
      echo "$buckle" > "$bucklefile"
  fi
  git_add_file "$bucklefile" "Add given buckle for $path to store."
}

cmd_edit() {
  [[ $# -ne 1 ]] && die "Usage: $PROGRAM $COMMAND buckle-name"

  local path="$1"
  check_sneaky_paths "$path"
  mkdir -p -v "$PREFIX/$(dirname "$path")"
  local bucklefile="$PREFIX/$path.sh.yml"

  tmpdir #Defines $SECURE_TMPDIR
  local tmp_file="$(mktemp -u "$SECURE_TMPDIR/XXXXXX")-${path//\//-}.txt"


  local action="Add"
  if [[ -f $bucklefile ]]; then
      mv -f "$bucklefile" "$tmp_file" || exit 1
      action="Edit"
  fi
  ${EDITOR:-vi} "$tmp_file"
  [[ -f $tmp_file ]] || die "New buckle not saved."
  cat "$bucklefile" 2>/dev/null | diff - "$tmp_file" &>/dev/null && die "Buckle unchanged."
  mv -f "$tmp_file" "$bucklefile"
  git_add_file "$bucklefile" "$action buckle for $path using ${EDITOR:-vi}."
}

cmd_delete() {
  local opts recursive="" force=0
  opts="$($GETOPT -o rf -l recursive,force -n "$PROGRAM" -- "$@")"
  local err=$?
  eval set -- "$opts"
  while true; do case $1 in
      -r|--recursive) recursive="-r"; shift ;;
      -f|--force) force=1; shift ;;
      --) shift; break ;;
  esac done
  [[ $# -ne 1 ]] && die "Usage: $PROGRAM $COMMAND [--recursive,-r] [--force,-f] buckle-name"
  local path="$1"
  check_sneaky_paths "$path"

  local bucklefile="$PREFIX/${path%/}"
  if [[ ! -d $bucklefile ]]; then
      bucklefile="$PREFIX/$path.sh.yml"
      [[ ! -f $bucklefile ]] && die "Error: $path is not in the strap configuration."
  fi

  if [[ $bucklefile =~ config.sh.yml$ ]]; then
    die "Error: $path is required by Strap, and cannot be removed."
  fi

  [[ $force -eq 1 ]] || yesno "Are you sure you would like to delete $path?"

  rm $recursive -f -v "$bucklefile"
  if [[ -d $GIT_DIR && ! -e $bucklefile ]]; then
      git rm -qr "$bucklefile"
      git_commit "Remove $path from store."
  fi
  rmdir -p "${bucklefile%/*}" 2>/dev/null
}

cmd_copy_move() {
  local opts move=1 force=0
  [[ $1 == "copy" ]] && move=0
  shift
  opts="$($GETOPT -o f -l force -n "$PROGRAM" -- "$@")"
  local err=$?
  eval set -- "$opts"
  while true; do case $1 in
      -f|--force) force=1; shift ;;
      --) shift; break ;;
  esac done
  [[ $# -ne 2 ]] && die "Usage: $PROGRAM $COMMAND [--force,-f] old-path new-path"
  check_sneaky_paths "$@"
  local old_path="$PREFIX/${1%/}"
  local new_path="$PREFIX/$2"
  local old_dir="$old_path"

  if [[ ! -d $old_path ]]; then
      old_dir="${old_path%/*}"
      old_path="${old_path}.sh.yml"
      [[ ! -f $old_path ]] && die "Error: $1 is not in the strap configuration."
  fi

  mkdir -p -v "${new_path%/*}"
  [[ -d $old_path || -d $new_path || $new_path =~ /$ ]] || new_path="${new_path}.sh.yml"

  local interactive="-i"
  [[ ! -t 0 || $force -eq 1 ]] && interactive="-f"

  if [[ $move -eq 1 ]]; then
      mv $interactive -v "$old_path" "$new_path" || exit 1
      [[ -e "$new_path" ]] && reencrypt_path "$new_path"

      if [[ -d $GIT_DIR && ! -e $old_path ]]; then
          git rm -qr "$old_path"
          git_add_file "$new_path" "Rename ${1} to ${2}."
      fi
      rmdir -p "$old_dir" 2>/dev/null
  else
      cp $interactive -r -v "$old_path" "$new_path" || exit 1
      [[ -e "$new_path" ]] && reencrypt_path "$new_path"
      git_add_file "$new_path" "Copy ${1} to ${2}."
  fi
}

cmd_git() {
  if [[ $1 == "init" ]]; then
      git "$@" || exit 1
      git_add_file "$PREFIX" "Add current contents of strap configuration."
  elif [[ -d $GIT_DIR ]]; then
      tmpdir nowarn #Defines $SECURE_TMPDIR. We don't warn, because at most, this only copies encrypted files.
      export TMPDIR="$SECURE_TMPDIR"
      git "$@"
  else
      die "Error: the strap configuration is not a git repository. Try \"$PROGRAM git init\"."
  fi
}

#
# END subcommand functions
#

PROGRAM="${0##*/}"
COMMAND="$1"

case "$1" in
  init) shift;                cmd_init "$@" ;;
  help|--help) shift;         cmd_usage "$@" ;;
  version|--version) shift;   cmd_version "$@" ;;
  show|ls|list) shift;        cmd_show "$@" ;;
  find|search) shift;         cmd_find "$@" ;;
  up) shift;                  cmd_up "$@" ;;
  grep) shift;                cmd_grep "$@" ;;
  insert|add) shift;          cmd_insert "$@" ;;
  edit) shift;                cmd_edit "$@" ;;
  delete|rm|remove) shift;    cmd_delete "$@" ;;
  rename|mv) shift;           cmd_copy_move "move" "$@" ;;
  copy|cp) shift;             cmd_copy_move "copy" "$@" ;;
  git) shift;                 cmd_git "$@" ;;
  *) COMMAND="up";            cmd_up "$@" ;;
esac
exit 0
