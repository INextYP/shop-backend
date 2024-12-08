#!/bin/bash

###
# Инициализируем конфигурационный сервер
###

docker compose exec -T configSrv mongosh --port 27017 <<EOF
rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27017" }
    ]
  }
);
exit();
EOF

###
# Инициализируем шарды
###

docker compose exec -T shard1 mongosh --port 27018 <<EOF
rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "shard1:27018" },
        { _id : 1, host : "shard1-1:27021" }
        { _id : 2, host : "shard1-2:27022" }
      ]
    }
);
exit();
EOF

docker compose exec -T shard2 mongosh --port 27019 <<EOF
rs.initiate(
    {
      _id : "shard2",
      members: [
        { _id : 3, host : "shard2:27019" },
        { _id : 4, host : "shard2-1:27023" }
        { _id : 5, host : "shard2-2:27024" }
      ]
    }
  );
exit();
EOF

###
# Инициализируем роутер и наполняем его данными
###

docker compose exec -T mongos_router mongosh --port 27020 <<EOF
sh.addShard( "shard1/shard1:27018");
sh.addShard( "shard1/shard1-1:27021");
sh.addShard( "shard1/shard1-2:27022");
sh.addShard( "shard2/shard2:27019");
sh.addShard( "shard2/shard2-1:27023");
sh.addShard( "shard2/shard2-2:27024");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )

use somedb

for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})

exit();
EOF