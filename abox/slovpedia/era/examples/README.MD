# Slovpedia – ilustračné dáta podľa modelu ERA (železnice)

---

## 1. Prehľad URI entít

Táto kapitola dokumentuje URI entít použité v ilustračných TTL súboroch Slovpedie podľa ontológie ERA.  
Zameriava sa na explicitné zdokumentovanie použitých ontológií (TBOX) a konvencie tvorby URI pre konkrétne objekty železničnej infraštruktúry (ABOX).

---

## 1.1 TBOX – použité ontológie

Zoznam ontológií použitých v TTL súboroch, uvedený v technickej podobe zodpovedajúcej deklaráciám prefixov:

```turtle
@prefix rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd:  <http://www.w3.org/2001/XMLSchema#> .
@prefix skos: <http://www.w3.org/2004/02/skos/core#> .

@prefix owl:  <http://www.w3.org/2002/07/owl#> .
@prefix sh:   <http://www.w3.org/ns/shacl#> .

@prefix era:  <http://data.europa.eu/949/> .
```
---
## 1.2 CBOX – použité kontrolované slovníky
```
http://publications.europa.eu/resource/authority/country/
http://data.europa.eu/949/concepts/
```
---
## 1.3 ABOX – URI konkrétnych objektov

Táto časť dokumentuje konkrétne URI objektov, ktoré reprezentujú reálne existujúce železničné objekty.
Zoznam slúži ako referencia pre tvorbu URI a demonštruje používanú URI konvenciu pre ERA-kompatibilné dáta v prostredí Slovenskej republiky.

1.3.1 Prehľad URI objektov
Národná trať
```
https://slovpedia.eu/id/era/national-line/180
```

Úsek trate
```
https://slovpedia.eu/id/era/section-of-line/180-zilina-vrutky
```

Operačný bod
```
https://slovpedia.eu/id/era/operational-point/zilina-01
```

Nástupište
```
https://slovpedia.eu/id/era/platform/zilina-1
```

Odstavná koľaj
```
https://slovpedia.eu/id/era/siding/zilina-01
```

Tunel
```
https://slovpedia.eu/id/era/tunnel/strecno-I
```
