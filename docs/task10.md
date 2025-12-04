## 10.1

Критичные части:
Товары, Корзина, Заказы
Не критичные:
История заказов, возврат товаров, Профиль

Для критичных частей важна быстрая масштабируемость, так как при акциях они будут
испытывать резкое увеличение нагрузки. Особенно это важно для Каталога товаров,
так как на него будет приходиться основная нагрузка при появлении новых акций.

## 10.2

### Orders

```postgres-psql
CREATE TABLE orders (
    user_id uuid,
    created_at timestamp,
    order_id uuid,
    status text,
    total_price decimal,
    location text,
    products list<frozen<product_item>>,
    PRIMARY KEY ((user_id), created_at, order_id)
) WITH CLUSTERING ORDER BY (created_at DESC)
   AND compaction = {'class': 'TimeWindowCompactionStrategy'}

CREATE TYPE product_item (
    product_id uuid,
    quantity int,
    price decimal
);
```

Partition Key: user_id - Равномерное распределение заказов пользователей
Clustering Key: created_at DESC - Последние заказы в начале
order_id в кластеринге - Уникальность и обращение к конкретному заказу
Большая часть запросов это поиск пользователем своих заказов и такая структура позволяет быстро получать историю
заказов.

### Products

```postgres-psql
CREATE TABLE products (
    location text,
    category text,
    product_id uuid,
    name text,
    price decimal,
    quantity int,
    attributes map<text, text>,
    PRIMARY KEY ((location, category), product_id)
);
```
Покрывает запрос типа "Наличие товара «Смартфон X» в Екатеринбурге"
Эффективные диапазонные запросы в пределах категории

```postgres-psql

CREATE TABLE carts (
  user_id uuid,
  session_id uuid,
  cart_id uuid,
  items list<frozen<cart_item>>,
  status text,
  created_at timestamp,
  updated_at timestamp,
  expires_at timestamp,
  location text,
  total_price decimal,
PRIMARY KEY ((user_id, session_id), created_at)
) WITH CLUSTERING ORDER BY (created_at DESC);

CREATE TYPE cart_item (
product_id uuid,
quantity int
);
```
Одна партиция на пользователя для быстрого доступа к корзине
DESC сортировка - Сначала последние созданные корзины

## 10.3

Для каталога товаров и заказы важно отображаться самые свежие данные об остатках,
а в корзине надо отображать все товары добавленные пользователем, поэтому тут подойдет
способ восстановления консистенции Read Repair

