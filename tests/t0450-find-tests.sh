#!/usr/bin/env bash

test_description='Find check'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Make sure find resolves correct files' '
  "$STRAP" init &&
  "$STRAP" insert -e Something/neat <<<"hello" &&
  "$STRAP" insert -e Anotherthing/okay <<<"hello" &&
  "$STRAP" insert -e Fish <<<"hello" &&
  "$STRAP" insert -e Fishthings <<<"hello" &&
  "$STRAP" insert -e Fishies/stuff <<<"hello" &&
  "$STRAP" insert -e Fishies/otherstuff <<<"hello" &&
  "$STRAP" find fish
'

test_done
