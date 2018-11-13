# Author: msmolik@devopsgroup.sk
# Inspiration from clakech/elastic-couchbase, GnaphronG/elasticsearch-couchbase

FROM elasticsearch:6.4.1

MAINTAINER Michal Smolik  <msmolik@devopsgroup.sk>

ENV COUCHBASE_ADMIN_USER="admin"
ENV COUCHBASE_ADMIN_PASSWORD="password"
ENV COUCHBASE_CLUSTER="enter-dns-name-or-ip-of-couchbase-node"
ENV COUCHBASE_BUCKET_1="name-of-bucket"
ENV COUCHBASE_BUCKET_2="none"


RUN mkdir /opt/couchbase-elastic


WORKDIR /usr/share/elasticsearch

RUN  wget  http://packages.couchbase.com/clients/connectors/elasticsearch/4.0.0/couchbase-elasticsearch-connector-4.0.0.zip -P /opt/couchbase-elastic/tmp
RUN  unzip -o /opt/couchbase-elastic/tmp/couchbase-elasticsearch-connector-4.0.0.zip -d /opt/couchbase-elastic 

RUN chown elasticsearch -R /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/

COPY bin/default-connector.toml /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/default-connector.toml
COPY bin/default-connector.toml /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/bucket2-connector.toml
COPY bin/couchbase-password.toml /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/secrets/couchbase-password.toml

RUN chown elasticsearch -R /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/

COPY bin/configure-node.sh /opt/couchbase-elastic

USER elasticsearch

CMD ["/opt/couchbase-elastic/configure-node.sh"]