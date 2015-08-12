#!/usr/bin/env bash

test_description='Test buckle type: repo'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Can strap buckle of type "repo"' '
  "$STRAP" init &&
  "$STRAP" insert -m "config"<<<"straps:
  gh: ping -c1 github.com" &&
  "$STRAP" insert -m "gh/strap"<<<"type: repo
vcs: git
url: git@github.com:outrightmental/strap.git
path: \$HOME/OpenSource/strap" &&
  export STRAP_MOCK_GIT="positive" &&
  "$STRAP" &&
  unset STRAP_MOCK_GIT
'

# TODO: test configuring a new rpo
# TODO: test updating an existing repo
# TODO: some kind of mock git repo harness (update: we now have `export STRAP_MOCK_GIT="positive"` -- but a spy would be nice too!)
# TODO: test that this does not overwrite an existing repo - a bug that just overwrites all the repos instead of testing them!

test_done
