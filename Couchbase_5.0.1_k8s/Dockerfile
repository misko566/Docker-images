FROM couchbase:community-5.0.1

ENV COUCHBASE_ADMIN_USER admin
ENV COUCHBASE_ADMIN_PASSWORD password

COPY bin/configure-node.sh /opt/couchbase

CMD ["/opt/couchbase/configure-node.sh"]
