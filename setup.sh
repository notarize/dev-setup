#!/bin/bash

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
echo "Installing Brew"
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install tools through Brew
echo "Installing Git"
brew install git jq gh

# Install heroku
echo "Installing Heroku"
brew tap heroku/brew && brew install heroku

# install nvm
echo "Installing NVM"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Generate SSH key
echo "Generating SSH key"
ssh-keygen -t rsa -b 4096 -C `whoami` -N ''

# Upload key to github
gh auth login -w 
gh ssh-key add ~/.ssh/id_rsa.pub -t 'default'

# authenticate with heroku
HEROKU_ORGANIZATION=notarize heroku login --sso
heroku auth:token
heroku config -a notarize-api-next
