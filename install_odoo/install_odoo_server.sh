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
else
    #------------------------------------------------------------------------------
    # Create folder structure for Odoo
    #------------------------------------------------------------------------------
    echo -e "\n---- Create Log directory ----"
    sudo mkdir -p ${ODOO_LOG_DIR}    
fi

#------------------------------------------------------------------------------
# Create group odoo
#------------------------------------------------------------------------------
sudo getent group odoo || sudo groupadd odoo
sudo usermod -a -G odoo "$USER"

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
sudo apt install -y python-dev libxml2-dev libxslt1.1 libxslt1-dev libevent-dev libsasl2-dev libssl-dev libssl1.1 libldap2-dev libpq-dev libpng-dev libjpeg-dev python-ldap || exit

#------------------------------------------------------------------------------
# Install Python Package
#------------------------------------------------------------------------------
echo -e "\n---- Install tool packages ----"
sudo apt install -y git gdebi-core libpq-dev || exit

#------------------------------------------------------------------------------
# Get repo Odoo
#------------------------------------------------------------------------------
if [[ ! -d ${ODOO_SOURCE_DIR} ]]
then
    echo -e "\n==== Get Odoo repo ===="
    sudo git clone --depth 1 --branch ${ODOO_VERSION} https://www.github.com/odoo/odoo ${ODOO_SOURCE_DIR}
else
    echo -e "\n==== Skip cloning Odoo repo ===="
fi

#------------------------------------------------------------------------------
# Clone OCA addons
#------------------------------------------------------------------------------
if [[ ! -d ${ODOO_ADDONS_DIR} ]]
then
    sudo mkdir -p ${ODOO_ADDONS_DIR}/oca_addons
    sudo cp "oca_mrconfig" "${ODOO_ADDONS_DIR}/oca_addons/.mrconfig"
    echo "${ODOO_ADDONS_DIR}/oca_addons/.mrconfig" >> ~/.mrtrust
    cd ${ODOO_ADDONS_DIR}/oca_addons || exit
    sudo mr update

    #------------------------------------------------------------------------------
    # Clone temp addons
    #------------------------------------------------------------------------------
    sudo cp "perso_mrconfig" "${ODOO_ADDONS_DIR}/.mrconfig"
    echo "${ODOO_ADDONS_DIR}/.mrconfig" >> ~/.mrtrust
    cd ${ODOO_ADDONS_DIR} || exit
    sudo mr update
else
    echo -e "\n==== Skip cloning OCA addons repo ===="
fi

#------------------------------------------------------------------------------
# Install Odoo Python Dependency and the for OCA addons
#------------------------------------------------------------------------------
echo -e "\n==== Install Odoo Requirements===="
cd ${ODOO_ADDONS_DIR} || exit
pip install -r ${ODOO_SOURCE_DIR}/requirements.txt --user
echo -e "\n==== Install OCA addons Requirements===="
cd ${ODOO_ADDONS_DIR}/oca_addons || exit
# the following command executes pip install in all subfolders of oca_addons
find . -name 'requirements.txt' -exec pip install -r {} --user \;
pip install pyminizip firebase_admin || exit

#------------------------------------------------------------------------------
# Apply group and right on the folder
#------------------------------------------------------------------------------
sudo chgrp -R odoo ${ODOO_SERVER_DIR}
sudo chmod g+w -R ${ODOO_SERVER_DIR}
