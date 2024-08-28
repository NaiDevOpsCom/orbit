#!/bin/bash

sudo apt update -y 
sudo apt install git -y

# sudo apt install nginx -y
# sudo systemctl enabel nginx
# sudo systemctl start nginx

sudo apt install -y curl software-properties-common

# Add NodeSource repository for Node.js v22
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -

sudo apt install -y nodejs


echo "starting github app cloning....."
git clone https://github.com/alvo254/orbit /root/orbit

echo "Waiting for 30 seconds to ensure the repository is fully cloned..."
sleep 90

# Check if the directory exists
if [ -d "/root/orbit/" ]; then
  cd /root/orbit/frontend
  
  # Install the dependencies
  npm install
  
  # Build the React app for production
  npm run build
  
  # Install a web server (e.g., serve) to serve the React app
  sudo npm install -g serve
  
  # Start the React app using 'serve'
  nohup serve -s build -l 80 &
else
  echo "Directory /root/orbit/frontend does not exist."
fi