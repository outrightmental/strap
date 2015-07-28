#!/usr/bin/env bash

test_description='Test rm'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test "rm" command' '
	"$STRAP" init &&
	"$STRAP" insert -e "cred1"<<<"BLAH!!" &&
	"$STRAP" rm cred1 &&
	[[ ! -e $STRAP_DIR/cred1.sh.yml ]]
'

test_expect_success 'Test "rm" command with spaces' '
	"$STRAP" insert -e "hello i have spaces"<<<"BLAH!!" &&
	[[ -e $STRAP_DIR/"hello i have spaces".sh.yml ]] &&
	"$STRAP" rm "hello i have spaces" &&
	[[ ! -e $STRAP_DIR/"hello i have spaces".sh.yml ]]
'

test_expect_success 'Test "rm" of non-existent buckle' '
	test_must_fail "$STRAP" rm does-not-exist
'

test_expect_success 'Test cannot "rm" required buckle config.sh.yml' '
  test_must_fail "$STRAP" rm config
'

test_done
