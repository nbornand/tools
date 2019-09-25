#!/bin/bash
###############################################################################
# Script for installing Odoo on Ubuntu Server 18.04 / 19.04
# Author: Eicher Stéphane
# Not run as sudo
###############################################################################

ODOO_VERSION="10.0"
SOURCE_PATH="source"
ADDONS_PATH="addons"
ODOO_NAME="odoo10"
ODOO_SERVER_DIR="/opt/odoo/$ODOO_NAME"
ODOO_SOURCE_DIR="$ODOO_SERVER_DIR/$SOURCE_PATH"
ODOO_ADDONS_DIR="$ODOO_SERVER_DIR/$ADDONS_PATH"
ODOO_LOG_DIR="/var/log/odoo/$ODOO_NAME"


#------------------------------------------------------------------------------
# Check if already installed via this script
#------------------------------------------------------------------------------
if [[ -d ${ODOO_LOG_DIR} ]]
then
    echo "This version seems to be already installed"
    exit
fi

#------------------------------------------------------------------------------
# Create group odoo
#------------------------------------------------------------------------------
sudo getent group odoo || sudo groupadd odoo
sudo usermod -a -G odoo "$USER"

#------------------------------------------------------------------------------
# Create folder structure for Odoo
#------------------------------------------------------------------------------
echo -e "\n---- Create Log directory ----"
sudo mkdir -p ${ODOO_LOG_DIR}

#------------------------------------------------------------------------------
# Update Server
#------------------------------------------------------------------------------
echo -e "\n---- Update Server ----"
sudo apt update
sudo apt upgrade -y

#------------------------------------------------------------------------------
# Install Dependencies
#------------------------------------------------------------------------------
echo -e "\n---- Install dependencies ----"
sudo apt install -y git python python-pip postgresql wget nodejs npm myrepos
sudo npm install -g less

#------------------------------------------------------------------------------
# Configure PostgreSQL Server
#------------------------------------------------------------------------------
echo -e "\n---- Creating the Odoo PostgreSQL User  ----"
sudo su - postgres -c "createuser -s $USER"

#------------------------------------------------------------------------------
# Install WKHTMLTOPDF
#------------------------------------------------------------------------------
echo -e "\n---- Install WKHTMLTOPDF and dependencies ----"
sudo apt install -y fontconfig fontconfig-config fonts-dejavu-core libfontconfig1 libfontenc1 libxrender1 x11-common xfonts-75dpi xfonts-base xfonts-encodings xfonts-utils
wget https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb
sudo dpkg -i wkhtmltox_0.12.5-1.bionic_amd64.deb
sudo apt install -f
rm wkhtmltox_0.12.5-1.bionic_amd64.deb

#------------------------------------------------------------------------------
# Install Odoo Dependencies
#------------------------------------------------------------------------------
sudo apt install -y python-dev libxml2-dev libxslt1.1 libxslt1-dev libevent-dev libsasl2-dev libssl-dev libssl1.1 libldap2-dev libpq-dev libpng-dev libjpeg-dev python-ldap pyminizip firebase_admin

#------------------------------------------------------------------------------
# Install Python Package
#------------------------------------------------------------------------------
echo -e "\n---- Install tool packages ----"
sudo apt install -y git gdebi-core libpq-dev

#------------------------------------------------------------------------------
# Get repo Odoo
#------------------------------------------------------------------------------
echo -e "\n==== Get Odoo repo ===="
sudo git clone --depth 1 --branch ${ODOO_VERSION} https://www.github.com/odoo/odoo ${ODOO_SOURCE_DIR}

#------------------------------------------------------------------------------
# Clone OCA addons
#------------------------------------------------------------------------------
sudo mkdir -p ${ODOO_ADDONS_DIR}/oca_addons
sudo cp "oca_mrconfig" "${ODOO_ADDONS_DIR}/oca_addons/.mrconfig"
echo "${ODOO_ADDONS_DIR}/oca_addons/.mrconfig" >> ~/.mrtrust
cd ${ODOO_ADDONS_DIR}/oca_addons || exit
sudo mr update
# the following command executes pip install in all subfolders of oca_addons
find . -name 'requirements.txt' -exec pip install -r {} --user \;

# Add custom remote for hr addon
cd ${ODOO_ADDONS_DIR}/oca_addons/hr || exit
sudo git remote add compassion https://github.com/CompassionCH/hr
sudo git pull compassion
sudo git checkout hr-extra-hours

# Add custom remote for web addon
cd ${ODOO_ADDONS_DIR}/oca_addons/web || exit
sudo git remote add compassion https://github.com/CompassionCH/web
sudo git pull compassion
sudo git checkout 10.0-widget-collapse-html

# Add custom remote for website addon
cd ${ODOO_ADDONS_DIR}/oca_addons/website || exit
sudo git remote add compassion https://github.com/CompassionCH/website
sudo git pull compassion
sudo git checkout 10.0

#------------------------------------------------------------------------------
# Clone temp addons
#------------------------------------------------------------------------------
cp "perso_mrconfig" "${ODOO_ADDONS_DIR}/.mrconfig"
echo "${ODOO_ADDONS_DIR}/.mrconfig" >> ~/.mrtrust
cd ${ODOO_ADDONS_DIR} || exit
mr update

#------------------------------------------------------------------------------
# Install Odoo Python Dependency
#------------------------------------------------------------------------------
echo -e "\n==== Install Odoo Requirements===="
pip install -r ${ODOO_SOURCE_DIR}/requirements.txt --user

#------------------------------------------------------------------------------
# Apply group and right on the folder
#------------------------------------------------------------------------------
sudo chgrp -R odoo ${ODOO_SERVER_DIR}
sudo chmod g+w -R ${ODOO_SERVER_DIR}
