FROM centos:7
MAINTAINER Hiroaki Nakamura <hnakamur@gmail.com>

RUN yum -y install @"Development Tools" rpm-build rpmdevtools patch curl less vim-enhanced \
 && rpmdev-setuptree

ADD lua53/ .

RUN rpm -i lua53-5.3.3-3.el7.centos.x86_64.rpm \
 && rpm -i lua53-devel-5.3.3-3.el7.centos.x86_64.rpm \
 && rpm -i lua53-static-5.3.3-3.el7.centos.x86_64.rpm

WORKDIR /root/rpmbuild
ADD SPECS/ ./SPECS/
ADD SOURCES/ ./SOURCES/

RUN source_urls=`rpmspec -P ./SPECS/haproxy16.spec | awk '/^Source[0-9]*:\s*http/ {print $2}'` \
 && for source_url in $source_urls; do \
      source_file=${source_url##*/}; \
      (cd ./SOURCES && if [ ! -f ${source_file} ]; then curl -sLO ${source_url}; fi); \
    done

RUN yum install -y epel-release \
 && yum-builddep -y ./SPECS/haproxy16.spec
# && yum-builddep -y ./SPECS/haproxy16.spec \
# && rpmbuild -bb ./SPECS/haproxy16.spec
