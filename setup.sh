#!/bin/bash
sudo apt update -y && sudo apt upgrade -y

# install docker 
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $(whoami)


# Python & Pip
sudo apt install -y python3-pip
sudo pip3 install pipenv 

mkdir -p feature
mkdir -p input
mkdir -p external
mkdir -p data
mkdir -p pickle
mkdir -p log
mkdir -p predict
