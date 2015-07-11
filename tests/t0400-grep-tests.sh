#!/usr/bin/env bash

test_description='Grep check'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Make sure grep prints normal lines' '
	"$STRAP" init &&
	"$STRAP" insert -e blah1 <<<"hello" &&
	"$STRAP" insert -e blah2 <<<"my name is" &&
	"$STRAP" insert -e folder/blah3 <<<"I hate computers" &&
	"$STRAP" insert -e blah4 <<<"me too!" &&
	"$STRAP" insert -e folder/where/blah5 <<<"They are hell" &&
	results="$("$STRAP" grep hell)" &&
	[[ $(wc -l <<<"$results") -eq 4 ]] &&
	grep -q blah5 <<<"$results" &&
	grep -q blah1 <<<"$results" &&
	grep -q "They are" <<<"$results"
'

test_done
