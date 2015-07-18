#!/usr/bin/env bash

test_description='Test buckle type: repo'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Can strap buckle of type "repo"' '
  "$STRAP" init &&
  "$STRAP" insert -fm "config"<<<"straps:\n  base: echo" &&
  "$STRAP" insert -e "base/rbenv"<<<"type: rbenv" &&
  "$STRAP"
'

# TODO: test configuring a new rpo
# TODO: test updating an existing repo
# TODO: some kind of mock git repo harness

# type: repo
# vcs: git
# url: git@github.com:charneykaye/pass.git
# clone_as: .password-store
# parent_path: $HOME

test_done
