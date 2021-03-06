node=$1

echo "Creating container " $node
curl --unix-socket /var/run/docker.sock -H "Content-Type: application/json" -d @/consul/backups/$node.json -X POST http:/v1.24/containers/create?name=$node

echo "Starting " $node
curl --unix-socket /var/run/docker.sock -X POST http:/v1.24/containers/$node/start

echo $node "respawned at "$(date)

echo $(date +%Y-%m-%d' '%H:%M)";create;"$node >> '/consul/supermonkey_history.log';
