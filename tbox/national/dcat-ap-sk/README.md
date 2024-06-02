# Rozhranie katalógu otvorených dát DCAT-AP-SK 3
Metadátový štandard založený na [Data Catalog Vocabulary (DCAT) - Version 3][DCAT3] a jeho aplikačnom profile [DCAT-AP 3] pre popis datasetov a pre rozhranie Národného (NKOD) a lokálných katalógov otvorených dát (LKOD).

[Zobrazenie štandardu](https://htmlpreview.github.io/?https://github.com/slovak-egov/centralny-model-udajov/blob/develop/tbox/national/dcat-ap-sk/index.html)

[DCAT3]: https://www.w3.org/TR/vocab-dcat-3/ "Data Catalog Vocabulary (DCAT) - Version 3"
[DCAT-AP-3]: https://joinup.ec.europa.eu/collection/semic-support-centre/solution/dcat-application-profile-data-portals-europe/release/300 "DCAT Application Profile for data portals in Europe (DCAT-AP) 3.0.0"
[PREVIEW]: https://htmlpreview.github.io/?https://github.com/datova-kancelaria/dcat-ap-sk-2.0/blob/develop/index.html

Vygenerovanie HTML z BS súboru

	
curl https://api.csswg.org/bikeshed/ -F file=@index.bs -F force=1 > index.html