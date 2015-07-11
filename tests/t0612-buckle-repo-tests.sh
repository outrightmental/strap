#!/usr/bin/env bash

test_description='Test buckle type: repo'
cd "$(dirname "$0")"
. ./setup.sh

# TODO: test configuring a new rpo
# TODO: test updating an existing repo

# type: repo
# vcs: git
# url: git@github.com:charneykaye/pass.git
# clone_as: .password-store
# parent_path: $HOME

test_done
