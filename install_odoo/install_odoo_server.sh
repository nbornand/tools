#!/bin/bash
###############################################################################
# Script for installing Odoo on Ubuntu Server 18.04
# Author: Eicher Stéphane
# Run as sudo
###############################################################################

# todo: ask the version
ODOO_VERSION="11.0"
SOURCE_PATH="source"
ADDONS_PATH="addons"
ODOO_NAME="odoo11"
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
sudo apt install -y git python3 python3-pip postgresql wget nodejs npm myrepos
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

#------------------------------------------------------------------------------
# Install Odoo Dependencies
#------------------------------------------------------------------------------
sudo apt install -y python3-dev libxml2-dev libxslt1-dev libevent-dev libsasl2-dev libssl1.0-dev libldap2-dev libpq-dev libpng-dev libjpeg-dev

#------------------------------------------------------------------------------
# Install Python Package
#----------------------------------------------------------------------------d--
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
cp "mrconfig" "${ODOO_ADDONS_DIR}/oca_addons/.mrconfig"
echo "${ODOO_ADDONS_DIR}/oca_addons/.mrconfig" >> ~/.mrtrust
cd ${ODOO_ADDONS_DIR}/oca_addons || exit
mr update

#------------------------------------------------------------------------------
# Install Odoo Python Dependency
#------------------------------------------------------------------------------
echo -e "\n==== Install Odoo Requirements===="
pip3 install -r ${ODOO_SOURCE_DIR}/requirements.txt --user

#------------------------------------------------------------------------------
# Apply group and right on the folder
#------------------------------------------------------------------------------
sudo chgrp -R odoo ${ODOO_SERVER_DIR}
sudo chmod g+w -R ${ODOO_SERVER_DIR}
