#!/bin/bash

# This script is used to start a Python environment with the necessary dependencies for the TGI server.

set -e

if [ -f "requirements.txt" ]; then
    echo "requirements.txt found, proceeding with setup."
else
    echo "requirements.txt not found, please ensure you are in the correct directory."
    exit 1
fi

python -m venv .venv
bash -c "source .venv/bin/activate"
pip install -r requirements.txt
