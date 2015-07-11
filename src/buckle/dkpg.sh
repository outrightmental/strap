# Copyright (C) 2015 Outright Mental Inc. <hiya@outright.io>. All Rights Reserved.
# This file is licensed under the GPLv2+. Please see COPYING for more information.

buckle_dpkg() {
  eval $(parse_yaml $1 "buckledata_") || error "Could not open $BOLD$2$NORMAL"
  if [ -z $buckledata_name ]; then error "$BOLD$2$NORMAL must have a ${BOLD}name:$NORMAL"; fi
  local tmpfile=$(mktemp)
  local dpkg_name=$buckledata_name
  dpkg -s $dpkg_name > $tmpfile
  local dpkg_version=$(cat $tmpfile | grep -i ^version | sed -e 's/version: \(.*\)/\1/gi' )
  if grep -i -q '^status.*installed' $tmpfile; then
    printf "$NOBULLET $BLUE$dpkg_name$NORMAL $dpkg_version\n"
  else
    printf "$NOBULLET $GOLD$dpkg_name$NORMAL\n"
    sudo apt-get install $dpkg_name
  fi
}
