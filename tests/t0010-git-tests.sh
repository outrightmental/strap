#!/usr/bin/env bash

test_description='Test git wrapper'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test standard "strap init" command throws no git errors' '
  results="$("$STRAP" init)" &&
  grep -q "Strap initialized" <<<"$results" &&
  ! grep -q "fatal" <<<"$results"
'

# See: https://github.com/outrightmental/strap/issues/2
#      ^ "Git breakage due to inconsistent use internal vs. buckles."

# TODO: smoke test existence of git wrapper function
# TODO: smoke test that internal `strap git ...` commands are actually working in $HOME/.strap/.git
# test_expect_success 'Test "git init" command' '
#   "$STRAP" init &&
#   "$STRAP" git init
# '


test_done
