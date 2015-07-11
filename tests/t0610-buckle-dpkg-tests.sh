#!/usr/bin/env bash

test_description='Test buckle type: dpkg'
cd "$(dirname "$0")"
. ./setup.sh

# TODO: smoke test for implementing a dpkg buckle
# TODO: test that buckle passes quietly if package is installed
# TODO: test that buckle installs package if not currently listed as "installed" in dpkg -s

test_done
