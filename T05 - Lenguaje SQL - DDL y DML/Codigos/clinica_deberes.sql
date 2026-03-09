/* =========================================================
   CLÍNICA - SCRIPT COMPLETO (MariaDB / XAMPP / phpMyAdmin)
   ========================================================= */

-- 1) CREAR BD
DROP DATABASE IF EXISTS clinica;
CREATE DATABASE clinica;
USE clinica;

-- =========================================================
-- TABLAS
-- =========================================================

CREATE TABLE paciente (
  id_paciente INT AUTO_INCREMENT PRIMARY KEY,
  nombre      VARCHAR(60) NOT NULL,
  apellidos   VARCHAR(90) NOT NULL,
  telefono    VARCHAR(20) UNIQUE
);

CREATE TABLE medico (
  id_medico    INT AUTO_INCREMENT PRIMARY KEY,
  nombre       VARCHAR(60) NOT NULL,
  apellidos    VARCHAR(90) NOT NULL,
  especialidad VARCHAR(80) NOT NULL
);

CREATE TABLE tratamiento (
  id_tratamiento INT AUTO_INCREMENT PRIMARY KEY,
  descripcion    VARCHAR(200) NOT NULL
);

CREATE TABLE cita (
  id_cita INT AUTO_INCREMENT PRIMARY KEY,
  fecha   DATETIME NOT NULL,
  id_paciente INT NOT NULL,
  FOREIGN KEY (id_paciente) REFERENCES paciente (id_paciente)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE atiende (
  id_cita INT NOT NULL,
  id_medico INT NOT NULL,
  PRIMARY KEY (id_cita, id_medico),
  FOREIGN KEY (id_cita) REFERENCES cita (id_cita),
  FOREIGN KEY (id_medico) REFERENCES medico (id_medico)
);

CREATE TABLE incluye (
  id_cita INT NOT NULL,
  id_tratamiento INT NOT NULL,
  PRIMARY KEY (id_cita, id_tratamiento),
  FOREIGN KEY (id_cita) REFERENCES cita (id_cita),
  FOREIGN KEY (id_tratamiento) REFERENCES tratamiento (id_tratamiento)
);

-- DATOS DE EJEMPLO
INSERT INTO paciente (nombre, apellidos, telefono) VALUES
('Lucía', 'Pérez Martín', '600111222'),
('Adrián', 'Gómez Ruiz', '600333444'),
('Nora', 'Sánchez Díaz', '600555666'),
('Hugo', 'Romero Paredes', '600777888'),
('Marta', 'Santos León', '600999000');

INSERT INTO medico (nombre, apellidos, especialidad) VALUES
('Marta',  'López Campos',     'Pediatría'),
('Carlos', 'Fernández Vega',   'Traumatología'),
('Irene',  'Navarro Gil',      'Dermatología'),
('Sergio', 'García Molina',    'Medicina general'),
('Laura',  'Ortega Prieto',    'Oftalmología');

INSERT INTO tratamiento (descripcion) VALUES
('Consulta general'), ('Radiografía'), ('Curación de herida'),
('Revisión dermatológica'), ('Infiltración'), ('Revisión pediátrica'),
('Revisión de vista'), ('Receta y medicación');

INSERT INTO cita (fecha, id_paciente) VALUES
('2026-02-02 10:00:00', 1), ('2026-02-02 12:30:00', 2),
('2026-02-03 09:15:00', 1), ('2026-02-03 11:00:00', 3),
('2026-02-04 16:45:00', 4), ('2026-02-05 08:30:00', 5);

INSERT INTO atiende (id_cita, id_medico) VALUES (1, 1), (2, 2), (3, 3), (4, 2), (4, 4), (5, 4), (6, 5);
INSERT INTO incluye (id_cita, id_tratamiento) VALUES (1, 6), (1, 8), (2, 2), (2, 3), (3, 4), (4, 2), (4, 5), (5, 1), (6, 7);

-- =========================================================
-- QUERIES RESUELTAS
-- =========================================================

-- ordenar paciente por apellidos y nombre
SELECT * FROM paciente ORDER BY apellidos, nombre;
-- Explicación: Ordena alfabéticamente primero por apellidos y, en caso de empate, por nombre.

-- LIKE (buscar texto)
-- Tratamiento que contiene revisión
SELECT * FROM tratamiento WHERE descripcion LIKE '%revisión%';
-- Explicación: Filtra tratamientos cuya descripción contenga la palabra clave en cualquier posición.

-- Medico que Contiene Vega en apellido
SELECT * FROM medico WHERE apellidos LIKE '%Vega%';
-- Explicación: Busca el apellido Vega dentro de la columna de apellidos.

/* MÁS CONSULTAS SENCILLAS */

-- 1) WHERE + ORDER BY: Mostrar las citas ordenadas por fecha descendente.
SELECT * FROM cita ORDER BY fecha DESC;
-- Explicación: Lista todas las citas poniendo las más recientes primero.

-- 2) LIKE: Mostrar pacientes cuyo apellido contenga 'Pérez'.
SELECT * FROM paciente WHERE apellidos LIKE '%Pérez%';
-- Explicación: Busca el patrón 'Pérez' dentro de la columna apellidos.

-- 3) COUNT con GROUP BY: Mostrar cuántas citas tiene cada paciente.
SELECT id_paciente, COUNT(*) FROM cita GROUP BY id_paciente;
-- Explicación: Agrupa las filas por el ID de paciente y cuenta las citas vinculadas a cada uno.
/* Concepto del "Cajón de Clasificación"
Imagina una pila de 100 papeles, donde cada papel es una cita. 
GROUP BY id_paciente, le dice a la base de datos: 
"Crea un cajón para cada ID_paciente y mete ahí todos los ID_cita que le correspondan". */

/* El motor de la base de datos procesa la consulta en este orden:
FROM cita: Abre la tabla de citas.
GROUP BY id_paciente: El sistema identifica todos los ID_paciente únicos y agrupa los registros hijos por cada ID_paciente
COUNT(*): Una vez que las citas están agrupadas, la función COUNT entra en cada "cajón" y cuenta cuántos papeles (filas) hay dentro.
SELECT: Finalmente, te muestra el número del cajón (el ID) y el resultado del conteo. */

-- 4) INNER JOIN sencillo: Mostrar nombre del paciente y fecha de su cita.
SELECT p.nombre, c.fecha FROM paciente p INNER JOIN cita c ON p.id_paciente = c.id_paciente;
-- Explicación: Combina ambas tablas mediante su clave común para relacionar nombres con fechas.

-- 5) INNER JOIN con médico: Mostrar médicos y las citas que atienden.
SELECT m.nombre, a.id_cita FROM medico m INNER JOIN atiende a ON m.id_medico = a.id_medico;
-- Explicación: Muestra qué médicos están vinculados a qué IDs de cita a través de la tabla intermedia.

-- 6) LEFT JOIN: Mostrar todos los médicos aunque no tengan citas.
SELECT m.id_medico, m.nombre, a.id_cita FROM medico m LEFT JOIN atiende a ON m.id_medico = a.id_medico;
-- Explicación: El LEFT JOIN asegura que salgan todos los médicos, tengan o no relación en la tabla 'atiende'.

-- 7) RIGHT JOIN: Mostrar todas las citas aunque no tengan médico asignado.
SELECT c.id_cita, a.id_medico FROM atiende a RIGHT JOIN cita c ON a.id_cita = c.id_cita;
-- Explicación: Asegura que se vean todas las citas, aunque no haya un registro de atención médica asociado.

-- 8) HAVING: Mostrar pacientes con más de una cita.
SELECT id_paciente, COUNT(*) FROM cita GROUP BY id_paciente HAVING COUNT(*) > 1;
-- Explicación: Filtra los grupos de pacientes que tienen un conteo de citas superior a 1.
/* Antes de contar, SQL junta a todos los pacientes que tienen el mismo ID.
Una vez hechos los montones, SQL cuenta cuántos expedientes hay en cada uno.
SE USA HAVING y no WHERE PORQUE:
WHERE filtra antes de agrupar. Y  no se puede decir WHERE COUNT(*) > 1 porque SQL aún no sabe cuántas citas tiene cada uno.
HAVING filtra grupos. Es como decirle al sistema: 
"Ahora que ya contaste los expedientes de cada montón, tírame a la basura los montones que tengan 1 o menos". */

-- 9) MIN: Mostrar la cita más antigua.
SELECT MIN(fecha) FROM cita;
-- Explicación: Obtiene el valor cronológico más bajo (el pasado más lejano).

-- 10) MAX: Mostrar la cita más reciente.
SELECT MAX(fecha) FROM cita;
-- Explicación: Obtiene el valor cronológico más alto.

-- 11) AVG sencillo: Calcular promedio de citas por paciente.
SELECT AVG(conteo) FROM (SELECT COUNT(*) AS conteo FROM cita GROUP BY id_paciente) AS subquery;
-- Explicación: Primero contamos citas por paciente en una subconsulta y luego calculamos la media de esos resultados.
/* Para entender esta consulta, imagina que estás intentando calcular el promedio de alumnos por salón en una escuela. 
No puedes simplemente promediar a los alumnos (que son unidades individuales); primero tienes que contar cuántos hay 
en cada salón y, con esos resultados en mano, sacar la media. */

/* SELECT COUNT(*) AS conteo FROM cita GROUP BY id_paciente
Agrupa todas las citas por cada paciente y cuenta cuántas tiene cada uno.
Produce una lista de números (ej: 2, 5, 1, 3...) que representa el "volumen de citas" por individuo.
SQL necesita que nombres a esta tabla temporal mediante un alias (AS subquery)
La Fase de Cálculo (La Consulta Externa)  Toma todos los resultados de la subconsulta y les aplica la función AVG.*/

-- 12) JOIN con tratamiento: Mostrar id de cita y descripción del tratamiento.
SELECT i.id_cita, t.descripcion FROM incluye i INNER JOIN tratamiento t ON i.id_tratamiento = t.id_tratamiento;
-- Explicación: Une la tabla intermedia 'incluye' con 'tratamiento' para traducir los IDs a descripciones legibles.