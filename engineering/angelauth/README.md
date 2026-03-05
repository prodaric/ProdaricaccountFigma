# Angelauth – modelo de autenticación y futuro servidor OAuth

Este directorio contiene el **modelo de datos de autenticación** (identidad, roles, permisos) y está previsto para albergar un servidor OAuth. Está **oculto** del repositorio del sistema contable (`.gitignore`) para no versionar aquí el código del servidor de auth.

## Uso en esta etapa

En desarrollo, el sistema contable (Prodaric Accounting) **necesita acceso al modelo de auth** para resolver permisos por tenant. Por eso los scripts SQL de este directorio se ejecutan en la **misma base de datos** `prodaric_accounting`, en el schema **`angelauth`**.

- **Orden de ejecución:** Después de los scripts del repo contable hasta `sql/05_public_views.sql`, y **antes** de `sql/06_public_rbac.sql`.
- Ejecutar como `prodaric_sys` conectado a `prodaric_accounting`:

```bash
psql -d prodaric_accounting -U prodaric_sys -f angelauth/sql/00_schema.sql
psql -d prodaric_accounting -U prodaric_sys -f angelauth/sql/01_tables.sql
psql -d prodaric_accounting -U prodaric_sys -f angelauth/sql/02_seed.sql
psql -d prodaric_accounting -U prodaric_sys -f angelauth/sql/03_grants.sql
```

Luego continuar con `sql/06_public_rbac.sql`, 07, 08, 09, 10.

## Producción

En producción el backend del sistema contable autenticará vía **OAuth2** contra un IdP externo (Keycloak, Auth0, etc.). El modelo definido aquí puede servir de referencia o migrarse a ese servicio.
