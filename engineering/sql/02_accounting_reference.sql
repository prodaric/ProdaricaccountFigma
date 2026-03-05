-- Prodaric Accounting: tablas de referencia en schema accounting
-- Solo escritura por prodaric_sys; la aplicación lee vía vistas en public.
-- Ejecutar conectado a prodaric_accounting como prodaric_sys: psql -d prodaric_accounting -U prodaric_sys -f sql/02_accounting_reference.sql

-- 0. Tipos ENUM en public (reutilizables)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'period_status') THEN
    CREATE TYPE public.period_status AS ENUM ('open', 'closed');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'account_element') THEN
    CREATE TYPE public.account_element AS ENUM ('asset', 'liability', 'equity', 'income', 'expense');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'normal_balance') THEN
    CREATE TYPE public.normal_balance AS ENUM ('debit', 'credit');
  END IF;
END
$$;

COMMENT ON TYPE public.period_status IS 'Estado del período contable: abierto o cerrado.';
COMMENT ON TYPE public.account_element IS 'Elemento NIIF del Marco Conceptual: activo, pasivo, patrimonio, ingreso, gasto.';
COMMENT ON TYPE public.normal_balance IS 'Naturaleza del saldo de la cuenta: débito o crédito.';

-- 1. Moneda (catálogo compartido)
CREATE TABLE IF NOT EXISTS accounting.currency (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code       text NOT NULL UNIQUE,
  name       text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE accounting.currency IS 'Catálogo de monedas (ISO 4217). Referencia para moneda funcional y de presentación.';

-- 2. Entidad de reporte (tenant / entidad legal)
CREATE TABLE IF NOT EXISTS accounting.entity (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code                  text NOT NULL,
  name                  text NOT NULL,
  jurisdiction          text,
  functional_currency_id uuid NOT NULL REFERENCES accounting.currency(id),
  created_at            timestamptz NOT NULL DEFAULT now(),
  updated_at            timestamptz NOT NULL DEFAULT now(),
  UNIQUE (code)
);

COMMENT ON TABLE accounting.entity IS 'Entidad de reporte (tenant). Una por jurisdicción en el modelo multi-tenant.';

-- 3. Período contable por entidad
CREATE TABLE IF NOT EXISTS accounting.period (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_id  uuid NOT NULL REFERENCES accounting.entity(id) ON DELETE CASCADE,
  from_date  date NOT NULL,
  to_date    date NOT NULL,
  status     public.period_status NOT NULL DEFAULT 'open'::public.period_status,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (entity_id, from_date, to_date),
  CHECK (to_date >= from_date)
);

COMMENT ON TABLE accounting.period IS 'Período de reporte por entidad. status=closed impide nuevos asientos.';

-- 4. Plan de cuentas (por entidad): elemento NIIF y naturaleza débito/crédito
CREATE TABLE IF NOT EXISTS accounting.account (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_id   uuid NOT NULL REFERENCES accounting.entity(id) ON DELETE CASCADE,
  code        text NOT NULL,
  name        text NOT NULL,
  element     public.account_element NOT NULL,
  normal_balance public.normal_balance NOT NULL,
  parent_id   uuid REFERENCES accounting.account(id) ON DELETE SET NULL,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (entity_id, code)
);

COMMENT ON TABLE accounting.account IS 'Plan de cuentas por entidad. element y normal_balance para partida doble y presentación NIIF.';

CREATE INDEX IF NOT EXISTS idx_period_entity ON accounting.period (entity_id);
CREATE INDEX IF NOT EXISTS idx_account_entity ON accounting.account (entity_id);
CREATE INDEX IF NOT EXISTS idx_account_parent ON accounting.account (parent_id);
