#!/bin/bash

echo 'Please enter you git username:'
read GITHUB_USERNAME

ODOO_VERSION="10.0"
ODOO_NAME="odoo10"
ADDONS_PATH="addons"
ODOO_SERVER_DIR="/opt/odoo/$ODOO_NAME"
ODOO_ADDONS_DIR="$ODOO_SERVER_DIR/$ADDONS_PATH"

#------------------------------------------------------------------------------
# Clone PERSO addons
#------------------------------------------------------------------------------
sudo mkdir -p ${ODOO_ADDONS_DIR}/oca_addons
cp "perso_mrconfig" "${ODOO_ADDONS_DIR}/.mrconfig"
echo "${ODOO_ADDONS_DIR}/.mrconfig" >> ~/.mrtrust
cd ${ODOO_ADDONS_DIR} || exit
mr update
# the following command executes pip install in all subfolders of oca_addons
# find . -name 'requirements.txt' -exec pip install -r {} --user \;

# Add paid-addons - can't se SSH if we have not write access to the repo
# A prompt will ask for github username and password
git clone https://github.com/CompassionCH/paid-addons.git
