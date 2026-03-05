# Recursos: esquemas XSD/XML de estándares IFRS/NIIF

Esta carpeta contiene (o debe contener, tras descarga) los esquemas XSD y paquetes XML/XBRL de los estándares que Prodaric Accounting aplica según el diseño del proyecto. Referencia: [design.md](../design.md) secciones 1 y 6.

## Contenido por subcarpeta

| Subcarpeta | Estándar | Versión | Uso en el proyecto |
|------------|----------|---------|--------------------|
| `ifrs-accounting-taxonomy/` | IFRS Accounting Taxonomy | 2024 (1 ene 2024) | NIIF Contabilidad: elementos, presentación (IAS 1), referencia para plan de cuentas y reportes. No sustituye el modelo transaccional. |
| `ifrs-sustainability-taxonomy/` | IFRS Sustainability Disclosure Taxonomy | 2024 (30 abr 2024) | IFRS S1 (revelaciones generales) e IFRS S2 (climáticas). Misma entidad de reporte que los estados financieros. |
| `xbrl-base/` (opcional) | XBRL 2.1 | — | Esquema base si hace falta para validación local de instancias o extensiones. |

## Cómo obtener las taxonomías

### Opción 1: Script automático

Desde la raíz del repositorio:

```bash
./scripts/download-taxonomies.sh
```

Si el sitio de la IFRS Foundation devuelve HTML (p. ej. aceptación de términos o cookies), el script indicará que la descarga no fue un ZIP y mostrará los enlaces para descarga manual.

### Opción 2: Descarga manual

1. **IFRS Accounting Taxonomy 2024**  
   Página oficial: [IFRS Accounting Taxonomy 2024](https://www.ifrs.org/issued-standards/ifrs-taxonomy/ifrs-accounting-taxonomy-2024).  
   Descargar el paquete ZIP que ofrece la página y extraer su contenido en `resources/ifrs-accounting-taxonomy/` (conservando la estructura de carpetas del ZIP).

2. **IFRS Sustainability Disclosure Taxonomy 2024**  
   Página oficial: [IFRS Sustainability Disclosure Taxonomy 2024](https://www.ifrs.org/issued-standards/ifrs-sustainability-taxonomy/ifrs-sustainability-disclosure-taxonomy-2024).  
   Descargar el paquete ZIP y extraer su contenido en `resources/ifrs-sustainability-taxonomy/`.

## Términos de uso y copyright

Las taxonomías IFRS son propiedad de la **IFRS Foundation**. Su uso en este proyecto es para **referencia y desarrollo** del producto Prodaric Accounting, alineado a los estándares. No se redistribuyen con fines comerciales como taxonomía independiente sin revisar la licencia y términos de uso publicados por la IFRS Foundation en sus sitios oficiales.

## Validación de instancias o extensiones

Para validar documentos de instancia XBRL o extensiones de taxonomía contra estos XSD se pueden usar herramientas estándar (p. ej. validadores XBRL o librerías que carguen los esquemas desde estas rutas). Los entry points típicos son:

- Contabilidad: dentro de `ifrs-accounting-taxonomy/`, el archivo de entrada (entry point) para Full IFRS suele nombrarse de forma similar a `full_ifrs_entry_point_2024-03-27.xsd`.
- Sostenibilidad: dentro de `ifrs-sustainability-taxonomy/`, el entry point para IFRS S1/S2 suele nombrarse de forma similar a `ifrs_sds_2024-04-26.xsd`.

Las rutas exactas dependen de la estructura del ZIP descargado (p. ej. subcarpetas por fecha).
