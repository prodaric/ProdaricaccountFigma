# Requerimientos de Software (Esbozo) — Prodaric Accounting

**Producto:** Prodaric Accounting  
**Posicionamiento:** Contabilidad, Sostenibilidad y Auditoría  
**Versión del esbozo:** 1.0  
**Referencia:** [design.md](design.md), [plan.md](plan.md)

Este documento es un **esbozo** del documento de Requerimientos de Software (RS). Establece alcance, objetivos, stakeholders, requerimientos funcionales y no funcionales, y restricciones, alineados al diseño y al plan de implementación del proyecto.

---

## 1. Introducción

### 1.1 Propósito del documento

Definir los requerimientos de software del sistema de administración contable Prodaric Accounting para que desarrolladores, diseñadores y stakeholders tengan una referencia única de qué debe hacer el sistema, bajo qué estándares y con qué restricciones.

### 1.2 Alcance del producto

- **Incluido:** Sistema de administración contable multi-tenant en PostgreSQL; libro diario inmutable (ledger); estados y reportes derivados (accounting); registro de asientos, reversión, cierre de período; plan de cuentas por entidad; estados financieros con no compensación (IAS 1.32); opcional módulo de sostenibilidad (métricas IFRS S1/S2); autenticación vía IdP externo (OAuth2); control de acceso por roles (admin, accountant, auditor, viewer); registro de auditoría (audit log); interfaz de usuario integrada en Prodaric Framework (Eclipse Theia).
- **No incluido en este esbozo:** Consolidación contable entre entidades; conversión de moneda (IAS 21) en detalle; reportes XBRL/taxonomía; módulos de nómina, inventarios o facturación fuera del alcance contable básico.

### 1.3 Definiciones y acrónimos

| Término | Definición |
|--------|-------------|
| NIIF/IFRS | Normas Internacionales de Información Financiera |
| IAS 1.32 | Prohibición de compensar activos con pasivos e ingresos con gastos en presentación |
| ISA | Normas Internacionales de Auditoría (IAASB) |
| IdP | Identity Provider (proveedor de identidad) |
| RBAC | Role-Based Access Control |
| Ledger | Libro diario; schema de BD con asientos inmutables |
| Tenant | Entidad de reporte (una por contexto jurídico en el modelo multi-tenant) |

---

## 2. Objetivos

### 2.1 Objetivos del negocio

- Permitir a las entidades de reporte llevar contabilidad alineada a NIIF/IFRS con libro diario inmutable y trazable.
- Generar estados financieros (situación financiera, resultado) y balance de comprobación sin compensación indebida (IAS 1.32).
- Facilitar la auditoría (ISA) mediante evidencia, checksums e historial no modificable.
- Soportar múltiples entidades (multi-tenant) con aislamiento de datos por tenant (entity_id).

### 2.2 Objetivos del sistema

- Que toda escritura contable pase por funciones que validen partida doble, período abierto y naturaleza de cuentas; sin escritura directa en el ledger desde la aplicación.
- Que la aplicación consuma solo vistas y funciones expuestas en el schema `public`.
- Que la autorización se resuelva por rol y tenant (OAuth2/IdP en producción; modelo opcional en BD en desarrollo).

---

## 3. Stakeholders y usuarios

### 3.1 Roles de usuario (RBAC por tenant)

| Rol | Descripción | Uso típico |
|-----|-------------|------------|
| **admin** | Acceso completo al tenant: entidades, períodos, plan de cuentas, journal, cierre, configuración, usuarios, audit log. | Administrador de la entidad. |
| **accountant** | Registrar asientos, consultar diario/saldos/reportes, plan de cuentas (lectura y escritura), configuración (lectura), sostenibilidad (lectura y escritura). No gestionar entidades ni usuarios. | Contador. |
| **auditor** | Solo lectura: entidad, período, plan de cuentas, libro diario, saldos, reportes, configuración, sostenibilidad, audit log. | Auditor externo o interno. |
| **viewer** | Lectura limitada: entidad, período, plan de cuentas, saldos, reportes. Opcionalmente sin acceso al libro diario. | Gerencia, analistas. |

Definición detallada de permisos (recurso:acción) en [design.md](design.md) §2.8.

### 3.2 Stakeholders

- **Entidad de reporte (tenant):** Empresa o grupo que usa el sistema para su contabilidad.
- **Equipo de desarrollo:** Implementación del backend, frontend (Prodaric Framework/Theia) e integración con IdP.
- **Auditor:** Usuario que debe poder consultar evidencia y trazabilidad (ISA).

---

## 4. Estándares de cumplimiento

El sistema debe cumplir o soportar:

| Estándar | Área | Requerimiento de cumplimiento |
|----------|------|-------------------------------|
| **Marco Conceptual NIIF** | Contabilidad | Elementos (activo, pasivo, patrimonio, ingreso, gasto); partida doble; ecuación contable. |
| **IAS 1** | Presentación | No compensación (activos/pasivos e ingresos/gastos en líneas separadas). |
| **ISA (IAASB)** | Auditoría | Trazabilidad, inmutabilidad del ledger, registro de auditoría (audit_log). |
| **IFRS S1 / S2** | Sostenibilidad (opcional) | Métricas por entidad y período; misma entidad que la contabilidad. |
| **OWASP** | Seguridad | Referencia a ASVS (autenticación, sesión, control de acceso); no almacenar contraseñas; IdP externo. |

---

## 5. Requerimientos funcionales

### 5.1 Gestión de entidad y período

| Id | Descripción | Prioridad |
|----|-------------|-----------|
| RF-EP-01 | El sistema permitirá seleccionar la entidad (tenant) de reporte en la sesión. | Alta |
| RF-EP-02 | El sistema permitirá listar períodos de la entidad con estado (abierto/cerrado). | Alta |
| RF-EP-03 | El sistema permitirá a usuarios con permiso `period:manage` crear períodos y cerrar períodos (vía función `close_period`). | Alta |
| RF-EP-04 | El sistema permitirá a usuarios con permiso `entity:manage` crear y editar entidades (vía funciones `create_entity`, `update_entity`). | Alta |

### 5.2 Plan de cuentas

| Id | Descripción | Prioridad |
|----|-------------|-----------|
| RF-PC-01 | El sistema mostrará el plan de cuentas por entidad con código, nombre, elemento (asset, liability, equity, income, expense) y naturaleza (débito/crédito). | Alta |
| RF-PC-02 | El sistema permitirá filtrar cuentas por elemento. | Media |
| RF-PC-03 | El sistema permitirá a usuarios con permiso `chart_of_accounts:write` crear y editar cuentas (vía `create_account`, `update_account`). | Alta |

### 5.3 Registro de asientos (journal)

| Id | Descripción | Prioridad |
|----|-------------|-----------|
| RF-J-01 | El sistema permitirá registrar un asiento con fecha, referencia, descripción y líneas (cuenta, débito, crédito) mediante la función `register_entry`. | Alta |
| RF-J-02 | El sistema validará partida doble (suma débitos = suma créditos) antes de persistir. | Alta |
| RF-J-03 | El sistema validará que la fecha del asiento esté dentro del período y que el período esté abierto. | Alta |
| RF-J-04 | El sistema validará que cada línea respete la naturaleza (normal_balance) de la cuenta. | Alta |
| RF-J-05 | El sistema no permitirá modificar ni eliminar asientos ya registrados; solo crear asientos de reversa. | Alta |

### 5.4 Libro diario y detalle de asiento

| Id | Descripción | Prioridad |
|----|-------------|-----------|
| RF-L-01 | El sistema mostrará el listado de asientos (libro diario) filtrable por entidad, período y rango de fechas (solo lectura desde vistas). | Alta |
| RF-L-02 | El sistema permitirá consultar el detalle de un asiento (cabecera y líneas) en solo lectura. | Alta |
| RF-L-03 | El sistema permitirá a usuarios con permiso adecuado crear un asiento de reversa desde un asiento existente (función `create_reversal_entry`). | Alta |

### 5.5 Saldos y reportes

| Id | Descripción | Prioridad |
|----|-------------|-----------|
| RF-R-01 | El sistema mostrará saldos por cuenta y período (vista `balance`). | Alta |
| RF-R-02 | El sistema mostrará el balance de comprobación (todas las cuentas con totales débito/crédito por período; vista `trial_balance`). | Alta |
| RF-R-03 | El sistema mostrará el estado de situación financiera por elemento (activos, pasivos, patrimonio) sin compensación (IAS 1.32). | Alta |
| RF-R-04 | El sistema mostrará el estado de resultado por elemento (ingresos, gastos) sin compensación (IAS 1.32). | Alta |
| RF-R-05 | El sistema permitirá exportar reportes (formato a definir: PDF, CSV, etc.). | Media |

### 5.6 Cierre de período

| Id | Descripción | Prioridad |
|----|-------------|-----------|
| RF-C-01 | El sistema permitirá cerrar un período (función `close_period`), impidiendo nuevos asientos en ese período. | Alta |
| RF-C-02 | Solo usuarios con permiso `period:manage` podrán ejecutar el cierre. | Alta |

### 5.7 Configuración

| Id | Descripción | Prioridad |
|----|-------------|-----------|
| RF-CFG-01 | El sistema permitirá consultar y, según permisos, modificar configuración de entidad (moneda funcional, tipos de documento, parámetros en `entity_config`). | Media |

### 5.8 Sostenibilidad (opcional)

| Id | Descripción | Prioridad |
|----|-------------|-----------|
| RF-S-01 | El sistema permitirá consultar métricas de sostenibilidad por entidad y período (vista `sustainability_metric`). | Baja |
| RF-S-02 | El sistema permitirá a usuarios con permiso `sustainability:write` cargar o actualizar métricas (función `upsert_sustainability_metric`). | Baja |

### 5.9 Auditoría y administración

| Id | Descripción | Prioridad |
|----|-------------|-----------|
| RF-AUD-01 | El sistema registrará en audit_log las operaciones sensibles (journal:write, configuration:write, user:manage, etc.). | Alta |
| RF-AUD-02 | El sistema permitirá a usuarios con rol auditor o admin consultar el registro de auditoría (audit log) con filtros. | Alta |

### 5.10 Autenticación y autorización

| Id | Descripción | Prioridad |
|----|-------------|-----------|
| RF-AUTH-01 | El sistema no gestionará contraseñas; la autenticación se realizará mediante IdP externo (OAuth2/OpenID Connect). | Alta |
| RF-AUTH-02 | La API validará el token (JWT), extraerá identificador de usuario y tenant, y resolverá permisos por rol para cada recurso. | Alta |
| RF-AUTH-03 | La visibilidad de menús y acciones en la interfaz dependerá del rol del usuario en el tenant seleccionado. | Alta |

---

## 6. Requerimientos no funcionales

### 6.1 Seguridad

| Id | Descripción |
|----|-------------|
| RNF-SEC-01 | La aplicación se conectará a la base de datos con un usuario que solo tenga acceso al schema `public`; no podrá escribir directamente en `ledger`, `accounting` ni `sustainability`. |
| RNF-SEC-02 | Toda escritura contable se realizará mediante funciones con SECURITY DEFINER que validen reglas de negocio antes de insertar en el ledger. |
| RNF-SEC-03 | Los datos del ledger serán inmutables (append-only); cada asiento tendrá checksum para verificación de integridad. |

### 6.2 Integridad de datos

| Id | Descripción |
|----|-------------|
| RNF-INT-01 | Partida doble: cada asiento debe cumplir suma de débitos = suma de créditos. |
| RNF-INT-02 | Cada línea de asiento debe tener solo débito o solo crédito (no ambos distintos de cero). |
| RNF-INT-03 | Los movimientos deben respetar la naturaleza (normal_balance) de la cuenta. |

### 6.3 Usabilidad e interfaz

| Id | Descripción |
|----|-------------|
| RNF-UI-01 | La interfaz se integrará en Prodaric Framework (Eclipse Theia); las pantallas del sistema contable serán vistas dentro del área de contenido del IDE. |
| RNF-UI-02 | Se preferirán tabs, fieldsets y tablas frente a modales para las operaciones principales. |
| RNF-UI-03 | Diseño visual con tonos grises al estilo GTK/Qt; sin logo en el shell (solo en splash). |

### 6.4 Mantenibilidad y convenciones

| Id | Descripción |
|----|-------------|
| RNF-MNT-01 | Nombres de objetos de BD en inglés, minúsculas, singular; claves foráneas como `tabla_id`; comentarios en español cuando ayuden. |
| RNF-MNT-02 | Documentación de diseño en `design.md`, plan en `plan.md`, contrato API en `plan.md` §3; wireframes en `docs/` y `docs-md/`. |

---

## 7. Restricciones

| Id | Restricción |
|----|-------------|
| R-01 | Base de datos PostgreSQL; modelo implementado en scripts SQL (schemas ledger, accounting, public, sustainability). |
| R-02 | No se permitirá escritura directa (INSERT/UPDATE/DELETE) desde la aplicación sobre tablas del ledger ni del accounting. |
| R-03 | Autenticación delegada en IdP externo; el sistema no almacenará contraseñas. |
| R-04 | Multi-tenant por entidad de reporte (entity_id); todos los datos contables están acotados por tenant. |

---

## 8. Glosario y referencias

### 8.1 Referencias internas

- **Diseño:** [design.md](design.md) — estándares, schemas, inmutabilidad, ACL.
- **Plan:** [plan.md](plan.md) — contrato API (funciones y vistas), alcance de pantallas.
- **Scripts SQL:** [sql/README.md](sql/README.md) — orden de ejecución.
- **Wireframes:** [docs/modules/ROOT/pages/wireframes.adoc](docs/modules/ROOT/pages/wireframes.adoc) o [docs-md/wireframes.md](docs-md/wireframes.md).
- **Instrucciones Figma:** [figma.md](figma.md).

### 8.2 Referencias externas (estándares)

- Marco Conceptual para la Información Financiera (IFRS Foundation).
- IAS 1 — Presentación de Estados Financieros.
- ISA (IAASB) — Normas Internacionales de Auditoría.
- IFRS S1, S2 — Sostenibilidad (ISSB).
- OWASP ASVS — Application Security Verification Standard.

---

*Este esbozo puede ampliarse con trazabilidad requisito–diseño, casos de prueba y criterios de aceptación en revisiones posteriores.*
