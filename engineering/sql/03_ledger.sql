-- Prodaric Accounting: tablas inmutables del journal en schema ledger
-- Solo escritura vía funciones en public (SECURITY DEFINER). Checksum para verificación.
-- Ejecutar conectado a prodaric_accounting como prodaric_sys: psql -d prodaric_accounting -U prodaric_sys -f sql/03_ledger.sql

-- 1. Asiento (cabecera)
CREATE TABLE IF NOT EXISTS ledger.entry (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_id    uuid NOT NULL REFERENCES accounting.entity(id),
  period_id    uuid NOT NULL REFERENCES accounting.period(id),
  reference    text,
  description  text NOT NULL,
  entry_date   date NOT NULL,
  reversal_of_id uuid REFERENCES ledger.entry(id),
  checksum     text,
  created_at   timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE ledger.entry IS 'Asiento inmutable del libro diario. Una fila por transacción; las líneas en entry_line.';
COMMENT ON COLUMN ledger.entry.checksum IS 'Hash (SHA-256 hex) del payload para verificación de integridad.';
COMMENT ON COLUMN ledger.entry.reversal_of_id IS 'Si es un asiento de reversa, referencia al asiento original.';

-- 2. Línea de asiento (débito/crédito por cuenta)
CREATE TABLE IF NOT EXISTS ledger.entry_line (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entry_id      uuid NOT NULL REFERENCES ledger.entry(id) ON DELETE CASCADE,
  account_id    uuid NOT NULL REFERENCES accounting.account(id),
  amount_debit  numeric(19,4) NOT NULL DEFAULT 0 CHECK (amount_debit >= 0),
  amount_credit numeric(19,4) NOT NULL DEFAULT 0 CHECK (amount_credit >= 0),
  line_order    int NOT NULL DEFAULT 0,
  CHECK (amount_debit >= 0 AND amount_credit >= 0 AND (amount_debit > 0 OR amount_credit > 0) AND (amount_debit = 0 OR amount_credit = 0))
);

COMMENT ON TABLE ledger.entry_line IS 'Líneas del asiento. Partida doble: por entry_id suma(amount_debit) = suma(amount_credit).';
COMMENT ON COLUMN ledger.entry_line.amount_debit IS 'Monto débito (>= 0).';
COMMENT ON COLUMN ledger.entry_line.amount_credit IS 'Monto crédito (>= 0).';

-- Partida doble a nivel de asiento (trigger o constraint): se valida en la función register_entry antes de insertar.
-- Constraint CHECK en la BD por si acaso: no se puede hacer CHECK que agregue otras filas; se hace en función.

CREATE INDEX IF NOT EXISTS idx_entry_entity_period ON ledger.entry (entity_id, period_id);
CREATE INDEX IF NOT EXISTS idx_entry_entry_date ON ledger.entry (entry_date);
CREATE INDEX IF NOT EXISTS idx_entry_line_entry ON ledger.entry_line (entry_id);
CREATE INDEX IF NOT EXISTS idx_entry_line_account ON ledger.entry_line (account_id);
