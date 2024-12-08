#!/bin/bash

###
# Получение общего количества документов в БД
###

docker compose exec -T mongos_router mongosh --port 27020 <<EOF
rs.status()
use somedb;
db.helloDoc.countDocuments();
EOF

###
# Получение общего количества документов по шардам
###

docker compose exec -T shard1 mongosh --port 27018 <<EOF
rs.status()
use somedb;
db.helloDoc.countDocuments();
EOF

docker compose exec -T shard2 mongosh --port 27019 <<EOF
rs.status()
use somedb;
db.helloDoc.countDocuments();
EOF
