#!/usr/bin/env bash

test_description='Test buckle type: rbenv'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test buckles of type "rbenv"' '
  "$STRAP" init &&
  "$STRAP" insert -fm "config"<<<"straps:\n  base: echo" &&
  "$STRAP" insert -e "base/rbenv"<<<"type: rbenv" &&
  "$STRAP"
'

# TODO: test configuring a new rbenv
# TODO: test updating an existing rbenv

test_done
