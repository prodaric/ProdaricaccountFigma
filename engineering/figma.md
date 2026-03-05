# Instrucciones para Figma: Prodaric Accounting

Este documento es la **fuente de instrucciones** para que la IA de Figma (o un diseñador) construya los prototipos de la interfaz gráfica del sistema de administración contable **Prodaric Accounting**. La aplicación se integrará en **Prodaric Framework** (basado en **Eclipse Theia**), por tanto la UI debe ser coherente con un IDE tipo VS Code: barras de herramientas, paneles, pestañas y tablas, sin depender de modales cuando sea posible.

---

## 1. Contexto técnico (stack)

- **Framework de host:** [Prodaric Framework](https://github.com/prodaric/prodaric-framework) — fork de Coderic IDE, construido sobre **Eclipse Theia**.
- **Shell:** Eclipse Theia (layout tipo VS Code: barra superior, barra lateral, área de contenido, paneles).
- **UI:** Web Components nativos; layout con **Lumino** (paneles, tabs, docking).
- **Implicación para Figma:** Los prototipos deben representar **vistas que se abren dentro del área de contenido del IDE**: cada “pantalla” del sistema contable es un panel o conjunto de pestañas dentro de esa área, no una SPA a pantalla completa separada. La barra superior del IDE incluye menú (p. ej. “Prodaric” o “Accounting”), selector de entidad/tenant y usuario; la barra lateral puede tener navegación por secciones (Home, Entity & Period, Chart of accounts, Journal, Ledger, etc.).

**Logo y splash:**
- **Dentro del sistema (IDE):** No hay logo en la interfaz. La barra superior del shell **no** incluye logo; solo selector de entidad/tenant y usuario (y menú del IDE). El logo no aparece en cabecera ni en la barra lateral.
- **Splash (pantalla de arranque):** El único lugar donde aparece el logo es en la **pantalla de splash** al iniciar la aplicación. Prodaric Framework tiene su propio splash (logo "PRODARIC" con subtítulo "THE PRODUCTIVITY FRAMEWORK" y icono de engranaje metálico sobre fondo en gradiente gris). Para **Prodaric Accounting**, el splash tendrá un logo propio (aún por diseñar). En Figma, usar un **placeholder (relleno)** para el logo de Prodaric Accounting en el splash: por ejemplo un rectángulo o área con color de relleno neutro (gris) y la etiqueta "Prodaric Accounting" como texto, hasta que se defina el logo final.

---

## 2. Diseño visual

- **Estética:** Tonos **grises tradicionales al estilo GTK y Qt** (claros y oscuros). Evitar paletas muy saturadas; priorizar grises neutros, bordes discretos y contraste suficiente para accesibilidad.
- **Sugerencia de paleta (referencia):**
  - Fondo principal: gris muy claro (p. ej. #f5f5f5) o blanco; modo oscuro: gris oscuro (#2d2d2d).
  - Bordes y divisores: gris medio (#c0c0c0 / #808080).
  - Texto: negro / gris muy oscuro (#1a1a1a); texto secundario: gris (#555).
  - Botones primarios: gris medio-oscuro; hover un poco más claro.
  - Campos de formulario: fondo blanco o gris muy claro, borde gris.
- **Tipografía:** Sans-serif legible (ej. Inter, Roboto, system-ui). Tamaños claros para jerarquía (títulos, cuerpo, etiquetas).
- **Espaciado:** Consistente; uso de fieldsets y agrupación visual en formularios en lugar de modales para bloques de datos.

---

## 3. Principios de UI

- **Evitar modales** siempre que sea posible: preferir paneles laterales, pestañas (tabs) o secciones expandibles en la misma vista. Reservar modales solo para confirmaciones destructivas o avisos críticos.
- **Tablas:** Usar tablas para listados (asientos, cuentas, períodos, audit log). Incluir cabeceras fijas, filas alternadas si ayuda a la lectura, y acciones por fila (View, Edit, etc.) como enlaces o botones discretos.
- **Tabs:** Agrupar contenido relacionado en pestañas (p. ej. “Entities” y “Periods” en Administración; “Statement of financial position” y “Statement of profit or loss” en Reportes).
- **Fieldsets:** En formularios, agrupar campos con etiquetas de grupo (fieldset/legend) en lugar de muchos campos sueltos: p. ej. “Datos del asiento”, “Líneas del asiento”, “Filtros”.
- **Barras de herramientas:** Cada vista principal debe tener una barra de herramientas (o barra de filtros) en la parte superior con: filtros (Entity, Period, etc.), botones de acción (Add, Export, Apply) y, si aplica, búsqueda. No ocultar acciones críticas en menús desplegables si pueden ir en la barra.
- **Roles de usuario:** La visibilidad de menús y botones depende del rol (admin, accountant, auditor, viewer). No diseñar pantallas distintas por rol; diseñar **una** pantalla por funcionalidad y documentar qué elementos se ocultan o deshabilitan por rol (ver sección 5).

---

## 4. Dónde están los wireframes

**Para Figma (y herramientas que no lean .adoc):** Los wireframes y el resto de la documentación de pantallas están replicados en **Markdown** en la carpeta `docs-md/`:

- **Wireframes:** `docs-md/wireframes.md` — Guía para Figma, layouts globales, wireframes por pantalla, pantallas ampliadas. Los ASCII en bloques de código (triple backtick).
- **Índice y navegación:** `docs-md/README.md`, `docs-md/index.md`, `docs-md/nav.md`.
- **Modelo de negocio y arquitectura:** `docs-md/example-business-model.md`, `docs-md/architecture.md` (diagramas en ```mermaid).

**Versión original (AsciiDoc/Antora):** `docs/modules/ROOT/pages/wireframes.adoc` — contenido equivalente a `docs-md/wireframes.md`.

**Contenido de wireframes:**
- Layouts globales, wireframes por pantalla, pantallas ampliadas (resumen en Guía para Figma dentro de wireframes.md).  
  - **Layouts globales** (sección “Layouts globales”): shell de navegación, layout de listado, layout de formulario, layout de reporte/consulta. Son la base de todas las pantallas.  
  - **Wireframes por pantalla** (sección “Wireframes por pantalla”): Entity & Period, Plan de cuentas (Chart of accounts), Journal, Libro diario (Ledger), Saldos (Balance), Reportes, Configuración, Sostenibilidad (opcional).  
  - **Pantallas ampliadas** (sección “Pantallas ampliadas”): Dashboard, Detalle de asiento, Balance de comprobación (Trial balance), Cierre de período, Administración entidad y período, Reversión de asiento, Consulta de audit log.

Al inicio de `docs-md/wireframes.md` hay una **Guía para Figma** (tabla pantalla → sección → tipo de layout). Usar esa guía como índice para ubicar cada wireframe en el archivo.

**Mapeo vista de datos ↔ pantalla:**  
- “Balance” (saldos por cuenta/período) = datos de la vista `balance`.  
- “Trial balance” (balance de comprobación) = datos de la vista `trial_balance`.  
El resto de vistas y funciones del backend se describen en `plan.md` §3.

---

## 5. Roles y permisos (qué mostrar u ocultar)

Los roles son por **tenant** (entidad). Definición completa en `design.md` §2.8; resumen para UI:

| Rol         | Permisos relevantes para UI |
|------------|-----------------------------|
| **admin**  | Todo: administración entidad/período, configuración, usuarios, audit log, journal, cierre, etc. |
| **accountant** | Ver entidad/período, plan de cuentas (lectura y escritura), registrar asientos (journal), libro diario, saldos, reportes, configuración (lectura), sostenibilidad (lectura y escritura). Sin gestionar entidades ni usuarios. |
| **auditor** | Solo lectura: entidad, período, plan de cuentas, libro diario, saldos, reportes, configuración, sostenibilidad, audit log. Sin botones de edición ni registro. |
| **viewer** | Lectura limitada: entidad, período, plan de cuentas, saldos, reportes. Opcionalmente sin acceso al libro diario (ledger). |

Al diseñar en Figma, considerar **variantes por rol** (o anotaciones) para: menú (ocultar “Administration”, “Audit log” para viewer), botones “Add” / “Edit” / “Register entry” / “Close period” / “Reverse”, y pestaña “Users” en administración. No se requieren prototipos separados por rol si se anota claramente la visibilidad.

---

## 6. Lista de pantallas (checklist para Figma)

Construir prototipos para todas las siguientes pantallas, aplicando los layouts indicados y el shell común (cabecera + menú + breadcrumb + contenido).

1. **Dashboard / Home** — Resumen: entidad/período actual, últimos asientos (tabla), avisos (p. ej. período por cerrar). Layout: reporte/resumen con bloques.
2. **Entity & Period** — Selector de entidad y período; listado de períodos de la entidad; botones New entity, New period. Layout: listado + filtros.
3. **Chart of accounts (Plan de cuentas)** — Filtro por elemento (Asset, Liability, Equity, Income, Expense); tabla Code, Name, Element, Type, Actions; Add account. Layout: listado.
4. **Journal (Registro de asiento)** — Formulario: fecha, referencia, descripción; tabla de líneas (Account, Debit, Credit); totales que coincidan; Register entry, Cancel. Layout: formulario con fieldset para líneas (evitar modal para añadir línea; usar filas en tabla editable o panel inferior).
5. **Ledger (Libro diario)** — Filtros Entity, Period, From date, To date; tabla Entry ID, Date, Description, Ref, Debit, Credit; solo lectura; abrir detalle al hacer clic. Layout: listado/reporte.
6. **Detalle de asiento** — Breadcrumb Home > Ledger > Entry #id; cabecera fecha, ref, description; tabla de líneas (Account, Name, Debit, Credit); botón Reverse si permiso. Layout: reporte/lectura.
7. **Reverse entry (Reversión)** — Origen del asiento (read-only); campo Reversal date, Description; Create reversal entry, Cancel. Preferir panel o página, no modal.
8. **Balance (Saldos / Mayor)** — Filtros Entity, Period, Account, As of date; tabla Account, Name, Debit, Credit, Balance; Export. Layout: reporte.
9. **Trial balance (Balance de comprobación)** — Filtros Entity, Period, As of date; tabla Account, Name, Debit total, Credit total; Export. Layout: reporte.
10. **Reports (Estados financieros)** — Tabs: Statement of financial position, Statement of profit or loss, (opcional) Cash flow; filtros Entity, Period; área de reporte; Export. Layout: reporte con tabs.
11. **Close period (Cierre de período)** — Selector de período; resumen de validaciones; Close period, Cancel. Layout: formulario/confirmación (panel o página, no modal crítico si se puede).
12. **Administration (Entidad y período)** — Tabs: Entities, Periods. Entities: tabla Name, Jurisdiction, Currency, Actions (Edit), Add entity. Periods: por entidad seleccionada, tabla From, To, Status, Add, Close. Layout: listado con tabs.
13. **Configuration** — Moneda funcional y de presentación; tipos de documento (list + Add); otros parámetros; Save, Cancel. Layout: formulario con fieldsets.
14. **Audit log** — Filtros User, Tenant, From, To, Resource; tabla User, Tenant, Action, Resource, At, OK; Export. Layout: listado.
15. **Sustainability (opcional)** — Entity, Period; formulario para métricas (Scope, name, value); listado de métricas. Layout: formulario + listado.

---

## 7. Navegación y shell común

- **Barra superior (shell):** Sin logo. Selector Entity/Tenant (dropdown) a la izquierda (o tras el menú del IDE) | [espacio] | User (dropdown) a la derecha.
- **Menú principal (barra o lateral):** Home, Entity/Period, Chart of accounts, Journal, Ledger, Trial balance, Reports, Close period, Configuration, Administration, Audit log, Sustainability (opcional). Los ítems pueden ocultarse por rol según §5.
- **Breadcrumb:** Debajo del menú, sobre el contenido: “Home > [Section] > [Subsection]”. Ejemplos: “Home”, “Home > Entity & Period”, “Home > Ledger > Entry #42”.
- **Zona de contenido:** Debajo del breadcrumb; aquí va el layout específico (listado, formulario o reporte) de cada pantalla.
- **Pie (opcional):** Versión, enlaces de ayuda, etc.

Todas las pantallas comparten este shell; solo cambia la zona de contenido y el breadcrumb.

---

## 8. Resto de documentación de referencia

- **Diseño del producto (estándares, schemas, ACL):** `design.md` — secciones 2.5 (schemas), 2.7 (flujo lectura/escritura), 2.8 (recursos, permisos, roles).
- **Plan de implementación y contrato API:** `plan.md` — §3 lista vistas y funciones que usa el backend; útil para saber qué datos muestra cada pantalla.
- **En Markdown (legible por Figma):** Toda la documentación de pantallas está replicada en `docs-md/`:
  - **Modelo de negocio:** `docs-md/example-business-model.md` — Corporación Coderic (SAS/Colombia, SA/Venezuela, Corporation/USA); siete productos en la nube; clientes en Latinoamérica.
  - **Arquitectura (Mermaid):** `docs-md/architecture.md` — flujo de registro, esquema de schemas, flujo de lectura.
  - **Índice y navegación:** `docs-md/index.md`, `docs-md/nav.md`, `docs-md/README.md`.
- **Versión Antora (AsciiDoc):** `docs/modules/ROOT/pages/*.adoc` — misma información para publicación con Antora.

Los wireframes en `docs-md/wireframes.md` son la fuente detallada de layout por pantalla para construir los prototipos en Figma.
