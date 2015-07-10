#!/usr/bin/env bash

# Copyright (C) 2012 - 2014 Outright Mental Inc. <hiya@outright.io>. All Rights Reserved.
# This file is licensed under the GPLv2+. Please see COPYING for more information.

umask "${STRAP_UMASK:-077}"
set -o pipefail

PREFIX="${STRAP_DIR:-$HOME/.strap}"
X_SELECTION="${STRAP_X_SELECTION:-clipboard}"
CLIP_TIME="${STRAP_CLIP_TIME:-45}"

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
die() {
	echo "$@" >&2
	exit 1
}
check_sneaky_paths() {
	local path
	for path in "$@"; do
		[[ $path =~ /\.\.$ || $path =~ ^\.\./ || $path =~ /\.\./ || $path =~ ^\.\.$ ]] && die "Error: You've attempted to strap a sneaky path to strap. Go home."
	done
}

#
# END helper functions
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
	=                  v0.1.0                  =
	=                                          =
	=            Outright Mental Inc.          =
	=              hiya@outright.io            =
	=                                          =
	=        http://strap.outright.io/         =
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
	    $PROGRAM [show] [--clip,-c] strap-name
	        Show existing buckle and optionally put it on the clipboard.
	        If put on the clipboard, it will be cleared in $CLIP_TIME seconds.
	    $PROGRAM grep search-string
	        Search for buckle files containing search-string when decrypted.
	    $PROGRAM insert [--echo,-e | --multiline,-m] [--force,-f] strap-name
	        Insert new buckle. Optionally, echo the buckle back to the console
	        during entry. Or, optionally, the entry may be multiline. Prompt before
	        overwriting existing buckle unless forced.
	    $PROGRAM edit strap-name
	        Insert a new buckle or edit an existing buckle using ${EDITOR:-vi}.
	    $PROGRAM rm [--recursive,-r] [--force,-f] strap-name
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

	local config_file="$PREFIX/$id_path/config"

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

cmd_show() {
	local opts clip=0
	opts="$($GETOPT -o c -l clip -n "$PROGRAM" -- "$@")"
	local err=$?
	eval set -- "$opts"
	while true; do case $1 in
		-c|--clip) clip=1; shift ;;
		--) shift; break ;;
	esac done

	[[ $err -ne 0 ]] && die "Usage: $PROGRAM $COMMAND [--clip,-c] [strap-name]"

	local path="$1"
	local bucklefile="$PREFIX/$path.yml"
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
		tree -C -l --noreport "$PREFIX/$path" | tail -n +2 | sed -E 's/\.yml(\x1B\[[0-9]+m)?( ->|$)/\1\2/g' # remove .yml at end of line, but keep colors
	elif [[ -z $path ]]; then
		die "Error: strap configuration is empty. Try \"strap init\"."
	else
		die "Error: $path is not in the strap configuration."
	fi
}

cmd_grep() {
	[[ $# -ne 1 ]] && die "Usage: $PROGRAM $COMMAND search-string"
	local search="$1" bucklefile grepresults
	while read -r -d "" bucklefile; do
		grepresults="$(cat "$bucklefile" | grep --color=always "$search")"
		[ $? -ne 0 ] && continue
		bucklefile="${bucklefile%.yml}"
		bucklefile="${bucklefile#$PREFIX/}"
		local bucklefile_dir="${bucklefile%/*}/"
		[[ $bucklefile_dir == "${bucklefile}/" ]] && bucklefile_dir=""
		bucklefile="${bucklefile##*/}"
		printf "\e[94m%s\e[1m%s\e[0m:\n" "$bucklefile_dir" "$bucklefile"
		echo "$grepresults"
	done < <(find -L "$PREFIX" -iname '*.yml' -print0)
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

	[[ $err -ne 0 || ( $multiline -eq 1 && $noecho -eq 0 ) || $# -ne 1 ]] && die "Usage: $PROGRAM $COMMAND [--echo,-e | --multiline,-m] [--force,-f] strap-name"
	local path="$1"
	local bucklefile="$PREFIX/$path.yml"
	check_sneaky_paths "$path"

	[[ $force -eq 0 && -e $bucklefile ]] && yesno "An entry already exists for $path. Overwrite it?"

	mkdir -p -v "$PREFIX/$(dirname "$path")"

	if [[ $multiline -eq 1 ]]; then
		echo "Enter contents of $path and press Ctrl+D when finished:"
		echo
		while IFS= read -r line; do
		  printf '%s\n' "$line"
		done < "$bucklefile" || exit 1
	elif [[ $noecho -eq 1 ]]; then
		local buckle buckle_again
		while true; do
			read -r -p "Enter buckle for $path: " -s buckle || exit 1
			echo
			read -r -p "Retype buckle for $path: " -s buckle_again || exit 1
			echo
			if [[ $buckle == "$buckle_again" ]]; then
				echo "$buckle" > "$bucklefile"
				break
			else
				echo "Error: the entered buckles do not match."
			fi
		done
	else
		local buckle
		read -r -p "Enter buckle for $path: " -e buckle
		echo "$buckle" > "$bucklefile"
	fi
	git_add_file "$bucklefile" "Add given buckle for $path to store."
}

cmd_edit() {
	[[ $# -ne 1 ]] && die "Usage: $PROGRAM $COMMAND strap-name"

	local path="$1"
	check_sneaky_paths "$path"
	mkdir -p -v "$PREFIX/$(dirname "$path")"
	local bucklefile="$PREFIX/$path.yml"

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
	[[ $# -ne 1 ]] && die "Usage: $PROGRAM $COMMAND [--recursive,-r] [--force,-f] strap-name"
	local path="$1"
	check_sneaky_paths "$path"

	local bucklefile="$PREFIX/${path%/}"
	if [[ ! -d $bucklefile ]]; then
		bucklefile="$PREFIX/$path.yml"
		[[ ! -f $bucklefile ]] && die "Error: $path is not in the strap configuration."
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
		old_path="${old_path}.yml"
		[[ ! -f $old_path ]] && die "Error: $1 is not in the strap configuration."
	fi

	mkdir -p -v "${new_path%/*}"
	[[ -d $old_path || -d $new_path || $new_path =~ /$ ]] || new_path="${new_path}.yml"

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
	init) shift;			cmd_init "$@" ;;
	help|--help) shift;		cmd_usage "$@" ;;
	version|--version) shift;	cmd_version "$@" ;;
	show|ls|list) shift;		cmd_show "$@" ;;
	grep) shift;			cmd_grep "$@" ;;
	insert|add) shift;		cmd_insert "$@" ;;
	edit) shift;			cmd_edit "$@" ;;
	delete|rm|remove) shift;	cmd_delete "$@" ;;
	rename|mv) shift;		cmd_copy_move "move" "$@" ;;
	copy|cp) shift;			cmd_copy_move "copy" "$@" ;;
	git) shift;			cmd_git "$@" ;;
	*) COMMAND="show";		cmd_show "$@" ;;
esac
exit 0
