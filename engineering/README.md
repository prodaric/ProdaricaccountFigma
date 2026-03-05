# Prodaric Accounting

Contabilidad, Sostenibilidad y Auditoría.

## Propósito

Prodaric Accounting es un **sistema de administración contable** en PostgreSQL, multi-tenant, que mantiene el libro diario en un ledger inmutable, expone estados y reportes mediante vistas derivadas y está alineado a NIIF/IFRS (contabilidad y sostenibilidad) y a estándares de auditoría IAASB (ISA).

## Uso

- **Orden de ejecución de scripts:** Ver [sql/README.md](sql/README.md). Los scripts se ejecutan como superusuario `postgres` para crear la base y roles; el resto como `prodaric_sys` sobre la base `prodaric_accounting`. El modelo de auth (angelauth) se ejecuta entre el script 05 y el 06.
- **Conexión en runtime:** La aplicación se conecta con el usuario **`prodaric`** (solo schema `public`). Toda **lectura** se hace mediante vistas en `public`; toda **escritura** en ledger y sustainability se hace mediante funciones en `public` con `SECURITY DEFINER`. El usuario **`prodaric_sys`** se usa para migraciones y mantenimiento.

## Motivos de diseño

- **Inmutabilidad del ledger:** El journal es la única fuente de verdad; no se modifican ni borran asientos; se permiten solo asientos de reversa.
- **Partida doble y no compensación (IAS 1.32):** Restricciones en el modelo y en las funciones; presentación sin compensar activos con pasivos ni ingresos con gastos.
- **Trazabilidad para auditoría (ISA):** Checksums, registro de auditoría (audit_log) y controles que facilitan el encargo del auditor.
- **Auth externa:** La aplicación no gestiona contraseñas; se usa un IdP externo (OAuth2/OpenID Connect). En desarrollo, roles y permisos pueden residir en el schema `angelauth` (directorio angelauth/, no versionado).

## Forma de implementación

- **Schemas:** `ledger` (journal inmutable: entry, entry_line), `accounting` (solo vistas derivadas), `public` (API: funciones, vistas expuestas, tablas configurables), `sustainability` (métricas S1/S2). Opcional `angelauth` para identidad y RBAC en desarrollo.
- **Flujo:** La aplicación **solo lee** desde vistas en `public` (que leen de accounting/ledger). La aplicación **solo escribe** llamando a funciones en `public` (p. ej. `register_entry`, `create_reversal_entry`, `close_period`); esas funciones validan reglas NIIF y escriben en `ledger` o en tablas de configuración. Contrato detallado en [plan.md](plan.md) §3.

## Estándares aplicados

- **Modelo de datos:** Convenciones en [.cursor/rules/data-model.mdc](.cursor/rules/data-model.mdc): inglés, minúsculas, singular; FKs como `tabla_id`; COMMENT en español cuando ayude a explicar.
- **Negocio:** NIIF/IFRS (Marco Conceptual, IAS 1, no compensación), ISA (auditoría). Detalle en [design.md](design.md).

## Estructura del repositorio

| Carpeta / archivo | Descripción |
|-------------------|-------------|
| `sql/` | Scripts SQL en orden numerado (00–10) y [sql/README.md](sql/README.md) con propósito y orden de ejecución. |
| `docs/` | Documentación Antora (antora.yml, modules/ROOT/): wireframes, modelo de negocio, arquitectura. |
| `docs-md/` | Réplicas en Markdown de la documentación .adoc (para Figma y herramientas que no lean AsciiDoc). |
| `.cursor/rules/` | Reglas de desarrollo y calidad; en especial [data-model.mdc](.cursor/rules/data-model.mdc) para el modelo de datos. |
| [design.md](design.md) | Diseño completo: estándares, schemas, inmutabilidad, auth, contrato. |
| [plan.md](plan.md) | Plan de implementación y contrato API (funciones y vistas). |
| [figma.md](figma.md) | Instrucciones para Figma (IA o diseñador): prototipos UI para Prodaric Framework/Theia. |
| [REQUERIMIENTOS-SOFTWARE.md](REQUERIMIENTOS-SOFTWARE.md) | Esbozo del documento de Requerimientos de Software (alcance, objetivos, RF, RNF, restricciones). |

## Enlaces

- **Diseño del proyecto:** [design.md](design.md)
- **Plan de implementación:** [plan.md](plan.md)
- **Requerimientos de Software (esbozo):** [REQUERIMIENTOS-SOFTWARE.md](REQUERIMIENTOS-SOFTWARE.md)
- **Instrucciones para Figma (prototipos UI):** [figma.md](figma.md)
- **Contexto Cursor (fuente de verdad para diseño/desarrollo):** [.cursor/README.md](.cursor/README.md)
- **Documentación Antora:** El contenido del componente está en `docs/` (antora.yml + modules/ROOT/...). Para publicar en docs.coderic.org se usa un playbook externo (antora-playbook.yml) que debe incluir este repositorio como content source apuntando a la carpeta `docs/`.
