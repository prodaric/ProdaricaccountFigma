# Modelo de negocio de ejemplo: Corporación Coderic

Este documento describe el modelo de negocio de ejemplo usado en los wireframes y en la documentación de Prodaric Accounting. Se asume arquitectura *multi-tenant* y un grupo de tres entidades legales.

## Dominios de referencia

La información pública de Coderic está disponible en:

- https://coderic.com
- https://coderic.org
- https://coderic.net
- https://coderic.co
- https://coderic.cloud
- https://coderic.store
- https://coderic.dev

## Arquitectura multi-tenant

Cada *tenant* corresponde a una entidad legal de reporte (una por jurisdicción en el ejemplo). Los usuarios se autentican mediante IdP externo (OAuth2/OIDC) y tienen acceso a uno o más tenants según su asignación de roles (ver design.md §2.8).

## Tres entidades legales (ejemplo)

### Coderic SAS (Colombia)

- *Forma jurídica:* Sociedad por Acciones Simplificada.
- *Sedes:* Distintas ciudades principales de Colombia.
- *Reporte:* NIIF/Colombia.
- *Moneda funcional:* p. ej. COP.

### Coderic SA (Venezuela)

- *Forma jurídica:* Sociedad Anónima.
- *Sedes:* Distintas ciudades principales de Venezuela.
- *Reporte:* Normativa local / NIIF.
- *Moneda funcional:* Según configuración.

### Coderic Corporation (Estados Unidos)

- *Forma jurídica:* Corporation.
- *Sedes:* Distintas ciudades de Estados Unidos.
- *Reporte:* US GAAP o NIIF según caso.
- *Moneda funcional:* USD.

## Productos y servicios

*Siete* productos/servicios en la nube, entre ellos (según dominios Coderic): Prodaric CRM, ERP, HRM, CCR, LCM, CMS y un séptimo servicio. Los datos de clientes pueden corresponder a *cualquier país de Latinoamérica* (multi-país, multi-moneda donde aplique).

## Sector y actividad

Casa de software; ingeniería de software open source desde 2004. Portales: team.coderic.org (incubadora, desarrollo), coderic.cloud (IaaS/PaaS/SaaS), coderic.co (Fintech), coderic.net (APIs, MQTT).

## Plan de cuentas (por tenant)

Las cinco cuentas principales con subcuentas coherentes con software en la nube: cash, receivables, deferred revenue, payables, equity, revenue from services/subscriptions, cost of sales, payroll, infraestructura.

## Operaciones de ejemplo

Por entidad/tenant: venta de servicios/suscripción, pago a proveedor, nómina, costos de infraestructura. Los wireframes ilustran la selección de entidad y asientos por tenant.
