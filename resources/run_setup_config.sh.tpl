#!/bin/bash

cd /var/www/linguard
set -e
source /var/www/linguard/venv/bin/activate
python3 setup_config.py
