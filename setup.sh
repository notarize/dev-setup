#!/bin/bash

set -e

# Install XCode command line  tools
xcode-select --install

# Install Brew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install tools through Brew
brew install git nvm jq gh heroku

# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Generate SSH key
ssh-keygen -t rsa -b 4096

# Upload key to github
gh auth login -w 
gh ssh-key add ~/.ssh/id_rsa.pub -t 'default'

# authenticate with heroku
HEROKU_ORGANIZATION=notarize heroku login --sso
heroku auth:token
heroku config -a notarize-api-next
