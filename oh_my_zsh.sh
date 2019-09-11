#!/bin/bash
sudo apt update
sudo apt install zsh
sudo usermod -s /usr/bin/zsh $(whoami)