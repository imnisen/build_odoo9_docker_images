#!/bin/bash

# 如果发生错误则退出执行
set -e

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file
# 要么从环境变量取值,要么设为默认值
: ${DB_HOST:='db'}
: ${DB_PORT:='5432'}
: ${DB_USER:='odoo'}
: ${DB_PASSWD:='odoo'}
: ${ADMIN_PASSWD:='admin'}

sed -i "s/DB_HOST/$DB_HOST/g" /opt/openerp-server.conf
sed -i "s/DB_PORT/$DB_PORT/g" /opt/openerp-server.conf
sed -i "s/DB_USER/$DB_USER/g" /opt/openerp-server.conf
sed -i "s/DB_PASSWD/$DB_PASSWD/g" /opt/openerp-server.conf
sed -i "s/ADMIN_PASSWD/$ADMIN_PASSWD/g" /opt/openerp-server.conf


exec python /opt/odoo/openerp-server -c /opt/openerp-server.conf

exit 1
