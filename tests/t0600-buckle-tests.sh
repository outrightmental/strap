#!/usr/bin/env bash

test_description='Test buckle prototype'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test "strap" command' '
  "$STRAP" init &&
  "$STRAP"
'

# https://github.com/outrightmental/strap/issues/12
# TODO: actually test that only group "one" is run below, and NOT group "two"
test_expect_success 'Strap xx can specify group' '
  "$STRAP" insert -m "config"<<<"straps:
  one: echo
  two: echo" &&
  "$STRAP" insert -m "one/apples"<<<"type: manual
name: apples
note: Install your apples
ensure: echo" &&
  "$STRAP" insert -m "two/bananas"<<<"type: manual
name: bananas
note: Install your bananas
ensure: echo" &&
  "$STRAP" one
'

test_done
