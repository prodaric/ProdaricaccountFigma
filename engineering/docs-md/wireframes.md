# Wireframes

Los wireframes están en ASCII. Se asume usuario autenticado (IdP externo) y selector de tenant según design.md §2.8. La visibilidad de menú y acciones puede depender del rol (admin, accountant, auditor, viewer).

*Mapeo con el contrato API:* La pantalla "Saldos" / "Balance" (saldos por cuenta y período) consulta la vista `public.balance`. La pantalla "Balance de comprobación" / "Trial balance" consulta la vista `public.trial_balance`. Ambas son de solo lectura; el resto de vistas y funciones en plan.md §3.

*Contenido:* Layouts globales (shell, listado, formulario, reporte) → Wireframes por pantalla (Entidad y período, Plan de cuentas, Journal, Libro diario, Saldos, Reportes, Configuración) → Pantallas ampliadas (Dashboard, Detalle de asiento, Balance de comprobación, Cierre de período, Administración entidad y período, Reversión de asiento, Audit log) → Sostenibilidad (v1 opcional).

## Guía para Figma

Esta sección resume la estructura de los wireframes para que la IA de Figma o un diseñador localice cada pantalla y su tipo de layout en este documento. Las instrucciones completas para construir los prototipos están en el archivo raíz del repositorio: `figma.md`.

**Layouts globales (construir primero):**
- Layout de navegación global (shell): cabecera, menú, breadcrumb, zona de contenido, pie opcional.
- Layout de listado: filtros, tabla, acciones por fila y globales, paginación.
- Layout de formulario: campos agrupados (usar fieldsets), botones primario y secundario.
- Layout de reporte/consulta: filtros, área de datos (tabla o lectura), exportar/imprimir.

**Pantallas y tipo de layout:**

| Pantalla | Sección en este archivo | Tipo de layout |
|----------|-------------------------|----------------|
| Dashboard / Home | Pantallas ampliadas > Dashboard / Inicio | Reporte/resumen con bloques |
| Entity & Period | Wireframes por pantalla > Entidad y período | Listado + filtros |
| Chart of accounts | Wireframes por pantalla > Plan de cuentas | Listado |
| Journal (Registro de asiento) | Wireframes por pantalla > Journal / Registro de asiento | Formulario |
| Ledger (Libro diario) | Wireframes por pantalla > Libro diario | Listado/reporte |
| Detalle de asiento | Pantallas ampliadas > Detalle de asiento | Reporte/lectura |
| Reverse entry | Pantallas ampliadas > Reversión de asiento | Formulario |
| Balance (Saldos / Mayor) | Wireframes por pantalla > Saldos / Mayor | Reporte |
| Trial balance | Pantallas ampliadas > Balance de comprobación | Reporte |
| Reports | Wireframes por pantalla > Estados financieros | Reporte (usar tabs) |
| Close period | Pantallas ampliadas > Cierre de período | Formulario/confirmación |
| Administration | Pantallas ampliadas > Administración entidad y período | Listado con tabs (Entities, Periods) |
| Configuration | Wireframes por pantalla > Configuración | Formulario/listado |
| Audit log | Pantallas ampliadas > Consulta de audit log | Listado |
| Sustainability | Wireframes por pantalla > Sostenibilidad | Formulario + listado |

Cada wireframe en ASCII está en un bloque de código debajo del título de la sección correspondiente. Evitar modales; preferir tabs, fieldsets y tablas según `figma.md`.

## Layouts globales

Construidos antes que las pantallas concretas; todas las pantallas reutilizan estos layouts.

### Layout de navegación global (shell)

Cabecera: sin logo (el logo solo aparece en el splash de arranque); selector de entidad/tenant, usuario. Menú principal: Inicio (dashboard), Entity/Period, plan de cuentas, journal, diario, detalle de asiento (desde diario), Trial balance, Balance (saldos/mayor), reportes, cierre de período, configuración, Administración (Entity & Period), opcional usuarios, audit log, opcional sostenibilidad. Zona de contenido central. En breadcrumbs se usa "Entity & Period" para la sección entidad/período. Pie opcional. Para la pantalla de splash de Prodaric Accounting usar placeholder (relleno) para el logo hasta tener el diseño definitivo.

```
+------------------------------------------------------------------+
| [ Entity/Tenant ▼ ]                              [ User ▼ ]      |
+------------------------------------------------------------------+
| Home | Entity/Period | Chart of accounts | Journal | Ledger | Trial balance |
| Reports | Close period | Configuration | Administration | Audit log | Sustainability |
+------------------------------------------------------------------+
| Breadcrumb: Home > Section                                        |
+------------------------------------------------------------------+
|                                                                  |
|                    ZONA DE CONTENIDO                             |
|                                                                  |
+------------------------------------------------------------------+
| Footer (optional)                                                 |
+------------------------------------------------------------------+
```

### Layout de listado

Filtros en la parte superior; tabla o lista; acciones por fila y globales.

```
+------------------------------------------------------------------+
| [ Filter 1 ] [ Filter 2 ] [ Filter 3 ]     [ Search ] [ Apply ]  |
+------------------------------------------------------------------+
| [ Add ] [ Export ]                                               |
+------------------------------------------------------------------+
| Col A    | Col B    | Col C    | Actions                          |
|----------|----------|----------|----------------------------------|
| ...      | ...      | ...      | [ View ] [ Edit ]                |
| ...      | ...      | ...      | [ View ] [ Edit ]                |
+------------------------------------------------------------------+
| Pagination                                                        |
+------------------------------------------------------------------+
```

### Layout de formulario

Campos agrupados; botones de acción primaria y secundaria.

```
+------------------------------------------------------------------+
| [ Field label 1 ]                                                |
| [ ___________________________ ]                                  |
| [ Field label 2 ]                                                |
| [ ___________________________ ]                                  |
| [ Group ]                                                        |
|   [ Subfield 1 ] [ __________ ]  [ Subfield 2 ] [ __________ ]   |
+------------------------------------------------------------------+
| [ Save ]  [ Cancel ]  [ Delete ]                                 |
+------------------------------------------------------------------+
```

### Layout de reporte / consulta

Filtros; área de datos (tabla o lectura); exportar/imprimir.

```
+------------------------------------------------------------------+
| [ Period ▼ ] [ Entity ▼ ] [ Account ▼ ]    [ Apply ] [ Export ]  |
+------------------------------------------------------------------+
|                                                                  |
| Report / data area (table or read-only content)                  |
|                                                                  |
+------------------------------------------------------------------+
| [ Print ] [ Export ]                                             |
+------------------------------------------------------------------+
```

## Wireframes por pantalla

Cada pantalla usa el shell anterior y el tipo de layout que corresponda (listado, formulario o reporte).

### Entidad y período (multi-tenant)

Selector de tenant/entidad de reporte (Coderic SAS, Coderic SA, Coderic Corporation); selección de período (abierto/cerrado); alta de entidad/periodo si aplica. Layout: listado o formulario según vista.

```
+------------------------------------------------------------------+
| [ Coderic SAS ▼ ]                                [ User ▼ ]      |
+------------------------------------------------------------------+
| Entity/Period | Chart of accounts | Journal | Ledger | ...        |
+------------------------------------------------------------------+
| Home > Entity & Period                                            |
+------------------------------------------------------------------+
| Entity: [ Coderic SAS ▼ ]   Period: [ 2024-01 ▼ ] (open)         |
| [ New entity ] [ New period ]                                    |
|------------------------------------------------------------------|
| List of periods for entity:                                      |
| From       | To         | Status  | Actions                       |
| 2024-01-01 | 2024-01-31 | Open    | [ Close ] [ View ]            |
+------------------------------------------------------------------+
```

### Plan de cuentas

Listado de cuentas por elemento (activo, pasivo, patrimonio, ingreso, gasto); detalle de cuenta; alta/extensión de cuentas. Layout: listado con filtro por elemento.

```
+------------------------------------------------------------------+
| Breadcrumb: Home > Chart of accounts                             |
+------------------------------------------------------------------+
| Element: [ Asset ▼ ] [ Liability ] [ Equity ] [ Income ] [ Expense]
+------------------------------------------------------------------+
| Code   | Name              | Element  | Type   | Actions           |
|--------|-------------------|----------|--------|-------------------|
| 1000   | Cash              | Asset    | Debit  | [ View ] [ Edit ]|
| 1100   | Receivables       | Asset    | Debit  | [ View ] [ Edit ]|
+------------------------------------------------------------------+
| [ Add account ]                                                  |
+------------------------------------------------------------------+
```

### Journal / Registro de asiento

Formulario: fecha, descripción, referencia; líneas con cuenta, débito/crédito, monto; validación partida doble; envío vía `register_entry`. Layout: formulario.

```
+------------------------------------------------------------------+
| Breadcrumb: Home > Journal > New entry                           |
+------------------------------------------------------------------+
| [ Date ] [ ___________ ]  [ Reference ] [ _________________ ]   |
| [ Description ] [ _________________________________________ ]   |
+------------------------------------------------------------------+
| Account      | Debit     | Credit    |                            |
|--------------|-----------|-----------|----------------------------|
| [ 1000 ▼ ]   | [ _____ ] | [ _____ ] |                            |
| [ 4100 ▼ ]   | [ _____ ] | [ _____ ] |                            |
|              | Total: X  | Total: X  | (must match)               |
+------------------------------------------------------------------+
| [ Register entry ]  [ Cancel ]                                    |
+------------------------------------------------------------------+
```

### Libro diario (consulta)

Listado de asientos por período/entidad; solo lectura; datos desde ledger vía vistas. Layout: listado/reporte.

```
+------------------------------------------------------------------+
| Breadcrumb: Home > Ledger                                         |
+------------------------------------------------------------------+
| [ Entity ▼ ] [ Period ▼ ] [ From date ] [ To date ] [ Apply ]    |
+------------------------------------------------------------------+
| Entry ID | Date       | Description  | Ref    | Debit  | Credit  |
|----------|------------|--------------|--------|--------|--------|
| 1        | 2024-01-15 | Sale invoice | INV-01 | 100.00 | 100.00 |
+------------------------------------------------------------------+
| (Read-only; data from ledger views)                               |
+------------------------------------------------------------------+
```

### Saldos / Mayor

Saldos por cuenta y período; filtros por entidad, período, cuenta. Layout: reporte.

```
+------------------------------------------------------------------+
| Breadcrumb: Home > Balance                                        |
+------------------------------------------------------------------+
| [ Entity ▼ ] [ Period ▼ ] [ Account ▼ ] [ As of date ] [ Apply ] |
+------------------------------------------------------------------+
| Account | Name       | Debit     | Credit    | Balance             |
|---------|------------|-----------|-----------|---------------------|
| 1000    | Cash       | 1,000.00  | 200.00    | 800.00 Dr           |
+------------------------------------------------------------------+
| [ Export ]                                                        |
+------------------------------------------------------------------+
```

### Estados financieros (reportes)

Estado de situación financiera; Estado de resultado; sin compensación IAS 1.32; opcional flujo de efectivo. Layout: reporte.

```
+------------------------------------------------------------------+
| Breadcrumb: Home > Reports                                        |
+------------------------------------------------------------------+
| [ Statement of financial position ] [ Statement of profit or loss]
| [ Cash flow ] (optional)                                          |
| [ Entity ▼ ] [ Period ▼ ] [ Apply ] [ Export ]                    |
+------------------------------------------------------------------+
| Statement of Financial Position as at 2024-01-31                |
| ASSETS                    |   EQUITY AND LIABILITIES            |
| Cash           800.00     |   Equity              1,000.00     |
| (no offsetting per IAS 1.32)                                      |
+------------------------------------------------------------------+
```

### Configuración

Moneda funcional y de presentación; tipos de documento; parámetros configurables (todo en public). Layout: formulario/listado según parámetro.

```
+------------------------------------------------------------------+
| Breadcrumb: Home > Configuration                                  |
+------------------------------------------------------------------+
| Functional currency:  [ USD ▼ ]   Presentation: [ USD ▼ ]        |
| Document types: [ List ] [ Add ]                                  |
| Other parameters: ...                                             |
+------------------------------------------------------------------+
| [ Save ]  [ Cancel ]                                              |
+------------------------------------------------------------------+
```

### Sostenibilidad (v1 opcional)

Entrada de métricas S1/S2 (p. ej. climáticas); consulta por entidad/periodo. Layout: formulario y listado/reporte.

```
+------------------------------------------------------------------+
| Breadcrumb: Home > Sustainability                                 |
+------------------------------------------------------------------+
| [ Entity ▼ ] [ Period ▼ ]                                         |
| Metric (S1/S2): [ ________ ]  Value: [ ______ ]  [ Add ]          |
|------------------------------------------------------------------|
| List of metrics (Scope 1, 2, 3; etc.)                            |
+------------------------------------------------------------------+
```

## Pantallas ampliadas

Pantallas que completan el sistema contable: dashboard, detalle de asiento, balance de comprobación, cierre de período, administración entidad/período, reversión de asiento y consulta de audit log.

### Dashboard / Inicio

Resumen tras login: entidad/período actual, últimos asientos, avisos (p. ej. período por cerrar). Layout: reporte/resumen con bloques.

```
+------------------------------------------------------------------+
| [ Coderic SAS ▼ ]                                [ User ▼ ]      |
+------------------------------------------------------------------+
| Home | Entity/Period | Chart of accounts | Journal | Ledger | ...  |
+------------------------------------------------------------------+
| Breadcrumb: Home                                                  |
+------------------------------------------------------------------+
| Current: Coderic SAS  |  Period: 2024-01 (Open)                  |
+------------------------------------------------------------------+
| Recent entries                                                    |
| Date       | Ref    | Description        | Total                  |
| 2024-01-15 | INV-01| Sale invoice       | 100.00                 |
+------------------------------------------------------------------+
| Alerts: Period 2023-12 is open and can be closed.                 |
+------------------------------------------------------------------+
```

### Detalle de asiento

Vista read-only de un asiento y sus líneas (acceso desde libro diario). Cabecera: fecha, descripción, referencia. Tabla de líneas. Opcional: [ Reverse ] si el usuario tiene permiso.

```
+------------------------------------------------------------------+
| Breadcrumb: Home > Ledger > Entry #42                             |
+------------------------------------------------------------------+
| Date: 2024-01-15   Ref: INV-01   Description: Sale invoice       |
+------------------------------------------------------------------+
| Account | Name       | Debit    | Credit                            |
|---------|------------|----------|--------                           |
| 1100    | Receivables| 100.00   |                                   |
| 4100    | Revenue    |          | 100.00                             |
+------------------------------------------------------------------+
| (Read-only)                                    [ Reverse ]        |
+------------------------------------------------------------------+
```

### Balance de comprobación (trial balance)

Listado de todas las cuentas con totales débito y crédito por período. Filtros entidad/período; exportar.

```
+------------------------------------------------------------------+
| Breadcrumb: Home > Trial balance                                  |
+------------------------------------------------------------------+
| [ Entity ▼ ] [ Period ▼ ] [ As of date ] [ Apply ] [ Export ]     |
+------------------------------------------------------------------+
| Account | Name       | Debit total | Credit total                    |
|---------|------------|-------------|-------------                    |
| 1000    | Cash       | 1,000.00    | 200.00                          |
| 1100    | Receivables | 500.00     | 0.00                             |
+------------------------------------------------------------------+
| Totals must match (double-entry)                                  |
+------------------------------------------------------------------+
```

### Cierre de período

Flujo para cerrar un período: validaciones (ecuación contable, partida doble); bloqueo. Solo admin/accountant. Layout: formulario/confirmación.

```
+------------------------------------------------------------------+
| Breadcrumb: Home > Entity & Period > Close period                 |
+------------------------------------------------------------------+
| Period: [ 2023-12 ▼ ] (Open)                                     |
| Validations: Equation OK. No open lines.                         |
+------------------------------------------------------------------+
| Closing this period will prevent new entries. Confirm?            |
| [ Close period ]  [ Cancel ]                                      |
+------------------------------------------------------------------+
```

### Administración entidad y período

Alta/edición de entidades y de períodos (rol admin). Listado de entidades con [ Add ] [ Edit ]; listado de períodos por entidad con [ Add ] [ Close ].

```
+------------------------------------------------------------------+
| Breadcrumb: Home > Administration                                 |
+------------------------------------------------------------------+
| [ Entities ] [ Periods ]                                          |
|------------------------------------------------------------------|
| Entities:                                                        |
| Name          | Jurisdiction | Currency | Actions                 |
| Coderic SAS   | Colombia     | COP      | [ Edit ]                |
| Coderic SA    | Venezuela    | ...      | [ Edit ]                |
| [ Add entity ]                                                    |
|------------------------------------------------------------------|
| Periods for selected entity:                                      |
| From       | To         | Status  | [ Add ] [ Close ]        |
+------------------------------------------------------------------+
```

### Reversión de asiento

Crea un asiento de reversa sin borrar el original (ledger inmutable). Origen: asiento a revertir (read-only); fecha de reversa; confirmación.

```
+------------------------------------------------------------------+
| Breadcrumb: Home > Ledger > Reverse entry                         |
+------------------------------------------------------------------+
| Source entry: #42 (2024-01-15, INV-01, Sale invoice)              |
| Lines: 1100 +100.00 / 4100 -100.00                               |
+------------------------------------------------------------------+
| Reversal date: [ 2024-01-20 ]                                     |
| Description:   [ Reversal of INV-01 ]                             |
+------------------------------------------------------------------+
| Reversal will create a new entry with opposite debits/credits.    |
| [ Create reversal entry ]  [ Cancel ]                              |
+------------------------------------------------------------------+
```

### Consulta de audit log

Lectura del registro de auditoría (quién, qué, cuándo); roles auditor/admin. Filtros por usuario, tenant, fecha, recurso; exportar.

```
+------------------------------------------------------------------+
| Breadcrumb: Home > Audit log                                      |
+------------------------------------------------------------------+
| [ User ▼ ] [ Tenant ▼ ] [ From ] [ To ] [ Resource ▼ ] [ Apply ] |
| [ Export ]                                                       |
+------------------------------------------------------------------+
| User   | Tenant      | Action        | Resource  | At        | OK   |
|--------|-------------|---------------|-----------|-----------|------|
| jane   | Coderic SAS | journal:write | entry     | 2024-01-15| yes  |
+------------------------------------------------------------------+
```
