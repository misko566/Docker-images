# Couchbase elasticsearch plugin 3.0.2 for elasticsearch 5.6.9 - Older version
WARN: To avoid vm.max_map_count errors you could set "Update host sysctl" to true. Then param vm.max_map_count will be update to 262144 if it's less in your hosts.


# usage sample

create bucket index in elastic
`curl -X PUT http://localhost:9200/beer-sample`

Then you need setup  replication in couchbase. (force  port  in host settings 9091)

View result
http://172.16.2.59:9200/beer-sample/_search?q=beer-sample

#documentation
https://docs.couchbase.com/elasticsearch-connector/3.0/index.html

# base Image
- based from - elasticsearch:5.6.9


# Build Docker image
   `docker build --rm=true --tag=your-docker-registry/elasticsearch:couchbase-elastic-5.6.9.`
   make build
   make push

# Run Docker
SET ENV in dockerfile first. you can use -e option
`docker run -d -p 9200:9200 -p 9300:9300 -p 9091:9091 misko566/elasticsearch:couchbase-elastic-5.6.9`




