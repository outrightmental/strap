#!/usr/bin/env bash

test_description='Test git wrapper'
cd "$(dirname "$0")"
. ./setup.sh

# See: https://github.com/outrightmental/strap/issues/2
#      ^ "Git breakage due to inconsistent use internal vs. buckles."

# TODO: smoke test existence of git wrapper function


test_done
