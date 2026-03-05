# Scripts SQL – Prodaric Accounting

**Propósito.** Estos scripts crean y pueblan la base de datos `prodaric_accounting`: schemas (ledger, accounting, sustainability), tablas de referencia, ledger inmutable, vistas derivadas, vistas y funciones en `public`, configuración, datos iniciales y módulo de sostenibilidad, según [design.md](../design.md) y [plan.md](../plan.md).

**Estándares.** Todos los objetos creados (tablas, vistas, funciones, etc.) siguen las convenciones de [.cursor/rules/data-model.mdc](../.cursor/rules/data-model.mdc): nombres en inglés, minúsculas, singular; claves foráneas como `tabla_id`; COMMENT en español cuando ayude a explicar.

Orden de ejecución (como superusuario `postgres` para 00; como `prodaric_sys` conectado a la base `prodaric_accounting` para el resto):

| Orden | Script | Descripción |
|-------|--------|-------------|
| 0 | `00_prodaric_database.sql` | Crear BD `prodaric_accounting` y roles (ejecutar conectado a `postgres`) |
| 1 | `01_roles.sql` | Schemas (ledger, accounting, sustainability) y permisos |
| 2 | `02_accounting_reference.sql` | Tablas de referencia: currency, entity, period, account |
| 3 | `03_ledger.sql` | Tablas inmutables: entry, entry_line |
| 4 | `04_accounting_views.sql` | Vistas en accounting derivadas de ledger |
| 5 | `05_public_views.sql` | Vistas en public para la aplicación |
| 5b | **angelauth** | Ejecutar en la misma BD: `angelauth/sql/00_schema.sql`, `01_tables.sql`, `02_seed.sql`, `03_grants.sql` (crea schema `angelauth` y tablas de identidad/roles/permisos) |
| 6 | `06_public_rbac.sql` | audit_log en public (identity, roles y permisos en schema angelauth) |
| 7 | `07_public_config.sql` | document_type, entity_config |
| 8 | `08_functions.sql` | register_entry, create_reversal_entry, close_period |
| 9 | `09_seed.sql` | Monedas, tipos de documento, entidad/período/cuentas de ejemplo |
| 10 | `10_sustainability.sql` | Tabla sustainability.metric, vista public.sustainability_metric y función upsert_sustainability_metric |

Ejemplo:

```bash
psql -U postgres -d postgres -f sql/00_prodaric_database.sql
psql -U postgres -d prodaric_accounting -f sql/01_roles.sql
psql -U prodaric_sys -d prodaric_accounting -f sql/02_accounting_reference.sql
# ... 03 a 10 en el mismo orden
```

La aplicación se conecta con el usuario `prodaric` (solo schema `public`). Toda escritura en `ledger` y `sustainability` se hace mediante funciones en `public` con `SECURITY DEFINER`.

**Modelo de auth (angelauth).** Las tablas de identidad, roles y permisos están en el directorio **angelauth/** (no versionado: está en `.gitignore`). Ese modelo se ejecuta en la misma base de datos `prodaric_accounting`, en el schema `angelauth`. Debe ejecutarse el SQL de angelauth (pasos 00 a 03) **antes** del script `06_public_rbac.sql`, ya que `audit_log` referencia `angelauth.identity(id)`.
