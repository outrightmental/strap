#!/usr/bin/env bash

test_description='Test edit'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test "edit" command' '
	"$STRAP" init &&
	"$STRAP" insert -e "person1"<<<"BLAH!!" &&
	export FAKE_EDITOR_STRAP="big fat fake buckle" &&
	export PATH="$TEST_HOME:$PATH"
	export EDITOR="fake-editor-change-buckle.sh" &&
	"$STRAP" edit person1 &&
	[[ $("$STRAP" show person1) == "$FAKE_EDITOR_STRAP" ]]
'

test_done
