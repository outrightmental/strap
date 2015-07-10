# This file should be sourced by all test-scripts
#
# This scripts sets the following:
#   $STRAP	Full path to strap script to test
#   $TEST_HOME	This folder


# We must be called from tests/ !!
TEST_HOME="$(pwd)"

. ./sharness.sh

export STRAP_DIR="$SHARNESS_TRASH_DIRECTORY/test-store/"
rm -rf "$STRAP_DIR"
mkdir -p "$STRAP_DIR"
if [[ ! -d $STRAP_DIR ]]; then
	echo "Could not create $STRAP_DIR"
	exit 1
fi

export GIT_DIR="$STRAP_DIR/.git"
export GIT_WORK_TREE="$STRAP_DIR"
git config --global user.email "Strap-Automated-Testing-Suite@outright.io"
git config --global user.name "Strap Automated Testing Suite"


STRAP="$TEST_HOME/../src/strap.sh"
if [[ ! -e $STRAP ]]; then
	echo "Could not find strap.sh"
	exit 1
fi