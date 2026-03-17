/* =========================================================
   BD de práctica JOINs (INNER / LEFT / RIGHT)
   ========================================================= */

CREATE DATABASE tienda_DAW;

-- =========================
-- 1) CLIENTES (1:N con pedidos)
-- =========================
CREATE TABLE clientes (
  id_cliente   INT AUTO_INCREMENT PRIMARY KEY,
  nombre       VARCHAR(80) NOT NULL,
  email        VARCHAR(120) UNIQUE,
  provincia    VARCHAR(50) NOT NULL,
  fecha_alta   DATE NOT NULL
);

-- =========================
-- 2) PRODUCTOS (N:M con pedidos)
-- =========================
CREATE TABLE productos (
  id_producto      INT AUTO_INCREMENT PRIMARY KEY,
  nombre_producto  VARCHAR(120) NOT NULL,
  categoria        VARCHAR(60) NOT NULL,
  precio_base      DECIMAL(10,2) NOT NULL,
  activo           BOOLEAN NOT NULL DEFAULT TRUE
);

-- =========================
-- 3) PEDIDOS (cabecera)
-- =========================
CREATE TABLE pedidos (
  id_pedido     INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente    INT NULL,
  fecha_compra  DATE NOT NULL,
  estado        ENUM('creado','pagado','enviado','cancelado') NOT NULL,

  CONSTRAINT fk_pedidos_clientes
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);
/* - ON UPDATE CASCADE (Efecto Dominó) ->> Mantiene la sincronización
Si decides cambiar el valor de la llave primaria en la tabla padre, el sistema busca 
automáticamente todos los registros relacionados en la tabla hija y los actualiza.
(Si el ID de un cliente cambia de "A" a "B", todas sus facturas se actualizan a "B" 
sin que tengas que hacerlo a mano).

- ON DELETE RESTRICT (Muro de Seguridad) ->> Evita "hijos huérfanos"
Impide que borres un registro en la tabla padre si todavía tiene registros asociados 
en la tabla hija. El motor de la base de datos bloquea la eliminación y lanza un error.
(Protege la integridad de los datos impidiendo que borres, por ejemplo, a un cliente 
que todavía tiene pedidos pendientes de pago. */

-- =========================
-- 4) PEDIDO_LINEAS (tabla puente N:M)
-- =========================
CREATE TABLE pedido_lineas (
  id_pedido      INT NOT NULL,
  id_producto    INT NOT NULL,
  cantidad       INT NOT NULL CHECK (cantidad > 0),
  precio_unitario DECIMAL(10,2) NOT NULL CHECK (precio_unitario >= 0),

  PRIMARY KEY (id_pedido, id_producto),

  CONSTRAINT fk_lineas_pedido
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
    ON UPDATE CASCADE
    ON DELETE CASCADE,

  CONSTRAINT fk_lineas_producto
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);
/* - ON DELETE CASCADE (Borrado Automático) ->> Automatiza la limpieza y evita datos huérfanos
Si eliminas un registro en la tabla padre, el sistema borra automáticamente todos los registros 
relacionados en la tabla hija. No pregunta ni bloquea; simplemente limpia todo lo que dependía 
de ese registro.
Es ideal para relaciones de "pertenencia" total.*/

-- =========================
-- 5) PAGOS (1:N con pedidos)
-- =========================
CREATE TABLE pagos (
  id_pago     INT AUTO_INCREMENT PRIMARY KEY,
  id_pedido   INT NOT NULL,
  metodo      ENUM('tarjeta','paypal','transferencia') NOT NULL,
  importe     DECIMAL(10,2) NOT NULL CHECK (importe >= 0),
  fecha_pago  DATE NOT NULL,
  estado      ENUM('ok','fallido','devuelto') NOT NULL,

  CONSTRAINT fk_pagos_pedidos
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

INSERT INTO clientes (nombre, email, provincia, fecha_alta) VALUES
('Ana López','ana@correo.com','Madrid','2024-09-01'),
('Luis Pérez','luis@correo.com','Sevilla','2024-09-10'),
('Marta Gil','marta@correo.com','Valencia','2024-10-05'),
('Juan Ruiz','juan@correo.com','Madrid','2024-11-12'),
('Noelia Díaz','noelia@correo.com','Granada','2024-12-01'),
('Sergio Martín','sergio@correo.com','Barcelona','2025-01-15');

INSERT INTO productos (nombre_producto, categoria, precio_base, activo) VALUES
('Portátil 14"','Informática',799.00, TRUE),
('Ratón inalámbrico','Informática',19.99, TRUE),
('Teclado mecánico','Informática',59.90, TRUE),
('Auriculares BT','Audio',39.50, TRUE),
('Monitor 24"','Informática',129.00, TRUE),
('Mochila','Accesorios',24.95, TRUE),
('Altavoz','Audio',49.90, FALSE);

-- pedidos: dejamos algunos clientes sin pedidos a propósito
INSERT INTO pedidos (id_cliente, fecha_compra, estado) VALUES
(1,'2025-01-10','pagado'),
(1,'2025-01-14','enviado'),
(2,'2025-01-20','pagado'),
(3,'2025-02-02','cancelado'),
(6,'2025-02-15','pagado'),
(NULL,'2025-02-19','creado'); -- pedido sin cliente (para practicar RIGHT/LEFT)

-- líneas: (id_pedido, id_producto) es PK compuesta: un producto aparece 1 vez por pedido
INSERT INTO pedido_lineas (id_pedido, id_producto, cantidad, precio_unitario) VALUES
(1, 1, 1, 799.00),
(1, 2, 2, 19.99),
(2, 3, 1, 59.90),
(3, 5, 1, 129.00),
(4, 6, 1, 24.95),
(5, 1, 1, 799.00),
(5, 2, 1, 19.99),
(5, 4, 1, 39.50);

-- pagos: dejamos algún pedido sin pago para practicar LEFT JOIN
INSERT INTO pagos (id_pedido, metodo, importe, fecha_pago, estado) VALUES
(1,'tarjeta',838.98,'2025-01-10','ok'),
(2,'paypal',59.90,'2025-01-14','ok'),
(3,'tarjeta',129.00,'2025-01-20','ok'),
(4,'tarjeta',24.95,'2025-02-03','devuelto'),
(5,'transferencia',858.49,'2025-02-15','ok');


--------------------------------------------------------------------------------------------

-- =========================================================
-- A) Básicos 
-- =========================================================

-- A1) Lista todos los clientes (id, nombre, provincia).
SELECT id_cliente, nombre, provincia
FROM clientes;
-- Explicación: muestra el identificador, nombre y provincia de todos los clientes.

-- A2) Lista todos los productos activos.
SELECT *
FROM productos
WHERE activo = TRUE;
-- Explicación: muestra los productos cuyo campo activo está en TRUE.

-- A3) Lista todos los pedidos y su estado.
SELECT id_pedido, estado
FROM pedidos;
-- Explicación: lista cada pedido junto a su estado actual.

-- A4) Lista todos los pagos con estado 'ok'.
SELECT *
FROM pagos
WHERE estado = 'ok';
-- Explicación: muestra solo los pagos que se han realizado correctamente.

-- A5) Lista los pedidos entre dos fechas.
SELECT *
FROM pedidos
WHERE fecha_compra BETWEEN '2025-01-01' AND '2025-01-31';
-- Explicación: muestra los pedidos realizados dentro de ese rango de fechas.


-- =========================================================
-- B) INNER JOIN
-- =========================================================

-- B1) nombre_cliente, id_pedido, fecha_compra, estado
SELECT c.nombre, p.id_pedido, p.fecha_compra, p.estado
FROM clientes c
INNER JOIN pedidos p ON c.id_cliente = p.id_cliente;
-- Explicación: muestra pedidos que tienen cliente asociado.

-- B2) pedidos con pago
SELECT p.id_pedido, pa.metodo, pa.importe, pa.fecha_pago
FROM pedidos p
INNER JOIN pagos pa ON p.id_pedido = pa.id_pedido;
-- Explicación: muestra solo pedidos que tienen registro de pago.

-- B3) clientes con pagos
SELECT c.nombre, p.id_pedido, pa.importe
FROM clientes c
INNER JOIN pedidos p ON c.id_cliente = p.id_cliente
INNER JOIN pagos pa ON p.id_pedido = pa.id_pedido;
-- Explicación: conecta cliente → pedido → pago.

-- B4) productos por pedido
SELECT pl.id_pedido, pr.nombre_producto, pl.cantidad, pl.precio_unitario
FROM pedido_lineas pl
INNER JOIN productos pr ON pl.id_producto = pr.id_producto;
-- Explicación: muestra qué productos contiene cada pedido.

-- B5) cliente, producto y cantidad
SELECT c.nombre, pr.nombre_producto, pl.cantidad
FROM clientes c
INNER JOIN pedidos p ON c.id_cliente = p.id_cliente
INNER JOIN pedido_lineas pl ON p.id_pedido = pl.id_pedido
INNER JOIN productos pr ON pl.id_producto = pr.id_producto;
-- Explicación: recorre toda la relación cliente → pedido → producto.

-- B6) pedidos con portátil 14
SELECT p.id_pedido
FROM pedidos p
INNER JOIN pedido_lineas pl ON p.id_pedido = pl.id_pedido
INNER JOIN productos pr ON pl.id_producto = pr.id_producto
WHERE pr.nombre_producto = 'Portátil 14"';
-- Explicación: busca pedidos que incluyan ese producto.

-- B7) pedidos con productos de Audio
SELECT DISTINCT p.id_pedido
FROM pedidos p
INNER JOIN pedido_lineas pl ON p.id_pedido = pl.id_pedido
INNER JOIN productos pr ON pl.id_producto = pr.id_producto
WHERE pr.categoria = 'Audio';
-- Explicación: obtiene pedidos que contienen productos de esa categoría.

/*Cuando una columna tiene muchos valores repetidos (por ejemplo, una lista de 
países en una tabla de clientes), SELECT DISTINCT te permite obtener la lista 
de valores existentes sin que se repitan.
Sin DISTINCT: Verías una fila por cada registro (ej. 100 veces "España").
Con DISTINCT: Verías una sola vez cada valor diferente (ej. una sola vez "España").*/


-- =========================================================
-- C) LEFT JOIN
-- =========================================================

-- C1) clientes y pedidos
SELECT c.nombre, p.id_pedido
FROM clientes c
LEFT JOIN pedidos p ON c.id_cliente = p.id_cliente;
-- Explicación: muestra todos los clientes, tengan o no pedidos.

-- C2) clientes sin pedidos
SELECT c.nombre
FROM clientes c
LEFT JOIN pedidos p ON c.id_cliente = p.id_cliente
WHERE p.id_pedido IS NULL;
-- Explicación: detecta clientes que no tienen pedidos.

-- C3) pedidos y pagos
SELECT p.id_pedido, pa.importe
FROM pedidos p
LEFT JOIN pagos pa ON p.id_pedido = pa.id_pedido;
-- Explicación: muestra todos los pedidos aunque no tengan pago.

-- C4) pedidos sin pagos
SELECT p.id_pedido
FROM pedidos p
LEFT JOIN pagos pa ON p.id_pedido = pa.id_pedido
WHERE pa.id_pago IS NULL;
-- Explicación: identifica pedidos que aún no tienen pago.

-- C5) productos y unidades vendidas
SELECT 
    pr.nombre_producto,                -- Selecciona el nombre desde la tabla productos
    SUM(pl.cantidad) AS unidades       -- Suma todas las cantidades de los pedidos y renombra la columna como 'unidades'
FROM productos pr                      -- Define 'productos' como la tabla principal (alias 'pr')
LEFT JOIN pedido_lineas pl             -- Une con 'pedido_lineas' (alias 'pl'), manteniendo todos los productos
    ON pr.id_producto = pl.id_producto -- La unión se hace donde coincidan los IDs de producto
GROUP BY pr.id_producto;               -- Agrupa los resultados por producto para que la suma (SUM) funcione correctamente
-- Explicación: cuenta unidades vendidas por producto, incluyendo los no vendidos.

-- C6) productos nunca vendidos
SELECT pr.nombre_producto
FROM productos pr
LEFT JOIN pedido_lineas pl ON pr.id_producto = pl.id_producto
WHERE pl.id_producto IS NULL;
-- Explicación: detecta productos que nunca aparecen en pedidos.

/* DIFERENCIA ENTRE INNER, LEFT Y JOIN:
1. INNER JOIN (La intersección): ->> Resultado: Solo lo común.
Muestra solo las filas que tienen coincidencia en ambas tablas.
2. LEFT JOIN (Prioridad izquierda) ->> Muestra todos los datos de la tabla de la izquierda (FROM), 
más las coincidencias que encuentre en la derecha.
(Si no hay coincidencia: Los campos de la Tabla que queda a la derecha aparecerán vacíos (NULL)).
3. RIGHT JOIN (Prioridad derecha) ->> Es el espejo del anterior.
(Se usa mucho menos que el LEFT JOIN, ya que casi siempre puedes lograr lo mismo cambiando el orden de las tablas). 
LEFT JOIN -> Todo de from (el que está a la izquierda) y coincdencias
RIGHT JOIN -> Coincidencias en from (que se ubica a la derecha) y todo de la otra */


-- =========================================================
-- D) RIGHT JOIN
-- =========================================================

-- D1) pedidos y cliente
SELECT p.id_pedido, c.nombre
FROM clientes c
RIGHT JOIN pedidos p ON c.id_cliente = p.id_cliente;
-- Explicación: muestra todos los pedidos aunque no tengan cliente.

-- D2) pedidos sin cliente
SELECT p.id_pedido
FROM clientes c
RIGHT JOIN pedidos p ON c.id_cliente = p.id_cliente
WHERE c.id_cliente IS NULL;
-- Explicación: detecta pedidos sin cliente asignado.


-- =========================================================
-- E) FILTRO EN ON + WHERE vs FILTRO EN ON + AND
-- =========================================================

-- E1) filtro en WHERE
SELECT 
    c.nombre,            -- El nombre del cliente
    p.id_pedido          -- El ID del pedido asociado
FROM clientes c          -- Tabla "maestra" (Izquierda)
LEFT JOIN pedidos p      -- Intenta traer todos los clientes, tengan o no pedidos
    ON c.id_cliente = p.id_cliente 
WHERE p.estado = 'pagado'; -- FILTRO CRÍTICO: Solo filas donde el estado es 'pagado'
/* Explicación: A primera vista parece que van a obtenerse todos los clientes, 
pero la cláusula WHERE cambia las reglas del juego. 
el WHERE p.estado = 'pagado' convierte esta consulta, en la práctica, en un INNER JOIN. */

-- E2) filtro en ON
SELECT 
    c.nombre,                -- El nombre del cliente (aparecerá SIEMPRE)
    p.id_pedido              -- El ID del pedido (solo aparecerá si está pagado)
FROM clientes c              -- Tabla maestra: Queremos ver a todos los clientes
LEFT JOIN pedidos p          -- Intentamos unir con pedidos
    ON c.id_cliente = p.id_cliente 
    AND p.estado = 'pagado'; -- CONDICIÓN DE UNIÓN: Solo "pega" el pedido si está pagado
/* A diferencia del ejemplo anterior con WHERE, aquí el filtro se aplica antes de terminar 
de montar la tabla. Esto significa:
No se eliminan filas de Clientes: Como es un LEFT JOIN, la tabla de la izquierda (clientes) manda. 
(Si un cliente no tiene pedidos pagados, no desaparece de la lista).
Filtrado selectivo de la derecha: El motor de la base de datos dice: "Voy a buscar pedidos 
para este cliente, pero solo me interesan los que digan 'pagado'. 
(Si encuentro uno, lo pongo al lado del nombre; si no lo encuentro (o está 'pendiente'), pongo un NULL"). */

/*Comparativa:
Característica    AND (en el ON)                                  WHERE
Momento           Se aplica durante la unión.                     Se aplica después de la unión.
Filas NULL        Las mantiene (no elimina la fila principal).    Las elimina (si el NULL no cumple el filtro).
Función           Define la relación entre tablas.                Define el criterio de búsqueda final.*/


-- =========================================================
-- G) Subconsultas
-- =========================================================

-- G1) clientes con pedidos
SELECT nombre
FROM clientes
WHERE id_cliente IN (SELECT id_cliente FROM pedidos);
-- Explicación: devuelve clientes cuyo id aparece en la tabla pedidos.

-- G3) clientes sin pedidos
SELECT *
FROM clientes c
WHERE NOT EXISTS (
  SELECT 1
  FROM pedidos p
  WHERE p.id_cliente = c.id_cliente
);
-- Explicación: muestra clientes que no tienen ningún pedido.

-- G4) clientes con pago OK
SELECT *
FROM clientes c
WHERE EXISTS (
  SELECT 1
  FROM pedidos p
  JOIN pagos pa ON p.id_pedido = pa.id_pedido
  WHERE p.id_cliente = c.id_cliente
  AND pa.estado = 'ok'
);
-- Explicación: comprueba si el cliente tiene al menos un pago correcto.

-- G5) pedidos con total > 500
SELECT *
FROM pedidos p
WHERE (
  SELECT SUM(cantidad * precio_unitario)
  FROM pedido_lineas pl
  WHERE pl.id_pedido = p.id_pedido
) > 500;
-- Explicación: calcula el total del pedido y filtra los que superan 500€.