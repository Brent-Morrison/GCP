#!/bin/bash

# Viewing the output of a Linux startup script
# sudo journalctl -u google-startup-scripts.service

# Copy requirements file
curl https://raw.githubusercontent.com/Brent-Morrison/GCP/master/requirements.txt --output /home/brent/requirements.txt


# Install venv
# https://stackoverflow.com/questions/39539110/pyvenv-not-working-because-ensurepip-is-not-available
# https://www.youtube.com/watch?v=Cs3yhmzie2U
apt update
apt upgrade
apt install python3.8-venv


# Install pip
curl https://bootstrap.pypa.io/get-pip.py --output /usr/bin/get-pip.py
python3 /usr/bin/get-pip.py


# Create virtual environment, activate & install requirements
python3 -m venv /home/brent/env
source /home/brent/env/bin/activate
# Grant read, write & execute permissions to all users recursively for all files and directories
sudo chmod -R a+rwx /home/brent/env
python3 -m pip install -r /home/brent/requirements.txt


# Copy python script & run
curl https://raw.githubusercontent.com/Brent-Morrison/GCP/master/docker_test1/main.py --output /home/brent/main.py
python3 /home/brent/main.py