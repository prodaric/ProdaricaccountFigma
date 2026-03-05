-- Angelauth: schema para modelo de autenticación (identity, role, permission, user_role)
-- Ejecutar conectado a prodaric_accounting como prodaric_sys: psql -d prodaric_accounting -U prodaric_sys -f angelauth/sql/00_schema.sql
-- Requiere haber ejecutado antes sql/01_roles.sql (prodaric_sys existe).

CREATE SCHEMA IF NOT EXISTS angelauth AUTHORIZATION prodaric_sys;

COMMENT ON SCHEMA angelauth IS 'Modelo de datos de autenticación (identidad, roles, permisos). En desarrollo compartido con prodaric_accounting; en producción puede vivir en IdP externo.';
