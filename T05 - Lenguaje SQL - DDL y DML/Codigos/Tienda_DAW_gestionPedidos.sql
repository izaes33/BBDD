CREATE DATABASE Tienda_DAW;
USE Tienda_DAW;

-- Clientes
CREATE TABLE clientes (
  id_cliente INT AUTO_INCREMENT NOT NULL,
  nombre     VARCHAR(60)  NOT NULL,
  email      VARCHAR(100) NOT NULL UNIQUE,
  ciudad     VARCHAR(50)  NOT NULL,
  fecha_alta DATE         NOT NULL,
  PRIMARY KEY (id_cliente)
);

-- Categorías
CREATE TABLE categorias (
  id_categoria INT AUTO_INCREMENT NOT NULL,
  nombre       VARCHAR(60) NOT NULL UNIQUE,
  PRIMARY KEY (id_categoria)
);

-- Productos (1:N con categorías)
CREATE TABLE productos (
  id_producto  INT AUTO_INCREMENT NOT NULL,
  nombre       VARCHAR(80)  NOT NULL,
  precio       DECIMAL(10,2) NOT NULL,
  stock        INT NOT NULL,
  id_categoria INT NOT NULL,
 
  PRIMARY KEY (id_producto),
  
  CONSTRAINT fk_productos_categorias
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

-- Pedidos (1:N con clientes)
CREATE TABLE pedidos (
  id_pedido   INT AUTO_INCREMENT NOT NULL,
  id_cliente  INT NOT NULL,
  fecha       DATE NOT NULL,
  estado      ENUM('PENDIENTE','PAGADO','ENVIADO','CANCELADO') NOT NULL,
  total       DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (id_pedido),

  CONSTRAINT fk_pedidos_clientes
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

-- Líneas de pedido (N:M pedidos-productos) tabla intermedia
CREATE TABLE lineas_pedido (
  id_pedido       INT NOT NULL,
  id_producto     INT NOT NULL,
  cantidad        INT NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
 
  PRIMARY KEY (id_pedido, id_producto),

  CONSTRAINT fk_lineas_pedidos
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  
    CONSTRAINT fk_lineas_productos
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

-- INSERCIONES DE DATOS
INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_alta) VALUES
(1,'Ana Ruiz','ana@correo.es','Sevilla','2024-01-10'),
(2,'Luis Pérez','luis@correo.es','Madrid','2024-02-05'),
(3,'Marta Gil','marta@correo.es','Valencia','2024-03-01');

INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_alta) VALUES 
(1000,'Maria Ruiz','maria@correo.es','Sevilla','2024-01-10');

INSERT INTO clientes (nombre, email, ciudad, fecha_alta) VALUES ('Pedro Ruiz','pr@correo.es','Madrid','2024-01-10');

INSERT INTO categorias (id_categoria, nombre) VALUES
(10,'Periféricos'),
(11,'Almacenamiento'),
(12,'Redes');

INSERT INTO productos (id_producto, nombre, precio, stock, id_categoria) VALUES
(100,'Teclado mecánico',79.90,15,10),
(101,'Ratón gaming',39.90,40,10),
(102,'SSD 1TB',89.00,20,11),
(103,'Router WiFi 6',129.00,8,12);

INSERT INTO pedidos (id_pedido, id_cliente, fecha, estado, total) VALUES
(500,1,'2024-05-03','PAGADO',119.80),
(501,1,'2024-05-10','PENDIENTE',89.00),
(502,2,'2024-05-12','ENVIADO',129.00),
(503,3,'2024-05-13','CANCELADO',39.90);

INSERT INTO lineas_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES
(500,100,1,79.90),
(500,101,1,39.90),
(501,102,1,89.00),
(502,103,1,129.00),
(503,101,1,39.90);

-- ==========================================
-- Consultas de práctica 
-- ==========================================

-- A) SELECT / WHERE / operadores

-- 1) Clientes de Sevilla
SELECT * FROM clientes WHERE ciudad = 'Sevilla';
-- Explicación: Filtra todos los campos de la tabla clientes donde el valor de la columna 'ciudad' coincida exactamente con el texto dado.

-- 2) Productos con stock bajo (<10)
SELECT * FROM productos WHERE stock < 10;
-- Explicación: Selecciona los productos cuya cantidad disponible (stock) es estrictamente menor que 10 unidades.

-- 3) Pedidos entre dos fechas (incluye extremos)
SELECT * FROM pedidos WHERE fecha BETWEEN '2024-05-01' AND '2024-05-31';
-- Explicación: El operador BETWEEN selecciona registros dentro de un rango inclusivo para el campo 'fecha'.

-- 4) Pedidos con estado en lista
SELECT * FROM pedidos WHERE estado IN ('PAGADO', 'ENVIADO');
-- Explicación: El operador IN permite comparar un campo contra una lista de valores posibles, abreviando el uso de múltiples OR.

-- 5) Productos cuyo nombre empieza por 'R'
SELECT * FROM productos WHERE nombre LIKE 'R%';
-- Explicación: El operador LIKE con el comodín '%' busca patrones. 'R%' indica que el texto debe comenzar por R y seguir con cualquier contenido.

-- 6) Emails que contienen 'correo'
SELECT email FROM clientes WHERE email LIKE '%correo%';
-- Explicación: Al poner el comodín '%' al principio y al final, buscamos la cadena 'correo' en cualquier posición de la columna email.

-- 7) Total >= 100 y NO cancelado
SELECT * FROM pedidos WHERE total >= 100 AND estado <> 'CANCELADO';
-- Explicación: Combina una condición lógica de comparación numérica con una de desigualdad (<> o !=) usando el operador AND.

-- 8) Productos de categorías 10 o 12 (IN)
SELECT * FROM productos WHERE id_categoria IN (10, 12);
-- Explicación: Filtra productos que pertenezcan a cualquiera de los IDs de categoría especificados en el conjunto.

-- 9) Pedidos con total NO en {89,129} (NOT IN)
SELECT * FROM pedidos WHERE total NOT IN (89, 129);
-- Explicación: Excluye los pedidos cuyo importe total sea exactamente 89 o 129.

-- 10) Pedidos PAGADOS o ENVIADOS (OR)
SELECT * FROM pedidos WHERE estado = 'PAGADO' OR estado = 'ENVIADO';
-- Explicación: Selecciona registros que cumplan al menos una de las dos condiciones especificadas.

-- 11) Pedidos NO (PAGADO) (NOT)
SELECT * FROM pedidos WHERE NOT estado = 'PAGADO';
-- Explicación: El operador NOT invierte la condición, devolviendo todos los pedidos que tengan cualquier estado distinto a 'PAGADO'.

-- 12) Productos con precio entre 40 y 100
SELECT * FROM productos WHERE precio BETWEEN 40 AND 100;
-- Explicación: Filtra productos cuyo precio esté en el rango inclusivo de 40 a 100.


-- B) ORDER BY / LIMIT / DISTINCT

-- 13) Productos más caros primero
SELECT * FROM productos ORDER BY precio DESC;
-- Explicación: ORDER BY ordena los resultados; DESC especifica orden descendente (de mayor a menor).

-- 14) Top 2 productos con menos stock
SELECT * FROM productos ORDER BY stock ASC LIMIT 2;
-- Explicación: Ordena de menor a mayor stock (ASC) y LIMIT restringe el resultado a las primeras 2 filas.

-- 15) Ciudades distintas de clientes
SELECT DISTINCT ciudad FROM clientes;
-- Explicación: DISTINCT elimina los duplicados del conjunto de resultados, mostrando cada ciudad una sola vez.

-- 16) Pedidos: primero los más recientes
SELECT * FROM pedidos ORDER BY fecha DESC;
-- Explicación: Ordena cronológicamente de la fecha más cercana a la más antigua.


-- C) Agregadas + GROUP BY + HAVING

-- 17) Número de pedidos por estado
SELECT estado, COUNT(*) as total_pedidos FROM pedidos GROUP BY estado;
-- Explicación: Agrupa los registros por el valor de 'estado' y cuenta cuántas filas hay en cada grupo.

-- 18) Facturación total por estado (solo estados con total > 100)
SELECT estado, SUM(total) FROM pedidos GROUP BY estado HAVING SUM(total) > 100;
-- Explicación: Suma la columna 'total' por grupos. HAVING actúa como un WHERE pero sobre los resultados ya agrupados/calculados.

-- 19) Precio medio y stock total por categoría (en productos)
SELECT id_categoria, AVG(precio), SUM(stock) FROM productos GROUP BY id_categoria;
-- Explicación: Calcula el promedio (AVG) y la suma total por cada grupo de categoría.

-- 20) Unidades vendidas por producto (en lineas_pedido)
SELECT id_producto, SUM(cantidad) FROM lineas_pedido GROUP BY id_producto;
-- Explicación: Suma la cantidad de productos vendidos agrupándolos por su identificador de producto.

-- 21) Pedido más caro y más barato (MAX/MIN)
SELECT MAX(total) as mas_caro, MIN(total) as mas_barato FROM pedidos;
-- Explicación: Las funciones MAX y MIN devuelven los valores extremos de la columna 'total' en toda la tabla.

-- 22) Precio máximo, mínimo y medio de productos
SELECT MAX(precio), MIN(precio), AVG(precio) FROM productos;
-- Explicación: Estadísticos básicos de la columna precio para todos los productos de la tienda.

-- 23) Stock total en la tienda
SELECT SUM(stock) FROM productos;
-- Explicación: Suma el stock de todos los artículos registrados en la tabla productos.

-- 24) Estados con 2 o más pedidos (HAVING COUNT)
SELECT estado FROM pedidos GROUP BY estado HAVING COUNT(*) >= 2;
-- Explicación: Agrupa por estado y filtra aquellos grupos que tengan un recuento de filas igual o superior a 2.


-- D) Subconsultas (SIN JOIN): IN / NOT IN / escalares

-- 25) Clientes que han hecho algún pedido (IN)
SELECT * FROM clientes WHERE id_cliente IN (SELECT id_cliente FROM pedidos);
-- Explicación: Selecciona clientes cuyo ID aparezca en la lista de IDs de la tabla pedidos.

-- 26) Clientes SIN pedidos (NOT IN)
SELECT * FROM clientes WHERE id_cliente NOT IN (SELECT id_cliente FROM pedidos);
-- Explicación: Selecciona clientes cuyo ID no figure en ningún registro de la tabla pedidos.

-- 27) Pedidos por encima de la media del total
SELECT * FROM pedidos WHERE total > (SELECT AVG(total) FROM pedidos);
-- Explicación: Usa una subconsulta escalar que devuelve un único valor (la media) para compararlo con el total de cada pedido.

-- 28) Productos que aparecen en alguna línea de pedido
SELECT * FROM productos WHERE id_producto IN (SELECT id_producto FROM lineas_pedido);
-- Explicación: Filtra los productos que han sido incluidos al menos una vez en una línea de detalle de pedido.

-- 29) Productos que NO aparecen en líneas (nunca vendidos)
SELECT * FROM productos WHERE id_producto NOT IN (SELECT id_producto FROM lineas_pedido);
-- Explicación: Identifica productos que no tienen ninguna referencia en la tabla intermedia de ventas.

-- 30) Pedidos cuyo total es igual al máximo total
SELECT * FROM pedidos WHERE total = (SELECT MAX(total) FROM pedidos);
-- Explicación: Busca el o los pedidos que coinciden exactamente con el valor más alto registrado en la tabla.


-- E) EXISTS / NOT EXISTS (correlacionadas)

-- 31) Clientes que tienen al menos 1 pedido (EXISTS)
SELECT nombre FROM clientes c WHERE EXISTS (SELECT 1 FROM pedidos p WHERE p.id_cliente = c.id_cliente);
-- Explicación: Comprueba para cada cliente si existe al menos una fila en pedidos que coincida con su ID.

-- 32) Clientes sin pedidos (NOT EXISTS)
SELECT nombre FROM clientes c WHERE NOT EXISTS (SELECT 1 FROM pedidos p WHERE p.id_cliente = c.id_cliente);
-- Explicación: Devuelve los clientes para los cuales la subconsulta de pedidos no encuentra ninguna coincidencia.

-- 33) Pedidos que tienen líneas (EXISTS)
SELECT * FROM pedidos p WHERE EXISTS (SELECT 1 FROM lineas_pedido l WHERE l.id_pedido = p.id_pedido);
-- Explicación: Verifica que el pedido tenga al menos una línea de detalle asociada en la tabla lineas_pedido.

-- 34) Pedidos que NO tienen líneas (NOT EXISTS) (por si existieran)
SELECT * FROM pedidos p WHERE NOT EXISTS (SELECT 1 FROM lineas_pedido l WHERE l.id_pedido = p.id_pedido);
-- Explicación: Busca pedidos "huérfanos" que se crearon pero no tienen productos asociados en el detalle.

-- 35) Para cada cliente, número de pedidos (columna calculada)
SELECT nombre, (SELECT COUNT(*) FROM pedidos p WHERE p.id_cliente = c.id_cliente) as num_pedidos FROM clientes c;
-- Explicación: Por cada fila de clientes, ejecuta una subconsulta que cuenta sus pedidos específicos y lo muestra como una columna nueva.

-- 36) Para cada pedido, número de líneas (columna calculada)
SELECT id_pedido, (SELECT COUNT(*) FROM lineas_pedido l WHERE l.id_pedido = p.id_pedido) as num_lineas FROM pedidos p;
-- Explicación: Similar a la anterior, cuenta el número de artículos distintos (líneas) que componen cada pedido.


-- F) Funciones de fecha y texto

-- 37) Clientes dados de alta en 2024 (YEAR)
SELECT * FROM clientes WHERE YEAR(fecha_alta) = 2024;
-- Explicación: Extrae la parte del año de la fecha para compararla con el número 2024.

-- 38) Pedidos del mes de mayo (MONTH)
SELECT * FROM pedidos WHERE MONTH(fecha) = 5;
-- Explicación: Utiliza la función MONTH para filtrar solo aquellos registros ocurridos en el quinto mes del año.

-- 39) Emails en mayúsculas (UPPER)
SELECT UPPER(email) FROM clientes;
-- Explicación: Transforma visualmente todos los caracteres de la columna email a su variante en mayúsculas.

-- 40) Longitud del nombre del producto (CHAR_LENGTH)
SELECT nombre, CHAR_LENGTH(nombre) FROM productos;
-- Explicación: Devuelve el número de caracteres que componen el nombre de cada producto.


-- G) INSERT / UPDATE / DELETE (PRUEBAS)

-- 41) Insertar un cliente nuevo con todos los atributos
INSERT INTO clientes (nombre, email, ciudad, fecha_alta) VALUES ('Carlos Soler', 'carlos@correo.es', 'Málaga', CURDATE());
-- Explicación: Añade un nuevo registro. Usamos CURDATE() para que la fecha de alta sea la del día de hoy automáticamente.

-- 42) Subir stock a 25 del producto 103
UPDATE productos SET stock = 25 WHERE id_producto = 103;
-- Explicación: Modifica el valor de la columna stock para un registro específico identificado por su clave primaria.

-- 43) Rebajar un 10% los productos de precio > 100
UPDATE productos SET precio = precio * 0.90 WHERE precio > 100;
-- Explicación: Actualiza el precio multiplicándolo por 0.90 (lo que equivale a restar el 10%) solo para los que cumplen el filtro.

-- 44) Poner stock a 0 a productos sin ventas (NOT IN)
UPDATE productos SET stock = 0 WHERE id_producto NOT IN (SELECT id_producto FROM lineas_pedido);
-- Explicación: Combina UPDATE con una subconsulta para identificar productos que nunca se han vendido y vaciar su stock.

-- 45) Borrar pedidos cancelados
DELETE FROM pedidos WHERE estado = 'CANCELADO';
-- Explicación: Elimina físicamente las filas de la tabla pedidos cuyo estado sea 'CANCELADO'.

-- 46) Borrar líneas de un pedido concreto
DELETE FROM lineas_pedido WHERE id_pedido = 501;
-- Explicación: Elimina el detalle (las líneas) asociadas al pedido 501.

-- 47) Borrar clientes sin pedidos (siempre que no estén referenciados)
DELETE FROM clientes WHERE id_cliente NOT IN (SELECT id_cliente FROM pedidos);
-- Explicación: Borra aquellos clientes que no tienen registros vinculados en la tabla de pedidos.


-- H) ALTER TABLE (estructura) 

-- 48) Añadir columna teléfono a clientes
ALTER TABLE clientes ADD COLUMN telefono VARCHAR(15);
-- Explicación: Modifica la estructura de la tabla existente para insertar un nuevo campo llamado 'telefono'.

-- 49) Cambiar longitud del nombre en productos
ALTER TABLE productos MODIFY COLUMN nombre VARCHAR(150) NOT NULL;
-- Explicación: Altera la definición de una columna existente para permitir nombres más largos (de 80 a 150 caracteres).

-- 50) Renombrar columna total -> total_eur 
ALTER TABLE pedidos RENAME COLUMN total TO total_eur;
-- Explicación: Cambia el nombre identificativo de la columna 'total' por uno más específico sin perder los datos.