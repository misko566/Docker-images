# Couchbase 5.0.1 community edition NoSQL database node

Couchbase storage service docker container definition.
This container can be used to deploy single Couchbase node, or replicated Couchbase cluster.

## Changelog


## Build Docker image
   `docker build --rm=true --tag=enter-your-registry/couchbase:community-5.0.1 .`

`

## Start Couchbase docker
First node
   `docker run -d --name couchbasedb -e NODE_TYPE=SERVER -e FIRST_NODE=localhost -p 8091-8094:8091-8094 -p 11210:11210 misko566/couchbase:community-5.0.1`

Adding nodes
   `docker run -d --name couchbasedb -e NODE_TYPE=NODE -e FIRST_NODE=enterip-of-first-node -p 8091-8094:8091-8094 -p 11210:11210 misko566/couchbase:community-5.0.1`


