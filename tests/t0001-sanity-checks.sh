#!/usr/bin/env bash

test_description='Sanity checks'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Make sure we can run strap' '
    "$STRAP" --help | grep "strap: one command to start your day"
'

test_expect_success 'Make sure we can initialize our test store' '
    "$STRAP" init &&
    [[ -e "$STRAP_DIR/config.sh.yml" ]]
'

test_done
