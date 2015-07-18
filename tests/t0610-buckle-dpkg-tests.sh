#!/usr/bin/env bash

test_description='Test buckle type: dpkg'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test buckles of type "dpkg"' '
  "$STRAP" init &&
  "$STRAP" insert -fm "config"<<<"straps:\n  ubuntu: [[ \"\$OSTYPE\" == \"linux\"* ]] && apt-get -v" &&
  "$STRAP" insert -e "ubuntu/passwordstore"<<<"type: dpkg\nname: git" &&
  "$STRAP"
'

# TODO: test that buckle passes quietly if package is installed
# TODO: test that buckle installs package if not currently listed as "installed" in dpkg -s

test_done
