#!/bin/bash

# Copyright 2020 dev-setup Authors.
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

set -o xtrace

set -o errexit

USER_HOME=/home/$USER

setup ()
{
	PATHS=$USER_HOME/.paths
	touch $PATHS

	echo "source $PATHS" >> $USER_HOME/.profile
}

update ()
{
	echo "updating"
	sudo apt update
	sudo apt list --upgradable
}


upgrade ()
{
	echo "upgrading"
	sudo apt upgrade -y
}

autoremove ()
{
    echo "autoremove"
    sudo apt autoremove
}

install_vscode ()
{
	echo "installing vscode"
	sudo apt install -y software-properties-common apt-transport-https wget
	wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
	update
	sudo apt install -y code
}

install_golang ()
{
	echo "setting up golang"
	wget https://dl.google.com/go/go1.15.3.linux-amd64.tar.gz
	sudo mkdir -p /usr/local/go
	sudo tar -xvf go1.15.3.linux-amd64.tar.gz -C /usr/local/go
	mkdir -p $USER_HOME/go

	rm go1.15.3.linux-amd64.tar.gz	
	
	echo 'export GOROOT=/usr/local/go' >> $PATHS
	echo 'export GOPATH=$HOME/go' >> $PATHS
	echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' >> $PATHS
}

install_node ()
{
	echo "setting up nodejs and npm"
	update
	sudo apt install -y nodejs npm
	mkdir -p $USER_HOME/.npm-global
	npm config set prefix '~/.npm-global'
	echo 'export PATH=~/.npm-global/bin:$PATH' >> $PATHS
	
}

install_kubectl ()
{
	echo "setting up kubectl"
	# Set the version of kubectl binary that will be downloaded
	KUBECTL_VERSION=v1.19.0

	# Download the binary
	curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl

	# Provide executable permissions to the binary
	chmod +x ./kubectl

	# Move kubectl to known PATH
	sudo mv ./kubectl /usr/local/bin/kubectl

	# Print the version of kubectl client
	kubectl version --client
}

install_rg ()
{
	echo "installing ripgrep"
	sudo apt install -y ripgrep
}

install_pip3 ()
{
	echo "installing pip3"
	sudo apt install -y python3-pip python3-distutils
}

install_jq_yq ()
{
	echo "installing jq"
	sudo apt install -y jq
	echo "installing yq"
	pip3 install yq
}

install_awscli ()
{
	echo "installing aws cli"
	sudo apt install -y awscli
}

install_stacer ()
{
	echo "installing stacer"
	sudo apt install -y stacer
}

install_sublime ()
{
	echo "installing sublime text"
	wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
	sudo apt-add-repository "deb https://download.sublimetext.com/ apt/stable/"

	update
	sudo apt install -y sublime-text
}

install_atom ()
{
	echo "installing atom editor"
	sudo snap install atom --classic
}

build_essentials ()
{
	echo "installing build-essential"
	sudo apt install -y build-essential
}

install_numpy ()
{
	echo "installing numpy"
	sudo apt install -y python3-numpy
}

configure_snap_store ()
{
	echo "configuring snap store"
	sudo snap install snap-store
}

install_thunderbird ()
{
	echo "thunderbird"
	sudo apt install -y thunderbird
}

install_basics ()
{
	echo "installing basic tools"
	sudo apt install -y vim wget curl gimp peek htop tmux ffmpeg python3-dev python3-venv vlc unzip 
}

install_emacs ()
{
	echo "installing emacs"
	sudo apt install -y emacs
}

git_prompt ()
{
	echo "setting up git-prompt"
	wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh > $USER_HOME/.git-prompt.sh
	cp .gitprompt_rc $USER_HOME/.gitprompt_rc
	echo 'source .gitprompt_rc' >> $USER_HOME/.bashrc
}

copy_npmrc ()
{
	echo "setting up npmrc"
	cp .npmrc $USER_HOME/.npmrc
}

copy_aliasrc ()
{
	echo "setting up aliases"
	cp .alias_rc $USER_HOME/.alias_rc
}

install_postman ()
{
	echo "Installing postman"
	sudo snap install postman
}

install_docker ()
{
	echo "Installing docker"
	sudo apt install -y apt-transport-https ca-certificates  curl gnupg-agent software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository  "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	update
	sudo apt install -y docker-ce docker-ce-cli containerd.io

	echo "Configuring docker to not use root"
	#sudo groupadd docker
	sudo usermod -aG docker $USER
}

kubectl_aliases()
{
	curl https://raw.githubusercontent.com/ahmetb/kubectl-alias/master/.kubectl_aliases >> $USER_HOME/.kubectl_aliases
}

backup_files()
{
	echo "backing up config files to $USER_HOME/.backup-configs"
	mkdir -p $USER_HOME/.backup-configs
	cp $USER_HOME/.bashrc $USER_HOME/.backup-configs/.bashrc
	cp $USER_HOME/.profile $USER_HOME/.backup-configs/.profile	
}

change_owners()
{
	sudo chown $USER:$USER .npmrc
	sudo chown $USER:$USER .paths
	sudo chown $USER:$USER .kubectl_aliases
	sudo chown $USER:$USER .git-prompt.sh
	sudo chown $USER:$USER .alias_rc
	sudo chown -R $USER:$USER .backup-configs
	sudo chown -R $USER:$USER go
	sudo chown -R $USER:$USER .npm-global
}

all()
{
	backup_files
	update
	upgrade
	build_essentials
	install_basics
	install_pip3
	install_vscode
	install_golang
	install_node
	install_docker
	install_postman
	copy_aliasrc
	copy_npmrc
	git_prompt
	configure_snap_store
	install_emacs
	install_thunderbird
	install_numpy
	install_atom
	install_sublime
	install_stacer
	install_awscli
	install_jq_yq
	install_rg
	install_kubectl
	kubectl_aliases
	#change_owners
	autoremove
}
