#!/usr/bin/env bash

test_description='Test buckle type: dpkg'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test buckles of type "dpkg"' '
  "$STRAP" init &&
  "$STRAP" insert -m "config"<<<"straps:
  ubuntu: [[ \"\$OSTYPE\" == \"linux\"* ]] && apt-get -v" &&
  "$STRAP" insert -m "ubuntu/passwordstore"<<<"type: dpkg
name: git" &&
  "$STRAP"
'

# TODO: test that buckle passes quietly if package is installed
# TODO: test that buckle installs package if not currently listed as "installed" in dpkg -s

test_done
