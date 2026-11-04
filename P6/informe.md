---
title: "Copias de seguridad en PostgreSQL: realización y restauración"
subtitle: "Administración y diseño de bases de datos · Grado en Ingeniería Informática · ULL"
author: "Francisco Javier Cañas González y [NOMBRE DE LA PAREJA, si aplica]"
---

## 1. Objetivo y entorno

Se realiza la **actividad práctica 2**: hacer una copia de seguridad de una base de datos y restaurarla, tanto en una base de datos nueva como sobrescribiendo la original. Se ha trabajado por consola (alternativa permitida en el enunciado), con las mismas herramientas que utiliza pgAdmin por debajo: `pg_dump` y `pg_restore`.

La base de datos es `clientesdb` (tablas `clientes` y `pedidos`), desplegada con Docker Compose a partir del repositorio de la asignatura (`postgresql-backups/src`, imagen `postgres:16.3`). Solo se levanta el servicio `pgdb`, ya que el servicio `pgbackup` pertenece a la actividad 1. Los comandos se ejecutan **dentro del contenedor** con `docker compose exec`, lo que garantiza que las versiones de `pg_dump`, `pg_restore` y del servidor coinciden.

## 2. Pasos realizados

### Paso 1. Despliegue y estado inicial

Se levanta el servicio y se comprueba que está en ejecución. A continuación se consulta el número de filas de cada tabla y un **resumen MD5** del contenido. Este resumen es la clave de la verificación: si tras restaurar el MD5 coincide, los datos son idénticos fila a fila, no solo "parecidos".

```bash
docker compose up -d pgdb
docker compose ps
docker compose exec pgdb psql -U admin -d clientesdb -c "\dt"
docker compose exec pgdb psql -U admin -d clientesdb -c "SELECT 'clientes' AS tabla, count(*), md5(string_agg(c::text, ',' ORDER BY id)) FROM clientes c UNION ALL SELECT 'pedidos', count(*), md5(string_agg(p::text, ',' ORDER BY id)) FROM pedidos p;"
```

![Despliegue del servicio y estado inicial de clientesdb](capturas/01_estado_inicial.png)

### Paso 2. Realización de la copia de seguridad

Se generan dos copias con `pg_dump` para poder compararlas:

- **Formato personalizado (`-Fc`)**: binario, comprimido, y el único que permite una restauración selectiva con `pg_restore`.
- **Formato SQL plano (por defecto)**: texto legible con las sentencias `CREATE TABLE` y `COPY`, que se restaura con `psql`.

```bash
docker compose exec pgdb pg_dump -U admin -d clientesdb -Fc -f /tmp/clientesdb.dump
docker compose exec pgdb pg_dump -U admin -d clientesdb -f /tmp/clientesdb.sql
docker compose exec pgdb ls -lh /tmp/clientesdb.dump /tmp/clientesdb.sql
docker compose exec pgdb pg_restore -l /tmp/clientesdb.dump
```

El último comando lista el **índice (TOC)** de la copia personalizada: tablas, secuencias, datos y restricciones que contiene. Es la prueba de que la copia es válida antes de necesitarla. `pg_dump` obtiene una instantánea consistente gracias a MVCC, sin bloquear a los usuarios que estén leyendo o escribiendo durante la copia.

Además, se copia el fichero al equipo anfitrión, porque una copia que solo vive dentro del mismo contenedor que la base de datos no protege frente a un fallo de ese contenedor:

```bash
docker compose cp pgdb:/tmp/clientesdb.dump ./clientesdb.dump
```

![Copia de seguridad en los dos formatos, tamaños y contenido del índice](capturas/02_backup.png)

### Paso 3. Restauración en una base de datos nueva

Es la forma más segura de comprobar una copia, porque no toca los datos originales. Se crea una base de datos vacía y se restaura en ella:

```bash
docker compose exec pgdb createdb -U admin clientesdb_restaurada
docker compose exec pgdb pg_restore -U admin -d clientesdb_restaurada /tmp/clientesdb.dump
docker compose exec pgdb psql -U admin -d clientesdb_restaurada -c "SELECT 'clientes' AS tabla, count(*), md5(string_agg(c::text, ',' ORDER BY id)) FROM clientes c UNION ALL SELECT 'pedidos', count(*), md5(string_agg(p::text, ',' ORDER BY id)) FROM pedidos p;"
```

El recuento y los MD5 coinciden con los del paso 1.

![Restauración en clientesdb_restaurada y verificación](capturas/03_restore_nueva_bd.png)

### Paso 4. Desastre simulado y restauración sobrescribiendo

Se simula un error humano grave: el borrado accidental de las tablas. Se comprueba que los datos han desaparecido y se recuperan desde la copia con `--clean --if-exists`, que elimina los objetos existentes antes de recrearlos (y no falla si ya no existen):

```bash
docker compose exec pgdb psql -U admin -d clientesdb -c "DROP TABLE pedidos; DROP TABLE clientes;"
docker compose exec pgdb psql -U admin -d clientesdb -c "\dt"
docker compose exec pgdb pg_restore -U admin -d clientesdb --clean --if-exists /tmp/clientesdb.dump
docker compose exec pgdb psql -U admin -d clientesdb -c "SELECT 'clientes' AS tabla, count(*), md5(string_agg(c::text, ',' ORDER BY id)) FROM clientes c UNION ALL SELECT 'pedidos', count(*), md5(string_agg(p::text, ',' ORDER BY id)) FROM pedidos p;"
```

Los MD5 vuelven a coincidir con los del paso 1: la recuperación ha sido completa, incluyendo la clave foránea de `pedidos` hacia `clientes`.

![Borrado accidental y recuperación con pg_restore --clean](capturas/04_desastre_restore.png)

### Paso 5. Restauración de la copia SQL plana

La copia en texto no se puede cargar con `pg_restore`, sino con `psql`. Se restaura en otra base de datos nueva:

```bash
docker compose exec pgdb createdb -U admin clientesdb_sql
docker compose exec pgdb psql -U admin -d clientesdb_sql -f /tmp/clientesdb.sql
docker compose exec pgdb psql -U admin -d clientesdb_sql -c "SELECT 'clientes' AS tabla, count(*), md5(string_agg(c::text, ',' ORDER BY id)) FROM clientes c UNION ALL SELECT 'pedidos', count(*), md5(string_agg(p::text, ',' ORDER BY id)) FROM pedidos p;"
```

![Restauración de la copia SQL con psql](capturas/05_restore_sql.png)

## 3. Equivalencia con pgAdmin y conclusiones

| Acción en pgAdmin | Herramienta equivalente | Uso |
|---|---|---|
| *Backup…* (formato Custom) | `pg_dump -Fc` | Copia comprimida y restaurable de forma selectiva |
| *Backup…* (formato Plain) | `pg_dump` | Copia en texto SQL, cargable con `psql` |
| *Restore…* | `pg_restore` | Restaura una copia Custom/Tar en una BD existente |

| | Formato personalizado (`-Fc`) | SQL plano |
|---|---|---|
| Se restaura con | `pg_restore` | `psql` |
| Tamaño | Comprimido | Mayor |
| Restauración selectiva y paralela | Sí | No |
| Legible y editable a mano | No | Sí |

**Conclusiones.** (1) Una copia solo sirve si se ha probado a restaurarla: por eso se verifica con MD5 en cada restauración y se ha comprobado el índice con `pg_restore -l`. (2) Restaurar primero en una base de datos nueva evita riesgos; `--clean --if-exists` es la opción cuando se quiere sobrescribir. (3) Estas son copias *lógicas*: recuperan el estado en el momento de la copia, pero no permiten volver a un instante intermedio. Para eso existen la copia física (`pg_basebackup`) y el archivado de WAL, que permiten la recuperación en un punto en el tiempo (PITR) y no se han utilizado en esta práctica. (4) Una copia almacenada en el mismo equipo que la base de datos no protege frente a la pérdida de ese equipo, por lo que se copió al anfitrión.
