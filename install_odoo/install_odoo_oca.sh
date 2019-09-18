#!/bin/bash

# This script install Odoo, Pycharm and the OCA addons we do not modify in /opt/

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
INSTALL_HOME=/opt/odoo/

# Get needed tools

sudo apt-get install git
sudo apt-get install myrepos
sudo apt-get install python-pip

# Clone Odoo

mkdir ${INSTALL_HOME}
cd ${INSTALL_HOME} || exit
git clone https://github.com/odoo/odoo.git -b 10.0

# Clone OCA addons

mkdir ${INSTALL_HOME}/odoo/oca_addons

cp "$DIR/.mrconfig" "$INSTALL_HOME/odoo/oca_addons/.mrconfig"
echo "$INSTALL_HOME/odoo/oca_addons/.mrconfig" >> ~/.mrtrust
cd ${INSTALL_HOME}/odoo/oca_addons/ || exit
mr update

# Add Compassion modified addons in wait of upstream merge

cd ${INSTALL_HOME}/odoo/oca_addons/hr || exit
git remote add compassion https://github.com/CompassionCH/hr
git pull compassion
git checkout hr-extra-hours

cd ${INSTALL_HOME}/odoo/oca_addons/web || exit
git remote add compassion https://github.com/CompassionCH/web
git pull compassion
git checkout 10.0-widget-collapse-html

cd /opt/ || exit
wget https://download.jetbrains.com/python/pycharm-professional-2019.1.tar.gz
tar -xvf pycharm-professional-2019.1.tar.gz
rm pycharm-professional-2019.1.tar.gz


sudo groupadd odoo
sudo usermod -a -G odoo $USER
sudo chgrp -R odoo ${INSTALL_HOME}
