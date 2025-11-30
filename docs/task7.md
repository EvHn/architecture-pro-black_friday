## Orders

```json
{
  "order_id": "UUID",
  "user_id": "UUID",
  "created_at": "date",
  "products": [
    {
      "product_id": "UUID",
      "quantity": "number",
      "price": "number"
    }
  ],
  "status": "string",
  "total_price": "number",
  "location": "string"
}
```

## Products

```json
{
  "product_id": "UUID",
  "name": "string",
  "category": "string",
  "price": "number",
  "remaining": [
    {
      "location": "string",
      "quantity": "number"
    }
  ],
  "attributes": [
    {
      "key": "string",
      "value": "string"
    }
  ]
}
```

## Carts

```json
{
  "cart_id": "UUID",
  "user_id": "UUID",
  "items": [
    {
      "product_id": "UUID",
      "quantity": "number"
    }
  ],
  "status": "string",
  "created_at": "date",
  "updated_at": "date",
  "expires_at": "date"
}
```

Запуск скрипта со схемами
```bash
./scripts/task7.sh
```

Для коллекций orders и carts подходит шардирование по хешу user_id, так как поиск происходит в основном по user_id
Для коллекции products можно сделать шардирование по категориям товаров, чтобы быстрее выдавать товары определенной категории
