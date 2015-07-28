#!/usr/bin/env bash

test_description='Test buckle type: repo'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Can strap buckle of type "repo"' '
  "$STRAP" init &&
  "$STRAP" insert -fm "config"<<<"straps:\n  gh: ping -c1 github.com" &&
  "$STRAP" insert -e "gh/strap"<<<"type: repo\nvcs: git\nurl: git@github.com/outrightmental/strap.git\npath: \$HOME/OpenSource/strap" &&
  "$STRAP"
'

# TODO: test configuring a new rpo
# TODO: test updating an existing repo
# TODO: some kind of mock git repo harness
# TODO: test that this does not overwrite an existing repo - a bug that just overwrites all the repos instead of testing them!

test_done
