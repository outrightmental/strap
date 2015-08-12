#!/usr/bin/env bash

test_description='Test insert'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test "insert" command' '
	"$STRAP" init &&
	echo "Hello world" | "$STRAP" insert -e person1 &&
	[[ $("$STRAP" show person1) == "Hello world" ]]
'

# TODO: test insert multiline

test_done
