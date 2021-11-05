#!/bin/bash
#
# Run this script from the directory where your git repositories will reside.
#

set -e

touch ~/.zshrc

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

# Generate SSH key
if [ -f ~/.ssh/id_rsa ]; then
    echo "SSH key already exists. Continuing . . . "
else
  echo "Generating SSH key"
  ssh-keygen -t rsa -b 4096 -C `whoami` -N ''
fi

# Upload key to github
echo "Uploading SSH key to github"
gh auth login -w 
gh ssh-key add ~/.ssh/id_rsa.pub -t 'default'

# clone bootstrap repo
echo "Downloading bootstrap repo from Github"
git clone git@github.com:notarize/bootstrap.git

echo "Initial Setup Complete. Next run bootstrap/bin/dev_setup.sh"



