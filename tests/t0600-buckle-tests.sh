#!/usr/bin/env bash

test_description='Test buckle prototype'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test "strap" command' '
  "$STRAP" init &&
  "$STRAP"
'

test_done
