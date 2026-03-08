-- ============================================
-- PRÁCTICA COMPLETA DE MYSQL
-- BIBLIOTECA MUNICIPAL
-- Incluye:
-- SELECT, INSERT, UPDATE, DELETE, ALTER,
-- JOIN, INNER JOIN, LEFT JOIN, RIGHT JOIN,
-- WHERE, ORDER BY, HAVING, COUNT, AVG, MIN, MAX,
-- SUBCONSULTAS
-- Entorno: XAMPP / phpMyAdmin
-- ============================================

CREATE DATABASE Biblioteca;

CREATE TABLE libros (
    id_libro INT PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    autor VARCHAR(100) NOT NULL,
    anio INT,
    disponible BOOLEAN DEFAULT TRUE
);

CREATE TABLE usuarios (
    id_usuario INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    correo VARCHAR(100),
    edad INT
);

CREATE TABLE prestamos (
    id_prestamo INT PRIMARY KEY,
    id_libro INT,
    id_usuario INT,
    fecha_prestamo DATE,
    fecha_devolucion DATE,
    FOREIGN KEY (id_libro) REFERENCES libros(id_libro),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);

-- Añadir nuevas columnas para practicar ALTER

ALTER TABLE usuarios
ADD telefono VARCHAR(20);

ALTER TABLE libros
ADD genero VARCHAR(50);

-- INSERTAR DATOS

INSERT INTO libros (id_libro, titulo, autor, anio, disponible, genero) VALUES
(1, 'Don Quijote', 'Miguel de Cervantes', 1605, TRUE, 'Novela'),
(2, '1984', 'George Orwell', 1949, FALSE, 'Distopía'),
(3, 'El Principito', 'Antoine de Saint-Exupéry', 1943, FALSE, 'Fábula'),
(4, 'Cien años de soledad', 'Gabriel García Márquez', 1967, TRUE, 'Realismo mágico'),
(5, 'La sombra del viento', 'Carlos Ruiz Zafón', 2001, TRUE, 'Misterio'),
(6, 'Rayuela', 'Julio Cortázar', 1963, FALSE, 'Novela');

INSERT INTO usuarios (id_usuario, nombre, correo, edad, telefono) VALUES
(1, 'Ana', 'ana@email.com', 22, '600111111'),
(2, 'Luis', 'luis@email.com', 25, '600222222'),
(3, 'Marta', 'marta@email.com', 18, '600333333'),
(4, 'Carlos', 'carlos@email.com', 30, '600444444'),
(5, 'Sonia', 'sonia@email.com', 27, '600555555');

INSERT INTO prestamos (id_prestamo, id_libro, id_usuario, fecha_prestamo, fecha_devolucion) VALUES
(1, 2, 1, '2026-02-01', NULL),
(2, 3, 2, '2026-02-10', NULL),
(3, 6, 4, '2026-02-15', '2026-02-28');

-- SELECT BÁSICOS

-- 1. Mostrar todos los libros
SELECT * FROM libros;
-- Explicación: muestra todas las columnas y registros de la tabla libros.

-- 2. Mostrar todos los usuarios
SELECT * FROM usuarios;
-- Explicación: devuelve todos los datos almacenados en la tabla usuarios.

-- 3. Mostrar solo título y autor
SELECT titulo, autor FROM libros;
-- Explicación: selecciona únicamente las columnas titulo y autor de la tabla libros.

-- 4. WHERE: libros publicados después de 1950
SELECT * FROM libros
WHERE anio > 1950;
-- Explicación: filtra los libros cuyo año de publicación es posterior a 1950.

-- 5. WHERE: usuarios mayores de 21 años
SELECT * FROM usuarios
WHERE edad > 21;
-- Explicación: muestra únicamente los usuarios con edad superior a 21.

-- 6. ORDER BY: libros ordenados por año ascendente
SELECT * FROM libros
ORDER BY anio ASC;
-- Explicación: ordena los libros desde el más antiguo al más reciente.

-- 7. ORDER BY descendente: usuarios por edad
SELECT * FROM usuarios
ORDER BY edad DESC;
-- Explicación: ordena los usuarios desde el de mayor edad al de menor.

-- 8. WHERE + ORDER BY
SELECT * FROM libros
WHERE disponible = TRUE
ORDER BY anio DESC;
-- Explicación: muestra solo los libros disponibles y los ordena desde el más reciente.

-- UPDATE

--9. SELECT previo al libro id= 5
SELECT *
FROM libros
WHERE id_libro = 5;

-- el libro 5 deja de estar disponible
UPDATE libros
SET disponible = FALSE
WHERE id_libro = 5;

-- Comprobación
SELECT *
FROM libros
WHERE id_libro = 5;

-- 10. SELECT previo al id_usuario = 1
SELECT *
FROM usuarios
WHERE id_usuario = 1;
-- Explicación: muestra los datos del usuario con id 1 antes de modificarlo.

-- Cambiar correo de Ana por ana.nuevo@email.com
UPDATE usuarios
SET correo = 'ana.nuevo@email.com'
WHERE id_usuario = 1;
-- Explicación: actualiza el correo del usuario con id 1.

-- Comprobación del cambio
SELECT *
FROM usuarios
WHERE id_usuario = 1;
-- Explicación: verifica que el correo se haya actualizado correctamente.

-- 11. Usuarios mayores de 25 años y sumarles 1 año mas
UPDATE usuarios
SET edad = edad + 1
WHERE edad > 25;
-- Explicación: incrementa en 1 la edad de los usuarios que tienen más de 25 años.

-- DELETE

-- SELECT previo a usuarios mayores de edad
SELECT *
FROM usuarios
WHERE edad >= 18;
-- Explicación: muestra los usuarios mayores de edad antes de decidir si se eliminan.

-- ¿Puedes borrar alguno de estos usuarios?
DELETE FROM usuarios
WHERE edad < 18;
-- Explicación: elimina los usuarios menores de edad (si existieran).

-- Comprobación
SELECT *
FROM usuarios;
-- Explicación: muestra la tabla usuarios para comprobar el resultado del borrado.

-- 12. SELECT previo al libro id_libro = 1
SELECT *
FROM libros
WHERE id_libro = 1;
-- Explicación: muestra el libro con id 1 antes de eliminarlo.

-- borralo
DELETE FROM libros
WHERE id_libro = 1;
-- Explicación: elimina el libro cuyo id es 1.

-- Comprobación
SELECT *
FROM libros;
-- Explicación: muestra los libros restantes tras el borrado.

-- JOIN, INNER JOIN, LEFT JOIN, RIGHT JOIN

-- 13. Mostrar préstamos con nombre de usuario y título del libro
SELECT p.id_prestamo, u.nombre, l.titulo, p.fecha_prestamo
FROM prestamos p
INNER JOIN usuarios u ON p.id_usuario = u.id_usuario
INNER JOIN libros l ON p.id_libro = l.id_libro;
-- Explicación: combina las tres tablas para mostrar qué usuario pidió qué libro.

-- 14. LEFT JOIN
-- Mostrar todos los usuarios, tengan o no préstamos
SELECT u.nombre, p.id_prestamo
FROM usuarios u
LEFT JOIN prestamos p ON u.id_usuario = p.id_usuario;
-- Explicación: muestra todos los usuarios aunque no tengan préstamos asociados.

-- 15. RIGHT JOIN
-- Mostrar todos los préstamos y los datos del usuario asociado
SELECT u.nombre, p.id_prestamo, p.fecha_prestamo
FROM usuarios u
RIGHT JOIN prestamos p ON u.id_usuario = p.id_usuario;
-- Explicación: muestra todos los préstamos y los usuarios que los realizaron.

-- FUNCIONES DE AGREGACIÓN

-- 16.COUNT: número total de libros
SELECT COUNT(*) AS total_libros
FROM libros;
-- Explicación: cuenta el número total de registros en la tabla libros.

-- 17. COUNT: número de usuarios
SELECT COUNT(*) AS total_usuarios
FROM usuarios;
-- Explicación: devuelve el número total de usuarios registrados.

-- 18. AVG: edad media de los usuarios
SELECT AVG(edad) AS edad_media
FROM usuarios;
-- Explicación: calcula la edad promedio de todos los usuarios.

-- 19. MIN: edad mínima
SELECT MIN(edad) AS edad_minima
FROM usuarios;
-- Explicación: obtiene la edad más baja registrada en la tabla usuarios.

-- 20. MAX: edad máxima
SELECT MAX(edad) AS edad_maxima
FROM usuarios;
-- Explicación: obtiene la edad más alta registrada.

-- 21. COUNT de libros disponibles
SELECT COUNT(*) AS libros_disponibles
FROM libros
WHERE disponible = TRUE;
-- Explicación: cuenta cuántos libros están disponibles para préstamo.

-- GROUP BY Y HAVING

-- 22. Contar cuántos libros hay por género
SELECT genero, COUNT(*) AS total
FROM libros
GROUP BY genero;
-- Explicación: agrupa los libros por género y cuenta cuántos hay de cada tipo.

-- 23. Mostrar géneros con más de 1 libro
SELECT genero, COUNT(*) AS total
FROM libros
GROUP BY genero
HAVING COUNT(*) > 1;
-- Explicación: muestra solo los géneros que tienen más de un libro registrado.

-- 24. Contar préstamos por usuario
SELECT id_usuario, COUNT(*) AS total_prestamos
FROM prestamos
GROUP BY id_usuario;
-- Explicación: cuenta cuántos préstamos ha realizado cada usuario.

-- 25. Mostrar solo usuarios con al menos 1 préstamo
SELECT id_usuario, COUNT(*) AS total_prestamos
FROM prestamos
GROUP BY id_usuario
HAVING COUNT(*) >= 1;
-- Explicación: filtra los usuarios que han realizado al menos un préstamo.

-- SUBCONSULTAS

-- 26. Mostrar usuarios que tienen préstamos
SELECT nombre
FROM usuarios
WHERE id_usuario IN (SELECT id_usuario FROM prestamos);
-- Explicación: selecciona los usuarios cuyo id aparece en la tabla préstamos.

-- 27. Mostrar libros que han sido prestados
SELECT titulo
FROM libros
WHERE id_libro IN (SELECT id_libro FROM prestamos);
-- Explicación: muestra los libros que aparecen en la tabla préstamos.

-- 28. Mostrar usuarios con edad superior a la edad media
SELECT *
FROM usuarios
WHERE edad > (SELECT AVG(edad) FROM usuarios);
-- Explicación: compara la edad de cada usuario con la media y muestra los que están por encima.

-- 29. Mostrar el libro más antiguo
SELECT *
FROM libros
WHERE anio = (SELECT MIN(anio) FROM libros);
-- Explicación: obtiene el libro cuyo año de publicación es el menor de toda la tabla.