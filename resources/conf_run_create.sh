#!/bin/bash

cd /var/www/linguard
set -e
source /var/www/linguard/venv/bin/activate
python3 conf_create.py
