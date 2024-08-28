#!/bin/bash

sudo apt update -y 
sudo apt install nginx -y
sudo systemctl enabel nginx
sudo systemctl start ngginx
