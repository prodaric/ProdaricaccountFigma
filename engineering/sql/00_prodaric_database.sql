-- Prodaric Accounting: crear base de datos y roles de conexión
-- Ejecutar como superusuario conectado a postgres (o a cualquier BD distinta de prodaric_accounting):
--   psql -U postgres -d postgres -f sql/00_prodaric_database.sql
--
-- Después, ejecutar 01_roles.sql conectado a prodaric_accounting:
--   psql -U postgres -d prodaric_accounting -f sql/01_roles.sql
--
-- Cambiar las contraseñas antes de usar en producción.

-- 1. Crear roles (prodaric_sys = owner/sysadmin, prodaric = aplicación solo public)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'prodaric_sys') THEN
    CREATE ROLE prodaric_sys WITH LOGIN PASSWORD 'e3=f&SjkA9B2!';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'prodaric') THEN
    CREATE ROLE prodaric WITH LOGIN PASSWORD '?u8.8_?bKTF.L^';
  END IF;
END
$$;

-- 2. Crear base de datos (CREATE DATABASE no puede ir dentro de transacción; se ejecuta en autocommit)
CREATE DATABASE prodaric_accounting
  OWNER prodaric_sys
  ENCODING 'UTF8'
  TEMPLATE template0;

-- 3. Conceder conexión a la base prodaric_accounting a ambos roles
GRANT CONNECT ON DATABASE prodaric_accounting TO prodaric_sys;
GRANT CONNECT ON DATABASE prodaric_accounting TO prodaric;
