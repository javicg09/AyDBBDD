# Práctica de PostgreSQL — Base de datos `biblioteca`

**Asignatura:** `Administracion y Diseño de BAse de Datos`

**Autor:** `Francisco Javier Cañas González`

## Entorno de ejecución

Todos los comandos de esta práctica se han ejecutado sobre una máquina virtual
accedida por SSH. Las salidas que aparecen en este documento son las salidas
reales obtenidas en esa máquina, copiadas tal cual.

| | |
|---|---|
| Sistema operativo de la VM | Ubuntu 24.04.3 LTS (*noble*) |
| Versión de PostgreSQL | 16.15 (Ubuntu 16.15-0ubuntu0.24.04.1) |
| Codificación del clúster | UTF8 |
| Collation | es_ES.UTF-8 |
| Base de datos | `biblioteca` |

`psql --version`:

```
psql (PostgreSQL) 16.15 (Ubuntu 16.15-0ubuntu0.24.04.1)
```

`lsb_release -a`:

```
Distributor ID:	Ubuntu
Description:	Ubuntu 24.04.3 LTS
Release:	24.04
Codename:	noble
```

---

## Índice

- [0. Preparación del entorno](#0-preparación-del-entorno)
  - [0.1 Comprobación de la versión de PostgreSQL instalada](#01-comprobación-de-la-versión-de-postgresql-instalada)
  - [0.2 Estado del servicio](#02-estado-del-servicio)
  - [0.3 Comprobación de la codificación UTF8](#03-comprobación-de-la-codificación-utf8)
  - [0.4 Método de autenticación (`pg_hba.conf`)](#04-método-de-autenticación-pg_hbaconf)
  - [0.5 Convención de conexión usada en la práctica](#05-convención-de-conexión-usada-en-la-práctica)
- [1. Creación de la base de datos](#1-creación-de-la-base-de-datos)
  - [1.1 Crear la base de datos `biblioteca`](#11-crear-la-base-de-datos-biblioteca)
- [2. Creación de usuarios](#2-creación-de-usuarios)
  - [Nota previa sobre el orden de los permisos](#nota-previa-sobre-el-orden-de-los-permisos)
  - [2.1 Crear `admin_biblio` y `usuario_biblio`](#21-crear-admin_biblio-y-usuario_biblio)
  - [2.2 Crear el rol `lectores`](#22-crear-el-rol-lectores)
  - [2.3 Asignar `usuario_biblio` al rol `lectores`](#23-asignar-usuario_biblio-al-rol-lectores)
  - [2.3.b Permisos sobre el schema y privilegios por defecto](#23b-permisos-sobre-el-schema-y-privilegios-por-defecto)
  - [2.4 Listar los usuarios creados (`pg_roles`)](#24-listar-los-usuarios-creados-pg_roles)
  - [2.5 Cambiar la contraseña de `usuario_biblio`](#25-cambiar-la-contraseña-de-usuario_biblio)
  - [2.6 Impedir que `usuario_biblio` elimine registros](#26-impedir-que-usuario_biblio-elimine-registros)
- [3. Creación de tablas](#3-creación-de-tablas)
  - [3.1 Crear las tablas con su clave primaria](#31-crear-las-tablas-con-su-clave-primaria)
  - [3.2 Claves foráneas](#32-claves-foráneas)
  - [3.3 Permisos sobre las tablas ya creadas](#33-permisos-sobre-las-tablas-ya-creadas)
- [4. Inserción de datos](#4-inserción-de-datos)
  - [4.1 Insertar autores, libros y préstamos](#41-insertar-autores-libros-y-préstamos)
- [5. Consultas básicas](#5-consultas-básicas)
  - [5.1 Listar todos los libros con su autor (JOIN)](#51-listar-todos-los-libros-con-su-autor-join)
  - [5.2 Préstamos sin fecha de devolución](#52-préstamos-sin-fecha-de-devolución)
  - [5.3 Autores con más de un libro (GROUP BY + HAVING)](#53-autores-con-más-de-un-libro-group-by--having)
- [6. Consultas con agregación](#6-consultas-con-agregación)
  - [6.1 Número total de préstamos](#61-número-total-de-préstamos)
  - [6.2 Número de libros prestados por cada usuario](#62-número-de-libros-prestados-por-cada-usuario)
- [7. Modificación de datos](#7-modificación-de-datos)
  - [7.1 Actualizar la fecha de devolución de un préstamo pendiente](#71-actualizar-la-fecha-de-devolución-de-un-préstamo-pendiente)
  - [7.2 Eliminar un libro y comprobar el `ON DELETE CASCADE`](#72-eliminar-un-libro-y-comprobar-el-on-delete-cascade)
- [8. Vistas](#8-vistas)
  - [8.1 Crear `vista_libros_prestados`](#81-crear-vista_libros_prestados)
  - [8.2 Conceder SELECT sobre la vista solo a `usuario_biblio`](#82-conceder-select-sobre-la-vista-solo-a-usuario_biblio)
- [9. Funciones y consultas avanzadas](#9-funciones-y-consultas-avanzadas)
  - [9.1 Función que devuelve los libros de un autor](#91-función-que-devuelve-los-libros-de-un-autor)
  - [9.2 Los 3 libros más prestados](#92-los-3-libros-más-prestados)
- [10. Exportación e importación](#10-exportación-e-importación)
  - [10.1 Exportar `libros` a CSV](#101-exportar-libros-a-csv)
  - [10.2 Importar un CSV de autores nuevos](#102-importar-un-csv-de-autores-nuevos)
- [Contenido del repositorio](#contenido-del-repositorio)
- [Problemas encontrados y cómo se resolvieron](#problemas-encontrados-y-cómo-se-resolvieron)

---

## 0. Preparación del entorno

Se accede a la VM por SSH. La contraseña de SSH **no** aparece en ningún
fichero de este repositorio: durante el trabajo se mantuvo únicamente en una
variable de entorno de la sesión local.

```bash
ssh usuario@10.6.130.123
```

### 0.1 Comprobación de la versión de PostgreSQL instalada

**Enunciado.** Comprobar si PostgreSQL está instalado y, si no, instalarlo.

**Comando**

```bash
psql --version
```

**Salida**

```
psql (PostgreSQL) 16.15 (Ubuntu 16.15-0ubuntu0.24.04.1)
```

### 0.2 Estado del servicio

**Enunciado.** Verificar que el servicio de PostgreSQL está activo.

**Comando**

```bash
systemctl is-active postgresql
systemctl is-enabled postgresql
```

**Salida**

```
active
enabled
```

**Explicación.** El servicio está `active` y además `enabled`, es decir, arranca solo al iniciar la máquina.

### 0.3 Comprobación de la codificación UTF8

**Enunciado.** Comprobar que la codificación del clúster es UTF8, porque una de las columnas se llama `año_publicacion` y contiene una `ñ`.

**Comando**

```sql
SHOW server_encoding;

SELECT datname, pg_encoding_to_char(encoding) AS encoding, datcollate
FROM pg_database
ORDER BY datname;
```

**Salida**

```
 server_encoding 
-----------------
 UTF8
(1 row)

  datname   | encoding | datcollate  
------------+----------+-------------
 biblioteca | UTF8     | es_ES.UTF-8
 mydb       | UTF8     | es_ES.UTF-8
 postgres   | UTF8     | es_ES.UTF-8
 template0  | UTF8     | es_ES.UTF-8
 template1  | UTF8     | es_ES.UTF-8
(5 rows)
```

**Explicación.** El clúster usa **UTF8** con collation `es_ES.UTF-8`, y las plantillas `template0`/`template1` también, así que cualquier base de datos nueva hereda UTF8. Por tanto la `ñ` de `año_publicacion` se puede usar directamente como identificador sin comillas. (La base `mydb` ya existía en la VM y no forma parte de esta práctica.)

### 0.4 Método de autenticación (`pg_hba.conf`)

**Enunciado.** Para conectar como `usuario_biblio`/`admin_biblio` por TCP hace falta que `pg_hba.conf` permita autenticación por contraseña en localhost.

**Comando**

```bash
grep -vE "^\s*#|^\s*$" /etc/postgresql/16/main/pg_hba.conf

# y el algoritmo de cifrado de contraseñas:
sudo -u postgres psql -tAc "SHOW password_encryption;"
```

**Salida**

```
local   all             postgres                                peer
local   all             all                                     peer
host    all             all             0.0.0.0/0               scram-sha-256
host    all             all             ::/0                    scram-sha-256
local   replication     all                                     peer
host    replication     all             127.0.0.1/32            scram-sha-256
host    replication     all             ::1/128                 scram-sha-256

scram-sha-256
```

**Explicación.** Las líneas `host all all 0.0.0.0/0 scram-sha-256` ya cubren las conexiones a `localhost` (127.0.0.1) con contraseña, y `password_encryption` ya es `scram-sha-256`. **No fue necesario modificar `pg_hba.conf`.** Las líneas `local ... peer` son las que permiten a la cuenta de sistema `postgres` entrar como superusuario sin contraseña.

### 0.5 Convención de conexión usada en la práctica

Para no exponer contraseñas en ficheros, las contraseñas de los roles de
PostgreSQL se pasan a `psql` por la variable de entorno `PGPASSWORD`:

```bash
# Superusuario (apartados 1 y 2.1 - 2.5): autenticación peer, sin contraseña
sudo -u postgres psql -d biblioteca

# Propietario de la BD (apartados 3 a 10)
PGPASSWORD='Adm1n_B1bl10' psql -h localhost -U admin_biblio -d biblioteca

# Usuario de solo lectura (demostraciones de permisos)
PGPASSWORD='NuevaClave_2025' psql -h localhost -U usuario_biblio -d biblioteca
```

Los ficheros SQL se ejecutan con `psql -a` (*echo all*), de forma que en la
salida aparecen tanto el comando enviado como su resultado. Cuando era
importante que los mensajes de `ERROR` salieran justo debajo de su sentencia
(apartados 2.6 y 10.1), cada sentencia se lanzó en su propia invocación de
`psql -c`, porque `psql` escribe los resultados por `stdout` y los errores por
`stderr` y al redirigirlos a un fichero el orden se mezclaba.

> Las contraseñas `Adm1n_B1bl10` / `NuevaClave_2025` son credenciales **de la
> base de datos** creadas para la práctica, no la contraseña de acceso a la VM.

---

## 1. Creación de la base de datos

### 1.1 Crear la base de datos `biblioteca`

**Enunciado.** Crear la base de datos `biblioteca`.

**Comando**

```sql
CREATE DATABASE biblioteca;
\l biblioteca
```

**Salida**

```
-- 1.1 Crear la base de datos biblioteca
CREATE DATABASE biblioteca;
CREATE DATABASE
\l biblioteca
                                                      List of databases
    Name    |  Owner   | Encoding | Locale Provider |   Collate   |    Ctype    | ICU Locale | ICU Rules | Access privileges 
------------+----------+----------+-----------------+-------------+-------------+------------+-----------+-------------------
 biblioteca | postgres | UTF8     | libc            | es_ES.UTF-8 | es_ES.UTF-8 |            |           | 
(1 row)
```

**Explicación.** Se crea como superusuario `postgres`; en el apartado 2.1 se le cambia el propietario a `admin_biblio`. Se comprueba con `\l` que hereda la codificación **UTF8** del clúster.

---

## 2. Creación de usuarios

### Nota previa sobre el orden de los permisos

El guion pide conceder permisos sobre las tablas (apartado 2.2) **antes** de
crearlas (apartado 3). Un `GRANT SELECT ON ALL TABLES IN SCHEMA public` en ese
momento no serviría de nada, porque `ALL TABLES` se expande a las tablas que
existen **en el instante de ejecutar el GRANT**, no a las futuras. La solución
usada es doble:

1. **`ALTER DEFAULT PRIVILEGES`** (apartado 2.3.b), que registra una regla: todo
   objeto de tipo tabla que cree `admin_biblio` en el schema `public` dará
   automáticamente `SELECT` al rol `lectores`.
2. **Repetir el `GRANT SELECT ON ALL TABLES`** después de crear las tablas
   (apartado 3.3), para dejarlo explícito y para cubrir el caso de que alguien
   ejecute el script sin los privilegios por defecto.

Además hay que conceder dos permisos que a menudo se olvidan:

- **`CONNECT` sobre la base de datos**, sin el cual el rol no puede ni abrir la
  conexión.
- **`USAGE` sobre el schema `public`**, sin el cual el rol no puede *ver* los
  objetos del schema aunque tenga `SELECT` sobre ellos.

Por último, las tablas se crean **conectado como `admin_biblio`** (apartado 3)
para que sea su propietario, que es justo lo que hace que la regla de
`ALTER DEFAULT PRIVILEGES FOR ROLE admin_biblio` se dispare.

### 2.1 Crear `admin_biblio` y `usuario_biblio`

**Enunciado.** Crear `admin_biblio` con permisos de administrador sobre la BD (hacerlo propietario de `biblioteca` y concederle `ALL PRIVILEGES`) y `usuario_biblio` solo con lectura.

**Comando**

```sql
CREATE ROLE admin_biblio   WITH LOGIN PASSWORD 'Adm1n_B1bl10';
CREATE ROLE usuario_biblio WITH LOGIN PASSWORD 'Usu4r10_B1bl10';

-- admin_biblio pasa a ser propietario de la base de datos
ALTER DATABASE biblioteca OWNER TO admin_biblio;
GRANT ALL PRIVILEGES ON DATABASE biblioteca TO admin_biblio;

-- usuario_biblio solo necesita poder conectarse
GRANT CONNECT ON DATABASE biblioteca TO usuario_biblio;
```

**Salida**

```
-- 2.1 Crear admin_biblio (administrador de la BD) y usuario_biblio (solo lectura)
CREATE ROLE admin_biblio WITH LOGIN PASSWORD 'Adm1n_B1bl10';
CREATE ROLE
CREATE ROLE usuario_biblio WITH LOGIN PASSWORD 'Usu4r10_B1bl10';
CREATE ROLE
-- admin_biblio pasa a ser propietario de la base de datos
ALTER DATABASE biblioteca OWNER TO admin_biblio;
ALTER DATABASE
GRANT ALL PRIVILEGES ON DATABASE biblioteca TO admin_biblio;
GRANT
-- usuario_biblio solo necesita poder conectarse
GRANT CONNECT ON DATABASE biblioteca TO usuario_biblio;
GRANT
```

**Explicación.** Se combinan **propiedad** y **`ALL PRIVILEGES`** porque son cosas distintas y las dos hacen falta. Ser *propietario* le da control total sobre los objetos que cree y sobre la propia base de datos (incluido `DROP`), y es lo que activa los `ALTER DEFAULT PRIVILEGES` asociados a su rol. `GRANT ALL PRIVILEGES ON DATABASE` le da los privilegios a nivel de base de datos (`CREATE`, `CONNECT`, `TEMPORARY`). Se ha preferido esto a hacerlo `SUPERUSER`: así es administrador **de esta base de datos** pero no de todo el clúster, que es el mínimo privilegio necesario. A `usuario_biblio` solo se le da `CONNECT`; su permiso de lectura le llegará por el rol `lectores` (apartado 2.3).

### 2.2 Crear el rol `lectores`

**Enunciado.** Crear el rol `lectores` con permisos únicamente de consulta sobre todas las tablas.

**Comando**

```sql
CREATE ROLE lectores NOLOGIN;
GRANT CONNECT ON DATABASE biblioteca TO lectores;
```

**Salida**

```
-- 2.2 Rol lectores: unicamente permisos de consulta
CREATE ROLE lectores NOLOGIN;
CREATE ROLE
GRANT CONNECT ON DATABASE biblioteca TO lectores;
GRANT
```

**Explicación.** `lectores` se crea como `NOLOGIN`: es un **rol de grupo**, pensado para agrupar permisos y asignárselos a usuarios, no para conectarse con él. Los permisos de consulta sobre las tablas se configuran en 2.3.b y 3.3.

### 2.3 Asignar `usuario_biblio` al rol `lectores`

**Enunciado.** Asignar `usuario_biblio` a `lectores`.

**Comando**

```sql
GRANT lectores TO usuario_biblio;
```

**Salida**

```
-- 2.3 Asignar usuario_biblio al rol lectores
GRANT lectores TO usuario_biblio;
GRANT ROLE
```

**Explicación.** A partir de este momento `usuario_biblio` hereda todos los permisos de `lectores`. La comprobación de la pertenencia se ve en el apartado 2.4.

### 2.3.b Permisos sobre el schema y privilegios por defecto

**Enunciado.** Dejar configurado que el rol `lectores` tendrá `SELECT` sobre las tablas que `admin_biblio` cree en `public` (ver la *Nota previa* más arriba).

**Comando**

```sql
GRANT USAGE ON SCHEMA public TO lectores;
GRANT USAGE ON SCHEMA public TO usuario_biblio;

-- Todo objeto TABLA/VISTA que cree admin_biblio en public
-- dará SELECT automáticamente a lectores
ALTER DEFAULT PRIVILEGES FOR ROLE admin_biblio IN SCHEMA public
    GRANT SELECT ON TABLES TO lectores;

\ddp
```

**Salida**

```
-- Permisos sobre el schema public y privilegios por defecto (se ejecuta ANTES de crear las tablas)
GRANT USAGE ON SCHEMA public TO lectores;
GRANT
GRANT USAGE ON SCHEMA public TO usuario_biblio;
GRANT
-- Todo objeto TABLA/VISTA que cree admin_biblio en public dara SELECT automaticamente a lectores
ALTER DEFAULT PRIVILEGES FOR ROLE admin_biblio IN SCHEMA public
    GRANT SELECT ON TABLES TO lectores;
ALTER DEFAULT PRIVILEGES
-- Comprobacion de los privilegios por defecto registrados
\ddp
                Default access privileges
    Owner     | Schema | Type  |    Access privileges    
--------------+--------+-------+-------------------------
 admin_biblio | public | table | lectores=r/admin_biblio
(1 row)
```

**Explicación.** La línea `lectores=r/admin_biblio` de `\ddp` confirma que la regla queda registrada: `r` es el privilegio de lectura (`SELECT`) y `admin_biblio` es quien lo concede. **Ojo:** en PostgreSQL `ON TABLES` incluye también las **vistas**, detalle que resultará relevante en el apartado 8.2.

### 2.4 Listar los usuarios creados (`pg_roles`)

**Enunciado.** Listar los usuarios creados consultando `pg_roles`.

**Comando**

```sql
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
```

**Salida**

```
-- 2.4 Listar los usuarios creados consultando pg_roles
SELECT rolname, rolsuper, rolcreatedb, rolcreaterole, rolcanlogin
FROM pg_roles
WHERE rolname NOT LIKE 'pg\_%'
ORDER BY rolname;
    rolname     | rolsuper | rolcreatedb | rolcreaterole | rolcanlogin 
----------------+----------+-------------+---------------+-------------
 admin_biblio   | f        | f           | f             | t
 lectores       | f        | f           | f             | f
 mydb_admin     | f        | f           | f             | t
 postgres       | t        | t           | t             | t
 usuario_biblio | f        | f           | f             | t
(5 rows)

-- Pertenencia a roles (usuario_biblio debe aparecer como miembro de lectores)
SELECT r.rolname AS rol, m.rolname AS miembro
FROM pg_auth_members am
JOIN pg_roles r ON r.oid = am.roleid
JOIN pg_roles m ON m.oid = am.member
WHERE r.rolname = 'lectores';
   rol    |    miembro     
----------+----------------
 lectores | usuario_biblio
(1 row)
```

**Explicación.** Se filtra con `NOT LIKE 'pg\_%'` para esconder los roles internos del sistema (`pg_read_all_data`, `pg_monitor`, etc.) y ver solo los relevantes. Se aprecia que `lectores` tiene `rolcanlogin = f` (no puede conectarse, es un grupo) y que ninguno de los tres roles creados es superusuario. La segunda consulta confirma el apartado 2.3. *(`mydb_admin` y `postgres` ya existían en la VM y no forman parte de la práctica.)*

### 2.5 Cambiar la contraseña de `usuario_biblio`

**Enunciado.** Cambiar la contraseña de `usuario_biblio`.

**Comando**

```sql
ALTER ROLE usuario_biblio WITH PASSWORD 'NuevaClave_2025';
```

**Salida**

```
-- 2.5 Cambiar la contrasena de usuario_biblio
ALTER ROLE usuario_biblio WITH PASSWORD 'NuevaClave_2025';
ALTER ROLE
```

Comprobación de que el cambio ha surtido efecto: la contraseña antigua deja de
funcionar y la nueva funciona.

**Comando**

```bash
echo "-- Con la contraseña ANTIGUA (debe fallar):"
PGPASSWORD="Usu4r10_B1bl10" psql -h localhost -U usuario_biblio -d biblioteca \
    -c "SELECT current_user;"

echo "-- Con la contraseña NUEVA (debe funcionar):"
PGPASSWORD="NuevaClave_2025" psql -h localhost -U usuario_biblio -d biblioteca \
    -c "SELECT current_user, current_database();"
```

**Salida**

```
-- Con la contrasena ANTIGUA (debe fallar):
psql: error: connection to server at "localhost" (127.0.0.1), port 5432 failed: FATAL:  password authentication failed for user "usuario_biblio"
connection to server at "localhost" (127.0.0.1), port 5432 failed: FATAL:  password authentication failed for user "usuario_biblio"

-- Con la contrasena NUEVA (debe funcionar):
  current_user  | current_database 
----------------+------------------
 usuario_biblio | biblioteca
(1 row)
```

### 2.6 Impedir que `usuario_biblio` elimine registros

**Enunciado.** Hacer que `usuario_biblio` no pueda eliminar registros en ninguna tabla y **demostrarlo** intentando un `DELETE` conectado como `usuario_biblio`.

**Comando**

```sql
-- Ejecutado como admin_biblio, propietario de las tablas
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM usuario_biblio;
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM lectores;
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM PUBLIC;

-- Y también para las tablas que se creen en el futuro
ALTER DEFAULT PRIVILEGES FOR ROLE admin_biblio IN SCHEMA public
    REVOKE DELETE, INSERT, UPDATE, TRUNCATE ON TABLES FROM lectores;
```

**Salida**

```
-- 2.6 usuario_biblio no puede eliminar registros en ninguna tabla.
-- Se revoca DELETE explicitamente a usuario_biblio, a lectores y a PUBLIC.
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM usuario_biblio;
REVOKE
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM lectores;
REVOKE
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE
-- Y tambien para las tablas que se creen en el futuro
ALTER DEFAULT PRIVILEGES FOR ROLE admin_biblio IN SCHEMA public
    REVOKE DELETE, INSERT, UPDATE, TRUNCATE ON TABLES FROM lectores;
ALTER DEFAULT PRIVILEGES
```

**Explicación.** Se revoca `DELETE` en los tres sitios de los que podría llegar: directamente al usuario, al rol `lectores` del que es miembro, y a `PUBLIC` (el pseudo-rol que representa «todo el mundo»). Revocar solo al usuario no bastaría, porque el permiso podría seguir heredándose de `lectores` o de `PUBLIC`. El resultado se comprueba con `\dp` en el [apartado 3.3](#33-permisos-sobre-las-tablas-ya-creadas): `lectores=r/admin_biblio` confirma que `lectores` se queda **solo** con `r` (`SELECT`), mientras que `admin_biblio=arwdDxt` conserva todos los privilegios.

Estos comandos se ejecutaron después de crear las tablas (apartado 3), ya que
`ON ALL TABLES` necesita que las tablas existan. La demostración se hace a
continuación, una vez insertados los datos (apartado 4).

#### Demostración: `DELETE` denegado como `usuario_biblio`

**Comando**

```bash
PGPASSWORD='NuevaClave_2025' psql -h localhost -U usuario_biblio -d biblioteca
```

```sql
SELECT current_user;
-- SÍ puede consultar
SELECT count(*) AS total_prestamos FROM prestamos;
-- NO puede borrar en ninguna tabla
DELETE FROM prestamos WHERE id_prestamo = 1;
DELETE FROM libros    WHERE id_libro    = 1;
DELETE FROM autores   WHERE id_autor    = 1;
-- Tampoco puede insertar ni actualizar
INSERT INTO autores (nombre, nacionalidad) VALUES ('Prueba', 'Prueba');
UPDATE libros SET titulo = 'otro titulo' WHERE id_libro = 1;
-- Los datos siguen intactos
SELECT count(*) AS prestamos_tras_los_intentos FROM prestamos;
```

**Salida**

```
-- 2.6 Demostracion de los permisos de usuario_biblio
SELECT current_user;
  current_user  
----------------
 usuario_biblio
(1 row)

-- SI puede consultar
SELECT count(*) AS total_prestamos FROM prestamos;
 total_prestamos 
-----------------
              14
(1 row)

-- NO puede borrar en ninguna tabla
DELETE FROM prestamos WHERE id_prestamo = 1;
ERROR:  permission denied for table prestamos
DELETE FROM libros WHERE id_libro = 1;
ERROR:  permission denied for table libros
DELETE FROM autores WHERE id_autor = 1;
ERROR:  permission denied for table autores
-- Tampoco puede insertar ni actualizar
INSERT INTO autores (nombre, nacionalidad) VALUES ('Prueba', 'Prueba');
ERROR:  permission denied for table autores
UPDATE libros SET titulo = 'otro titulo' WHERE id_libro = 1;
ERROR:  permission denied for table libros
-- Los datos siguen intactos
SELECT count(*) AS prestamos_tras_los_intentos FROM prestamos;
 prestamos_tras_los_intentos 
-----------------------------
                          14
(1 row)
```

**Explicación.** Los tres `DELETE` fallan con `ERROR: permission denied for
table ...`, uno por cada tabla, y el recuento final sigue siendo 14, es decir
que no se borró nada. Se añadieron también un `INSERT` y un `UPDATE` para
comprobar que el usuario es efectivamente de **solo lectura**: únicamente tiene
`SELECT`, heredado del rol `lectores`.

---

## 3. Creación de tablas

Las tablas se crean **conectado como `admin_biblio`**, para que sea su
propietario y para que se aplique la regla de `ALTER DEFAULT PRIVILEGES` del
apartado 2.3.b:

```bash
PGPASSWORD='Adm1n_B1bl10' psql -h localhost -U admin_biblio -d biblioteca
```

### 3.1 Crear las tablas con su clave primaria

**Enunciado.** Crear `autores(id_autor, nombre, nacionalidad)`, `libros(id_libro, titulo, año_publicacion, id_autor)` y `prestamos(id_prestamo, id_libro, fecha_prestamo, fecha_devolucion, usuario_prestatario)` con clave primaria.

**Comando**

```sql
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
```

**Salida**

```
-- 3.1 Creacion de las tablas con su clave primaria
CREATE TABLE autores (
    id_autor     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    nacionalidad VARCHAR(50)
);
CREATE TABLE
CREATE TABLE libros (
    id_libro        INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    titulo          VARCHAR(200) NOT NULL,
    año_publicacion INT,
    id_autor        INT
);
CREATE TABLE
CREATE TABLE prestamos (
    id_prestamo        INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_libro           INT,
    fecha_prestamo     DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_devolucion   DATE,
    usuario_prestatario VARCHAR(100) NOT NULL
);
CREATE TABLE
```

**Explicación.** Se usa **`GENERATED ALWAYS AS IDENTITY`** en vez de `SERIAL` porque es el estándar SQL y es más seguro: impide insertar un valor a mano en la clave primaria, con lo que la secuencia nunca se desincroniza. `fecha_prestamo` es `NOT NULL` con `DEFAULT CURRENT_DATE` (un préstamo siempre tiene fecha de inicio), mientras que **`fecha_devolucion` admite `NULL`**, que es precisamente la forma de representar «préstamo todavía no devuelto» que se explota en los apartados 5.2 y 7.1. El identificador `año_publicacion` se escribe sin comillas: al ser el clúster UTF8, la `ñ` es un carácter válido en un identificador.

### 3.2 Claves foráneas

**Enunciado.** Definir `libros.id_autor → autores` y `prestamos.id_libro → libros` con `ON DELETE CASCADE`. Mostrar `\d autores`, `\d libros` y `\d prestamos`.

**Comando**

```sql
ALTER TABLE libros
    ADD CONSTRAINT fk_libros_autor
    FOREIGN KEY (id_autor) REFERENCES autores(id_autor);

ALTER TABLE prestamos
    ADD CONSTRAINT fk_prestamos_libro
    FOREIGN KEY (id_libro) REFERENCES libros(id_libro) ON DELETE CASCADE;

\d autores
\d libros
\d prestamos
```

**Salida**

```
-- 3.2 Claves foraneas
ALTER TABLE libros
    ADD CONSTRAINT fk_libros_autor
    FOREIGN KEY (id_autor) REFERENCES autores(id_autor);
ALTER TABLE
ALTER TABLE prestamos
    ADD CONSTRAINT fk_prestamos_libro
    FOREIGN KEY (id_libro) REFERENCES libros(id_libro) ON DELETE CASCADE;
ALTER TABLE
\d autores
                                   Table "public.autores"
    Column    |          Type          | Collation | Nullable |           Default            
--------------+------------------------+-----------+----------+------------------------------
 id_autor     | integer                |           | not null | generated always as identity
 nombre       | character varying(100) |           | not null | 
 nacionalidad | character varying(50)  |           |          | 
Indexes:
    "autores_pkey" PRIMARY KEY, btree (id_autor)
Referenced by:
    TABLE "libros" CONSTRAINT "fk_libros_autor" FOREIGN KEY (id_autor) REFERENCES autores(id_autor)

\d libros
                                     Table "public.libros"
     Column      |          Type          | Collation | Nullable |           Default            
-----------------+------------------------+-----------+----------+------------------------------
 id_libro        | integer                |           | not null | generated always as identity
 titulo          | character varying(200) |           | not null | 
 año_publicacion | integer                |           |          | 
 id_autor        | integer                |           |          | 
Indexes:
    "libros_pkey" PRIMARY KEY, btree (id_libro)
Foreign-key constraints:
    "fk_libros_autor" FOREIGN KEY (id_autor) REFERENCES autores(id_autor)
Referenced by:
    TABLE "prestamos" CONSTRAINT "fk_prestamos_libro" FOREIGN KEY (id_libro) REFERENCES libros(id_libro) ON DELETE CASCADE

\d prestamos
                                      Table "public.prestamos"
       Column        |          Type          | Collation | Nullable |           Default            
---------------------+------------------------+-----------+----------+------------------------------
 id_prestamo         | integer                |           | not null | generated always as identity
 id_libro            | integer                |           |          | 
 fecha_prestamo      | date                   |           | not null | CURRENT_DATE
 fecha_devolucion    | date                   |           |          | 
 usuario_prestatario | character varying(100) |           | not null | 
Indexes:
    "prestamos_pkey" PRIMARY KEY, btree (id_prestamo)
Foreign-key constraints:
    "fk_prestamos_libro" FOREIGN KEY (id_libro) REFERENCES libros(id_libro) ON DELETE CASCADE
```

**Explicación.** Las claves foráneas se añaden con `ALTER TABLE` en lugar de inline en el `CREATE TABLE` para seguir la separación que marca el guion entre 3.1 y 3.2, y porque así se les puede dar un nombre explícito (`fk_libros_autor`, `fk_prestamos_libro`) que aparece en los mensajes de error. Solo `prestamos.id_libro` lleva `ON DELETE CASCADE`; `libros.id_autor` se deja con el comportamiento por defecto (`NO ACTION`), de modo que no se puede borrar un autor que todavía tenga libros registrados. En la salida de `\d` se ve el `año_publicacion` correctamente con su `ñ`.

### 3.3 Permisos sobre las tablas ya creadas

**Enunciado.** Repetir `GRANT SELECT ON ALL TABLES IN SCHEMA public TO lectores` una vez que las tablas existen (ver la *Nota previa* del apartado 2).

**Comando**

```sql
GRANT SELECT ON ALL TABLES IN SCHEMA public TO lectores;

-- (continuación del apartado 2.6, ver más arriba)
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM usuario_biblio;
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM lectores;
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE admin_biblio IN SCHEMA public
    REVOKE DELETE, INSERT, UPDATE, TRUNCATE ON TABLES FROM lectores;

\dp
```

**Salida**

```
-- 2.2 (repeticion) Permisos de consulta sobre las tablas ya creadas
GRANT SELECT ON ALL TABLES IN SCHEMA public TO lectores;
GRANT
-- 2.6 usuario_biblio no puede eliminar registros en ninguna tabla.
-- Se revoca DELETE explicitamente a usuario_biblio, a lectores y a PUBLIC.
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM usuario_biblio;
REVOKE
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM lectores;
REVOKE
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE
-- Y tambien para las tablas que se creen en el futuro
ALTER DEFAULT PRIVILEGES FOR ROLE admin_biblio IN SCHEMA public
    REVOKE DELETE, INSERT, UPDATE, TRUNCATE ON TABLES FROM lectores;
ALTER DEFAULT PRIVILEGES
-- Privilegios resultantes
\dp
                                                Access privileges
 Schema |           Name            |   Type   |         Access privileges         | Column privileges | Policies 
--------+---------------------------+----------+-----------------------------------+-------------------+----------
 public | autores                   | table    | admin_biblio=arwdDxt/admin_biblio+|                   | 
        |                           |          | lectores=r/admin_biblio           |                   | 
 public | autores_id_autor_seq      | sequence |                                   |                   | 
 public | libros                    | table    | admin_biblio=arwdDxt/admin_biblio+|                   | 
        |                           |          | lectores=r/admin_biblio           |                   | 
 public | libros_id_libro_seq       | sequence |                                   |                   | 
 public | prestamos                 | table    | admin_biblio=arwdDxt/admin_biblio+|                   | 
        |                           |          | lectores=r/admin_biblio           |                   | 
 public | prestamos_id_prestamo_seq | sequence |                                   |                   | 
(6 rows)
```

**Explicación.** El `\dp` final es la prueba de que todo el montaje de permisos del apartado 2 ha funcionado: las tres tablas tienen `admin_biblio=arwdDxt` (propietario, todos los privilegios) y `lectores=r` (solo lectura). Las secuencias de las columnas `IDENTITY` aparecen sin privilegios concedidos, lo cual es correcto: para hacer `SELECT` no se necesita acceso a la secuencia.

---

## 4. Inserción de datos

### 4.1 Insertar autores, libros y préstamos

**Enunciado.** Insertar al menos 5 autores, 8 libros y 5 préstamos, de forma que los apartados posteriores tengan sentido: al menos 2 autores con más de un libro, varios préstamos sin `fecha_devolucion`, libros con número de préstamos distinto para que el «top 3» sea claro, varios préstamos del mismo prestatario y un libro con préstamos fuera del top 3 (el que se borrará en 7.2).

**Comando**

```sql
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
```

**Salida**

```
\encoding UTF8
-- 4.1 Insercion de datos
INSERT INTO autores (nombre, nacionalidad) VALUES
    ('Gabriel García Márquez', 'Colombiana'),
    ('Jorge Luis Borges',      'Argentina'),
    ('Miguel de Cervantes',    'Española'),
    ('Isabel Allende',         'Chilena'),
    ('Haruki Murakami',        'Japonesa'),
    ('Virginia Woolf',         'Británica');
INSERT 0 6
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
INSERT 0 9
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
INSERT 0 14
```

**Explicación.** Se insertan **6 autores, 9 libros y 14 préstamos**. No se indica `id_autor` ni `id_libro` ni `id_prestamo` porque son `GENERATED ALWAYS AS IDENTITY` y PostgreSQL los asigna solo (1, 2, 3...), lo que permite referenciarlos en los `INSERT` siguientes. El reparto de préstamos se eligió a propósito: libro 1 → 5 préstamos, libro 5 → 4, libro 3 → 3, libro 9 → 2. Al ser todos los recuentos distintos, el top 3 del apartado 9.2 no tiene empates, y el libro 9 («La señora Dalloway») queda fuera del top 3 pero con 2 préstamos, que es justo lo que hace visible el `CASCADE` del apartado 7.2.

Comprobación del contenido de las tres tablas tras la inserción:

**Comando**

```sql
SELECT * FROM autores;
SELECT * FROM libros;
SELECT * FROM prestamos;
```

**Salida**

```
-- 4.1 Comprobacion de los datos insertados
SELECT * FROM autores;
 id_autor |         nombre         | nacionalidad 
----------+------------------------+--------------
        1 | Gabriel García Márquez | Colombiana
        2 | Jorge Luis Borges      | Argentina
        3 | Miguel de Cervantes    | Española
        4 | Isabel Allende         | Chilena
        5 | Haruki Murakami        | Japonesa
        6 | Virginia Woolf         | Británica
(6 rows)

SELECT * FROM libros;
 id_libro |              titulo               | año_publicacion | id_autor 
----------+-----------------------------------+-----------------+----------
        1 | Cien años de soledad              |            1967 |        1
        2 | El amor en los tiempos del cólera |            1985 |        1
        3 | Ficciones                         |            1944 |        2
        4 | El Aleph                          |            1949 |        2
        5 | Don Quijote de la Mancha          |            1605 |        3
        6 | La casa de los espíritus          |            1982 |        4
        7 | Tokio blues                       |            1987 |        5
        8 | Kafka en la orilla                |            2002 |        5
        9 | La señora Dalloway                |            1925 |        6
(9 rows)

SELECT * FROM prestamos;
 id_prestamo | id_libro | fecha_prestamo | fecha_devolucion | usuario_prestatario 
-------------+----------+----------------+------------------+---------------------
           1 |        1 | 2025-01-10     | 2025-01-24       | Ana Pérez
           2 |        1 | 2025-02-05     | 2025-02-19       | Luis Gómez
           3 |        1 | 2025-03-01     |                  | María Ruiz
           4 |        1 | 2025-04-12     | 2025-04-26       | Ana Pérez
           5 |        1 | 2025-05-20     |                  | Carlos Díaz
           6 |        5 | 2025-01-15     | 2025-01-29       | Luis Gómez
           7 |        5 | 2025-02-20     |                  | Ana Pérez
           8 |        5 | 2025-03-18     | 2025-04-01       | Elena Sanz
           9 |        5 | 2025-06-02     |                  | Luis Gómez
          10 |        3 | 2025-01-25     | 2025-02-08       | María Ruiz
          11 |        3 | 2025-04-03     |                  | Carlos Díaz
          12 |        3 | 2025-05-10     | 2025-05-24       | Ana Pérez
          13 |        9 | 2025-02-14     | 2025-02-28       | Elena Sanz
          14 |        9 | 2025-06-15     |                  | María Ruiz
(14 rows)
```

**Explicación.** Se cumplen todas las condiciones pedidas: tres autores con más
de un libro (García Márquez, Borges y Murakami), seis préstamos con
`fecha_devolucion` vacía (los `id_prestamo` 3, 5, 7, 9, 11 y 14), y varios
prestatarios repetidos (Ana Pérez aparece 4 veces, Luis Gómez y María Ruiz 3
veces cada uno).

---

## 5. Consultas básicas

### 5.1 Listar todos los libros con su autor (JOIN)

**Enunciado.** Listar todos los libros con su autor mediante un JOIN.

**Comando**

```sql
SELECT l.id_libro, l.titulo, l.año_publicacion, a.nombre AS autor, a.nacionalidad
FROM libros l
JOIN autores a ON a.id_autor = l.id_autor
ORDER BY l.id_libro;
```

**Salida**

```
-- 5.1 Listar todos los libros con su autor (JOIN)
SELECT l.id_libro, l.titulo, l.año_publicacion, a.nombre AS autor, a.nacionalidad
FROM libros l
JOIN autores a ON a.id_autor = l.id_autor
ORDER BY l.id_libro;
 id_libro |              titulo               | año_publicacion |         autor          | nacionalidad 
----------+-----------------------------------+-----------------+------------------------+--------------
        1 | Cien años de soledad              |            1967 | Gabriel García Márquez | Colombiana
        2 | El amor en los tiempos del cólera |            1985 | Gabriel García Márquez | Colombiana
        3 | Ficciones                         |            1944 | Jorge Luis Borges      | Argentina
        4 | El Aleph                          |            1949 | Jorge Luis Borges      | Argentina
        5 | Don Quijote de la Mancha          |            1605 | Miguel de Cervantes    | Española
        6 | La casa de los espíritus          |            1982 | Isabel Allende         | Chilena
        7 | Tokio blues                       |            1987 | Haruki Murakami        | Japonesa
        8 | Kafka en la orilla                |            2002 | Haruki Murakami        | Japonesa
        9 | La señora Dalloway                |            1925 | Virginia Woolf         | Británica
(9 rows)
```

**Explicación.** Se usa `JOIN` (equivalente a `INNER JOIN`), que devuelve solo los libros que tienen autor asignado. Como todos los libros insertados tienen `id_autor`, salen los 9. Si hubiera libros con `id_autor` a `NULL` y se quisieran ver también, habría que usar `LEFT JOIN`.

### 5.2 Préstamos sin fecha de devolución

**Enunciado.** Mostrar los préstamos que no tienen fecha de devolución.

**Comando**

```sql
SELECT p.id_prestamo, l.titulo, p.fecha_prestamo, p.usuario_prestatario
FROM prestamos p
JOIN libros l ON l.id_libro = p.id_libro
WHERE p.fecha_devolucion IS NULL
ORDER BY p.id_prestamo;
```

**Salida**

```
-- 5.2 Prestamos sin fecha de devolucion (todavia no devueltos)
SELECT p.id_prestamo, l.titulo, p.fecha_prestamo, p.usuario_prestatario
FROM prestamos p
JOIN libros l ON l.id_libro = p.id_libro
WHERE p.fecha_devolucion IS NULL
ORDER BY p.id_prestamo;
 id_prestamo |          titulo          | fecha_prestamo | usuario_prestatario 
-------------+--------------------------+----------------+---------------------
           3 | Cien años de soledad     | 2025-03-01     | María Ruiz
           5 | Cien años de soledad     | 2025-05-20     | Carlos Díaz
           7 | Don Quijote de la Mancha | 2025-02-20     | Ana Pérez
           9 | Don Quijote de la Mancha | 2025-06-02     | Luis Gómez
          11 | Ficciones                | 2025-04-03     | Carlos Díaz
          14 | La señora Dalloway       | 2025-06-15     | María Ruiz
(6 rows)
```

**Explicación.** La condición se escribe con **`IS NULL`** y no con `= NULL`: en SQL la comparación `= NULL` nunca es verdadera (devuelve `NULL`, que no es `TRUE`), por lo que la consulta no devolvería ninguna fila. Son los 6 préstamos aún no devueltos.

### 5.3 Autores con más de un libro (GROUP BY + HAVING)

**Enunciado.** Mostrar los autores que tienen más de un libro.

**Comando**

```sql
SELECT a.nombre AS autor, COUNT(l.id_libro) AS num_libros
FROM autores a
JOIN libros l ON l.id_autor = a.id_autor
GROUP BY a.id_autor, a.nombre
HAVING COUNT(l.id_libro) > 1
ORDER BY num_libros DESC, autor;
```

**Salida**

```
-- 5.3 Autores con mas de un libro (GROUP BY + HAVING)
SELECT a.nombre AS autor, COUNT(l.id_libro) AS num_libros
FROM autores a
JOIN libros l ON l.id_autor = a.id_autor
GROUP BY a.id_autor, a.nombre
HAVING COUNT(l.id_libro) > 1
ORDER BY num_libros DESC, autor;
         autor          | num_libros 
------------------------+------------
 Gabriel García Márquez |          2
 Haruki Murakami        |          2
 Jorge Luis Borges      |          2
(3 rows)
```

**Explicación.** El filtro va en **`HAVING`** y no en `WHERE` porque se aplica sobre el resultado de una función de agregación (`COUNT`): `WHERE` se evalúa antes de agrupar y no puede ver los grupos. Se agrupa por `a.id_autor` además de por el nombre para que dos autores homónimos no se mezclaran en un mismo grupo.

---

## 6. Consultas con agregación

### 6.1 Número total de préstamos

**Enunciado.** Obtener el número total de préstamos.

**Comando**

```sql
SELECT COUNT(*) AS total_prestamos FROM prestamos;
```

**Salida**

```
-- 6.1 Numero total de prestamos
SELECT COUNT(*) AS total_prestamos FROM prestamos;
 total_prestamos 
-----------------
              14
(1 row)
```

### 6.2 Número de libros prestados por cada usuario

**Enunciado.** Obtener el número de libros prestados por cada usuario.

**Comando**

```sql
SELECT p.usuario_prestatario,
       COUNT(*)                   AS prestamos_realizados,
       COUNT(DISTINCT p.id_libro) AS libros_distintos
FROM prestamos p
GROUP BY p.usuario_prestatario
ORDER BY prestamos_realizados DESC, p.usuario_prestatario;
```

**Salida**

```
-- 6.2 Numero de libros prestados por cada usuario prestatario
SELECT p.usuario_prestatario,
       COUNT(*) AS prestamos_realizados,
       COUNT(DISTINCT p.id_libro) AS libros_distintos
FROM prestamos p
GROUP BY p.usuario_prestatario
ORDER BY prestamos_realizados DESC, p.usuario_prestatario;
 usuario_prestatario | prestamos_realizados | libros_distintos 
---------------------+----------------------+------------------
 Ana Pérez           |                    4 |                3
 Luis Gómez          |                    3 |                2
 María Ruiz          |                    3 |                3
 Carlos Díaz         |                    2 |                2
 Elena Sanz          |                    2 |                2
(5 rows)
```

**Explicación.** Se muestran dos recuentos porque «número de libros prestados» es ambiguo: `COUNT(*)` cuenta **préstamos** y `COUNT(DISTINCT p.id_libro)` cuenta **libros distintos**. La diferencia se ve en Ana Pérez, que hizo 4 préstamos pero de solo 3 libros diferentes, porque tomó prestado dos veces «Cien años de soledad».

---

## 7. Modificación de datos

### 7.1 Actualizar la fecha de devolución de un préstamo pendiente

**Enunciado.** Actualizar la fecha de devolución de un préstamo pendiente, mostrando el antes y el después.

**Comando**

```sql
-- ANTES: el préstamo 3 está pendiente (fecha_devolucion = NULL)
SELECT * FROM prestamos WHERE id_prestamo = 3;

UPDATE prestamos SET fecha_devolucion = '2025-03-15' WHERE id_prestamo = 3;

-- DESPUÉS: ya tiene fecha de devolución
SELECT * FROM prestamos WHERE id_prestamo = 3;
SELECT COUNT(*) AS pendientes FROM prestamos WHERE fecha_devolucion IS NULL;
```

**Salida**

```
-- 7.1 Actualizar la fecha de devolucion de un prestamo pendiente
-- ANTES: el prestamo 3 esta pendiente (fecha_devolucion = NULL)
SELECT * FROM prestamos WHERE id_prestamo = 3;
 id_prestamo | id_libro | fecha_prestamo | fecha_devolucion | usuario_prestatario 
-------------+----------+----------------+------------------+---------------------
           3 |        1 | 2025-03-01     |                  | María Ruiz
(1 row)

UPDATE prestamos SET fecha_devolucion = '2025-03-15' WHERE id_prestamo = 3;
UPDATE 1
-- DESPUES: ya tiene fecha de devolucion
SELECT * FROM prestamos WHERE id_prestamo = 3;
 id_prestamo | id_libro | fecha_prestamo | fecha_devolucion | usuario_prestatario 
-------------+----------+----------------+------------------+---------------------
           3 |        1 | 2025-03-01     | 2025-03-15       | María Ruiz
(1 row)

-- Prestamos que siguen pendientes
SELECT COUNT(*) AS pendientes FROM prestamos WHERE fecha_devolucion IS NULL;
 pendientes 
------------
          5
(1 row)
```

**Explicación.** El `UPDATE` responde `UPDATE 1`, confirmando que se modificó exactamente una fila. El número de préstamos pendientes baja de 6 (apartado 5.2) a 5, lo que confirma el efecto del cambio.

### 7.2 Eliminar un libro y comprobar el `ON DELETE CASCADE`

**Enunciado.** Eliminar un libro y comprobar el efecto en `prestamos`: mostrar los préstamos de ese libro antes del `DELETE`, ejecutarlo y mostrar que se han borrado por el `CASCADE`. Justificar la elección de `CASCADE` frente a `RESTRICT` / `SET NULL`.

**Comando**

```sql
-- ANTES: préstamos del libro 9 ("La señora Dalloway")
SELECT * FROM prestamos WHERE id_libro = 9;
SELECT COUNT(*) AS total_prestamos_antes FROM prestamos;

DELETE FROM libros WHERE id_libro = 9;

-- DESPUÉS: sus préstamos han desaparecido por el CASCADE
SELECT * FROM prestamos WHERE id_libro = 9;
SELECT COUNT(*) AS total_prestamos_despues FROM prestamos;
SELECT * FROM libros ORDER BY id_libro;
```

**Salida**

```
-- 7.2 Eliminar un libro y comprobar el efecto ON DELETE CASCADE en prestamos
-- ANTES: prestamos del libro 9 ("La señora Dalloway")
SELECT * FROM prestamos WHERE id_libro = 9;
 id_prestamo | id_libro | fecha_prestamo | fecha_devolucion | usuario_prestatario 
-------------+----------+----------------+------------------+---------------------
          13 |        9 | 2025-02-14     | 2025-02-28       | Elena Sanz
          14 |        9 | 2025-06-15     |                  | María Ruiz
(2 rows)

SELECT COUNT(*) AS total_prestamos_antes FROM prestamos;
 total_prestamos_antes 
-----------------------
                    14
(1 row)

-- Se elimina el libro
DELETE FROM libros WHERE id_libro = 9;
DELETE 1
-- DESPUES: sus prestamos han desaparecido por el CASCADE
SELECT * FROM prestamos WHERE id_libro = 9;
 id_prestamo | id_libro | fecha_prestamo | fecha_devolucion | usuario_prestatario 
-------------+----------+----------------+------------------+---------------------
(0 rows)

SELECT COUNT(*) AS total_prestamos_despues FROM prestamos;
 total_prestamos_despues 
-------------------------
                      12
(1 row)

SELECT * FROM libros ORDER BY id_libro;
 id_libro |              titulo               | año_publicacion | id_autor 
----------+-----------------------------------+-----------------+----------
        1 | Cien años de soledad              |            1967 |        1
        2 | El amor en los tiempos del cólera |            1985 |        1
        3 | Ficciones                         |            1944 |        2
        4 | El Aleph                          |            1949 |        2
        5 | Don Quijote de la Mancha          |            1605 |        3
        6 | La casa de los espíritus          |            1982 |        4
        7 | Tokio blues                       |            1987 |        5
        8 | Kafka en la orilla                |            2002 |        5
(8 rows)
```

**Explicación.** El `DELETE` sobre `libros` responde `DELETE 1` (se borró un
libro), pero el total de préstamos pasa de **14 a 12**: las dos filas de
`prestamos` que apuntaban al libro 9 se borraron automáticamente sin haberlas
mencionado en ningún `DELETE`. Eso es el `ON DELETE CASCADE`.

Se eligió el libro 9 («La señora Dalloway») a propósito: tenía 2 préstamos y
estaba **fuera del top 3**, así que el borrado se nota en los recuentos pero no
altera el resultado del apartado 9.2.

**¿Por qué `CASCADE` y no `RESTRICT` o `SET NULL`?**

| Opción | Comportamiento al borrar un libro | Por qué no se eligió |
|---|---|---|
| `RESTRICT` / `NO ACTION` | El `DELETE` falla si el libro tiene préstamos | Obligaría a borrar los préstamos a mano antes; para un libro retirado del catálogo es una molestia innecesaria |
| `SET NULL` | Los préstamos quedan con `id_libro = NULL` | Dejaría **filas huérfanas**: un préstamo sin libro no significa nada y rompería los JOIN de los apartados 5 y 9 |
| **`CASCADE`** ✅ | Se borran también sus préstamos | Un préstamo **no tiene existencia propia** sin el libro al que se refiere: es información dependiente, así que su ciclo de vida debe ir unido al del libro |

Por el contrario, en `libros.id_autor` se dejó el comportamiento por defecto
(`NO ACTION`) justamente por el motivo opuesto: un libro **sí** tiene sentido
por sí mismo, y borrar un autor no debería hacer desaparecer su obra del
catálogo sin avisar.

---

## 8. Vistas

### 8.1 Crear `vista_libros_prestados`

**Enunciado.** Crear `vista_libros_prestados` con el título del libro, el nombre del autor y el nombre del prestatario.

**Comando**

```sql
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

\dp vista_libros_prestados
```

**Salida**

```
-- 8.1 Crear la vista vista_libros_prestados
CREATE VIEW vista_libros_prestados AS
SELECT l.titulo            AS titulo_libro,
       a.nombre            AS nombre_autor,
       p.usuario_prestatario AS nombre_prestatario,
       p.fecha_prestamo,
       p.fecha_devolucion
FROM prestamos p
JOIN libros  l ON l.id_libro = p.id_libro
JOIN autores a ON a.id_autor = l.id_autor;
CREATE VIEW
SELECT * FROM vista_libros_prestados ORDER BY titulo_libro, fecha_prestamo;
       titulo_libro       |      nombre_autor      | nombre_prestatario | fecha_prestamo | fecha_devolucion 
--------------------------+------------------------+--------------------+----------------+------------------
 Cien años de soledad     | Gabriel García Márquez | Ana Pérez          | 2025-01-10     | 2025-01-24
 Cien años de soledad     | Gabriel García Márquez | Luis Gómez         | 2025-02-05     | 2025-02-19
 Cien años de soledad     | Gabriel García Márquez | María Ruiz         | 2025-03-01     | 2025-03-15
 Cien años de soledad     | Gabriel García Márquez | Ana Pérez          | 2025-04-12     | 2025-04-26
 Cien años de soledad     | Gabriel García Márquez | Carlos Díaz        | 2025-05-20     | 
 Don Quijote de la Mancha | Miguel de Cervantes    | Luis Gómez         | 2025-01-15     | 2025-01-29
 Don Quijote de la Mancha | Miguel de Cervantes    | Ana Pérez          | 2025-02-20     | 
 Don Quijote de la Mancha | Miguel de Cervantes    | Elena Sanz         | 2025-03-18     | 2025-04-01
 Don Quijote de la Mancha | Miguel de Cervantes    | Luis Gómez         | 2025-06-02     | 
 Ficciones                | Jorge Luis Borges      | María Ruiz         | 2025-01-25     | 2025-02-08
 Ficciones                | Jorge Luis Borges      | Carlos Díaz        | 2025-04-03     | 
 Ficciones                | Jorge Luis Borges      | Ana Pérez          | 2025-05-10     | 2025-05-24
(12 rows)

-- Privilegios heredados automaticamente de ALTER DEFAULT PRIVILEGES (lectores ya tiene SELECT)
\dp vista_libros_prestados
                                             Access privileges
 Schema |          Name          | Type |         Access privileges         | Column privileges | Policies 
--------+------------------------+------+-----------------------------------+-------------------+----------
 public | vista_libros_prestados | view | admin_biblio=arwdDxt/admin_biblio+|                   | 
        |                        |      | lectores=r/admin_biblio           |                   | 
(1 row)
```

**Explicación.** La vista enlaza las tres tablas y añade las dos fechas del préstamo, que son las que dan sentido a la consulta. Devuelve 12 filas, coherente con los 12 préstamos que quedaban tras el apartado 7.2. **Lo importante está en el `\dp` final:** la vista ya aparece con `lectores=r/admin_biblio` sin haber ejecutado ningún `GRANT` sobre ella. Es el `ALTER DEFAULT PRIVILEGES ... ON TABLES` del apartado 2.3.b, que en PostgreSQL afecta también a las vistas. Esto es exactamente lo que hay que corregir en 8.2.

### 8.2 Conceder SELECT sobre la vista solo a `usuario_biblio`

**Enunciado.** Conceder `SELECT` sobre la vista únicamente a `usuario_biblio`, revocando antes el acceso que `lectores` y `PUBLIC` pudieran tener.

**Comando**

```sql
-- Primero se retira el acceso que lectores había heredado, y el de PUBLIC
REVOKE ALL ON vista_libros_prestados FROM lectores;
REVOKE ALL ON vista_libros_prestados FROM PUBLIC;

-- Y se concede SELECT directamente al usuario
GRANT SELECT ON vista_libros_prestados TO usuario_biblio;

\dp vista_libros_prestados
```

**Salida**

```
-- 8.2 Conceder SELECT sobre la vista UNICAMENTE a usuario_biblio
-- Primero se retira el acceso que lectores habia heredado, y el de PUBLIC
REVOKE ALL ON vista_libros_prestados FROM lectores;
REVOKE
REVOKE ALL ON vista_libros_prestados FROM PUBLIC;
REVOKE
-- Y se concede SELECT directamente al usuario
GRANT SELECT ON vista_libros_prestados TO usuario_biblio;
GRANT
\dp vista_libros_prestados
                                             Access privileges
 Schema |          Name          | Type |         Access privileges         | Column privileges | Policies 
--------+------------------------+------+-----------------------------------+-------------------+----------
 public | vista_libros_prestados | view | admin_biblio=arwdDxt/admin_biblio+|                   | 
        |                        |      | usuario_biblio=r/admin_biblio     |                   | 
(1 row)
```

**Explicación.** Tras los `REVOKE` y el `GRANT`, `\dp` muestra únicamente `admin_biblio=arwdDxt` (el propietario) y `usuario_biblio=r`: `lectores` ha desaparecido de la lista. El acceso a la vista es ahora un privilegio **directo del usuario**, no heredado del grupo, que es lo que pedía el enunciado («únicamente a `usuario_biblio`»).

#### Demostración: la vista se consulta como `usuario_biblio`

**Comando**

```bash
PGPASSWORD='NuevaClave_2025' psql -h localhost -U usuario_biblio -d biblioteca
```

```sql
SELECT current_user;
SELECT * FROM vista_libros_prestados ORDER BY titulo_libro, fecha_prestamo LIMIT 5;
```

**Salida**

```
-- 8.2 Demostracion conectado como usuario_biblio
SELECT current_user;
  current_user  
----------------
 usuario_biblio
(1 row)

SELECT * FROM vista_libros_prestados ORDER BY titulo_libro, fecha_prestamo LIMIT 5;
     titulo_libro     |      nombre_autor      | nombre_prestatario | fecha_prestamo | fecha_devolucion 
----------------------+------------------------+--------------------+----------------+------------------
 Cien años de soledad | Gabriel García Márquez | Ana Pérez          | 2025-01-10     | 2025-01-24
 Cien años de soledad | Gabriel García Márquez | Luis Gómez         | 2025-02-05     | 2025-02-19
 Cien años de soledad | Gabriel García Márquez | María Ruiz         | 2025-03-01     | 2025-03-15
 Cien años de soledad | Gabriel García Márquez | Ana Pérez          | 2025-04-12     | 2025-04-26
 Cien años de soledad | Gabriel García Márquez | Carlos Díaz        | 2025-05-20     | 
(5 rows)
```

#### Demostración: el acceso **no** viene del rol `lectores`

Para probar que el privilegio es directo y no heredado, se asume únicamente el
rol `lectores` con `SET ROLE` dentro de la misma sesión de `usuario_biblio`:

**Comando**

```sql
SET ROLE lectores;
SELECT current_user;
SELECT * FROM vista_libros_prestados LIMIT 1;
```

**Salida**

```
-- 8.2 Comprobacion de que el acceso NO viene del rol lectores:
-- al asumir unicamente el rol lectores, la consulta falla
SET ROLE lectores;
SET
SELECT current_user;
 current_user 
--------------
 lectores
(1 row)

SELECT * FROM vista_libros_prestados LIMIT 1;
psql:/tmp/bib/s82c.sql:5: ERROR:  permission denied for view vista_libros_prestados
```

**Explicación.** Con `SET ROLE lectores`, `current_user` pasa a ser `lectores` y
la misma consulta que antes funcionaba ahora falla con `permission denied for
view vista_libros_prestados`. Queda demostrado que el `SELECT` sobre la vista lo
tiene `usuario_biblio` en exclusiva y no el grupo. Este bloque se ejecutó en una
**única sesión de `psql`** (con `psql -a -f`), porque `SET ROLE` solo afecta a
la sesión en curso y se perdería si cada sentencia abriera su propia conexión.

---

## 9. Funciones y consultas avanzadas

### 9.1 Función que devuelve los libros de un autor

**Enunciado.** Crear una función (PL/pgSQL o SQL) que reciba el nombre de un autor y devuelva sus libros usando `RETURNS TABLE`. Mostrar una llamada de ejemplo.

**Comando**

```sql
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
```

**Salida**

```
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
CREATE FUNCTION
```

**Explicación.** Se usa `ILIKE '%' || p_nombre || '%'` en lugar de `=` para que la búsqueda no distinga mayúsculas y acepte coincidencias parciales, de modo que basta con el apellido. El parámetro se llama `p_nombre` (con prefijo) para que no colisione con la columna `nombre` de la tabla: dentro de PL/pgSQL, si un identificador puede ser a la vez variable y columna, PostgreSQL da un error de ambigüedad. Por el mismo motivo, todas las columnas del `SELECT` van cualificadas con su alias de tabla (`l.`, `a.`), ya que los nombres de `RETURNS TABLE` también se comportan como variables.

Llamadas de ejemplo:

**Comando**

```sql
SELECT * FROM libros_de_autor('Gabriel García Márquez');
SELECT * FROM libros_de_autor('Murakami');
SELECT * FROM libros_de_autor('Autor Inexistente');
```

**Salida**

```
-- 9.1 Llamadas de ejemplo a la funcion
SELECT * FROM libros_de_autor('Gabriel García Márquez');
 id_libro |              titulo               | año_publicacion 
----------+-----------------------------------+-----------------
        1 | Cien años de soledad              |            1967
        2 | El amor en los tiempos del cólera |            1985
(2 rows)

SELECT * FROM libros_de_autor('Murakami');
 id_libro |       titulo       | año_publicacion 
----------+--------------------+-----------------
        7 | Tokio blues        |            1987
        8 | Kafka en la orilla |            2002
(2 rows)

SELECT * FROM libros_de_autor('Autor Inexistente');
 id_libro | titulo | año_publicacion 
----------+--------+-----------------
(0 rows)
```

**Explicación.** La primera llamada usa el nombre completo y la segunda solo el
apellido, y ambas funcionan gracias al `ILIKE`. La tercera devuelve 0 filas en
lugar de dar un error, que es el comportamiento deseable para un nombre que no
existe.

### 9.2 Los 3 libros más prestados

**Enunciado.** Consulta con los 3 libros más prestados (`COUNT` + `ORDER BY` + `LIMIT 3`).

**Comando**

```sql
SELECT l.id_libro, l.titulo, a.nombre AS autor, COUNT(p.id_prestamo) AS veces_prestado
FROM libros l
JOIN prestamos p ON p.id_libro = l.id_libro
JOIN autores a ON a.id_autor = l.id_autor
GROUP BY l.id_libro, l.titulo, a.nombre
ORDER BY veces_prestado DESC
LIMIT 3;
```

**Salida**

```
-- 9.2 Los 3 libros mas prestados
SELECT l.id_libro, l.titulo, a.nombre AS autor, COUNT(p.id_prestamo) AS veces_prestado
FROM libros l
JOIN prestamos p ON p.id_libro = l.id_libro
JOIN autores a ON a.id_autor = l.id_autor
GROUP BY l.id_libro, l.titulo, a.nombre
ORDER BY veces_prestado DESC
LIMIT 3;
 id_libro |          titulo          |         autor          | veces_prestado 
----------+--------------------------+------------------------+----------------
        1 | Cien años de soledad     | Gabriel García Márquez |              5
        5 | Don Quijote de la Mancha | Miguel de Cervantes    |              4
        3 | Ficciones                | Jorge Luis Borges      |              3
(3 rows)
```

**Explicación.** Los recuentos (5, 4 y 3) son todos distintos, así que el top 3 es inequívoco y `LIMIT 3` no corta un empate arbitrariamente. Se agrupa por `l.id_libro` (la clave primaria) y no solo por el título, para que dos libros con el mismo título no se contaran juntos.

---

## 10. Exportación e importación

### 10.1 Exportar `libros` a CSV

**Enunciado.** Exportar `libros` a CSV con `\copy ... TO ... CSV HEADER`,
explicando por qué `\copy` y no `COPY`. Mostrar el contenido del CSV con `cat`.

Primero se comprueba qué ocurre con `COPY`, la versión del lado del servidor:

**Comando**

```sql
COPY libros TO '/home/usuario/biblioteca_practica/csv/libros.csv' CSV HEADER;
```

**Salida**

```
-- 10.1 Intento con COPY (del lado SERVIDOR): falla por falta de privilegios
COPY libros TO '/home/usuario/biblioteca_practica/csv/libros.csv' CSV HEADER;
ERROR:  permission denied to COPY to a file
DETAIL:  Only roles with privileges of the "pg_write_server_files" role may COPY to a file.
HINT:  Anyone can COPY to stdout or from stdin. psql's \copy command also works for anyone.
```

**Explicación.** `COPY ... TO '<fichero>'` lo ejecuta el **proceso servidor** de
PostgreSQL, que escribiría el fichero en el disco de la máquina del servidor y
con el usuario del sistema `postgres`. Por eso está restringido a superusuarios
o a miembros del rol `pg_write_server_files`, y `admin_biblio` no es ninguna de
las dos cosas. El propio mensaje de error sugiere la alternativa.

La forma correcta es `\copy`, un **meta-comando de `psql`** que lee la tabla por
la conexión y escribe el fichero en el **cliente**, con los permisos del usuario
del sistema que ejecuta `psql`. No necesita privilegios especiales en la base de
datos:

**Comando**

```sql
\copy libros TO '/home/usuario/biblioteca_practica/csv/libros.csv' CSV HEADER
```

```bash
cat /home/usuario/biblioteca_practica/csv/libros.csv
```

**Salida**

```
-- 10.1 Exportar la tabla libros a CSV con \copy (del lado CLIENTE)
\copy libros TO '/home/usuario/biblioteca_practica/csv/libros.csv' CSV HEADER
COPY 8
--- cat csv/libros.csv ---
id_libro,titulo,año_publicacion,id_autor
1,Cien años de soledad,1967,1
2,El amor en los tiempos del cólera,1985,1
3,Ficciones,1944,2
4,El Aleph,1949,2
5,Don Quijote de la Mancha,1605,3
6,La casa de los espíritus,1982,4
7,Tokio blues,1987,5
8,Kafka en la orilla,2002,5
```

**Explicación.** `COPY 8` confirma las 8 filas exportadas (9 libros menos el que
se borró en 7.2). La opción `HEADER` añade la primera línea con los nombres de
las columnas, y se observa que `año_publicacion` y los títulos acentuados se
escriben correctamente en UTF-8.

### 10.2 Importar un CSV de autores nuevos

**Enunciado.** Crear en la VM un CSV con 3-4 autores nuevos (solo
`nombre,nacionalidad`, sin id) e importarlo con
`\copy autores(nombre, nacionalidad) FROM ... CSV HEADER`. Mostrar el CSV y un
`SELECT * FROM autores` posterior.

**Comando**

```bash
cat > /home/usuario/biblioteca_practica/csv/autores_nuevos.csv <<CSV
nombre,nacionalidad
Mario Vargas Llosa,Peruana
Clarice Lispector,Brasileña
Umberto Eco,Italiana
Svetlana Aleksiévich,Bielorrusa
CSV

cat /home/usuario/biblioteca_practica/csv/autores_nuevos.csv
file /home/usuario/biblioteca_practica/csv/autores_nuevos.csv
```

**Salida**

```
--- cat csv/autores_nuevos.csv ---
nombre,nacionalidad
Mario Vargas Llosa,Peruana
Clarice Lispector,Brasileña
Umberto Eco,Italiana
Svetlana Aleksiévich,Bielorrusa

/home/usuario/biblioteca_practica/csv/autores_nuevos.csv: CSV Unicode text, UTF-8 text
```

**Comando**

```sql
\copy autores(nombre, nacionalidad) FROM '/home/usuario/biblioteca_practica/csv/autores_nuevos.csv' CSV HEADER

SELECT * FROM autores ORDER BY id_autor;
```

**Salida**

```
-- 10.2 Importar el CSV de autores nuevos (sin la columna id, que es IDENTITY)
\copy autores(nombre, nacionalidad) FROM '/home/usuario/biblioteca_practica/csv/autores_nuevos.csv' CSV HEADER
COPY 4
SELECT * FROM autores ORDER BY id_autor;
 id_autor |         nombre         | nacionalidad 
----------+------------------------+--------------
        1 | Gabriel García Márquez | Colombiana
        2 | Jorge Luis Borges      | Argentina
        3 | Miguel de Cervantes    | Española
        4 | Isabel Allende         | Chilena
        5 | Haruki Murakami        | Japonesa
        6 | Virginia Woolf         | Británica
        7 | Mario Vargas Llosa     | Peruana
        8 | Clarice Lispector      | Brasileña
        9 | Umberto Eco            | Italiana
       10 | Svetlana Aleksiévich   | Bielorrusa
(10 rows)
```

**Explicación.** En el `\copy` hay que indicar **la lista de columnas**
`autores(nombre, nacionalidad)`. Si se omitiera, PostgreSQL esperaría que el CSV
tuviera también la columna `id_autor`, y además esa columna es
`GENERATED ALWAYS AS IDENTITY`, que no admite valores explícitos. Al dejarla
fuera de la lista, la secuencia sigue su curso y asigna los ids 7, 8, 9 y 10 a
los cuatro autores importados. `file` confirma que el CSV está en UTF-8, por lo
que «Brasileña» y «Aleksiévich» se importan sin corrupción.

Los dos ficheros se copiaron a la carpeta local `csv/` del repositorio con `scp`:

```bash
scp usuario@<IP-DE-LA-VM>:/home/usuario/biblioteca_practica/csv/libros.csv          ./csv/
scp usuario@<IP-DE-LA-VM>:/home/usuario/biblioteca_practica/csv/autores_nuevos.csv  ./csv/
```

---

## Contenido del repositorio

```
.
├── README.md                   Esta memoria: enunciado, comando y salida real de cada apartado
├── script.sql                  Todos los comandos SQL en orden, comentados por apartado
└── csv/
    ├── libros.csv              Exportado de la tabla libros en el apartado 10.1
    └── autores_nuevos.csv      Importado a la tabla autores en el apartado 10.2
```

Sobre `script.sql`: recoge todas las sentencias SQL de la práctica en orden, pero
**no está pensado para ejecutarse de una sola vez**, porque los distintos
bloques se ejecutan con usuarios diferentes (`postgres`, `admin_biblio`,
`usuario_biblio`) y porque incluye a propósito las sentencias que deben fallar
(el `COPY` de 10.1 y los `DELETE` de 2.6). Cada bloque indica en un comentario
con qué usuario hay que conectarse.

Aun así, la parte reproducible del script (apartados 3 a 10, sin los bloques de
demostración de permisos) se validó volviéndola a ejecutar sobre una base de
datos limpia con `psql -v ON_ERROR_STOP=1`, que terminó con código de salida 0 y
sin errores, y reprodujo los mismos resultados.

---

## Problemas encontrados y cómo se resolvieron

**1. `psql: error: /home/usuario/.../s1.sql: Permission denied`**

Al ejecutar los ficheros `.sql` con `sudo -u postgres psql -f`, el usuario del
sistema `postgres` no tiene permiso de lectura sobre `/home/usuario`. Se
resolvió dejando los ficheros `.sql` en un directorio accesible para todos
(`/tmp/bib`) en lugar de en el *home* del usuario.

**2. Los mensajes de `ERROR` aparecían descolocados en la salida**

Con `psql -a -f fichero.sql 2>&1`, los `ERROR` no salían debajo de su sentencia
sino agrupados al final. La causa es que `psql` escribe los resultados por
`stdout` y los errores por `stderr`, y al redirigir a un fichero (no a un
terminal) `stdout` se almacena en un búfer mientras que `stderr` sale
inmediatamente. Se probó `stdbuf -o0`, que no lo corrigió, y `ssh -tt` para
forzar un pseudo-terminal, que dejó la sesión colgada. La solución definitiva
fue ejecutar **cada sentencia en su propia invocación de `psql -c`**: así cada
proceso termina antes de que empiece el siguiente y el orden queda garantizado.
Es el método usado en los apartados 2.6, 5, 6, 7 y 10.1.

**3. `lectores` tenía acceso a la vista sin habérselo concedido**

En el apartado 8.1, `\dp vista_libros_prestados` mostraba `lectores=r` recién
creada la vista. El motivo es que `ALTER DEFAULT PRIVILEGES ... GRANT SELECT ON
TABLES` del apartado 2.3.b afecta en PostgreSQL también a las **vistas**, no
solo a las tablas. Se resolvió como pide el apartado 8.2: `REVOKE ALL` a
`lectores` y a `PUBLIC` sobre la vista, y `GRANT SELECT` directo a
`usuario_biblio`.

**4. Roles y bases de datos preexistentes en la VM**

En las salidas de `pg_roles` y `pg_database` aparecen un rol `mydb_admin` y una
base de datos `mydb` que ya estaban en la máquina. No forman parte de esta
práctica y no se han modificado.

**5. Orden del guion: permisos sobre tablas antes de crearlas**

Descrito en la [nota previa del apartado 2](#nota-previa-sobre-el-orden-de-los-permisos):
se resolvió con `ALTER DEFAULT PRIVILEGES` antes de crear las tablas y
repitiendo el `GRANT SELECT ON ALL TABLES` después.

**6. Instalación de PostgreSQL**

No fue necesaria: la VM ya tenía PostgreSQL 16.15, con el servicio activo, el
clúster en UTF8 y `pg_hba.conf` configurado con `scram-sha-256` para las
conexiones por TCP a localhost, así que tampoco hubo que tocar `pg_hba.conf`.
