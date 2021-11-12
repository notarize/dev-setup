#!/bin/bash

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

# Install Brew
if ! command -v brew &> /dev/null
then
  echo "Installing Brew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Brew is already installed. Continuing . . ."
fi

# Install tools through Brew
if ! command -v git &> /dev/null
then
  echo "Installing Git"
  brew install git
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

# Docker
if [[ ! -d "/Applications/Docker.app" ]]; then
  echo "Installing Docker"
  brew install homebrew/cask/docker
  # Avoid asking the user if it's ok to run Docker.app
  xattr -dr com.apple.quarantine /Applications/Docker.app
  open --background /Applications/Docker.app
else
  echo "Docker is already installed. Continuing . . ."
fi

# Misc stuff
echo "Installing miscellaneous other programs"
brew install circleci gh jq slack

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
  ssh-keygen -t rsa -b 4096 -C "$current_usermail" -N '' -f ~/.ssh/id_rsa
  echo "Host *" > ~/.ssh/config
  echo " AddKeysToAgent yes" >> ~/.ssh/config
  echo " UseKeychain yes" >> ~/.ssh/config
  echo " IdentityFile ~/.ssh/id_rsa" >> ~/.ssh/config
fi

ssh-add --apple-use-keychain ~/.ssh/id_rsa

# Upload ssh key to github
# TODO, add some instruction to do this manually if stuck on password prompt in browser
echo "Authenticate into Github and upload SSH key into account."
# TODO Force sign-in to github with Okta URL
gh config set -h github.com git_protocol ssh
gh auth login -h github.com -s admin:public_key
gh ssh-key add ~/.ssh/id_rsa.pub -t `id -un`

# clone bootstrap repo
echo "Downloading bootstrap repo from Github"
git clone git@github.com:notarize/bootstrap.git ~/dev/notarize/bootstrap

read -n 1 -s -r -p "Initial Setup Complete. Next we will run bootstrap/bin/dev_setup.sh. Press any key to continue."

cd ~/dev/notarize/bootstrap
./bin/dev_setup.sh
