# Modelo Entidad/Relación – Tajinaste S.A.

## 1. Planteamiento general

A partir del enunciado se identifican cuatro bloques:

1. **Viveros, zonas y stock** de productos.
2. **Empleados**: destinos por temporada y tareas en zonas, con su histórico.
3. **Clientes Tajinaste Plus**, con sus pedidos y bonificaciones mensuales.
4. **Empleados que gestionan pedidos**, para medir los objetivos de venta.

La cardinalidad se expresa como (mín,máx) junto a la entidad a la que se refiere.

---

## 2. Entidades

### Vivero
| Atributo | Tipo | Motivo |
|---|---|---|
| ID_Vivero | Clave | Identifica cada vivero |
| Nombre | Simple | Dato descriptivo |
| Latitud, Longitud | Simple | *"De cada vivero (...) se conoce su georreferenciación"* |

### Zona (entidad débil de Vivero)
| Atributo | Tipo | Motivo |
|---|---|---|
| ID_Zona | Clave parcial | Una zona ("almacén", "exterior") solo tiene sentido dentro de su vivero |
| Nombre | Simple | Ej. zona exterior, almacén |
| Latitud, Longitud | Simple | El enunciado pide la georreferenciación también de cada zona |

Es débil porque no existe sin el vivero al que pertenece.

### Producto
| Atributo | Tipo | Motivo |
|---|---|---|
| ID_Producto | Clave | Identifica el producto |
| Nombre | Simple | Dato descriptivo |
| Tipo | Simple | Planta, jardinería o decoración |
| Precio | Simple | Necesario para la venta |

### Empleado
| Atributo | Tipo | Motivo |
|---|---|---|
| ID_Empleado | Clave | Identifica al empleado |
| DNI, Nombre | Simple | Datos personales básicos |

### Tarea / Puesto
| Atributo | Tipo | Motivo |
|---|---|---|
| ID_Tarea | Clave | Identifica la tarea |
| Descripción | Simple | Qué hace el empleado |

Se crea como entidad porque el enunciado habla de la **tarea** que se desempeña y del **histórico del puesto**.

### Cliente (Tajinaste Plus)
| Atributo | Tipo | Motivo |
|---|---|---|
| ID_Cliente | Clave | Identifica al cliente |
| Nombre | Simple | Dato descriptivo |
| Fecha Ingreso | Simple | *"pedidos (...) desde su ingreso en el programa"* |

### Pedido
| Atributo | Tipo | Motivo |
|---|---|---|
| ID_Pedido | Clave | Identifica el pedido |
| Fecha | Simple | Saber a qué mes pertenece y si es posterior al ingreso |
| Importe | Simple | Base para calcular el volumen de compras |

### Bonificación (entidad débil de Cliente)
| Atributo | Tipo | Motivo |
|---|---|---|
| Mes, Año | Clave parcial | Hay una bonificación por cliente y mes |
| Volumen compras | Derivado | Se calcula sumando el importe de los pedidos de ese mes |
| Importe | Simple | Bonificación concedida |

---

## 3. Relaciones

| Relación | Entidades | Cardinalidad | Atributos | Motivo |
|---|---|---|---|---|
| **Tiene** (identificadora) | Vivero – Zona | Vivero (1,N) – Zona (1,1) | — | Cada vivero tiene varias zonas y cada zona pertenece a un solo vivero |
| **Stock** | Zona – Producto | Zona (0,N) – Producto (0,N) | Cantidad | *"Cuánto hay disponible en cada zona"* |
| **Destinado** | Empleado – Vivero | Empleado (1,N) – Vivero (0,N) | Fecha Inicio, Fecha Fin | Los empleados cambian de vivero según la época del año, así que hay que guardar el histórico |
| **Desempeña** (ternaria) | Empleado – Zona – Tarea | (0,N) en las tres | Fecha Inicio, Fecha Fin, Productividad | Tarea en una zona, histórico del puesto y productividad por zona y empleado |
| **Contiene** | Pedido – Producto | Pedido (1,N) – Producto (0,N) | Cantidad | Qué productos lleva cada pedido |
| **Realiza** | Cliente – Pedido | Cliente (0,N) – Pedido (1,1) | — | Cada pedido lo hace un único cliente |
| **Gestiona** | Empleado – Pedido | Empleado (0,N) – Pedido (1,1) | — | *"Cada pedido sólo tiene un responsable"* |
| **Recibe** (identificadora) | Cliente – Bonificación | Cliente (0,N) – Bonificación (1,1) | — | Bonificaciones mensuales según el volumen de compras |

---

## 4. Restricciones semánticas

Hay condiciones que no se pueden expresar con cardinalidades y se indican aparte:

1. Un empleado **no puede tener dos destinos a la vez**: los periodos de Destinado no pueden solaparse.
2. La zona donde un empleado desempeña una tarea debe pertenecer al **vivero al que está destinado** en ese periodo.
3. **Fecha Inicio** forma parte de la clave de Destinado y Desempeña, para poder guardar el histórico.
4. **Volumen compras** se deriva de los importes de los pedidos del mes.
5. Para el programa solo cuentan los pedidos con fecha **posterior al ingreso** del cliente.

---

## 5. Notación usada

| Símbolo | Significado |
|---|---|
| Rectángulo | Entidad |
| Rectángulo doble | Entidad débil |
| Rombo | Relación |
| Rombo doble | Relación identificadora |
| Atributo subrayado | Clave |
| Subrayado discontinuo | Clave parcial |
| Elipse discontinua | Atributo derivado |
