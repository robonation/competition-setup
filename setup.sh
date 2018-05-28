#!/bin/sh

setup_ubuntu() {
  ## Update Ubuntu
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
  sudo apt-get -y update #fails the first time on brand new ubuntu install, so do it twice!
  sudo apt-get -y update

  ## Install key apps
  sudo apt-get -y install vim
  sudo apt-get -y install google-chrome-stable
  sudo apt-get -y install git

  ## Install Chrome in Launcher
  gsettings set com.canonical.Unity.Launcher favorites "['application://org.gnome.Nautilus.desktop', 'application://google-chrome.desktop', 'application://firefox.desktop', 'application://org.gnome.Software.desktop', 'application://unity-control-center.desktop', 'unity://running-apps', 'application://gnome-terminal.desktop', 'unity://expo-icon', 'unity://devices']"
}


###
# Main script
###
DISTRO="$(uname -v)"

case $DISTRO in
  *"Ubuntu"*) setup_ubuntu;;
  *) echo "This script does not support '$DISTRO'";;
esac
exit 0
