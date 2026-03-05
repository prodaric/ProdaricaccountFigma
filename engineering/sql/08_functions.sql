-- Prodaric Accounting: funciones API en public (SECURITY DEFINER para escribir en ledger)
-- register_entry, create_reversal_entry, close_period. Ejecutar como prodaric_sys.
-- Requiere extensión pgcrypto para checksum SHA-256.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Registrar un asiento en ledger (valida partida doble, período abierto, cuentas de la entidad)
CREATE OR REPLACE FUNCTION public.register_entry(
  p_entity_id   uuid,
  p_period_id   uuid,
  p_reference   text,
  p_description text,
  p_entry_date  date,
  p_lines       jsonb,
  p_reversal_of_id uuid DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, ledger, accounting
AS $$
DECLARE
  v_entry_id       uuid;
  v_line           jsonb;
  v_ord            int := 0;
  v_sum_debit      numeric(19,4) := 0;
  v_sum_credit     numeric(19,4) := 0;
  v_period_ok      boolean;
  v_from_date      date;
  v_to_date        date;
  v_entity_ok      boolean;
  v_normal_balance public.normal_balance;
  v_amt_debit      numeric(19,4);
  v_amt_credit     numeric(19,4);
  v_payload        text;
BEGIN
  -- Validar período abierto, pertenece a la entidad y obtener rango de fechas
  SELECT (p.entity_id = p_entity_id AND p.status = 'open'), p.from_date, p.to_date
  INTO v_period_ok, v_from_date, v_to_date
  FROM accounting.period p
  WHERE p.id = p_period_id;
  IF NOT v_period_ok THEN
    RAISE EXCEPTION 'period_closed_or_invalid: period must be open and belong to entity';
  END IF;
  IF p_entry_date < v_from_date OR p_entry_date > v_to_date THEN
    RAISE EXCEPTION 'entry_date_out_of_period: entry_date must be between period from_date and to_date';
  END IF;

  -- Validar partida doble sobre p_lines
  FOR v_line IN SELECT * FROM jsonb_array_elements(p_lines)
  LOOP
    v_sum_debit  := v_sum_debit  + COALESCE((v_line->>'amount_debit')::numeric(19,4), 0);
    v_sum_credit := v_sum_credit + COALESCE((v_line->>'amount_credit')::numeric(19,4), 0);
  END LOOP;
  IF abs(v_sum_debit - v_sum_credit) > 0.0001 THEN
    RAISE EXCEPTION 'double_entry_invalid: sum(debit) must equal sum(credit)';
  END IF;
  IF v_sum_debit <= 0 THEN
    RAISE EXCEPTION 'double_entry_invalid: at least one line with positive amount required';
  END IF;

  -- Insertar cabecera
  INSERT INTO ledger.entry (entity_id, period_id, reference, description, entry_date, reversal_of_id)
  VALUES (p_entity_id, p_period_id, p_reference, p_description, p_entry_date, p_reversal_of_id)
  RETURNING id INTO v_entry_id;

  -- Insertar líneas y validar que cada cuenta pertenezca a la entidad y respete normal_balance
  FOR v_line IN SELECT * FROM jsonb_array_elements(p_lines)
  LOOP
    v_ord := v_ord + 1;
    SELECT (a.entity_id = p_entity_id), a.normal_balance
    INTO v_entity_ok, v_normal_balance
    FROM accounting.account a
    WHERE a.id = (v_line->>'account_id')::uuid;
    IF NOT v_entity_ok THEN
      RAISE EXCEPTION 'account_invalid: account % does not belong to entity', v_line->>'account_id';
    END IF;
    v_amt_debit  := COALESCE((v_line->>'amount_debit')::numeric(19,4), 0);
    v_amt_credit := COALESCE((v_line->>'amount_credit')::numeric(19,4), 0);
    IF v_normal_balance = 'debit' THEN
      IF v_amt_credit > 0.0001 OR v_amt_debit <= 0 THEN
        RAISE EXCEPTION 'account_normal_balance: account has normal balance debit; line must have debit amount only';
      END IF;
    ELSIF v_normal_balance = 'credit' THEN
      IF v_amt_debit > 0.0001 OR v_amt_credit <= 0 THEN
        RAISE EXCEPTION 'account_normal_balance: account has normal balance credit; line must have credit amount only';
      END IF;
    END IF;
    INSERT INTO ledger.entry_line (entry_id, account_id, amount_debit, amount_credit, line_order)
    VALUES (v_entry_id, (v_line->>'account_id')::uuid, v_amt_debit, v_amt_credit, v_ord);
  END LOOP;

  -- Payload para checksum: id + campos cabecera + líneas ordenadas
  SELECT string_agg(
    v_entry_id::text || p_entity_id::text || p_period_id::text || COALESCE(p_reference,'') || p_description || p_entry_date::text ||
    (el.account_id::text || el.amount_debit::text || el.amount_credit::text),
    '' ORDER BY el.line_order
  ) INTO v_payload
  FROM ledger.entry_line el
  WHERE el.entry_id = v_entry_id;

  UPDATE ledger.entry
  SET checksum = encode(digest(v_entry_id::text || v_payload, 'sha256'), 'hex')
  WHERE id = v_entry_id;

  RETURN v_entry_id;
END;
$$;

COMMENT ON FUNCTION public.register_entry(uuid,uuid,text,text,date,jsonb,uuid) IS
  'Registra un asiento en ledger validando partida doble, período abierto, entry_date en rango del período y normal_balance por línea. Solo escritura vía esta función.';

-- Crear asiento de reversa (mismo período, líneas invertidas)
CREATE OR REPLACE FUNCTION public.create_reversal_entry(
  p_entry_id      uuid,
  p_reversal_date date,
  p_description   text DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, ledger, accounting
AS $$
DECLARE
  v_orig    ledger.entry%ROWTYPE;
  v_line    record;
  v_lines   jsonb := '[]'::jsonb;
BEGIN
  SELECT * INTO v_orig FROM ledger.entry WHERE id = p_entry_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'entry_not_found: %', p_entry_id;
  END IF;

  FOR v_line IN
    SELECT account_id, amount_debit, amount_credit
    FROM ledger.entry_line
    WHERE entry_id = p_entry_id
    ORDER BY line_order
  LOOP
    v_lines := v_lines || jsonb_build_array(jsonb_build_object(
      'account_id', v_line.account_id,
      'amount_debit', v_line.amount_credit,
      'amount_credit', v_line.amount_debit
    ));
  END LOOP;

  RETURN public.register_entry(
    v_orig.entity_id,
    v_orig.period_id,
    v_orig.reference,
    COALESCE(p_description, 'Reversal of ' || v_orig.reference),
    p_reversal_date,
    v_lines,
    p_entry_id
  );
END;
$$;

COMMENT ON FUNCTION public.create_reversal_entry(uuid,date,text) IS
  'Crea un asiento de reversa (débitos/créditos invertidos) sin borrar el original. Ledger inmutable.';

-- Cerrar período (solo si está abierto; opcionalmente valida ecuación contable Assets = Liabilities + Equity)
CREATE OR REPLACE FUNCTION public.close_period(p_period_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, accounting
AS $$
DECLARE
  v_entity_id uuid;
  v_sum       numeric(19,4);
BEGIN
  SELECT entity_id INTO v_entity_id FROM accounting.period WHERE id = p_period_id AND status = 'open';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'period_not_open: period % is already closed or does not exist', p_period_id;
  END IF;

  -- Validar ecuación contable: suma de saldos (asset + liability + equity) debe ser 0
  SELECT COALESCE(SUM(balance), 0) INTO v_sum
  FROM accounting.balance
  WHERE entity_id = v_entity_id AND period_id = p_period_id
    AND element IN ('asset', 'liability', 'equity');
  IF abs(v_sum) > 0.0001 THEN
    RAISE EXCEPTION 'accounting_equation_invalid: assets - liabilities - equity = % (must be 0 to close period)', v_sum;
  END IF;

  UPDATE accounting.period
  SET status = 'closed'
  WHERE id = p_period_id;
END;
$$;

COMMENT ON FUNCTION public.close_period(uuid) IS
  'Cierra un período contable validando ecuación contable (activos = pasivos + patrimonio). A partir de entonces no se pueden registrar asientos en ese período.';

-- Crear entidad de reporte (solo vía función para usuario prodaric)
CREATE OR REPLACE FUNCTION public.create_entity(
  p_code                  text,
  p_name                  text,
  p_jurisdiction          text DEFAULT NULL,
  p_functional_currency_id uuid
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, accounting
AS $$
DECLARE
  v_id uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM accounting.currency WHERE id = p_functional_currency_id) THEN
    RAISE EXCEPTION 'currency_not_found: functional_currency_id % does not exist', p_functional_currency_id;
  END IF;
  INSERT INTO accounting.entity (code, name, jurisdiction, functional_currency_id)
  VALUES (p_code, p_name, p_jurisdiction, p_functional_currency_id)
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;

COMMENT ON FUNCTION public.create_entity(text,text,text,uuid) IS
  'Crea una entidad de reporte. Solo escritura en accounting vía esta función.';

-- Actualizar entidad
CREATE OR REPLACE FUNCTION public.update_entity(
  p_id                    uuid,
  p_code                  text DEFAULT NULL,
  p_name                  text DEFAULT NULL,
  p_jurisdiction          text DEFAULT NULL,
  p_functional_currency_id uuid DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, accounting
AS $$
BEGIN
  IF p_functional_currency_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM accounting.currency WHERE id = p_functional_currency_id) THEN
    RAISE EXCEPTION 'currency_not_found: functional_currency_id % does not exist', p_functional_currency_id;
  END IF;
  UPDATE accounting.entity
  SET
    code                  = COALESCE(p_code, code),
    name                  = COALESCE(p_name, name),
    jurisdiction          = COALESCE(p_jurisdiction, jurisdiction),
    functional_currency_id = COALESCE(p_functional_currency_id, functional_currency_id),
    updated_at            = now()
  WHERE id = p_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'entity_not_found: %', p_id;
  END IF;
END;
$$;

COMMENT ON FUNCTION public.update_entity(uuid,text,text,text,uuid) IS
  'Actualiza una entidad de reporte. Solo escritura en accounting vía esta función.';

-- Crear período contable
CREATE OR REPLACE FUNCTION public.create_period(
  p_entity_id  uuid,
  p_from_date  date,
  p_to_date    date
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, accounting
AS $$
DECLARE
  v_id uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM accounting.entity WHERE id = p_entity_id) THEN
    RAISE EXCEPTION 'entity_not_found: %', p_entity_id;
  END IF;
  IF p_to_date < p_from_date THEN
    RAISE EXCEPTION 'period_invalid: to_date must be >= from_date';
  END IF;
  INSERT INTO accounting.period (entity_id, from_date, to_date, status)
  VALUES (p_entity_id, p_from_date, p_to_date, 'open'::public.period_status)
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;

COMMENT ON FUNCTION public.create_period(uuid,date,date) IS
  'Crea un período contable abierto para la entidad. Solo escritura en accounting vía esta función.';

-- Crear cuenta en el plan de cuentas
CREATE OR REPLACE FUNCTION public.create_account(
  p_entity_id      uuid,
  p_code           text,
  p_name           text,
  p_element        public.account_element,
  p_normal_balance public.normal_balance,
  p_parent_id      uuid DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, accounting
AS $$
DECLARE
  v_id uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM accounting.entity WHERE id = p_entity_id) THEN
    RAISE EXCEPTION 'entity_not_found: %', p_entity_id;
  END IF;
  IF p_parent_id IS NOT NULL THEN
    IF NOT EXISTS (SELECT 1 FROM accounting.account WHERE id = p_parent_id AND entity_id = p_entity_id) THEN
      RAISE EXCEPTION 'parent_account_invalid: parent must belong to same entity';
    END IF;
  END IF;
  INSERT INTO accounting.account (entity_id, code, name, element, normal_balance, parent_id)
  VALUES (p_entity_id, p_code, p_name, p_element, p_normal_balance, p_parent_id)
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;

COMMENT ON FUNCTION public.create_account(uuid,text,text,public.account_element,public.normal_balance,uuid) IS
  'Crea una cuenta en el plan de cuentas de la entidad. Solo escritura en accounting vía esta función.';

-- Actualizar cuenta
CREATE OR REPLACE FUNCTION public.update_account(
  p_id             uuid,
  p_code           text DEFAULT NULL,
  p_name           text DEFAULT NULL,
  p_element        public.account_element DEFAULT NULL,
  p_normal_balance public.normal_balance DEFAULT NULL,
  p_parent_id      uuid DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, accounting
AS $$
BEGIN
  IF p_parent_id IS NOT NULL THEN
    IF NOT EXISTS (
      SELECT 1 FROM accounting.account a
      WHERE a.id = p_parent_id AND a.entity_id = (SELECT entity_id FROM accounting.account WHERE id = p_id)
    ) THEN
      RAISE EXCEPTION 'parent_account_invalid: parent must belong to same entity';
    END IF;
  END IF;
  UPDATE accounting.account
  SET
    code           = COALESCE(p_code, code),
    name           = COALESCE(p_name, name),
    element        = COALESCE(p_element, element),
    normal_balance = COALESCE(p_normal_balance, normal_balance),
    parent_id      = COALESCE(p_parent_id, parent_id),
    updated_at     = now()
  WHERE id = p_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'account_not_found: %', p_id;
  END IF;
END;
$$;

COMMENT ON FUNCTION public.update_account(uuid,text,text,public.account_element,public.normal_balance,uuid) IS
  'Actualiza una cuenta del plan de cuentas. Solo escritura en accounting vía esta función.';

GRANT EXECUTE ON FUNCTION public.register_entry(uuid,uuid,text,text,date,jsonb,uuid) TO prodaric;
GRANT EXECUTE ON FUNCTION public.create_reversal_entry(uuid,date,text) TO prodaric;
GRANT EXECUTE ON FUNCTION public.close_period(uuid) TO prodaric;
GRANT EXECUTE ON FUNCTION public.create_entity(text,text,text,uuid) TO prodaric;
GRANT EXECUTE ON FUNCTION public.update_entity(uuid,text,text,text,uuid) TO prodaric;
GRANT EXECUTE ON FUNCTION public.create_period(uuid,date,date) TO prodaric;
GRANT EXECUTE ON FUNCTION public.create_account(uuid,text,text,public.account_element,public.normal_balance,uuid) TO prodaric;
GRANT EXECUTE ON FUNCTION public.update_account(uuid,text,text,public.account_element,public.normal_balance,uuid) TO prodaric;
