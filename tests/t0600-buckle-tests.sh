#!/usr/bin/env bash

test_description='Test buckle prototype'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test "strap" command' '
  "$STRAP" init &&
  "$STRAP" insert -fm "config"<<<"straps:\n  base: echo" &&
  "$STRAP" insert -e "base/passwordstore"<<<"type: pass" &&
  "$STRAP"
'

test_done
