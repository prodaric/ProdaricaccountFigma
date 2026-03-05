# Arquitectura

Diagramas de flujo y esquema de schemas de Prodaric Accounting (multi-tenant). Referencia: design.md y plan.md en la raíz del repositorio.

El alcance de pantallas documentado en [Wireframes](wireframes.md) incluye, además del journal y la consulta del diario/saldos/reportes, las pantallas ampliadas: dashboard, detalle de asiento, balance de comprobación (trial balance), cierre de período, administración de entidad y período, reversión de asiento (nuevo asiento de reversa vía API, sin borrar el original) y consulta de audit log. Los flujos de escritura (registro de asiento, reversión, cierre) pasan por funciones en `public` hacia `ledger` o tablas de configuración; las consultas y reportes usan las vistas derivadas de `accounting`.

## Flujo de registro de asiento (multi-tenant)

El usuario selecciona tenant/entidad, completa el formulario journal y la API llama a `register_entry` con tenant/entity_id. Tras validación NIIF se escribe en ledger (entry + entry_line + checksum); la respuesta es éxito o error.

```mermaid
flowchart LR
  User[User]
  Form[Journal form]
  API[register_entry API]
  Validate[Validate NIIF]
  Ledger[(ledger)]
  Response[Success / Error]

  User -->|select tenant| Form
  Form -->|entity_id + lines| API
  API --> Validate
  Validate -->|valid| Ledger
  Ledger --> Response
  Validate -->|invalid| Response
  Response --> User
```

## Esquema de schemas

Nodos: public, ledger, accounting, sustainability. El modelo incluye tenant/entity_id donde corresponde. Solo lectura desde public hacia accounting/ledger; escritura solo vía función hacia ledger.

```mermaid
flowchart TB
  subgraph publicSchema [public]
    Functions[Functions / API]
    Views[Views]
    Config[Configurable tables]
  end

  subgraph ledgerSchema [ledger]
    Entry[entry]
    EntryLine[entry_line]
    Checksum[checksum]
  end

  subgraph accountingSchema [accounting]
    ViewEntry[entry view]
    Balance[balance view]
    Account[account view]
  end

  subgraph sustainabilitySchema [sustainability]
    Metrics[metrics]
  end

  Functions -->|"write only via SECURITY DEFINER"| Entry
  Functions --> EntryLine
  Entry --> ViewEntry
  EntryLine --> ViewEntry
  ViewEntry --> Balance
  Views -->|read| ViewEntry
  Views -->|read| Balance
  Views -->|read| Account
  Functions -->|read/write via API| Config
  publicSchema -.->|"entity_id / tenant"| ledgerSchema
```

## Flujo de lectura

El usuario filtra por tenant/entidad; la aplicación consulta vistas (entry, balance, account); las vistas en accounting están derivadas de ledger. No hay escritura en este flujo.

```mermaid
flowchart LR
  User[User]
  Filter[Filter by tenant/entity]
  ViewQuery[Query views]
  AccountingViews[accounting views]
  LedgerData[(ledger)]

  User --> Filter
  Filter --> ViewQuery
  ViewQuery --> AccountingViews
  AccountingViews -->|derived from| LedgerData
  LedgerData --> AccountingViews
  AccountingViews --> ViewQuery
  ViewQuery --> User
```
