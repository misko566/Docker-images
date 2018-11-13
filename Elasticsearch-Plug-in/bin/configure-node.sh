# Author: michal.smolik@devopsgroup.sk
# Inspiration from clakech/elastic-couchbase, GnaphronG/elasticsearch-couchbase
#!/bin/bash



# Set default environment
[ "$ELASTIC_ADMIN_USER" == "" ] && ELASTIC_ADMIN_USER=admin
[ "$ELASTIC_ADMIN_PASSWORD" == "" ] && ELASTIC_ADMIN_PASSWORD=password
[ "$ELASTIC_BUCKET" == "" ] && $ELASTIC_BUCKET="bucket1 bucket2 bucket3 bucketx"


echo "Environment:"
echo "  ELASTIC_ADMIN_USER=$ELASTIC_ADMIN_USER"
echo "  ELASTIC_ADMIN_PASSWORD=$ELASTIC_ADMIN_PASSWORD"
echo "---------------------------------"
echo "  ELASTIC_BUCKET=$ELASTIC_BUCKET"
echo "---------------------------------"



#run elastic
echo "launch elastic"
#aenable job control
set -m
gosu elasticsearch elasticsearch &
echo "elasticsearch is starting"


echo "wait for elastic start"
while ! curl -s http://localhost:9200 2>&1 1>/dev/null
do
   i=$(( (i+1) %4 ))
    echo  "waiting..."
    sleep 1
done

printf "\r\r"
curl -s -XGET 'http://localhost:9200/_cluster/health?wait_for_status=green&timeout=50s' | grep -q '"timed_out":false'
curl -s -XPUT http://localhost:9200/_template/couchbase -d @plugins/transport-couchbase/couchbase_template.json -o /dev/null 


rm -- "$0"

echo "---------------------------------"
echo "creating indexs for buckets"
echo "---------------------------------"

for j in ${ELASTIC_BUCKET} 
do

    curl -X PUT http://localhost:9200/$j
    echo  "Creating index for bucket $j"
    sleep .1

done

# figure to process elastic
fg 1
