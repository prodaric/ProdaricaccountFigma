-- Angelauth: permisos para que la app contable (prodaric) lea identidad y roles
-- Ejecutar conectado a prodaric_accounting como prodaric_sys: psql -d prodaric_accounting -U prodaric_sys -f angelauth/sql/03_grants.sql

GRANT USAGE ON SCHEMA angelauth TO prodaric;
GRANT SELECT ON angelauth.identity TO prodaric;
GRANT SELECT ON angelauth.role TO prodaric;
GRANT SELECT ON angelauth.permission TO prodaric;
GRANT SELECT ON angelauth.role_permission TO prodaric;
GRANT SELECT ON angelauth.user_role TO prodaric;
