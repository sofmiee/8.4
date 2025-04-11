CREATE DATABASE products

CREATE TABLE products(
id_ SERIAL PRIMARY KEY,
name_ VARCHAR(100),
quantity_ INT
);
CREATE TABLE operations_log(
id_ SERIAL PRIMARY KEY,
product_id INT,
operation VARCHAR(100) CHECK (operation IN ('ADD', 'REMOVE')),
quantity INT,
FOREIGN KEY (product_id) REFERENCES products(id_)
);


CREATE OR REPLACE PROCEDURE update_stock(product_id INT, operation VARCHAR, quantity_log INT)
LANGUAGE plpgsql AS $$
BEGIN
IF operation = 'ADD' THEN

UPDATE products
SET quantity_ = quantity_ + quantity_log
WHERE id_ = product_id;

INSERT INTO operations_log(product_id, operation, quantity)
VALUES (product_id, operation, quantity_log);

ELSIF operation = 'REMOVE' THEN

IF (SELECT quantity_ From products WHERE id_ = product_id) >= quantity_log THEN
UPDATE products
SET quantity_ = quantity_ - quantity_log
WHERE id_ = product_id;

INSERT INTO operations_log(product_id, operation, quantity)
VALUES (product_id, operation, quantity_log);

ELSE
RAISE EXCEPTION 'недостаточно товара для удаления';
END IF;

ELSE
RAISE EXCEPTION 'неверно введенная оперпция';
END IF;

END;
$$;


INSERT INTO products (id_, name_, quantity_)
VALUES (1, 'Молоко', 4);

CALL update_stock(1, 'ADD', 4)
