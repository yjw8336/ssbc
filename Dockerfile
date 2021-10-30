FROM centos:7

ENV TZ='Asia/Shanghai'
RUN curl -sL https://rpm.nodesource.com/setup_10.x | bash -
RUN rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
RUN yum install nodejs -y
RUN npm install -g pm2 -y
RUN yum -y install gcc automake autoconf libtool make gcc-c++ -y nginx vim
RUN yum install -y http://sphinxsearch.com/files/sphinx-2.3.2-1.rhel7.x86_64.rpm
COPY spider /ssbc/spider
COPY web /ssbc/web
COPY ssbc.conf /etc/nginx/conf.d/
RUN mkdir -p /data/bt/index/db /data/bt/index/binlog
WORKDIR /ssbc
RUN cd spider && npm install && cd ..
RUN cd web && npm install && npm run build && cd ..

RUN cd spider indexer -c sphinx.conf hash searchd -c sphinx.conf
CMD cd spider/ && pm2 start ecosystem.config.js && cd .. \
    && cd web && pm2 start ecosystem.config.js && cd .. \
    && nginx \
    && pm2 logs

