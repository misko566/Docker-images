# Author: ,michal.smolik@devopsgroup.sk
# Inspired by Arun Gupta: https://github.com/arun-gupta/couchbase-kubernetes/blob/master/cluster-statefulset/configure-node.sh

set -m

/entrypoint.sh couchbase-server &



# Set default environment (can be overriden by docker -e option)
[ "$LOAD_SAMPLE_BUCKET" == "" ] && LOAD_SAMPLE_BUCKET=false
[ "$ADMIN_USER" == "" ] && ADMIN_USER=admin
[ "$ADMIN_PASSWORD" == "" ] && ADMIN_PASSWORD=password
[ "$MEMORY_QUOTA" == "" ] && MEMORY_QUOTA=300
[ "$INDEX_QUOTA" == "" ] && INDEX_QUOTA=300
[ "$AUTO_REBALANCE" == "" ] && AUTO_REBALANCE=false
[ "$COUCHBASE_MASTER" == "" ] && COUCHBASE_MASTER=couchbase-cluster-b-0.couchbase-cluster-b.namespace1.svc.cluster.local
[ "$SERVICE_FQDN" == "" ] && SERVICE_FQDN=couchbase-cluster-b.namespace1.svc.cluster.local
[ "$WAIT_FOR_SERVICE" == "" ] && WAIT_FOR_SERVICE=60

echo "Environment:"
echo "  LOAD_SAMPLE_BUCKET=$LOAD_SAMPLE_BUCKET"
echo "  ADMIN_USER=$ADMIN_USER"
echo "  ADMIN_PASSWORD=$ADMIN_PASSWORD"
echo "  MEMORY_QUOTA=$MEMORY_QUOTA"
echo "  INDEX_QUOTA=$INDEX_QUOTA"
echo "  FTEXT_QUOTA=$FTEXT_QUOTA"
echo "  BUCKET_COUNT_LIMIT=$BUCKET_COUNT_LIMIT"
echo "  AUTO_REBALANCE=$AUTO_REBALANCE"
echo "  COUCHBASE_MASTER=$COUCHBASE_MASTER"
echo "  SERVICE_FQDN=$SERVICE_FQDN" 
echo "  WAIT_FOR_SERVICE=$WAIT_FOR_SERVICE"

sleep ${WAIT_FOR_SERVICE}

HOST=$HOSTNAME.$SERVICE_FQDN


# Setup index and memory quota
echo -e "\nConfigure memory"
echo "--------------------------------"
curl -v -X POST http://127.0.0.1:8091/pools/default -d memoryQuota=$MEMORY_QUOTA -d indexMemoryQuota=$INDEX_QUOTA -d ftsMemoryQuota=${FTEXT_QUOTA}

# Rename Node
echo -e "\nRename Node name - $HOSTNAME.$SERVICE_FQDN"
echo "--------------------------------"
echo "curl  -v -X POST http://127.0.0.1:8091/node/controller/rename -d hostname=$HOST"
curl  -v -X POST http://127.0.0.1:8091/node/controller/rename -d hostname=$HOST


# Setup services
echo -e "\nConfigure services"
echo "--------------------------------"
curl -v http://127.0.0.1:8091/node/controller/setupServices -d 'services=kv%2Cn1ql%2Cindex%2Cfts'

# Setup autoFailover
echo -e "\nConfigure autoFailover"
echo "--------------------------------"
curl -v -X POST http://127.0.0.1:8091/settings/autoFailover -d 'enabled=true&timeout=600'

#echo -e "\nSetting bucket limit"
#echo "--------------------------------"
#curl -v -X POST -d maxBucketCount=${BUCKET_COUNT_LIMIT} "http://127.0.0.1:8091/internalSettings"

# Setup credentials
echo -e "\nConfigure credentials"
echo "--------------------------------"
curl -v http://127.0.0.1:8091/settings/web -d port=8091 -d username=$ADMIN_USER -d password=$ADMIN_PASSWORD

# Setup Memory Optimized Indexes
# Note: Available for enterprise edition only
echo -e "\nConfigure indexes optimalization"
echo "--------------------------------"
curl -i -u $ADMIN_USER:$ADMIN_PASSWORD -X POST http://127.0.0.1:8091/settings/indexes -d 'storageMode=forestdb'

# Conditionally load travel-sample bucket
if [ "$LOAD_SAMPLE_BUCKET" = "true" ]; then
	echo -e "\nLoad travel sample bucket"
	echo "--------------------------------"
	curl -v -u $ADMIN_USER:$ADMIN_PASSWORD -X POST http://127.0.0.1:8091/sampleBuckets/install -d '["travel-sample"]'
fi;



if [[ "$HOSTNAME" == *-0 ]]; then
  TYPE="MASTER"
else
  TYPE="WORKER"
fi


echo "Type: $TYPE"

if [ "$TYPE" = "WORKER" ]; then
  echo "Waiting $WAIT_FOR_SERVICEs"
  sleep ${WAIT_FOR_SERVICE}

  IP=`hostname -I`

  echo "Auto Rebalance: $AUTO_REBALANCE"
  if [ "$AUTO_REBALANCE" = "true" ]; then
    echo "couchbase-cli server-add -c $COUCHBASE_MASTER:8091 -u $ADMIN_USER  -p ***** --server-add $HOSTNAME.$SERVICE_FQDN:8091  --server-add-username $ADMIN_USER --server-add-password ***** --service=data,index,query,fts"
    couchbase-cli server-add -c $COUCHBASE_MASTER:8091 -u $ADMIN_USER  -p $ADMIN_PASSWORD --server-add $HOSTNAME.$SERVICE_FQDN:8091  --server-add-username $ADMIN_USER --server-add-password $ADMIN_PASSWORD --service=data,index,query,fts
		
    #wait for server initialiation 
   	sleep 180

    echo "couchbase-cli rebalance -c $COUCHBASE_MASTER:8091 -u $ADMIN_USER  -p ***** --no-wait"
    couchbase-cli rebalance -c $COUCHBASE_MASTER:8091 -u $ADMIN_USER  -p $ADMIN_PASSWORD --no-wait
  
  
  else
    echo "couchbase-cli server-add -c $COUCHBASE_MASTER:8091 -u $ADMIN_USER  -p ***** --server-add $HOSTNAME.$SERVICE_FQDN:8091  --server-add-username $ADMIN_USER --server-add-password ***** --service=data,index,query,fts" 
	  couchbase-cli server-add -c $COUCHBASE_MASTER:8091 -u $ADMIN_USER  -p $ADMIN_PASSWORD --server-add $HOSTNAME.$SERVICE_FQDN:8091  --server-add-username $ADMIN_USER --server-add-password $ADMIN_PASSWORD --service=data,index,query,fts
  fi;
fi;

fg 1
