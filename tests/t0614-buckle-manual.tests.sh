#!/usr/bin/env bash

test_description='Test buckle type: manual'
cd "$(dirname "$0")"
. ./setup.sh

# https://github.com/outrightmental/strap/issues/18
test_expect_success 'Can strap buckle of type "manual"' '
  "$STRAP" init &&
  "$STRAP" insert -m "config"<<<"straps:
  base: echo" &&
  "$STRAP" insert -m "base/mongo"<<<"type: manual
name: mongo
note: Installation instructions: http://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/#install-mongodb
ensure: true" &&
  "$STRAP"
'

# https://github.com/outrightmental/strap/issues/18
test_expect_success 'Buckle of type "manual" stops if condition is not ensured' '
  "$STRAP" insert -fm "base/mongo"<<<"type: manual
name: mongo
note: Installation instructions: http://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/#install-mongodb
ensure: false" &&
  ! "$STRAP"
'

test_done
