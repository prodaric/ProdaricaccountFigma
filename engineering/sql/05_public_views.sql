-- Prodaric Accounting: vistas en public que exponen accounting/ledger a la aplicación
-- El usuario prodaric solo tiene acceso a public; estas vistas leen de accounting con owner prodaric_sys.
-- Ejecutar conectado a prodaric_accounting como prodaric_sys: psql -d prodaric_accounting -U prodaric_sys -f sql/05_public_views.sql

CREATE OR REPLACE VIEW public.entity AS
SELECT id, code, name, jurisdiction, functional_currency_id, created_at, updated_at
FROM accounting.entity;

CREATE OR REPLACE VIEW public.period AS
SELECT id, entity_id, from_date, to_date, status, created_at
FROM accounting.period;

CREATE OR REPLACE VIEW public.currency AS
SELECT id, code, name, created_at
FROM accounting.currency;

CREATE OR REPLACE VIEW public.account AS
SELECT id, entity_id, code, name, element, normal_balance, parent_id, created_at, updated_at
FROM accounting.account;

CREATE OR REPLACE VIEW public.entry AS
SELECT id, entity_id, period_id, reference, description, entry_date, reversal_of_id, checksum, created_at,
  entity_code, entity_name, period_from, period_to, period_status
FROM accounting.entry;

CREATE OR REPLACE VIEW public.entry_line AS
SELECT id, entry_id, account_id, amount_debit, amount_credit, line_order, account_code, account_name, account_element
FROM accounting.entry_line;

CREATE OR REPLACE VIEW public.balance AS
SELECT entity_id, period_id, account_id, account_code, account_name, element, normal_balance, total_debit, total_credit, balance
FROM accounting.balance;

CREATE OR REPLACE VIEW public.statement_financial_position AS
SELECT entity_id, period_id, element, total_balance
FROM accounting.statement_financial_position;

CREATE OR REPLACE VIEW public.statement_result AS
SELECT entity_id, period_id, element, total_balance
FROM accounting.statement_result;

CREATE OR REPLACE VIEW public.trial_balance AS
SELECT entity_id, period_id, account_id, account_code, account_name, element, normal_balance, total_debit, total_credit, balance
FROM accounting.trial_balance;

COMMENT ON VIEW public.entity IS 'Entidades de reporte (tenant). Exposición en public para la aplicación.';
COMMENT ON VIEW public.period IS 'Períodos contables por entidad (abierto/cerrado).';
COMMENT ON VIEW public.currency IS 'Catálogo de monedas.';
COMMENT ON VIEW public.account IS 'Plan de cuentas por entidad (elemento y naturaleza débito/crédito).';
COMMENT ON VIEW public.entry IS 'Asientos del libro diario con datos de entidad y período (solo lectura).';
COMMENT ON VIEW public.entry_line IS 'Líneas de asientos con código y nombre de cuenta (solo lectura).';
COMMENT ON VIEW public.balance IS 'Saldos por entidad, período y cuenta (mayor).';
COMMENT ON VIEW public.statement_financial_position IS 'Agregación por elemento para estado de situación financiera (IAS 1.32).';
COMMENT ON VIEW public.statement_result IS 'Agregación por elemento para estado de resultado (IAS 1.32).';
COMMENT ON VIEW public.trial_balance IS 'Balance de comprobación: todas las cuentas por entidad y período con totales débito/crédito.';

-- Permisos: prodaric puede leer estas vistas
GRANT SELECT ON public.entity TO prodaric;
GRANT SELECT ON public.period TO prodaric;
GRANT SELECT ON public.currency TO prodaric;
GRANT SELECT ON public.account TO prodaric;
GRANT SELECT ON public.entry TO prodaric;
GRANT SELECT ON public.entry_line TO prodaric;
GRANT SELECT ON public.balance TO prodaric;
GRANT SELECT ON public.statement_financial_position TO prodaric;
GRANT SELECT ON public.statement_result TO prodaric;
GRANT SELECT ON public.trial_balance TO prodaric;
