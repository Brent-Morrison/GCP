#!/bin/bash

# Copy requirements file
curl https://raw.githubusercontent.com/Brent-Morrison/GCP/master/requirements.txt --output /home/brent/requirements.txt

# Install pip and invoke to install requirements
curl https://bootstrap.pypa.io/get-pip.py --output /usr/bin/get-pip.py
python3 /usr/bin/get-pip.py
python3 -m pip install -r /home/brent/requirements.txt

# Use venv
apt install python3.8-venv


# Copy python script & run
curl https://raw.githubusercontent.com/Brent-Morrison/GCP/master/docker_test1/main.py --output /home/brent/main.py
python3 /home/brent/main.py