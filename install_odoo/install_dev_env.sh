
#!/bin/bash

echo 'Please enter you git username:'
read GITHUB_USERNAME

#Odoo
ODOO_VERSION="10.0"
SERVER_NAME="odoo10"
ODOO_SERVER_PATH="odoo/$SERVER_NAME"
ODOO_DEV_HOME="$HOME/$ODOO_SERVER_PATH"
CONF_FILE_NAME="odoo"
CONF_FILE_PATH="${ODOO_DEV_HOME}/${CONF_FILE_NAME}.conf"
ADDONS_PATH="addons"
SOURCE_PATH="source"
SOURCE_DIR="/opt/${ODOO_SERVER_PATH}/${SOURCE_PATH}"
ADDONS_DIR="/opt/${ODOO_SERVER_PATH}/${ADDONS_PATH}"
SCRIPT_DIR=$PWD

#------------------------------------------------------------------------------
# Cloning the different compassion repos. You need access to private repository
# CompassionCH/paid-addons
#------------------------------------------------------------------------------
echo -e "\n---- Create addons directory ----"
sudo su "$USER" -c "mkdir -p $ODOO_DEV_HOME"

git clone https://github.com/$GITHUB_USERNAME/compassion-accounting.git --depth 1 --branch ${ODOO_VERSION} "$ODOO_DEV_HOME/compassion-accounting"
cd "$ODOO_DEV_HOME/compassion-accounting" || exit
git remote add upstream https://github.com/CompassionCH/compassion-accounting.git
git pull upstream ${ODOO_VERSION}

git clone https://github.com/$GITHUB_USERNAME/compassion-switzerland.git --depth 1 --branch ${ODOO_VERSION} "$ODOO_DEV_HOME/compassion-switzerland"
cd "$ODOO_DEV_HOME/compassion-switzerland" || exit
git remote add upstream https://github.com/CompassionCH/compassion-switzerland.git
git pull upstream ${ODOO_VERSION}
pip install --user -r requirements.txt

git clone https://github.com/$GITHUB_USERNAME/compassion-modules.git --depth 1 --branch ${ODOO_VERSION} "$ODOO_DEV_HOME/compassion-modules"
cd "$ODOO_DEV_HOME/compassion-modules" || exit
git remote add upstream https://github.com/CompassionCH/compassion-modules.git
git pull upstream ${ODOO_VERSION}
pip install --user -r requirements.txt

git clone https://github.com/CompassionCH/paid-addons.git --branch ${ODOO_VERSION} "$ODOO_DEV_HOME/paid-addons"
cd "$ODOO_DEV_HOME/paid-addons" || exit


#------------------------------------------------------------------------------
# Languages settings
#------------------------------------------------------------------------------
sudo /usr/share/locales/install-language-pack fr_CH
sudo /usr/share/locales/install-language-pack de_DE
sudo /usr/share/locales/install-language-pack it_IT
sudo /usr/share/locales/install-language-pack es_ES
sudo dpkg-reconfigure locales

#------------------------------------------------------------------------------
# Odoo conf
#------------------------------------------------------------------------------
echo -e "* Create server config file"

# Get paths of OCA addons
cd "${ADDONS_DIR}/oca_addons/" || exit
addons_path=$(for addon in * ; do
  realpath "$addon" | sed s/^/"\t"/ | sed s/$/,/
done)

sudo chmod a+w "/opt/${ODOO_SERVER_PATH}"
sudo touch "${ODOO_DEV_HOME}"/${CONF_FILE_NAME}.conf
sudo usermod -a -G odoo "$USER"
sudo chown "$USER" "${ODOO_DEV_HOME}/${CONF_FILE_NAME}.conf"
sudo chmod a+w /${ODOO_DEV_HOME}/${CONF_FILE_NAME}.conf

echo -e "* Creating server config file"
sudo su root -c "printf '[options] \n' >> ${CONF_FILE_PATH}"

# Add all addons needed by Odoo (oca, paid, switzerland, modules, accounting)
sudo su root -c "printf 'addons_path=' >> ${CONF_FILE_PATH}"
sudo su root -c "printf '$addons_path \n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf '\t${ODOO_DEV_HOME}/compassion-accounting, \n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf '\t${ODOO_DEV_HOME}/compassion-switzerland, \n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf '\t${ODOO_DEV_HOME}/compassion-modules, \n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf '\t${ODOO_DEV_HOME}/paid-addons, \n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf '\t${SOURCE_DIR}/addons, \n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf '\t${SOURCE_DIR}/odoo/addons \n\n' >> ${CONF_FILE_PATH}"

# Append config from the template with the username replaced.
cat ${SCRIPT_DIR}/${CONF_FILE_NAME}.conf.tmpl | sed "s/{user}/$USER/g" >> ${CONF_FILE_PATH}

