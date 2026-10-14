# Salidas de las consultas – BD `viveros`

Salida obtenida al ejecutar `psql -U postgres -e -f viveros.sql` en PostgreSQL 16. Cada bloque muestra la sentencia ejecutada y su resultado.

## Contenido de las tablas

### VIVERO

```text
SELECT * FROM vivero ORDER BY id_vivero;
 id_vivero |          nombre          |  latitud  |  longitud  
-----------+--------------------------+-----------+------------
         1 | Vivero La Laguna         | 28.487220 | -16.315820
         2 | Vivero Santa Cruz        | 28.463630 | -16.251850
         3 | Vivero Puerto de la Cruz | 28.414080 | -16.548690
         4 | Vivero Adeje             | 28.122690 | -16.726050
         5 | Vivero Los Realejos      | 28.384830 | -16.583400
(5 rows)
```

### ZONA

```text
SELECT * FROM zona ORDER BY id_vivero, id_zona;
 id_vivero | id_zona |   nombre    |  latitud  |  longitud  
-----------+---------+-------------+-----------+------------
         1 |       1 | Exterior    | 28.487300 | -16.315900
         1 |       2 | Almacén     | 28.487100 | -16.315700
         1 |       3 | Invernadero | 28.487400 | -16.316000
         2 |       1 | Exterior    | 28.463700 | -16.251900
         2 |       2 | Almacén     | 28.463500 | -16.251800
         3 |       1 | Exterior    | 28.414100 | -16.548700
         4 |       1 | Almacén     | 28.122700 | -16.726100
         5 |       1 | Exterior    | 28.384900 | -16.583500
(8 rows)
```

### PRODUCTO

```text
SELECT * FROM producto ORDER BY id_producto;
 id_producto |         nombre         |    tipo    | precio 
-------------+------------------------+------------+--------
           1 | Drago canario          | Planta     |  24.90
           2 | Tajinaste rojo         | Planta     |  12.50
           3 | Sustrato universal 50L | Jardinería |   8.95
           4 | Tijera de podar        | Jardinería |  15.00
           5 | Maceta terracota 30cm  | Decoración |   9.50
           6 | Farolillo solar        | Decoración |   6.75
           7 | Cactus mini            | Planta     |   3.20
(7 rows)
```

### STOCK

```text
SELECT * FROM stock ORDER BY id_vivero, id_zona, id_producto;
 id_vivero | id_zona | id_producto | cantidad 
-----------+---------+-------------+----------
         1 |       1 |           1 |       40
         1 |       1 |           2 |       25
         1 |       2 |           3 |      100
         1 |       2 |           4 |       15
         1 |       3 |           2 |        0
         1 |       3 |           7 |       30
         2 |       1 |           1 |       10
         2 |       1 |           2 |        0
         2 |       2 |           5 |       30
         3 |       1 |           6 |       50
         4 |       1 |           3 |       60
         5 |       1 |           6 |       20
(12 rows)
```

### EMPLEADO

```text
SELECT * FROM empleado ORDER BY id_empleado;
 id_empleado |    dni    |     nombre     
-------------+-----------+----------------
           0 | 00000000T | Sin asignar
           1 | 12345678Z | Ana Pérez
           2 | 23456789D | Luis Rodríguez
           3 | 34567890V | Carmen Díaz
           4 | 45678901G | Pedro Martín
           5 | 56789012B | Laura González
(6 rows)
```

### TAREA

```text
SELECT * FROM tarea ORDER BY id_tarea;
 id_tarea |     descripcion     
----------+---------------------
        1 | Riego
        2 | Atención al cliente
        3 | Reposición
        4 | Poda
        5 | Inventario
        6 | Carga y descarga
(6 rows)
```

### DESEMPENO

```text
SELECT * FROM desempeno ORDER BY id_empleado, fecha_inicio;
 id_empleado | id_vivero | id_zona | id_tarea | fecha_inicio | fecha_fin  | productividad 
-------------+-----------+---------+----------+--------------+------------+---------------
           1 |         1 |       1 |        1 | 2025-01-01   | 2025-03-31 |         85.00
           1 |         1 |       2 |        5 | 2025-04-01   | 2025-05-31 |         90.00
           1 |         3 |       1 |        2 | 2025-06-01   | 2025-09-30 |         78.50
           1 |         1 |       3 |        4 | 2025-10-01   |            |              
           2 |         2 |       1 |        2 | 2025-03-01   |            |         88.00
           3 |         1 |       2 |        3 | 2025-01-15   | 2025-12-31 |         92.25
           3 |         1 |       1 |        1 | 2025-06-01   | 2025-08-31 |         80.00
           4 |         4 |       1 |        3 | 2025-02-01   | 2025-12-31 |         70.00
           5 |         3 |       1 |        1 | 2026-01-01   |            |              
(9 rows)
```

### CLIENTE

```text
SELECT * FROM cliente ORDER BY id_cliente;
 id_cliente |     nombre      |          email           | fecha_ingreso 
------------+-----------------+--------------------------+---------------
          1 | María Hernández | maria.hernandez@mail.com | 2025-01-10
          2 | José Febles     | jose.febles@mail.com     | 2025-03-01
          3 | Elena Torres    | elena.torres@mail.com    | 2025-06-15
          4 | Sergio Alonso   |                          | 2026-01-05
          5 | Rosa Méndez     | rosa.mendez@mail.com     | 2026-02-01
(5 rows)
```

### PEDIDO

```text
SELECT * FROM pedido ORDER BY id_pedido;
 id_pedido | id_cliente | id_empleado |   fecha    | importe 
-----------+------------+-------------+------------+---------
         1 |          1 |           1 | 2025-02-10 |  293.75
         2 |          1 |           2 | 2025-02-20 |  498.00
         3 |          1 |           1 | 2025-03-05 |   46.00
         4 |          2 |           2 | 2025-03-15 | 1026.00
         5 |          3 |           3 | 2025-07-01 |  125.00
         6 |          4 |           4 | 2026-01-20 |   34.85
         7 |          2 |           3 | 2025-04-02 |   28.50
(7 rows)
```

### LINEA_PEDIDO

```text
SELECT * FROM linea_pedido ORDER BY id_pedido, id_producto;
 id_pedido | id_producto | cantidad | precio_unitario | subtotal 
-----------+-------------+----------+-----------------+----------
         1 |           1 |       10 |           24.90 |   249.00
         1 |           3 |        5 |            8.95 |    44.75
         2 |           1 |       20 |           24.90 |   498.00
         3 |           5 |        2 |            9.50 |    19.00
         3 |           6 |        4 |            6.75 |    27.00
         4 |           1 |       40 |           24.90 |   996.00
         4 |           4 |        2 |           15.00 |    30.00
         5 |           2 |       10 |           12.50 |   125.00
         6 |           3 |        3 |            8.95 |    26.85
         6 |           5 |        1 |            8.00 |     8.00
         7 |           4 |        1 |           15.00 |    15.00
         7 |           6 |        2 |            6.75 |    13.50
(12 rows)
```

### BONIFICACION

```text
SELECT * FROM bonificacion ORDER BY id_cliente, anio, mes;
 id_cliente | anio | mes | volumen_compras | porcentaje | importe 
------------+------+-----+-----------------+------------+---------
          1 | 2025 |   2 |          791.75 |       5.00 |   39.59
          1 | 2025 |   3 |           46.00 |       0.00 |    0.00
          2 | 2025 |   3 |         1026.00 |      10.00 |  102.60
          2 | 2025 |   4 |           28.50 |       0.00 |    0.00
          3 | 2025 |   7 |          125.00 |       2.00 |    2.50
          4 | 2026 |   1 |           34.85 |       0.00 |    0.00
(6 rows)
```

## D1: borrar una línea de pedido

```text
SELECT id_pedido, importe FROM pedido WHERE id_pedido = 1;
 id_pedido | importe 
-----------+---------
         1 |  293.75
(1 row)

SELECT * FROM bonificacion WHERE id_cliente = 1 AND anio = 2025 AND mes = 2;
 id_cliente | anio | mes | volumen_compras | porcentaje | importe 
------------+------+-----+-----------------+------------+---------
          1 | 2025 |   2 |          791.75 |       5.00 |   39.59
(1 row)

DELETE FROM linea_pedido WHERE id_pedido = 1 AND id_producto = 3;
DELETE 1
SELECT id_pedido, importe FROM pedido WHERE id_pedido = 1;
 id_pedido | importe 
-----------+---------
         1 |  249.00
(1 row)

SELECT * FROM bonificacion WHERE id_cliente = 1 AND anio = 2025 AND mes = 2;
 id_cliente | anio | mes | volumen_compras | porcentaje | importe 
------------+------+-----+-----------------+------------+---------
          1 | 2025 |   2 |          747.00 |       5.00 |   37.35
(1 row)
```

## D2: borrar un pedido

```text
DELETE FROM pedido WHERE id_pedido = 2;
DELETE 1
SELECT * FROM bonificacion WHERE id_cliente = 1 AND anio = 2025 AND mes = 2;
 id_cliente | anio | mes | volumen_compras | porcentaje | importe 
------------+------+-----+-----------------+------------+---------
          1 | 2025 |   2 |          249.00 |       2.00 |    4.98
(1 row)

SELECT COUNT(*) AS lineas_pedido_2 FROM linea_pedido WHERE id_pedido = 2;
 lineas_pedido_2 
-----------------
               0
(1 row)
```

## D3: borrar un empleado

```text
DELETE FROM empleado WHERE id_empleado = 4;
DELETE 1
SELECT id_pedido, id_empleado FROM pedido WHERE id_pedido = 6;
 id_pedido | id_empleado 
-----------+-------------
         6 |           0
(1 row)

SELECT COUNT(*) AS desempenos_emp_4 FROM desempeno WHERE id_empleado = 4;
 desempenos_emp_4 
------------------
                0
(1 row)
```

## D4: borrar productos

```text
DO $$ BEGIN
    DELETE FROM producto WHERE id_producto = 1;
EXCEPTION WHEN foreign_key_violation THEN RAISE NOTICE 'D4a OK rechazado (producto con ventas): %', SQLERRM; END $$;
NOTICE:  D4a OK rechazado (producto con ventas): update or delete on table "producto" violates foreign key constraint "linea_pedido_id_producto_fkey" on table "linea_pedido"
DELETE FROM producto WHERE id_producto = 7;
DELETE 1
SELECT COUNT(*) AS stock_producto_7 FROM stock WHERE id_producto = 7;
 stock_producto_7 
------------------
                0
(1 row)
```

## D5: borrar viveros

```text
DO $$ BEGIN
    DELETE FROM vivero WHERE id_vivero = 1;
EXCEPTION WHEN foreign_key_violation THEN RAISE NOTICE 'D5a OK rechazado (vivero con personal): %', SQLERRM; END $$;
NOTICE:  D5a OK rechazado (vivero con personal): update or delete on table "zona" violates foreign key constraint "desempeno_id_vivero_id_zona_fkey" on table "desempeno"
DELETE FROM vivero WHERE id_vivero = 5;
DELETE 1
SELECT COUNT(*) AS zonas_vivero_5 FROM zona WHERE id_vivero = 5;
 zonas_vivero_5 
----------------
              0
(1 row)
```

## D6: borrar tareas

```text
DO $$ BEGIN
    DELETE FROM tarea WHERE id_tarea = 1;
EXCEPTION WHEN foreign_key_violation THEN RAISE NOTICE 'D6a OK rechazado (tarea en uso): %', SQLERRM; END $$;
NOTICE:  D6a OK rechazado (tarea en uso): update or delete on table "tarea" violates foreign key constraint "desempeno_id_tarea_fkey" on table "desempeno"
DELETE FROM tarea WHERE id_tarea = 6;
DELETE 1
```

## D7: borrar un cliente

```text
DELETE FROM cliente WHERE id_cliente = 3;
DELETE 1
SELECT (SELECT COUNT(*) FROM pedido       WHERE id_cliente = 3) AS pedidos,
       (SELECT COUNT(*) FROM bonificacion WHERE id_cliente = 3) AS bonificaciones;
 pedidos | bonificaciones 
---------+----------------
       0 |              0
(1 row)
```

## U1: actualizar en cascada

```text
UPDATE zona SET id_zona = 9 WHERE id_vivero = 2 AND id_zona = 2;
UPDATE 1
SELECT * FROM stock WHERE id_vivero = 2 ORDER BY id_zona;
 id_vivero | id_zona | id_producto | cantidad 
-----------+---------+-------------+----------
         2 |       1 |           1 |       10
         2 |       1 |           2 |        0
         2 |       9 |           5 |       30
(3 rows)
```

## Estado final de las bonificaciones

```text
SELECT * FROM bonificacion ORDER BY id_cliente, anio, mes;
 id_cliente | anio | mes | volumen_compras | porcentaje | importe 
------------+------+-----+-----------------+------------+---------
          1 | 2025 |   2 |          249.00 |       2.00 |    4.98
          1 | 2025 |   3 |           46.00 |       0.00 |    0.00
          2 | 2025 |   3 |         1026.00 |      10.00 |  102.60
          2 | 2025 |   4 |           28.50 |       0.00 |    0.00
          4 | 2026 |   1 |           34.85 |       0.00 |    0.00
(5 rows)
```
