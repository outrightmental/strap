#!/usr/bin/env bash

test_description='Test insert'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test "insert" command' '
	"$STRAP" init &&
	echo "Hello world" | "$STRAP" insert -e cred1 &&
	[[ $("$STRAP" show cred1) == "Hello world" ]]
'

test_done
