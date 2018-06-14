#!/bin/bash

COMPETITION="RoboBoat"

HERE=$(cd -- $(dirname ${BASH_SOURCE[0]}) > /dev/null && pwd)
cd -- "$HERE"

###
# Setup this server if it is running Ubuntu
###
setup_ubuntu() {
  ## Install new apt-get repo
  sudo add-apt-repository -y ppa:webupd8team/java

  ## Update Ubuntu
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
  sudo apt-get -y update #fails the first time on brand new ubuntu install, so do it twice!
  sudo apt-get -y update

  ## Install key apps
  sudo apt-get -y install vim
  sudo apt-get -y install google-chrome-stable
  sudo apt-get -y install curl

  ## Setup SSH
  sudo apt-get -y install openssh-server

  ## Setup build tools
  sudo apt-get -y install git
  sudo apt-get -y install maven
  sudo apt-get install -y python-software-properties debconf-utils
  echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
  sudo apt-get -y install oracle-java8-installer    #apt-get is unable to find java9 these days... revisit later

  ## Install Chrome in Launcher
  gsettings set com.canonical.Unity.Launcher favorites "['application://org.gnome.Nautilus.desktop', 'application://google-chrome.desktop', 'application://firefox.desktop', 'application://org.gnome.Software.desktop', 'application://unity-control-center.desktop', 'unity://running-apps', 'application://gnome-terminal.desktop', 'unity://expo-icon', 'unity://devices']" || echo "No X11 available while running this script"

  ## Make this script run as a service
  sudo cp competition-setup /etc/init.d/competition-setup
  sudo update-rc.d competition-setup defaults
}


###
# Check when was the last time this script was ran and updates it is >24h
# Return 0 if up-to-date or successfully update; 1 if no network connection
##
auto_update_script() {
  if ! ping -q -c 1 -W 1 google.com >/dev/null; then
    echo "===> Internet access not available. Skip auto-update"
    return 1
  fi
  file="last_setup.time"
  LASTTIME=0
  if [ -s $file ]; then
    LASTTIME=`cat $file`
  fi

  NOW=`date +%s`  
  # Update last_setup.time to now
  echo "$NOW" > last_setup.time

  let YESTERDAY="$NOW - (3600 * 24)"
  if [ "$YESTERDAY" -gt "$LASTTIME" ]; then
    echo "  Updating this script since last pull is >24h"
    git pull
    printf "  Restarting setup script \n\n"
    exec $(readlink -f "$0")
  fi
  return 0
}

###
# RoboBoat setup
###
setup_roboboat() {
  file="/home/robonation/roboboat"
  if [ ! -d $file ]; then
    git clone https://github.com/robonation/roboboat-server.git "$file/roboboat-server/"
  fi
 
  sudo mkdir -p /etc/roboboat
  sudo chown robonation:robonation /etc/roboboat
  sudo cp $file/roboboat-server/roboboat-server /etc/init.d/roboboat-server
  sudo update-rc.d roboboat-server defaults
}

###
# RobotX setup
###
setup_robotx() {
  echo "RobotX not yet implemented"
}

###
#
###
check_git_setup() {
  file="/home/robonation/.git-credentials"
  if [ ! -f $file ]; then
    printf "*** Unable to setup competition software as git-setup is not complete on this server. Please run 'git config --global credential.helper store && git clone https://github.com/robonation/roboboat-server /tmp/roboboat-server && rm -rf /tmp/roboboat-server'\n\n"
    exit 1
  fi
}

###
# Main script
###
printf "*** RoboNation's server setup script \n  (note: robonation password is on the back of the server)\n"


## 1. Check if script is up-to-date
auto_update_script;
DISTRO="$(uname -v)"

case $DISTRO in
  *"Ubuntu"*) setup_ubuntu;;
  *) echo "This script does not support '$DISTRO'";;
esac

check_git_setup;
case $COMPETITION in
  *"RoboBoat"*) setup_roboboat;;
  *"RobotX"*) setup_robotx;;
  *) echo "This script does not support competition '$COMPETITION'";;
esac

printf "*** RoboNation's server setup script successfull completed its run ***\n"
exit 0
