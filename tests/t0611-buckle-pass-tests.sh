#!/usr/bin/env bash

test_description='Test buckle type: pass'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test buckles of type "pass"' '
  "$STRAP" init &&
  "$STRAP" insert -fm "config"<<<"straps:\n  base: echo" &&
  "$STRAP" insert -e "base/passwordstore"<<<"type: pass" &&
  "$STRAP"
'

# TODO: test configuring a new pass
# TODO: test updating an existing pass

test_done
