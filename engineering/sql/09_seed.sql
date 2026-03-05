-- Prodaric Accounting: datos iniciales (monedas, tipos de documento, plan de cuentas base)
-- Ejecutar una vez tras 02–08, conectado a prodaric_accounting como prodaric_sys: psql -d prodaric_accounting -U prodaric_sys -f sql/09_seed.sql
-- Idempotente donde sea posible (INSERT ... ON CONFLICT DO NOTHING o comprobaciones).

-- 1. Monedas (ISO 4217)
INSERT INTO accounting.currency (id, code, name) VALUES
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'USD', 'US Dollar'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'COP', 'Colombian Peso'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'VES', 'Venezuelan Bolívar'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', 'EUR', 'Euro')
ON CONFLICT (code) DO NOTHING;

-- 2. Tipos de documento
INSERT INTO public.document_type (id, code, name) VALUES
  ('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a21', 'INV', 'Invoice'),
  ('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'REC', 'Receipt'),
  ('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a23', 'PAY', 'Payment'),
  ('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a24', 'JEV', 'Journal entry'),
  ('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a25', 'REV', 'Reversal')
ON CONFLICT (code) DO NOTHING;

-- 3. Entidad y período de ejemplo (para tener plan de cuentas base)
-- Si ya existe una entidad con code 'SEED', no duplicar
DO $$
DECLARE
  v_entity_id   uuid;
  v_period_id   uuid;
  v_usd         uuid := 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';
BEGIN
  IF NOT EXISTS (SELECT 1 FROM accounting.entity WHERE code = 'SEED') THEN
    INSERT INTO accounting.entity (id, code, name, jurisdiction, functional_currency_id)
    VALUES (gen_random_uuid(), 'SEED', 'Seed entity (template)', 'Template', v_usd)
    RETURNING id INTO v_entity_id;

    INSERT INTO accounting.period (id, entity_id, from_date, to_date, status)
    VALUES (gen_random_uuid(), v_entity_id, date_trunc('month', current_date)::date,
            (date_trunc('month', current_date) + interval '1 month - 1 day')::date, 'open')
    RETURNING id INTO v_period_id;

    -- 4. Plan de cuentas base (5 elementos NIIF + subcuentas mínimas para IAS 1)
    INSERT INTO accounting.account (entity_id, code, name, element, normal_balance, parent_id) VALUES
      (v_entity_id, '1000', 'Cash and bank', 'asset', 'debit', NULL),
      (v_entity_id, '1100', 'Receivables', 'asset', 'debit', NULL),
      (v_entity_id, '1200', 'Inventory', 'asset', 'debit', NULL),
      (v_entity_id, '2000', 'Payables', 'liability', 'credit', NULL),
      (v_entity_id, '2100', 'Deferred revenue', 'liability', 'credit', NULL),
      (v_entity_id, '3000', 'Equity', 'equity', 'credit', NULL),
      (v_entity_id, '4000', 'Revenue from services', 'income', 'credit', NULL),
      (v_entity_id, '4100', 'Other income', 'income', 'credit', NULL),
      (v_entity_id, '5000', 'Cost of sales', 'expense', 'debit', NULL),
      (v_entity_id, '5100', 'Payroll', 'expense', 'debit', NULL),
      (v_entity_id, '5200', 'Infrastructure and other', 'expense', 'debit', NULL);
  END IF;
END
$$;
