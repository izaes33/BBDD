/* =========================================================
   GIMNASIO - ARCHIVO ÚNICO .SQL (PK/UNIQUE INLINE)
   MariaDB / XAMPP / phpMyAdmin

   CONTENIDO:
   1) DDL: BD + tablas + claves + vistas
   2) DML: datos de ejemplo
   3) DML de PRÁCTICA con ENUNCIADOS
   ========================================================= */

-- =========================================================
-- 1) CREACIÓN DE LA BASE DE DATOS
-- =========================================================

DROP DATABASE IF EXISTS gimnasio;
CREATE DATABASE gimnasio;
USE gimnasio;


-- =========================================================
-- 2) DDL - TABLAS
-- =========================================================

-- Tabla SOCIO
CREATE TABLE socio (
  id_socio INT AUTO_INCREMENT PRIMARY KEY,
  nombre   VARCHAR(80) NOT NULL,
  telefono VARCHAR(20) UNIQUE
);

-- Tabla INSTRUCTOR
CREATE TABLE instructor (
  id_instructor INT AUTO_INCREMENT PRIMARY KEY,
  nombre        VARCHAR(80) NOT NULL,
  especialidad  VARCHAR(80) NOT NULL
);

-- Tabla SALA
CREATE TABLE sala (
  id_sala   INT AUTO_INCREMENT PRIMARY KEY,
  nombre    VARCHAR(80) NOT NULL,
  capacidad INT NOT NULL,
  CHECK (capacidad > 0)
);

CREATE TABLE sala2 (
    id_sala int AUTO_INCREMENT PRIMARY KEY,
    nombre_sala varchar(20) NOT null UNIQUE,
    capacidad int not null check(capacidad > 0) 
);

-- Tabla CLASE
CREATE TABLE clase (
  id_clase INT AUTO_INCREMENT PRIMARY KEY,
  nombre   VARCHAR(120) NOT NULL,

  -- Socio que reserva la clase
  id_socio INT NOT NULL,
    FOREIGN KEY (id_socio) REFERENCES socio (id_socio),


  -- Instructor que imparte la clase
  id_instructor INT NOT NULL,
  FOREIGN KEY (id_instructor) REFERENCES instructor (id_instructor),

  -- Sala donde se imparte la clase
  id_sala INT NOT NULL,
  FOREIGN KEY (id_sala) REFERENCES sala (id_sala)

);

-- =========================================================
-- VISTAS (Necesarias para las consultas 6 y 7)
-- =========================================================

CREATE VIEW vista_clases_detalle AS
SELECT c.id_clase, c.nombre AS nombre_clase, s.nombre AS nombre_socio, s.id_socio, i.nombre AS nombre_instructor, sa.nombre AS nombre_sala
FROM clase c
JOIN socio s ON c.id_socio = s.id_socio
JOIN instructor i ON c.id_instructor = i.id_instructor
JOIN sala sa ON c.id_sala = sa.id_sala;

CREATE VIEW vista_reservas_por_socio AS
SELECT s.nombre, COUNT(c.id_clase) AS num_clases_reservadas
FROM socio s
LEFT JOIN clase c ON s.id_socio = c.id_socio
GROUP BY s.id_socio;


-- =========================================================
-- 3) DML - DATOS DE EJEMPLO
-- =========================================================

INSERT INTO socio (nombre, telefono) VALUES
('Luis Gómez', '600111222'),
('Claudia Pérez', '600333444'),
('Nora Sánchez', '600555666'),
('Hugo Romero', '600777888');

INSERT INTO instructor (nombre, especialidad) VALUES
('María López', 'Spinning'),
('Carlos Vega', 'Crossfit'),
('Irene Navarro', 'Yoga'),
('Sergio Molina', 'Pilates');

INSERT INTO sala (nombre, capacidad) VALUES
('Sala A', 20),
('Sala B', 15),
('Sala Yoga', 25),
('Sala Funcional', 18);

INSERT INTO clase (nombre, id_socio, id_instructor, id_sala) VALUES
('Spinning - mañana',  1, 1, 1),
('Crossfit - tarde',   2, 2, 4),
('Yoga - iniciación',  3, 3, 3),
('Pilates - avanzado', 1, 4, 2),
('Yoga - intermedio',  4, 3, 3),
('Spinning - tarde',   2, 1, 1);


-- =========================================================
-- 5) CONSULTAS DML PARA PRACTICAR 
-- =========================================================

-- =========================================================
-- A) INSERT
-- ========================================================= 

-- 1) Añade un nuevo socio llamado “María García” con teléfono 600999000
INSERT INTO socio (nombre, telefono)
VALUES ('María García', '600999000');
-- Explicación: Insertamos un nuevo registro en la tabla socio definiendo los campos nombre y teléfono.

-- 2) Añade un nuevo instructor especializado en BodyPump
INSERT INTO instructor (nombre, especialidad)
VALUES ('Raúl Peña', 'BodyPump');
-- Explicación: Añadimos una fila a instructor. El id_instructor se genera solo por ser AUTO_INCREMENT.

-- 3) Añade una nueva sala llamada “Sala C” con capacidad para 12 personas
INSERT INTO sala (nombre, capacidad)
VALUES ('Sala C', 12);
-- Explicación: Creamos la sala C cumpliendo el CHECK de que la capacidad sea mayor que 0.

-- 4) Inserta una nueva clase de Spinning por la noche
--    (usa un socio, instructor y sala que ya existan)
INSERT INTO clase (nombre, id_socio, id_instructor, id_sala)
VALUES ('Spinning - noche', 1, 1, 1);
-- Explicación: Creamos el registro en clase vinculando los IDs existentes de socio(1), instructor(1) y sala(1).


/* =========================================================
   B) SELECT
========================================================= */

-- 5) Muestra todos los socios del gimnasio
SELECT * FROM socio;
-- Explicación: Selección simple de todas las columnas y filas de la tabla socio.

-- 6) Muestra todas las clases con su información completa
SELECT * FROM vista_clases_detalle ORDER BY id_clase;
-- Explicación: Consultamos la vista que une (JOIN) las tablas para ver nombres en lugar de IDs numéricos.

-- 7) Muestra cuántas clases tiene reservadas cada socio
SELECT * FROM vista_reservas_por_socio
ORDER BY num_clases_reservadas DESC;
-- Explicación: Usa la vista con la función de agregado COUNT() para contar reservas por cada socio.

-- 8) Muestra las clases reservadas por el socio con id 1
SELECT * FROM vista_clases_detalle
WHERE id_socio = 1;
-- Explicación: Filtramos los detalles de las clases donde el ID del socio sea exactamente 1.

-- 9) Muestra todas las clases de Yoga
SELECT * FROM clase WHERE nombre LIKE '%Yoga%';
-- Explicación: Usamos LIKE con el comodín % para buscar cualquier clase cuyo nombre contenga la palabra "Yoga".

-- 10) Muestra las clases que se imparten en la Sala Yoga
SELECT * FROM clase WHERE id_sala = (SELECT id_sala FROM sala WHERE nombre = 'Sala Yoga');
-- Explicación: Usamos una subconsulta para encontrar primero el ID de la 'Sala Yoga' y luego filtramos las clases por ese ID.

-- 11) Muestra los socios que no tienen ninguna clase reservada
SELECT * FROM socio WHERE id_socio NOT IN (SELECT id_socio FROM clase);
-- Explicación: Seleccionamos los socios cuyo ID no aparece en la lista de IDs de la tabla clase (subconsulta).


-- =========================================================
  -- C) UPDATE
-- ========================================================= 

-- 12) Cambia el teléfono del socio con id 1
UPDATE socio SET telefono = '611222333' WHERE id_socio = 1;
-- Explicación: Actualizamos el campo teléfono filtrando específicamente por la clave primaria del socio.

-- 13) Cambia la capacidad de la Sala Yoga a 30 personas
UPDATE sala SET capacidad = 30 WHERE nombre = 'Sala Yoga';
-- Explicación: Modificamos el valor de capacidad buscando la sala por su nombre descriptivo.

-- 14) Cambia el instructor de la clase con id 3
UPDATE clase SET id_instructor = 2 WHERE id_clase = 3;
-- Explicación: Reasignamos el ID del instructor en una clase específica.

-- 15) Cambia la sala de todas las clases de Spinning a la Sala B
UPDATE clase SET id_sala = (SELECT id_sala FROM sala WHERE nombre = 'Sala B') 
WHERE nombre LIKE '%Spinning%';
-- Explicación: Cambiamos masivamente la sala de las clases que contienen "Spinning" usando una subconsulta para obtener el ID de la 'Sala B'.


/* =========================================================
   D) DELETE
========================================================= */

-- 16) Borra la clase con id 6
DELETE FROM clase WHERE id_clase = 6;
-- Explicación: Eliminación simple de una fila específica mediante su ID.

-- 17) Intenta borrar un socio que tenga clases (observa el error)
-- DELETE FROM socio WHERE id_socio = 1;
-- Explicación: Esto daría error de "Foreign Key Constraint" porque el socio 1 tiene clases asignadas y no se pueden dejar registros huérfanos.

-- 18) Borra correctamente un socio: primero sus clases y después el socio
DELETE FROM clase WHERE id_socio = 4;
DELETE FROM socio WHERE id_socio = 4;
-- Explicación: Para mantener la integridad referencial, primero borramos las dependencias (clases) y luego el registro principal (socio).

-- 19) Borra todas las clases impartidas por instructores de Crossfit
DELETE FROM clase WHERE id_instructor IN (SELECT id_instructor FROM instructor WHERE especialidad = 'Crossfit');
-- Explicación: Borramos las clases cuyo instructor pertenece al grupo obtenido en la subconsulta (especialidad Crossfit).


/* =========================================================
   FIN DEL SCRIPT
========================================================= */