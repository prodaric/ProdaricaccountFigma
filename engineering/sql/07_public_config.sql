-- Prodaric Accounting: tablas de configuración en public
-- Tipos de documento, parámetros por entidad (moneda de presentación, etc.).
-- Ejecutar conectado a prodaric_accounting como prodaric_sys: psql -d prodaric_accounting -U prodaric_sys -f sql/07_public_config.sql

-- 1. Tipo de documento (referencia para asientos: INV, REC, PAY, etc.)
CREATE TABLE IF NOT EXISTS public.document_type (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code        text NOT NULL UNIQUE,
  name        text NOT NULL,
  created_at  timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.document_type IS 'Tipos de documento para referencia de asientos (factura, recibo, pago, etc.).';

-- 2. Configuración por entidad (moneda de presentación, parámetros)
CREATE TABLE IF NOT EXISTS public.entity_config (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_id   uuid NOT NULL REFERENCES accounting.entity(id) ON DELETE CASCADE UNIQUE,
  presentation_currency_id uuid REFERENCES accounting.currency(id),
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.entity_config IS 'Parámetros por entidad: moneda de presentación, etc.';

CREATE INDEX IF NOT EXISTS idx_entity_config_entity ON public.entity_config (entity_id);

-- La aplicación puede leer y, donde corresponda, escribir configuración
GRANT SELECT ON public.document_type TO prodaric;
GRANT SELECT, INSERT, UPDATE ON public.entity_config TO prodaric;
