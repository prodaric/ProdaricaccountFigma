-- Prodaric Accounting: audit_log en public (identidad y RBAC en schema angelauth)
-- Las tablas identity, role, permission, role_permission, user_role están en el schema angelauth;
-- scripts en el directorio angelauth/ (ejecutar angelauth/sql/00 a 03 antes de este script).
-- Ejecutar conectado a prodaric_accounting como prodaric_sys: psql -d prodaric_accounting -U prodaric_sys -f sql/06_public_rbac.sql

-- Audit log (trazabilidad ISA/OWASP): identity_id apunta a angelauth.identity
CREATE TABLE IF NOT EXISTS public.audit_log (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  identity_id uuid REFERENCES angelauth.identity(id) ON DELETE SET NULL,
  tenant_id   uuid REFERENCES accounting.entity(id) ON DELETE SET NULL,
  action      text NOT NULL,
  resource    text NOT NULL,
  at          timestamptz NOT NULL DEFAULT now(),
  result      text,
  detail      jsonb
);

COMMENT ON TABLE public.audit_log IS 'Registro de auditoría para operaciones sensibles (journal:write, configuration:write, etc.).';

CREATE INDEX IF NOT EXISTS idx_audit_log_tenant ON public.audit_log (tenant_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_at ON public.audit_log (at);

GRANT SELECT, INSERT ON public.audit_log TO prodaric;
