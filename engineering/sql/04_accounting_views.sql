-- Prodaric Accounting: vistas en schema accounting derivadas de ledger y tablas de referencia
-- Solo lectura. La aplicación accede vía vistas en public que seleccionan de aquí.
-- Ejecutar conectado a prodaric_accounting como prodaric_sys: psql -d prodaric_accounting -U prodaric_sys -f sql/04_accounting_views.sql

-- 1. Vista asiento (cabecera + entidad y período)
CREATE OR REPLACE VIEW accounting.entry AS
SELECT
  e.id,
  e.entity_id,
  e.period_id,
  e.reference,
  e.description,
  e.entry_date,
  e.reversal_of_id,
  e.checksum,
  e.created_at,
  ent.code AS entity_code,
  ent.name AS entity_name,
  p.from_date AS period_from,
  p.to_date AS period_to,
  p.status AS period_status
FROM ledger.entry e
JOIN accounting.entity ent ON ent.id = e.entity_id
JOIN accounting.period p ON p.id = e.period_id;

COMMENT ON VIEW accounting.entry IS 'Asientos del libro diario con datos de entidad y período (solo lectura).';

-- 2. Vista línea de asiento (con cuenta)
CREATE OR REPLACE VIEW accounting.entry_line AS
SELECT
  el.id,
  el.entry_id,
  el.account_id,
  el.amount_debit,
  el.amount_credit,
  el.line_order,
  a.code AS account_code,
  a.name AS account_name,
  a.element AS account_element
FROM ledger.entry_line el
JOIN accounting.account a ON a.id = el.account_id;

COMMENT ON VIEW accounting.entry_line IS 'Líneas de asientos con código y nombre de cuenta (solo lectura).';

-- 3. Vista saldos por cuenta y período (balance / mayor)
CREATE OR REPLACE VIEW accounting.balance AS
SELECT
  e.entity_id,
  e.period_id,
  el.account_id,
  a.code AS account_code,
  a.name AS account_name,
  a.element,
  a.normal_balance,
  COALESCE(SUM(el.amount_debit), 0)::numeric(19,4) AS total_debit,
  COALESCE(SUM(el.amount_credit), 0)::numeric(19,4) AS total_credit,
  COALESCE(SUM(el.amount_debit), 0) - COALESCE(SUM(el.amount_credit), 0) AS balance
FROM ledger.entry e
JOIN ledger.entry_line el ON el.entry_id = e.id
JOIN accounting.account a ON a.id = el.account_id
GROUP BY e.entity_id, e.period_id, el.account_id, a.id, a.code, a.name, a.element, a.normal_balance;

COMMENT ON VIEW accounting.balance IS 'Saldos por entidad, período y cuenta (mayor). balance = total_debit - total_credit.';

-- 4. Estado de situación financiera por elemento (IAS 1.32: sin compensación; activos, pasivos y patrimonio en líneas separadas)
CREATE OR REPLACE VIEW accounting.statement_financial_position AS
SELECT
  entity_id,
  period_id,
  element,
  SUM(balance) AS total_balance
FROM accounting.balance
WHERE element IN ('asset', 'liability', 'equity')
GROUP BY entity_id, period_id, element;

COMMENT ON VIEW accounting.statement_financial_position IS 'Agregación por elemento para estado de situación financiera (IAS 1.32: sin compensar activos con pasivos).';

-- 5. Estado de resultado por elemento (IAS 1.32: sin compensación; ingresos y gastos en líneas separadas)
CREATE OR REPLACE VIEW accounting.statement_result AS
SELECT
  entity_id,
  period_id,
  element,
  SUM(balance) AS total_balance
FROM accounting.balance
WHERE element IN ('income', 'expense')
GROUP BY entity_id, period_id, element;

COMMENT ON VIEW accounting.statement_result IS 'Agregación por elemento para estado de resultado (IAS 1.32: sin compensar ingresos con gastos).';

-- 6. Balance de comprobación (trial balance): todas las cuentas de la entidad por período con total débito/crédito (0 si no hay movimiento)
CREATE OR REPLACE VIEW accounting.trial_balance AS
SELECT
  a.entity_id,
  p.id AS period_id,
  a.id AS account_id,
  a.code AS account_code,
  a.name AS account_name,
  a.element,
  a.normal_balance,
  COALESCE(b.total_debit, 0)::numeric(19,4) AS total_debit,
  COALESCE(b.total_credit, 0)::numeric(19,4) AS total_credit,
  COALESCE(b.balance, 0)::numeric(19,4) AS balance
FROM accounting.account a
JOIN accounting.period p ON p.entity_id = a.entity_id
LEFT JOIN accounting.balance b ON b.entity_id = a.entity_id AND b.period_id = p.id AND b.account_id = a.id;

COMMENT ON VIEW accounting.trial_balance IS 'Balance de comprobación: todas las cuentas por entidad y período con total_debit/total_credit (0 si no hay movimiento).';
