#!/bin/bash

docker compose exec -T mongos_router mongosh --port 27026 <<EOF
use somedb;

db.createCollection("orders", {
  validator: {
    \$jsonSchema: {
      bsonType: "object",
      required: ["order_id", "user_id", "created_at", "products", "status", "total_price", "location"],
      properties: {
        order_id: {
          bsonType: "string",
          pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
        },
        user_id: {
          bsonType: "string",
          pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
        },
        created_at: {
          bsonType: "date",
        },
        products: {
          bsonType: "array",
          minItems: 1,
          items: {
            bsonType: "object",
            required: ["product_id", "quantity", "price"],
            properties: {
              product_id: {
                bsonType: "string",
                pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
              },
              quantity: {
                bsonType: "number",
                minimum: 1
              },
              price: {
                bsonType: "number",
                minimum: 0
              }
            }
          }
        },
        status: {
          bsonType: "string",
          enum: ["pending", "confirmed", "shipped", "delivered", "cancelled"]
        },
        total_price: {
          bsonType: "number",
          minimum: 0
        },
        location: {
          bsonType: "string",
          minLength: 1
        }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

sh.shardCollection("orders", { "user_id": "hashed" });

db.createCollection("products", {
  validator: {
    \$jsonSchema: {
      bsonType: "object",
      required: ["product_id", "name", "category", "price", "remaining", "attributes"],
      properties: {
        product_id: {
          bsonType: "string",
          pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
        },
        name: {
          bsonType: "string",
          minLength: 1
        },
        category: {
          bsonType: "string",
          minLength: 1
        },
        price: {
          bsonType: "number",
          minimum: 0
        },
        remaining: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: ["location", "quantity"],
            properties: {
              location: {
                bsonType: "string",
                minLength: 1
              },
              quantity: {
                bsonType: "number",
                minimum: 0
              }
            }
          }
        },
        attributes: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: ["key", "value"],
            properties: {
              key: {
                bsonType: "string",
                minLength: 1
              },
              value: {
                bsonType: "string"
              }
            }
          }
        }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

sh.shardCollection("products", { "category": 1 });

db.createCollection("carts", {
  validator: {
    \$jsonSchema: {
      bsonType: "object",
      required: ["cart_id", "user_id", "items", "status", "created_at", "updated_at", "expires_at"],
      properties: {
        cart_id: {
          bsonType: "string",
          pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
        },
        user_id: {
          bsonType: "string",
          pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
        },
        items: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: ["product_id", "quantity"],
            properties: {
              product_id: {
                bsonType: "string",
                pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
              },
              quantity: {
                bsonType: "number",
                minimum: 1
              }
            }
          }
        },
        status: {
          bsonType: "string",
          enum: [ "active", "ordered", "abandoned"]
        },
        created_at: {
          bsonType: "date"
        },
        updated_at: {
          bsonType: "date"
        },
        expires_at: {
          bsonType: "date"
        }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

sh.shardCollection("carts", { "user_id": "hashed" });

db.orders.createIndex({ "order_id": 1 }, { unique: true });
db.orders.createIndex({ "user_id": 1 });
db.orders.createIndex({ "created_at": -1 });
db.orders.createIndex({ "status": 1 });

db.products.createIndex({ "product_id": 1 }, { unique: true });
db.products.createIndex({ "category": 1 });
db.products.createIndex({ "name": "text" });

db.carts.createIndex({ "cart_id": 1 }, { unique: true });
db.carts.createIndex({ "user_id": 1 }, { unique: true });
db.carts.createIndex({ "status": 1 });
db.carts.createIndex({ "expires_at": 1 });

db.orders.insertOne({
  order_id: "123e4567-e89b-12d3-a456-426614174000",
  user_id: "123e4567-e89b-12d3-a456-426614174001",
  created_at: new Date("2025-01-15T10:30:00Z"),
  products: [
    {
      product_id: "823e4567-e89b-12d3-a456-426614174030",
      quantity: 2,
      price: 89.99
    }
  ],
  status: "pending",
  total_price: 179.98,
  location: "Ekaterinburg"
});

db.products.insertOne({
  product_id: "823e4567-e89b-12d3-a456-426614174030",
  name: "Wireless Bluetooth Headphones",
  category: "Electronics",
  price: 89.99,
  remaining: [
    {
      location: "Ekaterinburg",
      quantity: 15
    },
    {
      location: "Moscow",
      quantity: 25
    },
    {
      location: "Sochi",
      quantity: 8
    }
  ],
  attributes: [
    {
      key: "brand",
      value: "SuperCool"
    },
    {
      key: "color",
      value: "Black"
    },
    {
      key: "battery_life",
      value: "20 hours"
    },
    {
      key: "connectivity",
      value: "Bluetooth 5.0"
    }
  ]
});

db.carts.insertOne({
  cart_id: "c23e4567-e89b-12d3-a456-426614174070",
  user_id: "123e4567-e89b-12d3-a456-426614174001",
  items: [
    {
      product_id: "823e4567-e89b-12d3-a456-426614174030",
      quantity: 1
    }
  ],
  status: "active",
  created_at: new Date("2025-01-18T11:20:00Z"),
  updated_at: new Date("2025-01-18T16:45:00Z"),
  expires_at: new Date("2025-03-17T11:20:00Z")
});
EOF