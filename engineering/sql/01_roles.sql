-- Prodaric Accounting: schemas y permisos dentro de la base prodaric_accounting
-- Requiere haber ejecutado antes: sql/00_prodaric_database.sql (como postgres, conectado a postgres)
--
-- Uso: conectado a la base prodaric_accounting (psql -d prodaric_accounting -U postgres o prodaric_sys)
--   psql -U postgres -d prodaric_accounting -f sql/01_roles.sql
--
-- Usuario aplicación: prodaric (solo schema public)
-- Usuario sysadmin: prodaric_sys (acceso total al modelo)

-- 1. Schemas: crear con owner prodaric_sys
CREATE SCHEMA IF NOT EXISTS ledger AUTHORIZATION prodaric_sys;
CREATE SCHEMA IF NOT EXISTS accounting AUTHORIZATION prodaric_sys;
CREATE SCHEMA IF NOT EXISTS sustainability AUTHORIZATION prodaric_sys;
-- public existe por defecto; las funciones/vistas en public las crea prodaric_sys.

-- 2. Usuario prodaric: solo public (USAGE en schema public)
GRANT USAGE ON SCHEMA public TO prodaric;

-- Permisos por defecto en public para objetos creados por prodaric_sys (prodaric podrá usarlos)
ALTER DEFAULT PRIVILEGES FOR ROLE prodaric_sys IN SCHEMA public
  GRANT EXECUTE ON FUNCTIONS TO prodaric;
ALTER DEFAULT PRIVILEGES FOR ROLE prodaric_sys IN SCHEMA public
  GRANT SELECT ON TABLES TO prodaric;
ALTER DEFAULT PRIVILEGES FOR ROLE prodaric_sys IN SCHEMA public
  GRANT USAGE ON SEQUENCES TO prodaric;
-- Para tablas configurables donde prodaric deba escribir: conceder INSERT/UPDATE/DELETE explícitamente en esas tablas.

-- 3. Asegurar que prodaric NO tiene acceso a ledger, accounting, sustainability
REVOKE ALL ON SCHEMA ledger FROM prodaric;
REVOKE ALL ON SCHEMA accounting FROM prodaric;
REVOKE ALL ON SCHEMA sustainability FROM prodaric;

-- Nota: Las funciones en public que escriben en ledger deben ser creadas con SECURITY DEFINER
-- y pertenecer a prodaric_sys, para que al ejecutarlas como prodaric se eleve el privilegio solo dentro de la función.
