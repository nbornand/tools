#!/bin/bash

# This script install Odoo, Pycharm and the OCA addons we do not modify in /opt/

ODOO_VERSION="10.0"
ODOO_NAME="odoo10"
ADDONS_PATH="addons"
ODOO_SERVER_DIR="/opt/server/$ODOO_NAME"
ODOO_ADDONS_DIR="$ODOO_SERVER_DIR/$ADDONS_PATH"

# Add Compassion modified addons in wait of upstream merge
sudo mkdir ${ODOO_ADDONS_DIR}/hr
cd ${ODOO_ADDONS_DIR}/hr || exit
git init
git remote add compassion https://github.com/CompassionCH/hr
git pull compassion
git checkout hr-extra-hours

sudo mkdir ${ODOO_ADDONS_DIR}/web
cd ${ODOO_ADDONS_DIR}/web || exit
git init
git remote add compassion https://github.com/CompassionCH/web
git pull compassion
git checkout 10.0-widget-collapse-html

# Add paid-addons
sudo mkdir ${ODOO_ADDONS_DIR}/paid_addons
cd ${ODOO_ADDONS_DIR}/paid_addons || exit
git clone git@github.com:CompassionCH/paid-addons.git

