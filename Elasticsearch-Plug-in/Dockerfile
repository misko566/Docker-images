# Author: msmolik@devopsgroup.sk
# Inspiration from clakech/elastic-couchbase, GnaphronG/elasticsearch-couchbase

FROM elasticsearch:5.6.9

MAINTAINER Michal Smolik  <msmolik@devopsgroup.sk>

ENV ELASTIC_ADMIN_USER = "admin"
ENV ELASTIC_ADMIN_PASSWORD  = "password"
ENV ELASTIC_BUCKET =   "bucket1 bucket2 bucket3 bucketx"


RUN mkdir /opt/couchbase-elastic

WORKDIR /usr/share/elasticsearch

RUN  /usr/share/elasticsearch/bin/elasticsearch-plugin install -b https://github.com/couchbase/couchbase-elasticsearch-connector/releases/download/3.0.2-cypress/elasticsearch-transport-couchbase-3.0.2-cypress-es5.6.9.zip

COPY bin/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
COPY bin/configure-node.sh /opt/couchbase-elastic

CMD ["/opt/couchbase-elastic/configure-node.sh"]
