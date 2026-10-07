-- =====================================================================
--  Practica de PostgreSQL: base de datos "biblioteca"
--  Script completo con todos los comandos SQL en orden, por apartado.
--
--  La practica se ejecuto sobre PostgreSQL 16.15 en Ubuntu 24.04.3 LTS.
-- =====================================================================


-- =====================================================================
-- 1. CREACION DE LA BASE DE DATOS
-- =====================================================================

-- 1.1 Crear la base de datos biblioteca
--     [conectado como: postgres]
CREATE DATABASE biblioteca;

\l biblioteca


-- =====================================================================
-- 2. CREACION DE USUARIOS
-- =====================================================================
-- A partir de aqui, conectado a la base de datos biblioteca:
--     \c biblioteca
--     [conectado como: postgres]

-- 2.1 Crear admin_biblio (administrador de la BD) y usuario_biblio (solo lectura)
CREATE ROLE admin_biblio   WITH LOGIN PASSWORD 'Adm1n_B1bl10';
CREATE ROLE usuario_biblio WITH LOGIN PASSWORD 'Usu4r10_B1bl10';

-- admin_biblio pasa a ser propietario de la base de datos
ALTER DATABASE biblioteca OWNER TO admin_biblio;
GRANT ALL PRIVILEGES ON DATABASE biblioteca TO admin_biblio;

-- usuario_biblio solo necesita poder conectarse
GRANT CONNECT ON DATABASE biblioteca TO usuario_biblio;

-- 2.2 Rol lectores: unicamente permisos de consulta
CREATE ROLE lectores NOLOGIN;
GRANT CONNECT ON DATABASE biblioteca TO lectores;

-- 2.3 Asignar usuario_biblio al rol lectores
GRANT lectores TO usuario_biblio;

-- Permisos sobre el schema public y privilegios POR DEFECTO.
-- El guion pide dar permisos sobre las tablas antes de crearlas: se resuelve
-- con ALTER DEFAULT PRIVILEGES, que se aplica a los objetos futuros.
GRANT USAGE ON SCHEMA public TO lectores;
GRANT USAGE ON SCHEMA public TO usuario_biblio;

ALTER DEFAULT PRIVILEGES FOR ROLE admin_biblio IN SCHEMA public
    GRANT SELECT ON TABLES TO lectores;

\ddp

-- 2.4 Listar los usuarios creados consultando pg_roles
SELECT rolname, rolsuper, rolcreatedb, rolcreaterole, rolcanlogin
FROM pg_roles
WHERE rolname NOT LIKE 'pg\_%'
ORDER BY rolname;

-- Pertenencia a roles (usuario_biblio debe aparecer como miembro de lectores)
SELECT r.rolname AS rol, m.rolname AS miembro
FROM pg_auth_members am
JOIN pg_roles r ON r.oid = am.roleid
JOIN pg_roles m ON m.oid = am.member
WHERE r.rolname = 'lectores';

-- 2.5 Cambiar la contrasena de usuario_biblio
ALTER ROLE usuario_biblio WITH PASSWORD 'NuevaClave_2025';


-- =====================================================================
-- 3. CREACION DE TABLAS
-- =====================================================================
-- Las tablas se crean conectado como admin_biblio para que sea su propietario:
--     psql -h localhost -U admin_biblio -d biblioteca
--     [conectado como: admin_biblio]

-- 3.1 Creacion de las tablas con su clave primaria
CREATE TABLE autores (
    id_autor     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    nacionalidad VARCHAR(50)
);

CREATE TABLE libros (
    id_libro        INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    titulo          VARCHAR(200) NOT NULL,
    año_publicacion INT,
    id_autor        INT
);

CREATE TABLE prestamos (
    id_prestamo         INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_libro            INT,
    fecha_prestamo      DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_devolucion    DATE,
    usuario_prestatario VARCHAR(100) NOT NULL
);

-- 3.2 Claves foraneas
ALTER TABLE libros
    ADD CONSTRAINT fk_libros_autor
    FOREIGN KEY (id_autor) REFERENCES autores(id_autor);

ALTER TABLE prestamos
    ADD CONSTRAINT fk_prestamos_libro
    FOREIGN KEY (id_libro) REFERENCES libros(id_libro) ON DELETE CASCADE;

\d autores
\d libros
\d prestamos


-- ---------------------------------------------------------------------
-- 2.2 / 2.6 (continuacion) Permisos sobre las tablas YA creadas
--     [conectado como: admin_biblio, propietario de las tablas]
-- ---------------------------------------------------------------------

-- 2.2 Se repite el GRANT ahora que las tablas existen
GRANT SELECT ON ALL TABLES IN SCHEMA public TO lectores;

-- 2.6 usuario_biblio no puede eliminar registros en ninguna tabla
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM usuario_biblio;
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM lectores;
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM PUBLIC;

-- Y tambien para las tablas que se creen en el futuro
ALTER DEFAULT PRIVILEGES FOR ROLE admin_biblio IN SCHEMA public
    REVOKE DELETE, INSERT, UPDATE, TRUNCATE ON TABLES FROM lectores;

\dp


-- =====================================================================
-- 4. INSERCION DE DATOS
-- =====================================================================
--     [conectado como: admin_biblio]

\encoding UTF8

-- 4.1 Insercion de datos
INSERT INTO autores (nombre, nacionalidad) VALUES
    ('Gabriel García Márquez', 'Colombiana'),
    ('Jorge Luis Borges',      'Argentina'),
    ('Miguel de Cervantes',    'Española'),
    ('Isabel Allende',         'Chilena'),
    ('Haruki Murakami',        'Japonesa'),
    ('Virginia Woolf',         'Británica');

INSERT INTO libros (titulo, año_publicacion, id_autor) VALUES
    ('Cien años de soledad',                1967, 1),
    ('El amor en los tiempos del cólera',   1985, 1),
    ('Ficciones',                           1944, 2),
    ('El Aleph',                            1949, 2),
    ('Don Quijote de la Mancha',            1605, 3),
    ('La casa de los espíritus',            1982, 4),
    ('Tokio blues',                         1987, 5),
    ('Kafka en la orilla',                  2002, 5),
    ('La señora Dalloway',                  1925, 6);

INSERT INTO prestamos (id_libro, fecha_prestamo, fecha_devolucion, usuario_prestatario) VALUES
    (1, '2025-01-10', '2025-01-24', 'Ana Pérez'),
    (1, '2025-02-05', '2025-02-19', 'Luis Gómez'),
    (1, '2025-03-01', NULL,         'María Ruiz'),
    (1, '2025-04-12', '2025-04-26', 'Ana Pérez'),
    (1, '2025-05-20', NULL,         'Carlos Díaz'),
    (5, '2025-01-15', '2025-01-29', 'Luis Gómez'),
    (5, '2025-02-20', NULL,         'Ana Pérez'),
    (5, '2025-03-18', '2025-04-01', 'Elena Sanz'),
    (5, '2025-06-02', NULL,         'Luis Gómez'),
    (3, '2025-01-25', '2025-02-08', 'María Ruiz'),
    (3, '2025-04-03', NULL,         'Carlos Díaz'),
    (3, '2025-05-10', '2025-05-24', 'Ana Pérez'),
    (9, '2025-02-14', '2025-02-28', 'Elena Sanz'),
    (9, '2025-06-15', NULL,         'María Ruiz');

-- Comprobacion de los datos insertados
SELECT * FROM autores;
SELECT * FROM libros;
SELECT * FROM prestamos;


-- ---------------------------------------------------------------------
-- 2.6 (demostracion) Se ejecuta DESPUES de tener datos, conectado como
--     usuario_biblio:  psql -h localhost -U usuario_biblio -d biblioteca
--     [conectado como: usuario_biblio]
-- ---------------------------------------------------------------------
SELECT current_user;

-- SI puede consultar
SELECT count(*) AS total_prestamos FROM prestamos;

-- NO puede borrar en ninguna tabla  -> ERROR: permission denied
DELETE FROM prestamos WHERE id_prestamo = 1;
DELETE FROM libros    WHERE id_libro    = 1;
DELETE FROM autores   WHERE id_autor    = 1;

-- Tampoco puede insertar ni actualizar -> ERROR: permission denied
INSERT INTO autores (nombre, nacionalidad) VALUES ('Prueba', 'Prueba');
UPDATE libros SET titulo = 'otro titulo' WHERE id_libro = 1;

-- Los datos siguen intactos
SELECT count(*) AS prestamos_tras_los_intentos FROM prestamos;


-- =====================================================================
-- 5. CONSULTAS BASICAS
-- =====================================================================
--     [conectado como: admin_biblio]

-- 5.1 Listar todos los libros con su autor (JOIN)
SELECT l.id_libro, l.titulo, l.año_publicacion, a.nombre AS autor, a.nacionalidad
FROM libros l
JOIN autores a ON a.id_autor = l.id_autor
ORDER BY l.id_libro;

-- 5.2 Prestamos sin fecha de devolucion (todavia no devueltos)
SELECT p.id_prestamo, l.titulo, p.fecha_prestamo, p.usuario_prestatario
FROM prestamos p
JOIN libros l ON l.id_libro = p.id_libro
WHERE p.fecha_devolucion IS NULL
ORDER BY p.id_prestamo;

-- 5.3 Autores con mas de un libro (GROUP BY + HAVING)
SELECT a.nombre AS autor, COUNT(l.id_libro) AS num_libros
FROM autores a
JOIN libros l ON l.id_autor = a.id_autor
GROUP BY a.id_autor, a.nombre
HAVING COUNT(l.id_libro) > 1
ORDER BY num_libros DESC, autor;


-- =====================================================================
-- 6. CONSULTAS CON AGREGACION
-- =====================================================================

-- 6.1 Numero total de prestamos
SELECT COUNT(*) AS total_prestamos FROM prestamos;

-- 6.2 Numero de libros prestados por cada usuario prestatario
SELECT p.usuario_prestatario,
       COUNT(*)                   AS prestamos_realizados,
       COUNT(DISTINCT p.id_libro) AS libros_distintos
FROM prestamos p
GROUP BY p.usuario_prestatario
ORDER BY prestamos_realizados DESC, p.usuario_prestatario;


-- =====================================================================
-- 7. MODIFICACION DE DATOS
-- =====================================================================

-- 7.1 Actualizar la fecha de devolucion de un prestamo pendiente
-- ANTES: el prestamo 3 esta pendiente (fecha_devolucion = NULL)
SELECT * FROM prestamos WHERE id_prestamo = 3;

UPDATE prestamos SET fecha_devolucion = '2025-03-15' WHERE id_prestamo = 3;

-- DESPUES: ya tiene fecha de devolucion
SELECT * FROM prestamos WHERE id_prestamo = 3;
SELECT COUNT(*) AS pendientes FROM prestamos WHERE fecha_devolucion IS NULL;

-- 7.2 Eliminar un libro y comprobar el efecto ON DELETE CASCADE en prestamos
-- ANTES: prestamos del libro 9 ("La señora Dalloway")
SELECT * FROM prestamos WHERE id_libro = 9;
SELECT COUNT(*) AS total_prestamos_antes FROM prestamos;

DELETE FROM libros WHERE id_libro = 9;

-- DESPUES: sus prestamos han desaparecido por el CASCADE
SELECT * FROM prestamos WHERE id_libro = 9;
SELECT COUNT(*) AS total_prestamos_despues FROM prestamos;
SELECT * FROM libros ORDER BY id_libro;


-- =====================================================================
-- 8. VISTAS
-- =====================================================================

-- 8.1 Crear la vista vista_libros_prestados
CREATE VIEW vista_libros_prestados AS
SELECT l.titulo              AS titulo_libro,
       a.nombre              AS nombre_autor,
       p.usuario_prestatario AS nombre_prestatario,
       p.fecha_prestamo,
       p.fecha_devolucion
FROM prestamos p
JOIN libros  l ON l.id_libro = p.id_libro
JOIN autores a ON a.id_autor = l.id_autor;

SELECT * FROM vista_libros_prestados ORDER BY titulo_libro, fecha_prestamo;

-- Al crearla, la vista HEREDA el SELECT para lectores de ALTER DEFAULT PRIVILEGES
\dp vista_libros_prestados

-- 8.2 Conceder SELECT sobre la vista UNICAMENTE a usuario_biblio
-- Primero se retira el acceso que lectores habia heredado, y el de PUBLIC
REVOKE ALL ON vista_libros_prestados FROM lectores;
REVOKE ALL ON vista_libros_prestados FROM PUBLIC;

-- Y se concede SELECT directamente al usuario
GRANT SELECT ON vista_libros_prestados TO usuario_biblio;

\dp vista_libros_prestados

-- Demostracion conectado como usuario_biblio
--     [conectado como: usuario_biblio]
SELECT current_user;
SELECT * FROM vista_libros_prestados ORDER BY titulo_libro, fecha_prestamo LIMIT 5;

-- Comprobacion de que el acceso NO viene del rol lectores:
-- al asumir unicamente el rol lectores, la consulta falla
SET ROLE lectores;
SELECT current_user;
SELECT * FROM vista_libros_prestados LIMIT 1;   -- ERROR: permission denied
RESET ROLE;


-- =====================================================================
-- 9. FUNCIONES Y CONSULTAS AVANZADAS
-- =====================================================================
--     [conectado como: admin_biblio]

-- 9.1 Funcion que recibe el nombre de un autor y devuelve sus libros
CREATE OR REPLACE FUNCTION libros_de_autor(p_nombre VARCHAR)
RETURNS TABLE (id_libro INT, titulo VARCHAR, año_publicacion INT)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT l.id_libro, l.titulo, l.año_publicacion
        FROM libros l
        JOIN autores a ON a.id_autor = l.id_autor
        WHERE a.nombre ILIKE '%' || p_nombre || '%'
        ORDER BY l.año_publicacion;
END;
$$;

-- Llamadas de ejemplo
SELECT * FROM libros_de_autor('Gabriel García Márquez');
SELECT * FROM libros_de_autor('Murakami');
SELECT * FROM libros_de_autor('Autor Inexistente');

-- 9.2 Los 3 libros mas prestados
SELECT l.id_libro, l.titulo, a.nombre AS autor, COUNT(p.id_prestamo) AS veces_prestado
FROM libros l
JOIN prestamos p ON p.id_libro = l.id_libro
JOIN autores a ON a.id_autor = l.id_autor
GROUP BY l.id_libro, l.titulo, a.nombre
ORDER BY veces_prestado DESC
LIMIT 3;


-- =====================================================================
-- 10. EXPORTACION E IMPORTACION
-- =====================================================================
--     [conectado como: admin_biblio]

-- 10.1 Exportar la tabla libros a CSV.
--      COPY actua en el SERVIDOR y requiere ser superusuario o miembro de
--      pg_write_server_files, por lo que la siguiente sentencia FALLA:
COPY libros TO '/home/usuario/biblioteca_practica/csv/libros.csv' CSV HEADER;
--      ERROR:  permission denied to COPY to a file

--      \copy es un meta-comando de psql: lee/escribe en el CLIENTE y no
--      necesita privilegios especiales. Esta es la forma correcta:
\copy libros TO '/home/usuario/biblioteca_practica/csv/libros.csv' CSV HEADER

-- 10.2 Importar un CSV con autores nuevos.
--      El fichero csv/autores_nuevos.csv contiene solo nombre,nacionalidad
--      (sin id_autor, que es GENERATED ALWAYS AS IDENTITY).
\copy autores(nombre, nacionalidad) FROM '/home/usuario/biblioteca_practica/csv/autores_nuevos.csv' CSV HEADER

SELECT * FROM autores ORDER BY id_autor;
