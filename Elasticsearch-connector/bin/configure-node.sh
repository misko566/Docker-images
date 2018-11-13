# Author: msmolik@devopsgroup.sk
# Inspiration from clakech/elastic-couchbase, GnaphronG/elasticsearch-couchbase
#!/bin/bash



# Set default environment
# [ "$ELASTIC_ADMIN_USER" == "" ] && ELASTIC_ADMIN_USER=admin
# [ "$ELASTIC_ADMIN_PASSWORD" == "" ] && ELASTIC_ADMIN_PASSWORD=password
# [ "$ELASTIC_BUCKET_1" == "" ] && ELASTIC_BUCKET_1=parkingsearch
# [ "$ELASTIC_BUCKET_2" == "" ] && ELASTIC_BUCKET_2=



echo "Environment:"
echo "  COUCHBASE_ADMIN_USER=$COUCHBASE_ADMIN_USER"
echo "  COUCHBASE_ADMIN_PASSWORD=$COUCHBASE_ADMIN_PASSWORD"
echo "---------------------------------"
echo "  COUCHBASE_CLUSTER=$COUCHBASE_CLUSTER"
echo "---------------------------------"
echo "  COUCHBASE_BUCKET_1=$COUCHBASE_BUCKET_1"
echo "---------------------------------"
echo "  COUCHBASE_BUCKET_2=$COUCHBASE_BUCKET_2"
echo "---------------------------------"


#run elastic
echo "launch elastic"
#aenable job control
set -m
elasticsearch &
echo "elasticsearch is starting"


echo "wait for elastic start"
while ! curl -s http://localhost:9200 2>&1 1>/dev/null
do
   i=$(( (i+1) %4 ))
    echo  "Waiting for elastic start on port 9200 ..."
    sleep 1
done

#printf "\r\r"
#curl -s -XGET 'http://localhost:9200/_cluster/health?wait_for_status=green&timeout=50s' | grep -q '"timed_out":false'

#toml default config customisation
##################################

#[group]
sed -i "15s/.*/  name = 'elastic-group-$COUCHBASE_BUCKET_1'/"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/default-connector.toml
#[group.static]
sed -i "22s/.*/  memberNumber = 1 # A value from 1 to 'totalMembers', inclusive./"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/default-connector.toml
sed -i "29s/.*/  totalMembers = 1/"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/default-connector.toml
#[couchbase]
sed -i "45s/.*/  hosts = ['$COUCHBASE_CLUSTER']/"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/default-connector.toml
sed -i "46s/.*/  bucket = '$COUCHBASE_BUCKET_1'/"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/default-connector.toml
sed -i "50s/.*/  username = '$COUCHBASE_ADMIN_USER'/"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/default-connector.toml
sed -i "54s#.*#  pathToPassword = 'secrets/couchbase-password.toml' #"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/default-connector.toml
sed -i "59s/.*/  secureConnection = false/"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/default-connector.toml
#[[elasticsearch.type]]
sed -i "140s/.*/  prefix = '${COUCHBASE_BUCKET_1}_'/"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/default-connector.toml
sed -i "141s/.*/  index = '$COUCHBASE_BUCKET_1'/"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/default-connector.toml
sed -i "142s/.*/  pipeline = ''/"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/default-connector.toml
#[[elasticsearch.type]]
sed -i "146s/.*/  regex = '.*port_.*'/"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/default-connector.toml
sed -i "147s/.*/  index = '$COUCHBASE_BUCKET_1'/"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/default-connector.toml
#[[elasticsearch.type]]
sed -i "157s/.*/  prefix = '' # Empty prefix matches any document ID./"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/default-connector.toml
sed -i "158s/.*/  index = '$COUCHBASE_BUCKET_1'/"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/default-connector.toml


echo " password = '$COUCHBASE_ADMIN_PASSWORD'" >> /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/secrets/couchbase-password.toml

##################################
#[group]
sed -i "15s/.*/  name = 'elastic-group-$COUCHBASE_BUCKET_2'/"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/bucket2-connector.toml
#[group.static]
sed -i "22s/.*/  memberNumber = 1 # A value from 1 to 'totalMembers', inclusive./"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/bucket2-connector.toml
sed -i "29s/.*/  totalMembers = 1/"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/bucket2-connector.toml
#[couchbase]
sed -i "45s/.*/  hosts = ['$COUCHBASE_CLUSTER']/"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/bucket2-connector.toml
sed -i "46s/.*/  bucket = '$COUCHBASE_BUCKET_2'/"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/bucket2-connector.toml
sed -i "50s/.*/  username = '$COUCHBASE_ADMIN_USER'/"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/bucket2-connector.toml
sed -i "54s#.*#  pathToPassword = 'secrets/couchbase-password.toml' #"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/bucket2-connector.toml
sed -i "59s/.*/  secureConnection = false/"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/bucket2-connector.toml
#[[elasticsearch.type]]
sed -i "140s/.*/  prefix = '${COUCHBASE_BUCKET_2}'/"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/bucket2-connector.toml
sed -i "141s/.*/  index = '$COUCHBASE_BUCKET_2'/"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/bucket2-connector.toml
sed -i "142s/.*/  pipeline = ''/"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/bucket2-connector.toml
#[[elasticsearch.type]]
sed -i "146s/.*/  regex = '.*port_.*'/"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/bucket2-connector.toml
sed -i "147s/.*/  index = '$COUCHBASE_BUCKET_2'/"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/bucket2-connector.toml
#[[elasticsearch.type]]
sed -i "157s/.*/  prefix = '' # Empty prefix matches any document ID./"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/bucket2-connector.toml
sed -i "158s/.*/  index = '$COUCHBASE_BUCKET_2'/"  /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/bucket2-connector.toml


echo " password = '$COUCHBASE_ADMIN_PASSWORD'" >> /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/secrets/couchbase-password.toml

##################################

sleep 1


echo "---------------------------------"
echo "starting $COUCHBASE_BUCKET_1 conector group"
echo "---------------------------------"
/opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/bin/cbes &



 if [ "${COUCHBASE_BUCKET_2}" == "none" ] ;  
 then
     echo "---------------------------------"
     echo "second connector not set"
     echo "---------------------------------"
 else
     echo "---------------------------------"
     echo "starting $COUCHBASE_BUCKET_2 conector group"
     /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/bin/cbes --config /opt/couchbase-elastic/couchbase-elasticsearch-connector-4.0.0/config/bucket2-connector.toml &
 fi

# figure to process elastic
echo "---------------------------------"
fg 1
