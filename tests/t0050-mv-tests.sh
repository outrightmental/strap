#!/usr/bin/env bash

test_description='Test mv command'
cd "$(dirname "$0")"
. ./setup.sh

INITIAL_STRAP="bla bla bla will we make it!!"

test_expect_success 'Basic move command' '
	"$STRAP" init &&
	"$STRAP" git init &&
	"$STRAP" insert -e cred1 <<<"$INITIAL_STRAP" &&
	"$STRAP" mv cred1 cred2 &&
	[[ -e $STRAP_DIR/cred2.sh.yml && ! -e $STRAP_DIR/cred1.sh.yml ]]
'

test_expect_success 'Directory creation' '
	"$STRAP" mv cred2 directory/ &&
	[[ -d $STRAP_DIR/directory && -e $STRAP_DIR/directory/cred2.sh.yml ]]
'

test_expect_success 'Directory creation with file rename and empty directory removal' '
	"$STRAP" mv directory/cred2 "new directory with spaces"/cred &&
	[[ -d $STRAP_DIR/"new directory with spaces" && -e $STRAP_DIR/"new directory with spaces"/cred.sh.yml && ! -e $STRAP_DIR/directory ]]
'

test_expect_success 'Directory rename' '
	"$STRAP" mv "new directory with spaces" anotherdirectory &&
	[[ -d $STRAP_DIR/anotherdirectory && -e $STRAP_DIR/anotherdirectory/cred.sh.yml && ! -e $STRAP_DIR/"new directory with spaces" ]]
'

test_expect_success 'Directory move into new directory' '
	"$STRAP" mv anotherdirectory "new directory with spaces"/ &&
	[[ -d $STRAP_DIR/"new directory with spaces"/anotherdirectory && -e $STRAP_DIR/"new directory with spaces"/anotherdirectory/cred.sh.yml && ! -e $STRAP_DIR/anotherdirectory ]]
'

test_expect_success 'Multi-directory creation and multi-directory empty removal' '
	"$STRAP" mv "new directory with spaces"/anotherdirectory/cred new1/new2/new3/new4/thecred &&
	"$STRAP" mv new1/new2/new3/new4/thecred cred &&
	[[ ! -d $STRAP_DIR/"new directory with spaces"/anotherdirectory && ! -d $STRAP_DIR/new1/new2/new3/new4 && -e $STRAP_DIR/cred.sh.yml ]]
'

test_expect_success 'Buckle made it until the end' '
	[[ $("$STRAP" show cred) == "$INITIAL_STRAP" ]]
'

test_expect_success 'Git is consistent' '
 [[ -z $("$STRAP" git status --porcelain cred2>&1) ]]
'


test_done
