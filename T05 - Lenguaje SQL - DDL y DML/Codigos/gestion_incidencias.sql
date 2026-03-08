-- Base de datos para ejercicios GROUP BY y HAVING

CREATE DATABASE gestion_incidencias;
USE gestion_incidencias;

-- Tabla usuarios
CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50),
    rol VARCHAR(20)
);

INSERT INTO usuarios (nombre, rol) VALUES
('Ana', 'admin'),
('Luis', 'admin'),
('Carlos', 'tecnico'),
('Marta', 'tecnico'),
('Sonia', 'usuario'),
('Pedro', 'usuario'),
('Lucia', 'usuario');

-- Tabla incidencias
CREATE TABLE incidencias (
    id_incidencia INT AUTO_INCREMENT PRIMARY KEY,
    estado VARCHAR(20),
    prioridad VARCHAR(20)
);

INSERT INTO incidencias (estado, prioridad) VALUES
('abierta', 'alta'), ('abierta', 'alta'), ('abierta', 'alta'), ('abierta', 'alta'),
('abierta', 'alta'), ('abierta', 'alta'), ('abierta', 'media'), ('abierta', 'media'),
('abierta', 'media'), ('abierta', 'baja'), ('en_proceso', 'alta'), ('en_proceso', 'media'),
('en_proceso', 'media'), ('resuelta', 'alta'), ('resuelta', 'media'), ('resuelta', 'baja'),
('resuelta', 'baja'), ('resuelta', 'baja'), ('resuelta', 'baja'), ('resuelta', 'baja'),
('resuelta', 'baja');

-- Tabla reparaciones
CREATE TABLE reparaciones (
    id_reparacion INT AUTO_INCREMENT PRIMARY KEY,
    vehiculo_id INT,
    precio DECIMAL(8,2)
);

INSERT INTO reparaciones (vehiculo_id, precio) VALUES
(1, 120.50), (1, 80.00), (1, 200.00), (2, 300.00),
(2, 150.00), (3, 90.00), (3, 110.00), (3, 60.00);


-- =========================================================
-- CONSULTAS DML: GROUP BY Y HAVING
-- =========================================================

-- Usuarios por rol
SELECT rol, COUNT(*) AS total_usuarios 
FROM usuarios 
GROUP BY rol;
-- Explicación: Agrupa los registros por la columna 'rol' y cuenta cuántas filas pertenecen a cada grupo (admin, técnico, etc.).

-- Incidencias por prioridad
SELECT prioridad, COUNT(*) AS total 
FROM incidencias 
GROUP BY prioridad;
-- Explicación: Divide la tabla en grupos según su prioridad y nos devuelve el volumen de incidencias para cada nivel.

-- Estados con más de 10 incidencias
SELECT estado, COUNT(*) 
FROM incidencias 
GROUP BY estado 
HAVING COUNT(*) > 10;
-- Explicación: Aquí usamos HAVING porque queremos filtrar un resultado calculado (el conteo). Solo nos mostrará estados muy "congestionados".

-- Precio medio de reparaciones por vehículo
SELECT vehiculo_id, AVG(precio) AS precio_medio 
FROM reparaciones 
GROUP BY vehiculo_id;
-- Explicación: AVG() calcula el promedio de la columna precio para cada ID de vehículo distinto.

-- Incidencias por estado excluyendo resueltas
SELECT estado, COUNT(*) 
FROM incidencias 
WHERE estado <> 'resuelta' 
GROUP BY estado;
-- Explicación: Primero eliminamos las resueltas con WHERE (antes de agrupar) y luego contamos lo que queda por estado.

-- Prioridades con más de 5 incidencias abiertas
SELECT prioridad, COUNT(*) 
FROM incidencias 
WHERE estado = 'abierta' 
GROUP BY prioridad 
HAVING COUNT(*) > 5;
-- Explicación: Filtramos primero las 'abiertas', agrupamos por prioridad y finalmente usamos HAVING para ver cuáles superan el umbral de 5.

-- Roles que tengan más de 1 usuario
SELECT rol, COUNT(*) 
FROM usuarios 
GROUP BY rol 
HAVING COUNT(*) > 1;
-- Explicación: Útil para identificar roles compartidos. Filtra los grupos que tienen más de una persona asignada.

-- Número total de usuarios (sin agrupar)
SELECT COUNT(*) AS total_global_usuarios 
FROM usuarios;
-- Explicación: Al no haber GROUP BY, COUNT(*) actúa sobre toda la tabla devolviendo un único valor escalar.

-- Número total de incidencias
SELECT COUNT(*) AS total_global_incidencias 
FROM incidencias;
-- Explicación: Conteo total de filas en la tabla incidencias.

-- Incidencias por estado y prioridad
SELECT estado, prioridad, COUNT(*) 
FROM incidencias 
GROUP BY estado, prioridad;
-- Explicación: Agrupamiento múltiple. Crea subgrupos (ej. 'abierta-alta', 'abierta-media') para un análisis más detallado.

-- Estados que tengan incidencias de prioridad alta
SELECT estado 
FROM incidencias 
WHERE prioridad = 'alta' 
GROUP BY estado;
-- Explicación: Filtra filas con prioridad alta y luego las agrupa por estado para evitar duplicados en la lista de resultados.

-- Estados con más de 2 incidencias no resueltas
SELECT estado, COUNT(*) 
FROM incidencias 
WHERE estado <> 'resuelta' 
GROUP BY estado 
HAVING COUNT(*) > 2;
-- Explicación: Combina exclusión de filas (WHERE), agrupamiento y filtrado de grupos (HAVING).

-- Prioridad con más incidencias en estado abierto
SELECT prioridad, COUNT(*) 
FROM incidencias 
WHERE estado = 'abierta' 
GROUP BY prioridad 
ORDER BY COUNT(*) DESC 
LIMIT 1;
-- Explicación: Filtramos abiertas, contamos, ordenamos de mayor a menor y nos quedamos solo con la primera fila (la más frecuente).

-- Número de incidencias por estado (ordenadas de mayor a menor)
SELECT estado, COUNT(*) 
FROM incidencias 
GROUP BY estado 
ORDER BY COUNT(*) DESC;
-- Explicación: Agrupa y cuenta, usando ORDER BY para poner los estados con más volumen al principio.

-- Precio máximo de reparación por vehículo
SELECT vehiculo_id, MAX(precio) 
FROM reparaciones 
GROUP BY vehiculo_id;
-- Explicación: Identifica la reparación más costosa realizada a cada vehículo individual.

-- Vehículos con un precio medio de reparación superior a 100 €
SELECT vehiculo_id, AVG(precio) 
FROM reparaciones 
GROUP BY vehiculo_id 
HAVING AVG(precio) > 100;
-- Explicación: Calcula la media por vehículo y descarta aquellos cuyos gastos promedio son bajos o moderados (<= 100).