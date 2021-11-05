#!/bin/bash
#
# Run this script from the directory where your git repositories will reside.
#

set -e

touch ~/.zshrc

# Verify preliminary requirements
while true; do
    echo "Preliminary Requirements:"
    echo "Have you successfully authenticated into ALL of the following from your Okta dashboard:"
    read -p "Github, Heroku, Docker Hub, AWS Single Sign-On? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) echo "Please authenticate into each of these first and then try again."; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# get email address
echo "Enter your work email address: "
read current_useremail

# Install XCode command line  tools
if ! command -v xcodebuild &> /dev/null
then
  echo "Installing Xcode Cli Tools"
  sudo xcode-select --install
  read -n 1 -s -r -p "Follow the dialogues to install xcode utilites. Once completed press any key to continue."
else
  echo "Xcode Cli Tools is already installed. Continuing . . ."
fi

# Install Brew
if ! command -v brew &> /dev/null
then
  echo "Installing Brew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  echo "Brew is already installed. Continuing . . ."
fi

# Install tools through Brew
if ! command -v git &> /dev/null
then
  echo "Installing Git"
  brew install git jq gh
  git config --global user.name "`id -F`" 
  git config --global user.email "$current_useremail"
else
  echo "Git is already installed. Continuing . . ."
fi  

# Install heroku
if ! command -v heroku &> /dev/null
then
  echo "Installing Heroku"
  brew tap heroku/brew && brew install heroku
else
  echo "Heroku is already installed. Continuing . . ."
fi  
  
# install nvm
if ! command -v node &> /dev/null
then
  echo "Installing NVM"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
 else
  echo "NVM is already installed. Continuing . . ."
fi   

# install docker
if ! command -v docker &> /dev/null
then
  echo "Installing Docker"
  open "https://desktop.docker.com/mac/main/amd64/Docker.dmg?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-mac-amd64"
  read -n 1 -s -r -p "Install the Docker dmg once download completes. Press any key to continue once installation is complete."
 else
  echo "Docker is already installed. Continuing . . ."
fi  

# Generate SSH key
if [ -f ~/.ssh/id_rsa ]; then
    echo "SSH key already exists. Continuing . . . "
else
  echo "Generating SSH key"
  ssh-keygen -t rsa -b 4096 -C "$current_usermail" -N ''
  echo "Host *" > ~/.ssh/config
  echo " AddKeysToAgent yes" >> ~/.ssh/config
  echo " UseKeychain yes" >> ~/.ssh/config
  echo " IdentityFile ~/.ssh/id_rsa" >> ~/.ssh/config

ssh-add -K ~/.ssh/id_rsa
fi

# Upload ssh key to github
pbcopy < ~/.ssh/id_rsa.pub
echo "Your SSH key is copied to clipboard; about to open github page with key installation instructions, ready?"
read
open https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/
echo "Now authorize your new ssh key for SSO, about to open github settings page, CLICK on SSO there, ready?"
read
open https://github.com/settings/keys
read -n 1 -s -r -p "Press any key to continue once key authorization is complete."

# clone bootstrap repo
echo "Downloading bootstrap repo from Github"
git clone git@github.com:notarize/bootstrap.git

echo "Initial Setup Complete. Next run bootstrap/bin/dev_setup.sh"



