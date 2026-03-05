-- Prodaric Accounting: schema sustainability (métricas IFRS S1/S2)
-- Solo escritura por prodaric_sys; la aplicación lee/escribe vía vistas y funciones en public.
-- Ejecutar conectado a prodaric_accounting como prodaric_sys: psql -d prodaric_accounting -U prodaric_sys -f sql/10_sustainability.sql

CREATE TABLE IF NOT EXISTS sustainability.metric (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_id   uuid NOT NULL REFERENCES accounting.entity(id) ON DELETE CASCADE,
  period_id   uuid NOT NULL REFERENCES accounting.period(id) ON DELETE CASCADE,
  scope       text NOT NULL DEFAULT '' CHECK (scope IN ('', 'S1', 'S2', 'S3')),
  name        text NOT NULL,
  value       numeric(19,4),
  unit        text,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (entity_id, period_id, scope, name)
);

COMMENT ON TABLE sustainability.metric IS 'Métricas de sostenibilidad (IFRS S1/S2). Scope S1/S2/S3 para emisiones climáticas.';

CREATE INDEX IF NOT EXISTS idx_metric_entity_period ON sustainability.metric (entity_id, period_id);

-- Vista en public para que la aplicación lea (owner prodaric_sys)
CREATE OR REPLACE VIEW public.sustainability_metric AS
SELECT id, entity_id, period_id, scope, name, value, unit, created_at, updated_at
FROM sustainability.metric;

GRANT SELECT ON public.sustainability_metric TO prodaric;

-- Función para que la app escriba métricas (SECURITY DEFINER; validar permiso en capa API)
CREATE OR REPLACE FUNCTION public.upsert_sustainability_metric(
  p_entity_id uuid,
  p_period_id uuid,
  p_scope     text DEFAULT '',
  p_name      text,
  p_value     numeric(19,4),
  p_unit      text DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, sustainability, accounting
AS $$
DECLARE
  v_id uuid;
  v_scope text := COALESCE(NULLIF(trim(p_scope), ''), '');
BEGIN
  IF v_scope IS NOT NULL AND v_scope NOT IN ('S1', 'S2', 'S3') THEN
    v_scope := '';
  END IF;
  INSERT INTO sustainability.metric (entity_id, period_id, scope, name, value, unit)
  VALUES (p_entity_id, p_period_id, v_scope, p_name, p_value, p_unit)
  ON CONFLICT (entity_id, period_id, scope, name)
  DO UPDATE SET value = EXCLUDED.value, unit = COALESCE(EXCLUDED.unit, sustainability.metric.unit), updated_at = now()
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;

COMMENT ON FUNCTION public.upsert_sustainability_metric(uuid,uuid,text,text,numeric,text) IS
  'Inserta o actualiza una métrica de sostenibilidad. Autorización (sustainability:write) debe validarse en la API.';

GRANT EXECUTE ON FUNCTION public.upsert_sustainability_metric(uuid,uuid,text,text,numeric,text) TO prodaric;
