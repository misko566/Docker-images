# Couchbase elasticsearch conector 4.0.0 for elasticsearch 6.4.1 - New version
WARN: To avoid vm.max_map_count errors you could set "Update host sysctl" to true. Then param vm.max_map_count will be update to 262144 if it's less in your hosts.


# usage sample

create bucket index in elastic - don't need anymore
`curl -X PUT http://localhost:9200/beer-sample`
display all indexes `_cat/indices?v`
display all items `indexname/_search?q=*:*`


View result
http://172.16.2.59:9200/beer-sample/_search?q=beer-sample

#documentation
https://docs.couchbase.com/elasticsearch-connector/4.0/index.html

# base Image
- based from - elasticsearch:6.4.1


# Build Docker image
   `docker build --rm=true --tag=your-docker-registry/elasticsearch:couchbase-elastic-6.4.1.`
   make build
   make push

# Run Docker
SET ENV in dockerfile first.
docker run -d -p 9200:9200 -p 9300:9300 -p 9091:9091 your-docker-registryelasticsearch:couchbase-elastic-6.4.1
