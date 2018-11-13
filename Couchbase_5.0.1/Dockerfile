FROM couchbase:community-5.0.1


ENV ADMIN_USER="admin"
ENV ADMIN_PASSWORD="password"
ENV NODE_TYPE="SERVER"
ENV FIRST_NODE="localhost"
ENV WAIT_FOR_SERVICE="15"
ENV MEMORY_QUOTA="300"
ENV INDEX_QUOTA="300"
ENV AUTO_REBALANCE="true"


COPY bin/configure-node.sh /opt/couchbase

CMD ["/opt/couchbase/configure-node.sh"]
