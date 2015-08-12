#!/usr/bin/env bash

test_description='Test buckle type: pass'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Buckle type "pass" confirms existence of pass tool' '
  "$STRAP" init &&
  "$STRAP" insert -m "config"<<<"straps:
  base: echo" &&
  "$STRAP" insert -e "base/passwordstore"<<<"type: pass" &&
  export STRAP_MOCK_BUCKLES="positive" &&
  "$STRAP" &&
  unset STRAP_MOCK_BUCKLES
'

test_expect_success 'Buckle type "pass" stops with message to manually install pass tool' '
  export STRAP_MOCK_BUCKLES="negative" &&
  ! "$STRAP" &&
  unset STRAP_MOCK_BUCKLES
'

# TODO: test configuring a new pass
# TODO: test updating an existing pass

test_done
