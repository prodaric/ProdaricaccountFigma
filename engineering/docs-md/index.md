# Prodaric Accounting

Sistema de contabilidad en PostgreSQL alineado a estándares IFRS/NIIF (contabilidad y sostenibilidad) y preparado para generar información auditable según IAASB (ISA).

## Propósito

Prodaric Accounting es un sistema de administración contable multi-tenant que mantiene el libro diario en un ledger inmutable, expone estados y reportes mediante vistas derivadas y cumple reglas NIIF/ISA. La aplicación solo lee mediante vistas en `public` y solo escribe mediante funciones en `public` (p. ej. registro de asientos, reversión, cierre de período). El diseño completo está en `design.md` y `plan.md` en la raíz del repositorio.

## Implementación

El orden de ejecución de los scripts SQL está documentado en `sql/README.md`. El contrato de funciones y vistas que debe respetar la capa de aplicación está en `plan.md` §3. Las convenciones del modelo de datos (inglés, singular, FK `tabla_id`, COMMENT en español) están en `.cursor/rules/data-model.mdc`. La documentación técnica de diseño y plan vive en la raíz del repo (`design.md`, `plan.md`).

## Enlaces

- [Modelo de negocio de ejemplo](example-business-model.md) — Corporación Coderic (multi-tenant: SAS/Colombia, SA/Venezuela, Corporation/USA).
- [Wireframes](wireframes.md) — Layouts globales y pantallas del sistema en ASCII: entidad/período, plan de cuentas, journal, diario, saldos, reportes, configuración; pantallas ampliadas (dashboard, detalle de asiento, balance de comprobación, cierre de período, administración entidad/período, reversión de asiento, audit log); opcional sostenibilidad.
- [Arquitectura](architecture.md) — Diagramas Mermaid: flujo de registro, schemas, flujo de lectura.

## Referencia

El diseño y el plan de implementación del proyecto están en la raíz del repositorio: `design.md` y `plan.md`.
