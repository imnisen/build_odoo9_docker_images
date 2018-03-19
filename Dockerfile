FROM ubuntu:16.04
MAINTAINER zhimian

# 安装系统依赖 采用阿里apt源,采用淘宝npm源
# 移除临时的文件
RUN set -x; \
    sed -i 's#http://archive.ubuntu.com#http://mirrors.aliyun.com#g' /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        xz-utils \
        python-pip \
        python-setuptools \
        npm \
        libsasl2-dev \
        python-dev \
        python-wheel \
        libldap2-dev \
        libssl-dev \
        libxml2-dev \
        libxslt1-dev \
        build-essential \
        libjpeg8-dev \
    && ln -s /usr/bin/nodejs /usr/bin/node \
    && npm install -g less less-plugin-clean-css --registry=https://registry.npm.taobao.org \
    && rm -rf /var/lib/apt/lists/*

# 手动安装 依赖wkhtmltox
COPY ./wkhtmltox-0.12.4_linux-generic-amd64.tar.xz /
RUN echo '3f923f425d345940089e44c1466f6408b9619562 wkhtmltox-0.12.4_linux-generic-amd64.tar.xz' | sha1sum -c - \
        && mkdir -p /wkhtmltox && tar xvf /wkhtmltox-0.12.4_linux-generic-amd64.tar.xz -C wkhtmltox --strip-components=1 \
        && cp wkhtmltox/lib/* /usr/local/lib/ \
        && cp wkhtmltox/bin/* /usr/local/bin/ \
        && cp -r wkhtmltox/share/man/man1 /usr/local/share/man/ \
        && rm -rf /wkhtmltox-0.12.4_linux-generic-amd64.tar.xz /wkhtmltox

# 拷贝odoo源码
COPY ./odoo /opt/odoo/

# 拷贝配置文件
COPY ./openerp-server.conf /opt/

## 拷贝启动脚本
COPY ./docker_run.sh /

# 安装python依赖
RUN pip install -r /opt/odoo/requirements.txt -i https://mirrors.aliyun.com/pypi/simple

# 用于挂载依赖
# /var/lib/odoo for odoo data
# /mnt/extra-addons for customise addons
RUN mkdir -p /mnt/extra-addons
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# 暴露服务接口
# 8069 for xmlrpc_port
# 9071 for xmlrpcs_port
EXPOSE 8069 8071

# 设置用户和权限
RUN useradd -rm odoo
RUN chown -R odoo /mnt/extra-addons
RUN chown -R odoo /var/lib/odoo

USER odoo
CMD ["/bin/bash", "-c", "/opt/docker_run.sh"]