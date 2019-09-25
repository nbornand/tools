#!/bin/bash

#Odoo
ODOO_VERSION="10.0"
GITHUB_USERNAME="quentingigon"
SERVER_NAME="odoo10"
ODOO_SERVER_PATH="odoo/$SERVER_NAME"
ODOO_DEV_HOME="$HOME/$ODOO_SERVER_PATH"
CONF_FILE_NAME="odoo"
CONF_FILE_PATH="${ODOO_DEV_HOME}/${CONF_FILE_NAME}.conf"
ADDONS_PATH="addons"
SOURCE_PATH="source"
SOURCE_DIR="/opt/${ODOO_SERVER_PATH}/${SOURCE_PATH}"
ADDONS_DIR="/opt/${ODOO_SERVER_PATH}/${ADDONS_PATH}"
PAID_ADDONS_DIR="${ADDONS_DIR}/paid-addons"

#------------------------------------------------------------------------------
# Configuration parameters
#------------------------------------------------------------------------------

# Sensitive paramters, to complete
ADMIN_PWD=""
CONNECT_API_KEY=""
CONNECT_SECRET=""
CONNECT_TOKEN_CERT=""
CONNECT_TOKEN_ENDPOINT=""
CONNECT_TOKEN_ISSUER=""
CONNECT_TOKEN_SERVER=""
CONNECT_URL=""
CSV_INTERNAL_SEP=","
DETECT_LANGUAGE_API_KEY=""
MYSQL_TRANSLATE_PW=""
MYSQL_TRANSLATE_USER=""
SENDGRID_API_KEY=""
SMB_IP=""
SMB_PWD=""
SMB_USER=""
WORDPRESS_HOST=""
WORDPRESS_PWD=""
WORDPRESS_USER=""
WP_SFTP_HOST=""
WP_SFTP_PWD=""
WP_SFTP_USER=""

# Non-sensitive parameters
CONNECT_CLIENT="Compassion.CH"

DATA_DIR="/home/${USER}/.local/share/Odoo"
DB_HOST="False"
DB_MAXCONN=64
DB_NAME="devel"
DB_PASSWORD="test"
DB_PORT="5432"
DB_TEMPLATE="template1"
DB_USER=$USER
DB_FILTER=".*"

EMAIL_FROM="False"

GEOIP_DATABASE="/usr/share/GeoIP/GeoLite2-City.mmdb"
GP_PICTURES="/test_photos/"

LIMIT_MEMORY_HARD=2684354560
LIMIT_MEMORY_SOFT=2147483648
LIMIT_REQUEST=8192
LIMIT_TIME_CPU=60
LIMIT_TIME_REAL=120
LIMIT_TIME_REAL_CRON=-1
LIST_DB="True"
LOG_DB="False"
LOG_DB_LEVEL="warning"
LOG_HANDLER=":INFO"
LOG_LEVEL="info"
LOGFILE="False"
LOGROTATE="False"
LONGPOLLING_PORT=8072

MAX_CRON_THREADS=2
MYSQL_TRANSLATE_DB="traduction test"
MYSQL_TRANSLATE_HOST="metier.compassion.ch"

OSV_MEMORY_AGE_LIMIT=1.0
OSV_MEMORY_COUNT_LIMIT="False"

PG_PATH="None"
PIDFILE="False"
PROXY_MODE="False"

REPORTGZ="False"

SENDGRID_TEST_ADDRESS="test@address.ch"
SERVER_WIDE_MODULES="web, web_kanban"

SMB_PORT=139

SMTP_PASSWORD="False"
SMTP_PORT=25
SMTP_SERVER="localhost"
SMTP_SSL="False"
SMTP_USER="False"
SYSLOG="False"

TEST_COMMIT="False"
TEST_ENABLE="False"
TEST_FILE="False"
TEST_REPORT_DIRECTORY="False"
TRANSLATE_MODULES=['ALL']

UNACCENT="False"

WITHOUT_DEMO="False"

WORKERS=0
WP_CSV_PATH="/home/clients/06d8eab33e523b29a0fa9d4db2b89230/web/wp-content/plugins/child-import-odoo/uploads"
WP_PICTURES_PATH="/home/clients/06d8eab33e523b29a0fa9d4db2b89230/web/wp-content/uploads/child-import"

XMLRPC="True"
XMLRPC_INTERFACE=""
XMLRPC_PORT=8069

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

sudo touch "${ODOO_DEV_HOME}"/${CONF_FILE_NAME}.conf
echo -e "* Creating server config file"
sudo su root -c "printf '[options] \n' >> ${CONF_FILE_PATH}"

# Add all addons needed by Odoo (oca, paid, switzerland, modules, accounting)
sudo su root -c "printf 'addons_path=' >> ${CONF_FILE_PATH}"
sudo su root -c "printf '$addons_path \n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf '\t${ODOO_DEV_HOME}/compassion-accounting, \n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf '\t${ODOO_DEV_HOME}/compassion-switzerland, \n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf '\t${ODOO_DEV_HOME}/compassion-modules, \n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf '\t${PAID_ADDONS_DIR}, \n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf '\t${SOURCE_DIR}/addons, \n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf '\t${SOURCE_DIR}/odoo/addons \n\n' >> ${CONF_FILE_PATH}"

#------------------------------------------------------------------------------
# Parameters of configuration file, sorted by alphabetical order
#------------------------------------------------------------------------------
sudo su root -c "printf 'admin_passwd = ${ADMIN_PWD}\n' >> ${CONF_FILE_PATH}"

sudo su root -c "printf 'connect_api_key = ${CONNECT_API_KEY}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'connect_client = ${CONNECT_CLIENT}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'connect_secret = ${CONNECT_SECRET}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'connect_token_cert = ${CONNECT_TOKEN_CERT}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'connect_token_endpoint = ${CONNECT_TOKEN_ENDPOINT}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'connect_token_issuer = ${CONNECT_TOKEN_ISSUER}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'connect_token_server = ${CONNECT_TOKEN_SERVER}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'connect_url = ${CONNECT_URL}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'csv_internal_sep = ${CSV_INTERNAL_SEP}\n' >> ${CONF_FILE_PATH}"

sudo su root -c "printf 'data_dir = ${DATA_DIR}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'db_host = ${DB_HOST}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'db_maxconn = ${DB_MAXCONN}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'db_name = ${DB_NAME}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'db_password = ${DB_PASSWORD}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'db_port = ${DB_PORT}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'db_template = ${DB_TEMPLATE}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'db_user = ${DB_USER}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'db_filter = ${DB_FILTER}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'detect_language_api_key = ${DETECT_LANGUAGE_API_KEY}\n' >> ${CONF_FILE_PATH}"

sudo su root -c "printf 'email_from = ${EMAIL_FROM}\n' >> ${CONF_FILE_PATH}"

sudo su root -c "printf 'geoip_database = ${GEOIP_DATABASE}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'gp_pictures = ${GP_PICTURES}\n' >> ${CONF_FILE_PATH}"

sudo su root -c "printf 'limit_memory_hard = ${LIMIT_MEMORY_HARD}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'limit_memory_soft = ${LIMIT_MEMORY_SOFT}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'limit_request = ${LIMIT_REQUEST}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'limit_time_cpu = ${LIMIT_TIME_CPU}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'limit_time_real = ${LIMIT_TIME_REAL}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'limit_time_real_cron = ${LIMIT_TIME_REAL_CRON}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'list_db = ${LIST_DB}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'log_db = ${LOG_DB}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'log_db_level = ${LOG_DB_LEVEL}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'log_handler = ${LOG_HANDLER}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'log_level = ${LOG_LEVEL}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'logfile = ${LOGFILE}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'logrotate = ${LOGROTATE}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'longpolling_port = ${LONGPOLLING_PORT}\n' >> ${CONF_FILE_PATH}"

sudo su root -c "printf 'max_corn_threads = ${MAX_CRON_THREADS}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'mysql_translate_db = ${MYSQL_TRANSLATE_DB}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'mysql_translate_host = ${MYSQL_TRANSLATE_HOST}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'mysql_translate_pw = ${MYSQL_TRANSLATE_PW}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'mysql_translate_user = ${MYSQL_TRANSLATE_USER}\n' >> ${CONF_FILE_PATH}"

sudo su root -c "printf 'osv_memory_age_limit = ${OSV_MEMORY_AGE_LIMIT}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'osv_memory_count_limit = ${OSV_MEMORY_COUNT_LIMIT}\n' >> ${CONF_FILE_PATH}"

sudo su root -c "printf 'pg_path = ${PG_PATH}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'pidfile = ${PIDFILE}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'proxy_mode = ${PROXY_MODE}\n' >> ${CONF_FILE_PATH}"

sudo su root -c "printf 'reportgz = ${REPORTGZ}\n' >> ${CONF_FILE_PATH}"

sudo su root -c "printf 'sendgrid_api_key = ${SENDGRID_API_KEY}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'sendgrid_test_address = ${SENDGRID_TEST_ADDRESS}\n' >> ${CONF_FILE_PATH}"

sudo su root -c "printf 'server_wide_modules = ${SERVER_WIDE_MODULES}\n' >> ${CONF_FILE_PATH}"

sudo su root -c "printf 'smb_ip = ${SMB_IP}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'smb_port = ${SMB_PORT}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'smb_pwd = ${SMB_PWD}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'smb_user = ${SMB_USER}\n' >> ${CONF_FILE_PATH}"

sudo su root -c "printf 'wordpress_host = ${WORDPRESS_HOST}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'wordpress_pwd = ${WORDPRESS_PWD}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'wordpress_user = ${WORDPRESS_USER}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'workers = ${WORKERS}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'wp_csv_path = ${WP_CSV_PATH}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'wp_pictures_path = ${WP_PICTURES_PATH}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'wp_sftp_host = ${WP_SFTP_HOST}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'wp_sftp_pwd = ${WP_SFTP_PWD}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'wp_sftp_user = ${WP_SFTP_USER}\n' >> ${CONF_FILE_PATH}"

sudo su root -c "printf 'xmprpc = ${XMLRPC}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'xmlrpc_interface = ${XMLRPC_INTERFACE}\n' >> ${CONF_FILE_PATH}"
sudo su root -c "printf 'xmlrpc_port = ${XMLRPC_PORT}\n\n' >> ${CONF_FILE_PATH}"

sudo su root -c "printf '[queue_job] \n' >> ${CONF_FILE_PATH}"

sudo usermod -a -G odoo "$USER"
sudo chown "$USER" "${ODOO_DEV_HOME}/${CONF_FILE_NAME}.conf"
sudo chmod 755 /${ODOO_DEV_HOME}/${CONF_FILE_NAME}.conf
