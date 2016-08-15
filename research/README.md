updated always at 14:30 CNB (Czech Republic -> World)

- https://www.cnb.cz/cs/financni_trhy/devizovy_trh/kurzy_devizoveho_trhu/denni_kurz.txt?date=04.08.2014

updated always at 16:00 ECB (European Central Bank -> World)

- https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml

ECB API documentation
https://sdw-wsrest.ecb.europa.eu/

KB update rates at 18:00

RB updates rates at ?
CSOB updated rates at ? (when the market opens or same as CNB)

-----

FIO - has API
RB - no API, scapping or crawling
CSOB - probable API
CNB - has API
ECB - has API
UNICREDIT - has some API, needs scraping for cookie and session
KB - has API

-----

RB - public domain running on liferay (https://web.liferay.com/products/liferay-portal/features/enterprise-cms)

---

CBOS - daughter of KBC

---

some of exchange rates does not work historicaly. Only since for "today date"

CNB
* support historic lookup
* has querystring for date

CSOB
* does not support historic lookup (only today when emmited)
* no query string for date

ECB
* does not support historic lookup (only today when emmited)
* no query string for date

KB
* support historic lookup
* has querystring for date

RAIFFEISEN
* support historic lookup
* has querystring for date

UNICREDIT
* does not support historic lookup (only today when emmited)
* no query string for date


does support history:
- CNB
- RB
- KB

does not support history:
- CSOB
- ECB
- UNICREDIT

---

list of existing bank institutions in CZE: http://www.banky.cz/kurzy-men

>>>

without any API - purely server-side rendered HTML

* AirBank -> https://www.airbank.cz/cs/kurzovni-listek/ (partialy)
* J&T Bank -> https://www.jtbanka.sk/uzitocne-informacie/kurzovy-listok/
* CityBank -> http://www.citibank.cz/czech/gcb/personal_banking/czech/static/kurzy.jsp
* EquaBank -> https://www.equabank.cz/dulezite-dokumenty/kurzovni-listek (partialy)
* Zuno Bank -> https://www.zuno.cz/pomoc/uzitecne-informace/kurzovni-listek/ (partialy)
* PPF Bank -> https://www.ppfbanka.cz/cz/dokumenty-a-dulezite-informace/kurzovni-listek.html
* Sberbank -> https://www.sberbankcz.cz/poplatky-a-sazby/kurzy
* ING Bank -> http://www.ingbank.cz/o-ing-bank/kurzovni-listek/

>>>

with some API - downloadable as resource

* mBank -> http://www.mbank.cz/ajax/currency/getCSV/?id=1&date=2016-08-12%2016:31:00&lang=cz
* Era -> https://www.erasvet.cz/delegate/getExchangeRates?date=12.08.2016
* OberBank -> http://www.oberbank.at/OBK_webp/OBK/Application/Rechner/CZ/Fixing/Fixing_cz_export.jsp?dat1=12.08.2016&dat2=12.08.2016&dk=on&fn=on

>>>

no information whatsoever

* ČMSS -> https://www.cmss.cz

----

foreign exchange rate feeds

http://www.floatrates.com/feeds.html



---

infrastructure scan

UNICREDIT
* ocsp.unicredit.eu


----

need to find historic warehouse for:

ECB
CSOB
UNICREDIT



