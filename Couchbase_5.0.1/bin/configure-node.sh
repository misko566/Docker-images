# Author: msmolik@devopsgroup.sk
# Inspired by Arun Gupta's

set -m

/entrypoint.sh couchbase-server &
echo "couchbase is starting"

echo "Environment variables:"
echo "  ADMIN_USER=$ADMIN_USER"
echo "  ADMIN_PASSWORD=$ADMIN_PASSWORD"
echo "  NODE_TYPE=$NODE_TYPE"
echo "  FIRST_NODE=$FIRST_NODE"
echo "  WAIT_FOR_SERVICE=$WAIT_FOR_SERVICE"
echo "  MEMORY_QUOTA=$MEMORY_QUOTA"
echo "  INDEX_QUOTA=$INDEX_QUOTA"
echo "  AUTO_REBALANCE=$AUTO_REBALANCE"




echo "wait for couchbase start"
while ! curl -s http://localhost:8091 2>&1 1>/dev/null
do
   i=$(( (i+1) %4 ))
    echo  "Waiting for couchbase start on port 8091 ..."
    sleep 1
done


# Setup index and memory quota
echo -e "\nConfigure default bucket memory"
echo "--------------------------------"
curl -v -X POST http://127.0.0.1:8091/pools/default -d memoryQuota=$MEMORY_QUOTA -d indexMemoryQuota=$INDEX_QUOTA

# Setup services
echo -e "\nConfigure services"
echo "--------------------------------"
curl -v http://127.0.0.1:8091/node/controller/setupServices -d 'services=kv%2Cn1ql%2Cindex%2Cfts'

# Setup autoFailover
echo -e "\nConfigure autoFailover"
echo "--------------------------------"
curl -v -X POST http://127.0.0.1:8091/settings/autoFailover -d 'enabled=true&timeout=240'

# Setup credentials
echo -e "\nConfigure credentials"
echo "--------------------------------"
curl -v http://127.0.0.1:8091/settings/web -d port=8091 -d username=$ADMIN_USER -d password=$ADMIN_PASSWORD




THIS_NODE_IP=`hostname -I`

# Add Couchbase NODE to cluster
if [ "$NODE_TYPE" = "NODE" ]; then
  sleep $WAIT_FOR_SERVICE

  echo "--------------------------------"
  echo "Adding this node to Couchbase cluster..."
  echo "--------------------------------"
  echo "THIS_NODE_IP=$THIS_NODE_IP"
  echo "FIRST_NODE=$FIRST_NODE"

  if [ "$AUTO_REBALANCE" = "true" ]; then
 	couchbase-cli server-add -c ${FIRST_NODE}:8091 -u $ADMIN_USER  -p $ADMIN_PASSWORD --server-add ${THIS_NODE_IP}  --server-add-username $ADMIN_USER --server-add-password $ADMIN_PASSWORD --service=data,index,query,fts
		echo "couchbase-cli server-add -c ${FIRST_NODE}:8091 -u $ADMIN_USER  -p ***** --server-add ${THIS_NODE_IP}  --server-add-username $ADMIN_USER --server-add-password ***** --service=data,index,query,fts"

   	sleep 5

    couchbase-cli rebalance -c ${FIRST_NODE}:8091 -u $ADMIN_USER  -p $ADMIN_PASSWORD --no-wait
		echo "couchbase-cli rebalance -c $FIRST_NODE:8091 -u $ADMIN_USER  -p ***** --no-wait"
  else
    couchbase-cli server-add -c ${FIRST_NODE}:8091 -u $ADMIN_USER  -p $ADMIN_PASSWORD --server-add ${THIS_NODE_IP}  --server-add-username $ADMIN_USER --server-add-password $ADMIN_PASSWORD --service=data,index,query,fts
		echo "couchbase-cli server-add -c $FIRST_NODE:8091 -u $ADMIN_USER  -p ***** --server-add ${THIS_NODE_IP}  --server-add-username $ADMIN_USER --server-add-password ***** --service=data,index,query,fts"  
  fi;
fi;

fg 1
