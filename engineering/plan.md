# Plan de implementación: Prodaric Accounting

**Producto:** Prodaric Accounting  
**Posicionamiento:** Contabilidad, Sostenibilidad y Auditoría

El diseño completo (estándares, schemas, inmutabilidad, journal en ledger, vistas derivadas, configuración) está en [design.md](design.md). Este documento resume el plan de implementación.

**Forma de implementación:** Orden de ejecución de scripts en [sql/README.md](sql/README.md). Definición de schemas en design.md §2.5; flujo de lectura (vistas) y escritura (solo vía funciones) en design.md §2.7.

---

## 1. Alcance y decisiones de diseño (resumen)

- **Ledger** = única fuente de verdad del journal (libro diario); datos inmutables con checksum (SHA-256/SHA-1). No pueden crearse asientos fuera de las reglas NIIF/ISA; toda escritura vía funciones en `public`.
- **Accounting** = solo vistas derivadas sobre `ledger` (y tablas de referencia de solo lectura si aplica); sin tablas de hechos de escritura.
- **Public** = API (funciones, vistas, secuencias, procedimientos) + **tablas/parámetros configurables** (lo que la entidad o el usuario pueda configurar).
- **Sustainability** = tablas de datos; acceso vía funciones/vistas en public; escritura restringida a sysadmin.
- **Roles:** Base de datos `prodaric_accounting`. Usuario aplicación `prodaric` (solo `public`); usuario sysadmin `prodaric_sys` (acceso total a ledger, accounting, sustainability). Definición en [sql/01_roles.sql](sql/01_roles.sql).
- **Nombres de objetos de BD:** Según [.cursor/rules/data-model.mdc](.cursor/rules/data-model.mdc): inglés, minúsculas, singular; FK como `tabla_id`; COMMENT en español cuando sea necesario para explicar.
- **Auth/ACL:** El modelo de datos de auth (identity, role, permission, role_permission, user_role) está en el directorio **angelauth** (schema `angelauth` en la misma BD durante desarrollo); el backend en producción usará OAuth2 contra un IdP externo (Keycloak, Auth0, etc.). RBAC por tenant: roles admin, accountant, auditor, viewer; recursos y permisos en design.md §2.8. Audit log en public para operaciones sensibles (ISA/OWASP).
- **Alcance de pantallas (wireframes):** Definido en [docs/modules/ROOT/pages/wireframes.adoc](docs/modules/ROOT/pages/wireframes.adoc): entidad/período, plan de cuentas, journal, diario, saldos, reportes, configuración; pantallas ampliadas (dashboard, detalle de asiento, balance de comprobación, cierre de período, administración entidad/período, reversión de asiento, audit log); opcional sostenibilidad y gestión de usuarios/roles.

---

## 2. Próximos pasos de implementación

1. **Definir alcance funcional v1:** Solo contabilidad (libro mayor, balances, reportes básicos) o también módulo de sostenibilidad (métricas S1/S2).
2. **Datos iniciales y plan de cuentas:** Seed data (monedas, tipos de documento) y plan de cuentas base de 5 elementos (Activos, Pasivos, Patrimonio, Ingresos, Gastos) extensible; detalle suficiente para ítems mínimos IAS 1.
3. **Diseñar esquema PostgreSQL:**
   - Schema `ledger`: tablas inmutables del journal (p. ej. `entry`, `entry_line`) con checksum; restricciones de partida doble y ecuación contable en la API.
   - Schema `accounting`: vistas derivadas de `ledger` en singular (p. ej. `entry`, `balance` por account/period, `account` como plan de cuentas, `entity`, `period`, `currency`).
   - Schema `public`: funciones (p. ej. `register_entry`), vistas de consulta, tablas configurables; secuencias expuestas.
   - Roles y permisos: `prodaric` (solo public), `prodaric_sys` (acceso total). Script: [sql/01_roles.sql](sql/01_roles.sql).
4. **Auth y autorización:** Modelo de auth en angelauth (schema `angelauth`; scripts en directorio angelauth/). En producción: integración con IdP (OAuth2; claims: sub, tenant_id, role). En la API: validar JWT, resolver permiso por rol/tenant, registrar audit_log en operaciones sensibles.
5. **Reglas de presentación:** Vistas o capa de reportes que apliquen "no compensación" (IAS 1.32) al presentar activos/pasivos e ingresos/gastos.
6. **Consultar .cursor/rules:** Alinear nombres, convenciones y calidad de código con las reglas del proyecto.
7. **Requisitos ISA:** Diseño de reportes y trazabilidad (evidencia, inmutabilidad, controles) para facilitar encargos de auditoría según IAASB.
8. **Inmutabilidad y API:** Implementar funciones SECURITY DEFINER que validen reglas NIIF y escriban solo en `ledger`; checksums en registros; sin escritura directa desde la aplicación sobre ledger/accounting/sustainability.

---

## 3. Contrato API (capa de aplicación)

Si la API (REST, GraphQL u otra) vive en este repositorio o en otro, el contrato con la base de datos es el siguiente. La aplicación se conecta con el usuario `prodaric` y **no** ejecuta INSERT/UPDATE/DELETE directos sobre `ledger`, `accounting` ni `sustainability`.

- **Escritura:** Solo mediante funciones en `public`: `register_entry`, `create_reversal_entry`, `close_period`, `create_entity`, `update_entity`, `create_period`, `create_account`, `update_account`, `upsert_sustainability_metric`. La API debe validar JWT, resolver permisos por rol/tenant (design.md §2.8) y, en operaciones sensibles, registrar en `audit_log`.
- **Lectura:** Mediante vistas en `public`: `entity`, `period`, `currency`, `account`, `entry`, `entry_line`, `balance`, `statement_financial_position`, `statement_result`, `trial_balance`, `sustainability_metric`; y tablas configurables (p. ej. `document_type`, `entity_config`) cuando corresponda.
- **Configuración:** Lectura y, donde aplique, escritura en tablas de `public` (entity_config, etc.) y en desarrollo en `angelauth` (identity, role, permission, user_role) según permisos del usuario.

Referencia de funciones y vistas: scripts en [sql/](sql/) (08_functions, 05_public_views, 06_public_rbac, 07_public_config). La vista `sustainability_metric` y la función `upsert_sustainability_metric` se crean en [sql/10_sustainability.sql](sql/10_sustainability.sql).

---

## 4. Referencia

- **Diseño completo:** [design.md](design.md)
