#!/usr/bin/env bash

test_description='Test mv command'
cd "$(dirname "$0")"
. ./setup.sh

INITIAL_STRAP="bla bla bla will we make it!!"

test_expect_success 'Basic move command' '
	"$STRAP" init &&
	"$STRAP" git init &&
	"$STRAP" insert -e person1 <<<"$INITIAL_STRAP" &&
	"$STRAP" mv person1 person2 &&
	[[ -e $STRAP_DIR/person2.sh.yml && ! -e $STRAP_DIR/person1.sh.yml ]]
'

test_expect_success 'Directory creation' '
	"$STRAP" mv person2 directory/ &&
	[[ -d $STRAP_DIR/directory && -e $STRAP_DIR/directory/person2.sh.yml ]]
'

test_expect_success 'Directory creation with file rename and empty directory removal' '
	"$STRAP" mv directory/person2 "new directory with spaces"/person &&
	[[ -d $STRAP_DIR/"new directory with spaces" && -e $STRAP_DIR/"new directory with spaces"/person.sh.yml && ! -e $STRAP_DIR/directory ]]
'

test_expect_success 'Directory rename' '
	"$STRAP" mv "new directory with spaces" anotherdirectory &&
	[[ -d $STRAP_DIR/anotherdirectory && -e $STRAP_DIR/anotherdirectory/person.sh.yml && ! -e $STRAP_DIR/"new directory with spaces" ]]
'

test_expect_success 'Directory move into new directory' '
	"$STRAP" mv anotherdirectory "new directory with spaces"/ &&
	[[ -d $STRAP_DIR/"new directory with spaces"/anotherdirectory && -e $STRAP_DIR/"new directory with spaces"/anotherdirectory/person.sh.yml && ! -e $STRAP_DIR/anotherdirectory ]]
'

test_expect_success 'Multi-directory creation and multi-directory empty removal' '
	"$STRAP" mv "new directory with spaces"/anotherdirectory/person new1/new2/new3/new4/theperson &&
	"$STRAP" mv new1/new2/new3/new4/theperson person &&
	[[ ! -d $STRAP_DIR/"new directory with spaces"/anotherdirectory && ! -d $STRAP_DIR/new1/new2/new3/new4 && -e $STRAP_DIR/person.sh.yml ]]
'

test_expect_success 'Buckle made it until the end' '
	[[ $("$STRAP" show person) == "$INITIAL_STRAP" ]]
'

test_expect_success 'Git is consistent' '
 [[ -z $("$STRAP" git status --porcelain person2>&1) ]]
'


test_done
