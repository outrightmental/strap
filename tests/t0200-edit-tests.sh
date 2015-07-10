#!/usr/bin/env bash

test_description='Test edit'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test "edit" command' '
	"$STRAP" init &&
	"$STRAP" insert -e "cred1"<<<"BLAH!!" &&
	export FAKE_EDITOR_STRAP="big fat fake buckle" &&
	export PATH="$TEST_HOME:$PATH"
	export EDITOR="fake-editor-change-buckle.sh" &&
	"$STRAP" edit cred1 &&
	[[ $("$STRAP" show cred1) == "$FAKE_EDITOR_STRAP" ]]
'

test_done
