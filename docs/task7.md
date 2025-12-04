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
  "location": "string",
  "quantity": "number",
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
  "session_id": "UUID",
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

Для коллекций orders и carts подходит шардирование по хешу user_id, так как поиск происходит в основном по user_id. 
cards можно ещё шардировать по session_id.
Для коллекции products можно сделать шардирование по категориям товаров, чтобы быстрее выдавать товары определенной
категории.
Дополнительно можно применить шардирование по геозоне.

Ребалансировку следует добавить в первую очередь для коллекции orders, так как количество заказов будет расти быстро с
каждой покупкой. Так же стоит добавить ребалансировку для products, так как количество записей будет расти с быстро с 
появлением новых геозон и продуктов.
Для carts можно не добавлять, по крайней мере первое время так как записи будут удаляться по истечению срока и при 
оформлении заказа.