#!/bin/bash

###
# Инициализируем бд
###

docker compose exec -T configSrv mongosh --port 27017 <<EOF
rs.initiate(
  {
    _id : "config_server",
    configsvr: true,
    members: [
      { _id : 0, host : "configSrv.1:27017" },
      { _id : 1, host : "configSrv.2:27018" },
      { _id : 2, host : "configSrv.3:27019" }
    ]
  }
);
exit();
EOF

docker compose exec -T shard1.1 mongosh --port 27020 <<EOF
rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "shard1.1:27020" },
        { _id : 1, host : "shard1.2:27021" },
        { _id : 2, host : "shard1.3:27022" }
      ]
    }
);
exit();
EOF

docker compose exec -T shard2.1 mongosh --port 27023 <<EOF
rs.initiate(
    {
      _id : "shard2",
      members: [
        { _id : 0, host : "shard2.1:27023" },
        { _id : 1, host : "shard2.2:27024" },
        { _id : 2, host : "shard2.3:27025" }
      ]
    }
  );
exit();
EOF

docker compose exec -T mongos_router mongosh --port 27026 <<EOF
sh.addShard( "shard1/shard1.1:27020,shard1.2:27021,shard1.3:27022");
sh.addShard( "shard2/shard2.1:27023,shard2.2:27024,shard2.3:27025");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } );

use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i})
db.helloDoc.countDocuments();
exit();
EOF