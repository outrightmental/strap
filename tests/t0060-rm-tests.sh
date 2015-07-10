#!/usr/bin/env bash

test_description='Test rm'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test "rm" command' '
	"$STRAP" init &&
	"$STRAP" insert -e "cred1"<<<"BLAH!!" &&
	"$STRAP" rm cred1 &&
	[[ ! -e $STRAP_DIR/cred1.yml ]]
'

test_expect_success 'Test "rm" command with spaces' '
	"$STRAP" insert -e "hello i have spaces"<<<"BLAH!!" &&
	[[ -e $STRAP_DIR/"hello i have spaces".yml ]] &&
	"$STRAP" rm "hello i have spaces" &&
	[[ ! -e $STRAP_DIR/"hello i have spaces".yml ]]
'

test_expect_success 'Test "rm" of non-existent buckle' '
	test_must_fail "$STRAP" rm does-not-exist
'

test_done
