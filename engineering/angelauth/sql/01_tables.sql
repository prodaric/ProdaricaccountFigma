-- Angelauth: tablas identity, role, permission, role_permission, user_role en schema angelauth
-- Ejecutar después de sql/02_accounting_reference.sql (accounting.entity existe).
-- Ejecutar conectado a prodaric_accounting como prodaric_sys: psql -d prodaric_accounting -U prodaric_sys -f angelauth/sql/01_tables.sql

-- 1. Identidad (usuario desde IdP; sub + tenant)
CREATE TABLE IF NOT EXISTS angelauth.identity (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  external_id text NOT NULL,
  tenant_id   uuid REFERENCES accounting.entity(id) ON DELETE CASCADE,
  email       text,
  name        text,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (external_id, tenant_id)
);

COMMENT ON TABLE angelauth.identity IS 'Usuarios conocidos por la app. external_id = sub del JWT; tenant_id = entidad a la que pertenece.';

-- 2. Rol (admin, accountant, auditor, viewer)
CREATE TABLE IF NOT EXISTS angelauth.role (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code        text NOT NULL UNIQUE,
  name        text NOT NULL
);

COMMENT ON TABLE angelauth.role IS 'Roles RBAC por tenant (admin, accountant, auditor, viewer).';

-- 3. Permiso (recurso:acción)
CREATE TABLE IF NOT EXISTS angelauth.permission (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code        text NOT NULL UNIQUE,
  name        text
);

COMMENT ON TABLE angelauth.permission IS 'Permisos en formato recurso:acción (ej. journal:write, ledger:read).';

-- 4. Rol – permiso (N:N)
CREATE TABLE IF NOT EXISTS angelauth.role_permission (
  role_id       uuid NOT NULL REFERENCES angelauth.role(id) ON DELETE CASCADE,
  permission_id uuid NOT NULL REFERENCES angelauth.permission(id) ON DELETE CASCADE,
  PRIMARY KEY (role_id, permission_id)
);

-- 5. Usuario – rol por tenant
CREATE TABLE IF NOT EXISTS angelauth.user_role (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  identity_id uuid NOT NULL REFERENCES angelauth.identity(id) ON DELETE CASCADE,
  role_id     uuid NOT NULL REFERENCES angelauth.role(id) ON DELETE CASCADE,
  tenant_id   uuid NOT NULL REFERENCES accounting.entity(id) ON DELETE CASCADE,
  created_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (identity_id, role_id, tenant_id)
);

COMMENT ON TABLE angelauth.user_role IS 'Asignación de rol a usuario por tenant (entity_id).';

CREATE INDEX IF NOT EXISTS idx_angelauth_identity_tenant ON angelauth.identity (tenant_id);
CREATE INDEX IF NOT EXISTS idx_angelauth_user_role_identity ON angelauth.user_role (identity_id);
CREATE INDEX IF NOT EXISTS idx_angelauth_user_role_tenant ON angelauth.user_role (tenant_id);
