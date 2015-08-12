#!/usr/bin/env bash

test_description='Test buckle type: rbenv'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Buckle type "rbenv" confirms existence of rbenv tool' '
  "$STRAP" init &&
  "$STRAP" insert -fm "config"<<<"straps:
  base: echo" &&
  "$STRAP" insert -e "base/rbenv"<<<"type: rbenv" &&
  export STRAP_MOCK_BUCKLES="positive" &&
  "$STRAP" &&
  unset STRAP_MOCK_BUCKLES
'

test_expect_success 'Buckle type "pass" attempts to automatically install pass tool' '
  export STRAP_MOCK_BUCKLES="negative" &&
  export STRAP_MOCK_GIT="positive" &&
  ! "$STRAP" &&
  unset STRAP_MOCK_BUCKLES
  unset STRAP_MOCK_GIT
'

# TODO: test configuring a new rbenv
# TODO: test updating an existing rbenv

test_done
