#!/usr/bin/env bash

test_description='Test show'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test "show" command' '
	"$STRAP" init &&
	"$STRAP" insert -e "cred1"<<<"BLAH!!" &&
	"$STRAP" show cred1
'

test_expect_success 'Test "show" command with spaces' '
	"$STRAP" insert -e "I am a cred with lots of spaces"<<<"BLAH!!" &&
	[[ $("$STRAP" show "I am a cred with lots of spaces") == "BLAH!!" ]]
'

test_expect_success 'Test "show" of nonexistant buckle' '
	test_must_fail "$STRAP" show cred2
'

test_done
