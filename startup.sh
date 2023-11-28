#!/bin/bash

# Viewing the output of a Linux startup script
# sudo journalctl -u google-startup-scripts.service

# Copy requirements file
curl https://raw.githubusercontent.com/Brent-Morrison/GCP/master/requirements.txt --output /home/brent/requirements.txt


# Use venv
# https://stackoverflow.com/questions/39539110/pyvenv-not-working-because-ensurepip-is-not-available
#apt update
#apt upgrade
#apt install python3-venv
#python3 -m venv /home/brent/env
#source /home/brent/env/bin/activate


# Install pip and invoke to install requirements
curl https://bootstrap.pypa.io/get-pip.py --output /usr/bin/get-pip.py
python3 /usr/bin/get-pip.py
python3 -m pip install -r /home/brent/requirements.txt


# Copy python script & run
curl https://raw.githubusercontent.com/Brent-Morrison/GCP/master/docker_test1/main.py --output /home/brent/main.py
python3 /home/brent/main.py