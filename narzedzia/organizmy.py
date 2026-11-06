"""Organizmy tabel – grupy powiązanych tabel, od źródła danych do Trust Score.

Konwencja jak na schemacie prowadzącego (Oracle SQL Developer Data Modeler):
- nazwa tabeli po angielsku, PascalCase, w liczbie pojedynczej, np. SourcePlatform,
- klucz główny <Tabela>Key typu NUMBER(n) – dopisuje go generator; n wynika z szacunku, ile wierszy może mieć tabela
  (do 20 → NUMBER(2), do 5 000 → NUMBER(4)) – klucz ma być tak duży, jak trzeba, i nie większy,
- klucz nie ma znaczenia: kod urzędowy (kod kraju, formy prawnej, TERYT) to osobna kolumna tekstowa,
- klucz obcy nazywa się tak samo jak klucz, do którego prowadzi (SourcePlatformKey),
- w słownikach nazwa wartości to <Tabela>Name (APITypeName, DataFormatName),
- flaga to NUMBER(1): 1 = tak, 0 = nie,
- przypisanie, które zmienia się w czasie, ma datę od, datę do i flagę „aktualne”; wierszy nie usuwamy,
  a indeks unikalny warunkowy pilnuje, żeby aktualny był tylko jeden.

Każdy organizm odpowiada na dwa pytania: co to jest w szerszym kontekście i jakie mogą być warianty.
Organizm połączony (1 = dawne 1–3) ma klucze obce między wszystkimi swoimi tabelami. Tabela z innego organizmu jest
na diagramie szarą ramką, a klucze obce do niej są w pliku 99.

Pola:
  wiersze      – szacunek, ile wierszy może mieć tabela; z niego wynika liczba cyfr klucza,
  poz          – miejsce na diagramie: (kolumna, wiersz) siatki, liczone od 0,
  zewnetrzne   – tabele z innych organizmów pokazane na diagramie i ich miejsca,
  wartosci     – przykładowe wiersze; w słownikach to lista wariantów (trafia też do SQL jako INSERT),
  rodzaj       – podpis tabeli: słownik, łącząca, przypisanie, historia, zdarzenia, migawka,
  unikalne_gdy – unikalność tylko w części wierszy, np. ("IsCurrent = 1", ("SourcePlatformKey",)) = jedna aktualna
                 umowa na platformę (w SQL: unikalny indeks funkcyjny).

Po zmianie uruchom: python narzedzia/build_web.py (strona web/organizmy.html i pliki sql/organizmy/).
"""

# W bazie nazwa tabeli dostaje przedrostek numeru organizmu (ORG01_SourcePlatform), żeby tabele jednego organizmu
# stały na liście obok siebie. Kolumny i klucze zostają bez przedrostka (SourcePlatformKey). False = bez przedrostków.
PRZEDROSTEK_TABEL = True


def kol(nazwa, typ, opis, pusta=False, unikalna=False):
    return {"name": nazwa, "type": typ, "desc": opis, "null": pusta, "unique": unikalna}


def flaga(nazwa, opis, pusta=False):
    return {"name": nazwa, "type": "NUMBER(1)", "desc": opis, "null": pusta, "flag": True}


def fk(tabela, opis, nazwa=None, pusta=False, unikalna=False):
    return {"ref": tabela, "name": nazwa or tabela + "Key", "desc": opis, "null": pusta, "unique": unikalna}


def tabela(nazwa, wiersze, opis, kolumny, poz, rodzaj=None, unikalne=(), warunki=(), wartosci=None, unikalne_gdy=()):
    return {"name": nazwa, "rows_est": wiersze, "desc": opis, "cols": list(kolumny), "pos": poz, "kind": rodzaj,
            "unique": [list(u) for u in unikalne], "checks": list(warunki), "rows": wartosci,
            "unique_when": [(w, list(k)) for w, k in unikalne_gdy]}


def slownik(nazwa, wiersze, opis, wartosci, poz, dlugosc=40, kolumny=(), opis_nazwy="Nazwa wariantu", warunki=(),
            unikalne=()):
    cols = [kol(nazwa + "Name", f"VARCHAR2({dlugosc})", opis_nazwy, unikalna=True)] + list(kolumny)
    rows = [w if isinstance(w, tuple) else (w,) for w in wartosci]
    return tabela(nazwa, wiersze, opis, cols, poz, rodzaj="słownik", wartosci=rows, warunki=warunki, unikalne=unikalne)


def po_kolei(od, do, ostro=False):
    """Warunek: koniec nie wcześniej niż początek (ostro: koniec później niż początek)."""
    return f"{do} IS NULL OR {do} {'>' if ostro else '>='} {od}"


def zamkniety(flaga_kol, do):
    """Warunek: wiersz, który nie jest aktualny (flaga = 0), musi mieć datę końca."""
    return f"{flaga_kol} = 1 OR {do} IS NOT NULL"


def kod(nazwa, typ, opis, wzorzec, pusta=False, unikalna=True):
    """Kod urzędowy jako tekst (może zaczynać się od zera) z warunkiem na format – osobno od klucza."""
    return kol(nazwa, typ, opis, pusta=pusta, unikalna=unikalna), f"REGEXP_LIKE({nazwa}, '{wzorzec}')"


def organizm(nr, etap, tytul, krotko, kontekst, warianty, pytanie, mapa, tabele, zewnetrzne=None, polaczone=()):
    return {"id": nr, "stage": etap, "title": tytul, "short": krotko, "context": kontekst,
            "variants": [{"text": t, "tables": list(tb)} for t, tb in warianty],
            "questions": [pytanie] if isinstance(pytanie, str) else list(pytanie),
            "map": [{"layer": w, "what": co} for w, co in mapa], "tables": tabele, "stubs": zewnetrzne or {},
            "merged": list(polaczone)}


ETAPY = {
    "A": "Źródło danych",
    "B": "Firma",
    "C": "Ogłoszenie",
    "D": "Kandydat i zgłoszenia",
    "E": "Ocena firmy",
    "F": "Zaplecze systemu",
}

# Schemat pokazany przez prowadzącego – punkt wyjścia organizmu 1.
SCHEMAT_PROWADZACEGO = [
    ("SourcePlatform", "zostaje, organizm 1; rodzaj platformy przeszedł do tabeli łączącej (platforma bywa kilku rodzajów)"),
    ("PlatformAPI", "zostaje, organizm 1; doszły sposób zabezpieczenia, kierunek i wersje"),
    ("APIType", "zostaje, organizm 1"),
    ("DataFormat", "zostaje, organizm 1; format konkretnej odpowiedzi jest też przy endpoincie"),
    ("PlatformAPIData", "rozbita na APIEndpoint → EndpointResponse → EndpointData, organizm 1 – brakowało endpointów"),
]

# Fragmenty mapy, które rozpiszemy po uwagach prowadzącego (te same zasady).
DO_ROZPISANIA = [
    ("Moderacja i odwołania firm", 5, "appeals, moderator_decisions, moderation_queue, case_files"),
    ("Wnioski RODO", 5, "privacy_requests"),
    ("Odznaka przy ofercie i raporty publiczne", 5, "badge_view_stats, public_reports"),
    ("Dziennik audytu", 6, "audit_log"),
    ("Parametry, harmonogram i kolejka zleceń", 6, "system_parameters, job_runs, task_queue, system_alerts"),
    ("Pamięć i koszty zapytań do AI", 6, "llm_cache, llm_usage_log"),
]

_kraj, _kraj_ck = kod("CountryCode", "CHAR(2)", "Kod kraju ISO 3166, np. PL", "^[A-Z]{2}$")
_http, _http_ck = kod("HTTPStatusCode", "CHAR(3)", "Kod odpowiedzi HTTP, np. 200, 404, 429 – tekst, bo to kod, a nie liczba",
                      "^[1-5][0-9]{2}$", unikalna=False)
_forma, _forma_ck = kod("LegalFormCode", "CHAR(3)", "Kod szczególnej formy prawnej z rejestru REGON, np. 117 – tekst, "
                        "bo kody zaczynają się od zera (019, 048, 099)", "^[0-9]{3}$", pusta=True)
_pkd, _pkd_ck = kod("PKDSymbol", "VARCHAR2(7)", "Symbol, np. 52.10.B", "^[0-9]{2}\\.[0-9]{2}\\.[A-Z]$", unikalna=False)
_woj, _woj_ck = kod("RegionCode", "CHAR(2)", "Kod województwa z rejestru TERYT, np. 12 (puste za granicą)", "^[0-9]{2}$",
                    pusta=True, unikalna=False)
_simc, _simc_ck = kod("SIMCCode", "CHAR(7)", "Identyfikator miejscowości z rejestru TERYT (SIMC), np. 0950463 – "
                      "Kraków (puste za granicą)", "^[0-9]{7}$", pusta=True)
_waluta, _waluta_ck = kod("CurrencyCode", "CHAR(3)", "Kod waluty ISO 4217, np. PLN", "^[A-Z]{3}$")

ORGANIZMY = [
    # ───────────── A. ŹRÓDŁO DANYCH ─────────────
    organizm(
        1, "A", "Źródło danych: platforma, API i endpointy",
        "Skąd i jak przychodzą dane: platforma, jej kanały API, wersje i endpointy – aż do pojedynczego pola w odpowiedzi.",
        "Źródło danych to w szerszym kontekście cały łańcuch: serwis z ofertami pracy (platforma), kanał, którym "
        "przekazuje dane (API), wersja tego kanału, konkretne zapytanie (endpoint) i pole, które ono zwraca. Wcześniej "
        "były to trzy osobne organizmy (1–3); teraz to jeden organizm z kluczami obcymi między wszystkimi tabelami – "
        "rozwinięty schemat z zajęć.",
        [
            ("Źródłem może być portal z ofertami pracy, serwis ogłoszeń drobnych, agregator ofert, serwis społecznościowy, "
             "urząd pracy albo strona kariery firmy – a jedna platforma bywa kilku rodzajów naraz (OLX to serwis ogłoszeń "
             "drobnych i portal z ofertami pracy), tak jak lekarz bywa chirurgiem i onkologiem.",
             ["PlatformType", "PlatformClassification"]),
            ("Platforma działa pod kilkoma adresami i w kilku krajach, a adresy i kraje zmieniają się w czasie – zapisujemy "
             "datę od, datę do i flagę „aktualne”, zamiast usuwać.", ["PlatformDomain", "PlatformMarket", "Country"]),
            ("Umowa z platformą przechodzi przez etapy (negocjacje → pilotaż → aktywna → rozwiązana) – każdy etap to nowy "
             "wiersz, a aktualny jest jeden.", ["PartnerAgreement", "AgreementStatus"]),
            ("Kanał wymiany danych bywa różnego rodzaju (REST, GraphQL, webhook, plik…), w różnym formacie, z różnym "
             "zabezpieczeniem i kierunkiem.", ["PlatformAPI", "APIType", "DataFormat", "AuthMethod", "APIDirection"]),
            ("API ma wersje, a każda wersja – środowisko testowe i produkcyjne; z jednej wersji korzystamy teraz (flaga).",
             ["APIVersion", "APIEnvironment", "EnvironmentType"]),
            ("Wersja ma wiele endpointów, endpoint – wiele możliwych odpowiedzi (kod HTTP i format), a odpowiedź – wiele "
             "pól, także zagnieżdżonych.",
             ["APIEndpoint", "HTTPMethod", "DataSubject", "EndpointResponse", "EndpointData", "FieldDataType"]),
            ("Każda platforma nazywa te same dane inaczej (salary_from, wynagrodzenie_min) – przypisujemy je do naszych "
             "nazw.", ["CanonicalField", "FieldMapping"]),
        ],
        [
            "Czy strony kariery firm (systemy ATS) zostawić jako jeden z rodzajów platformy – tak jest teraz – czy "
            "wydzielić je osobno?",
            "PlatformAPI ma format domyślny, a format konkretnej odpowiedzi jest przy endpoincie – czy tak może zostać?",
            "Czy rozbicie PlatformAPIData na APIEndpoint → EndpointResponse → EndpointData ma dobry poziom szczegółu?",
        ],
        [(1, "źródło „Platformy” i dane kont firm od platform"), (2, "ogłoszenia i zdarzenia od platform"),
         (3, "log aplikacji od platform"), (6, "zbiór partners")],
        [
            slownik("PlatformType", 20, "Rodzaj platformy – czym w szerszym kontekście jest źródło ofert.",
                    ["Portal z ofertami pracy", "Serwis ogłoszeń drobnych", "Agregator ofert", "Serwis społecznościowy",
                     "Publiczny urząd pracy", "Strona kariery firmy (ATS)"], (0, 0), opis_nazwy="Nazwa rodzaju platformy"),
            tabela("PlatformClassification", 10000, "Rodzaj platformy – jedna platforma bywa kilku rodzajów naraz; tabela "
                   "łącząca platformy z rodzajami.", [
                       fk("SourcePlatform", "Platforma"),
                       fk("PlatformType", "Rodzaj"),
                       flaga("IsMainType", "1 = rodzaj główny, 0 = dodatkowy"),
                   ], (1, 0), rodzaj="łącząca", unikalne=[("SourcePlatformKey", "PlatformTypeKey")],
                   unikalne_gdy=[("IsMainType = 1", ("SourcePlatformKey",))],
                   wartosci=[(1, 1, 1), (2, 2, 1), (2, 1, 0)]),
            tabela("SourcePlatform", 5000, "Platforma, z której pochodzą dane, np. pracuj.pl albo OLX – ta sama tabela co "
                   "na schemacie z zajęć.", [
                       kol("SourcePlatformName", "VARCHAR2(50)", "Nazwa platformy, np. pracuj.pl", unikalna=True),
                       kol("MainHomePage", "VARCHAR2(100)", "Adres strony głównej"),
                       kol("AddedDate", "DATE", "Kiedy dodaliśmy platformę jako źródło"),
                   ], (2, 1), wartosci=[("pracuj.pl", "https://www.pracuj.pl", "2026-10-01"),
                                       ("OLX", "https://www.olx.pl", "2026-10-01")]),
            tabela("PlatformDomain", 20000, "Adres, pod którym działa platforma – z historią: adres może przestać działać "
                   "albo przejść do innej platformy.", [
                       fk("SourcePlatform", "Platforma"),
                       kol("DomainName", "VARCHAR2(100)", "Domena, np. it.pracuj.pl"),
                       flaga("IsMainDomain", "1 = główny adres platformy"),
                       kol("ValidFrom", "DATE", "Od kiedy adres należy do platformy"),
                       kol("ValidTo", "DATE", "Do kiedy (puste = nadal)", pusta=True),
                       flaga("IsCurrent", "1 = adres aktualny, 0 = już nie"),
                   ], (2, 0), rodzaj="historia",
                   warunki=[po_kolei("ValidFrom", "ValidTo"), zamkniety("IsCurrent", "ValidTo")],
                   unikalne_gdy=[("IsCurrent = 1", ("DomainName",)),
                                 ("IsCurrent = 1 AND IsMainDomain = 1", ("SourcePlatformKey",))]),
            tabela("PlatformMarket", 20000, "Kraj, w którym platforma publikuje oferty – przypisanie w czasie: platforma "
                   "wchodzi do kraju i z niego wychodzi.", [
                       fk("SourcePlatform", "Platforma"),
                       fk("Country", "Kraj"),
                       kol("ValidFrom", "DATE", "Od kiedy platforma działa w tym kraju (puste = nie wiemy)", pusta=True),
                       kol("ValidTo", "DATE", "Do kiedy (puste = nadal)", pusta=True),
                       flaga("IsCurrent", "1 = platforma działa tu teraz"),
                   ], (1, 2), rodzaj="przypisanie",
                   warunki=[po_kolei("ValidFrom", "ValidTo"), zamkniety("IsCurrent", "ValidTo")],
                   unikalne_gdy=[("IsCurrent = 1", ("SourcePlatformKey", "CountryKey"))]),
            tabela("PartnerAgreement", 2000, "Etap umowy o współpracy z platformą. Każdy etap to nowy wiersz, aktualny jest "
                   "jeden.", [
                       fk("SourcePlatform", "Platforma"),
                       fk("AgreementStatus", "Etap umowy"),
                       kol("SignedDate", "DATE", "Data podpisania", pusta=True),
                       kol("ValidFrom", "DATE", "Od kiedy obowiązuje"),
                       kol("ValidTo", "DATE", "Do kiedy obowiązuje (puste = bez końca)", pusta=True),
                       flaga("IsCurrent", "1 = etap aktualny"),
                       flaga("HasDataProcessingAgreement", "1 = podpisano umowę powierzenia danych osobowych (RODO)"),
                   ], (1, 1), rodzaj="historia",
                   warunki=[po_kolei("ValidFrom", "ValidTo"), zamkniety("IsCurrent", "ValidTo")],
                   unikalne_gdy=[("IsCurrent = 1", ("SourcePlatformKey",))]),
            slownik("AgreementStatus", 20, "Etap umowy z platformą.",
                    ["Negocjacje", "Pilotaż", "Aktywna", "Zawieszona", "Rozwiązana"], (0, 1), dlugosc=30,
                    opis_nazwy="Nazwa etapu umowy"),
            tabela("Country", 300, "Kraj – słownik używany też w organizmach 6 i 8.", [
                _kraj,
                kol("CountryName", "VARCHAR2(60)", "Nazwa kraju"),
            ], (0, 2), rodzaj="słownik", warunki=[_kraj_ck],
                wartosci=[("PL", "Polska"), ("DE", "Niemcy"), ("CZ", "Czechy"), ("RO", "Rumunia"), ("PT", "Portugalia"),
                          ("UA", "Ukraina")]),
            slownik("APIType", 20, "Rodzaj API – jak na schemacie z zajęć.",
                    ["REST", "GraphQL", "SOAP", "Webhook", "Eksport pliku", "Kanał RSS"], (3, 0), dlugosc=20,
                    opis_nazwy="Nazwa rodzaju API"),
            slownik("DataFormat", 20, "Format danych – jak na schemacie z zajęć, z typem MIME.",
                    [("JSON", "application/json"), ("XML", "application/xml"), ("CSV", "text/csv"), ("HTML", "text/html")],
                    (2, 3), dlugosc=15, opis_nazwy="Nazwa formatu",
                    kolumny=[kol("MimeType", "VARCHAR2(60)", "Typ MIME, np. application/json", unikalna=True)]),
            slownik("AuthMethod", 20, "Sposób uwierzytelnienia przy połączeniu z API.",
                    ["Klucz API", "OAuth 2.0", "Certyfikat klienta (mTLS)", "Podpis HMAC", "Brak zabezpieczenia"], (4, 1),
                    opis_nazwy="Nazwa sposobu uwierzytelnienia"),
            tabela("PlatformAPI", 10000, "Kanał wymiany danych z jedną platformą – tabela ze schematu z zajęć, rozszerzona.", [
                fk("SourcePlatform", "Platforma, do której należy API"),
                fk("APIType", "Rodzaj API"),
                fk("DataFormat", "Format domyślny"),
                fk("AuthMethod", "Jak się uwierzytelniamy"),
                fk("APIDirection", "Kto zaczyna przesyłanie danych"),
                kol("PlatformAPIName", "VARCHAR2(60)", "Nazwa API, np. „Partner API”"),
                kol("DocumentationURL", "VARCHAR2(200)", "Adres dokumentacji API", pusta=True),
            ], (3, 1)),
            slownik("APIDirection", 9, "Kierunek przesyłania danych.",
                    ["My pobieramy dane (pull)", "Platforma wysyła dane (push)"], (4, 0), opis_nazwy="Nazwa kierunku"),
            tabela("APIVersion", 30000, "Wersja API. Endpointy różnią się między wersjami, a stare wersje platforma wyłącza.", [
                fk("PlatformAPI", "API, którego to wersja"),
                kol("VersionLabel", "VARCHAR2(10)", "Oznaczenie wersji, np. v2"),
                kol("ReleaseDate", "DATE", "Kiedy wersja weszła"),
                kol("RetirementDate", "DATE", "Kiedy platforma wyłączy tę wersję", pusta=True),
                flaga("IsInUse", "1 = z tej wersji korzysta teraz nasz program"),
            ], (3, 2), rodzaj="historia", unikalne=[("PlatformAPIKey", "VersionLabel")],
                warunki=[po_kolei("ReleaseDate", "RetirementDate")],
                unikalne_gdy=[("IsInUse = 1", ("PlatformAPIKey",))]),
            slownik("EnvironmentType", 9, "Rodzaj środowiska API.", ["Testowe (sandbox)", "Produkcyjne"], (5, 2),
                    dlugosc=30, opis_nazwy="Nazwa środowiska"),
            tabela("APIEnvironment", 60000, "Środowisko danej wersji API z własnym adresem i limitem zapytań.", [
                fk("APIVersion", "Wersja API"),
                fk("EnvironmentType", "Rodzaj środowiska"),
                kol("BaseURL", "VARCHAR2(200)", "Adres bazowy, np. https://api.platforma.example/v2"),
                kol("RequestLimitPerMinute", "NUMBER(6)", "Ile zapytań na minutę pozwala platforma", pusta=True),
            ], (4, 2), unikalne=[("APIVersionKey", "EnvironmentTypeKey")]),
            slownik("HTTPMethod", 20, "Metoda HTTP endpointu.", ["GET", "POST", "PUT", "PATCH", "DELETE"], (4, 3),
                    dlugosc=10, opis_nazwy="Nazwa metody"),
            slownik("DataSubject", 20, "Czego dotyczą dane z endpointu – łączy endpointy z dalszymi organizmami.",
                    ["Konto firmy", "Ogłoszenie", "Zdarzenie ogłoszenia", "Aplikacja kandydata", "Status aplikacji"],
                    (4, 4), opis_nazwy="Nazwa rodzaju danych"),
            tabela("APIEndpoint", 300000, "Jedno zapytanie w danej wersji API.", [
                fk("APIVersion", "Wersja API"),
                fk("HTTPMethod", "Metoda HTTP"),
                fk("DataSubject", "Czego dotyczą zwracane dane"),
                kol("EndpointPath", "VARCHAR2(200)", "Ścieżka, np. /v2/jobs"),
                flaga("IsPaginated", "1 = wyniki są dzielone na strony"),
                kol("EndpointDescription", "VARCHAR2(300)", "Co robi endpoint", pusta=True),
            ], (3, 3), unikalne=[("APIVersionKey", "HTTPMethodKey", "EndpointPath")]),
            tabela("EndpointResponse", 2000000, "Jedna możliwa odpowiedź endpointu: kod HTTP i format.", [
                fk("APIEndpoint", "Endpoint"),
                _http,
                fk("DataFormat", "Format tej odpowiedzi"),
                flaga("IsErrorResponse", "1 = odpowiedź z błędem"),
                kol("ResponseDescription", "VARCHAR2(200)", "Kiedy pojawia się ta odpowiedź", pusta=True),
            ], (3, 4), unikalne=[("APIEndpointKey", "HTTPStatusCode", "DataFormatKey")], warunki=[_http_ck]),
            slownik("FieldDataType", 20, "Typ danych pola w odpowiedzi.",
                    ["Tekst", "Liczba całkowita", "Liczba dziesiętna", "Prawda / fałsz", "Data", "Data i godzina",
                     "Lista", "Obiekt"], (2, 5), dlugosc=30, opis_nazwy="Nazwa typu"),
            tabela("EndpointData", 30000000, "Jedno pole w odpowiedzi endpointu – odpowiednik PlatformAPIData ze schematu "
                   "z zajęć.", [
                       fk("EndpointResponse", "Odpowiedź, w której jest pole"),
                       fk("EndpointData", "Pole nadrzędne, gdy pole jest zagnieżdżone", nazwa="ParentEndpointDataKey",
                          pusta=True),
                       kol("DataName", "VARCHAR2(50)", "Nazwa pola u platformy, np. salary_from"),
                       kol("DataPath", "VARCHAR2(200)", "Pełna ścieżka pola, np. salary.from"),
                       fk("FieldDataType", "Typ danych pola"),
                       flaga("IsRequired", "1 = platforma zawsze podaje to pole"),
                       kol("ExampleValue", "VARCHAR2(200)", "Przykładowa wartość", pusta=True),
                   ], (3, 5), unikalne=[("EndpointResponseKey", "DataPath")]),
            tabela("CanonicalField", 1000, "Nasza jedna nazwa danej, niezależna od platformy.", [
                kol("CanonicalFieldName", "VARCHAR2(60)", "Nazwa, np. „Wynagrodzenie od”", unikalna=True),
                fk("DataSubject", "Czego dotyczy"),
                kol("CanonicalFieldDescription", "VARCHAR2(300)", "Opis", pusta=True),
            ], (4, 5), rodzaj="słownik", wartosci=[("Wynagrodzenie od", 2, "Dolna granica widełek"),
                                                   ("Rodzaj umowy", 2, None), ("NIP firmy", 1, "NIP wpisany w koncie firmy"),
                                                   ("Data aplikacji", 4, None)]),
            tabela("FieldMapping", 30000000, "Przypisanie pola platformy do naszej nazwy, z regułą przeliczenia.", [
                fk("EndpointData", "Pole platformy"),
                fk("CanonicalField", "Nasza nazwa"),
                kol("TransformationRule", "VARCHAR2(300)", "Jak przeliczyć wartość, np. „grosze na złote: /100”", pusta=True),
            ], (3, 6), unikalne=[("EndpointDataKey", "CanonicalFieldKey")]),
        ],
        polaczone=(1, 2, 3),
    ),
    organizm(
        4, "A", "Odbiór danych z platformy",
        "Każda dostawa danych: kiedy, którym endpointem, z jakim skutkiem – i surowa kopia każdego rekordu.",
        "Przyjęcie danych to w szerszym kontekście zdarzenie w czasie: kto, kiedy, którym kanałem i z jakim skutkiem "
        "dostarczył dane. Zapisujemy je, żeby o każdym rekordzie wiedzieć, skąd pochodzi, i żeby po błędzie móc "
        "przetworzyć dane jeszcze raz.",
        [
            ("Dane przychodzą różnie: pobieramy je sami o ustalonej porze, platforma wysyła je sama (webhook), dostajemy "
             "plik albo ręcznie doładowujemy historię.", ["DeliveryMode"]),
            ("Dostawa kończy się w całości, częściowo albo wcale.", ["DeliveryStatus"]),
            ("Błąd dotyczy całej dostawy (np. odrzucony klucz API) albo jednego rekordu (brak pola) i bywa różnego "
             "rodzaju.", ["DeliveryError", "ErrorType"]),
            ("Surową kopię rekordu trzymamy bez zmian, żeby po poprawce programu przetworzyć ją jeszcze raz; po skrócie "
             "treści rozpoznajemy duplikaty.", ["RawRecord"]),
        ],
        "Czy surowe dane (RawRecord) trzymać w bazie, czy wystarczy plik na dysku i odnośnik do niego?",
        [(2, "zbiór raw_postings"), (6, "zbiory api_access_log i job_runs")],
        [
            slownik("DeliveryMode", 20, "Sposób, w jaki dane do nas trafiły.",
                    ["Pobranie według harmonogramu", "Powiadomienie od platformy (webhook)", "Plik z eksportem",
                     "Ręczne doładowanie historii"], (0, 0), opis_nazwy="Nazwa sposobu dostawy"),
            slownik("DeliveryStatus", 20, "Wynik dostawy.", ["W toku", "Zakończona", "Zakończona częściowo", "Nieudana"],
                    (2, 0), dlugosc=30, opis_nazwy="Nazwa wyniku"),
            tabela("DataDelivery", 1000000000, "Jedna dostawa danych jednym endpointem.", [
                fk("APIEndpoint", "Którym endpointem przyszły dane"),
                fk("DeliveryMode", "Sposób dostawy"),
                fk("DeliveryStatus", "Wynik dostawy"),
                kol("StartedAt", "TIMESTAMP", "Początek"),
                kol("FinishedAt", "TIMESTAMP", "Koniec", pusta=True),
                kol("RecordsReceived", "NUMBER(7)", "Ile rekordów przyszło", pusta=True),
                kol("RecordsAccepted", "NUMBER(7)", "Ile rekordów przyjęliśmy", pusta=True),
            ], (1, 1), rodzaj="zdarzenia", warunki=["RecordsAccepted <= RecordsReceived",
                                                    po_kolei("StartedAt", "FinishedAt")]),
            tabela("RawRecord", 100000000000, "Rekord dokładnie w takiej postaci, w jakiej przyszedł od platformy.", [
                fk("DataDelivery", "Dostawa"),
                kol("ExternalRecordId", "VARCHAR2(100)", "Numer rekordu u platformy"),
                kol("RecordPayload", "CLOB", "Treść rekordu bez zmian (np. JSON)"),
                kol("PayloadHash", "VARCHAR2(64)", "Skrót SHA-256 treści – do wykrywania duplikatów"),
                kol("ReceivedAt", "TIMESTAMP", "Kiedy rekord przyszedł"),
            ], (0, 2)),
            tabela("DeliveryError", 1000000000, "Błąd dostawy albo pojedynczego rekordu.", [
                fk("DataDelivery", "Dostawa"),
                fk("RawRecord", "Którego rekordu dotyczy (puste = całej dostawy)", pusta=True),
                fk("ErrorType", "Rodzaj błędu"),
                kol("ErrorMessage", "VARCHAR2(400)", "Treść błędu", pusta=True),
                kol("OccurredAt", "TIMESTAMP", "Kiedy wystąpił"),
            ], (1, 2), rodzaj="zdarzenia"),
            slownik("ErrorType", 50, "Rodzaj błędu przy odbiorze danych.",
                    ["Brak wymaganego pola", "Zły format danych", "Odrzucony klucz API", "Przekroczony limit zapytań",
                     "Brak odpowiedzi platformy", "Nieznana wersja API"], (2, 2), opis_nazwy="Nazwa rodzaju błędu"),
        ],
        zewnetrzne={"APIEndpoint": (1, 0)},
    ),
    # ───────────── B. FIRMA ─────────────
    organizm(
        5, "B", "Konto firmy na platformie",
        "Profil, pod którym ktoś publikuje ogłoszenia – zanim wiemy, jaka firma za nim stoi.",
        "Konto to w szerszym kontekście profil, pod którym ktoś publikuje ogłoszenia na jednej platformie. To jeszcze "
        "nie jest firma: za kontem może stać firma, agencja, osoba prywatna albo urząd, a dane konta wpisał sam "
        "właściciel i nikt ich nie sprawdził.",
        [
            ("Konto prowadzi firma, agencja rekrutacyjna, osoba prywatna albo instytucja publiczna.", ["AccountType"]),
            ("Platforma może konto zawiesić albo usunąć, a potem przywrócić – stan konta jest w wersjach, więc historia "
             "zostaje.", ["AccountStatus", "EmployerAccountVersion"]),
            ("Dane konta zmieniają się w czasie – firma może zmienić nazwę, żeby uciec od złych opinii. Każda zmiana to "
             "nowy wiersz z datami, a aktualny jest jeden (flaga).", ["EmployerAccountVersion"]),
            ("Numer konta jest unikalny tylko w obrębie jednej platformy, dlatego klucz unikalny to platforma + numer.",
             ["EmployerAccount"]),
        ],
        "Czy historię zmian konta trzymać jako wersje całego wiersza – tak jest teraz – czy jako dziennik zmian "
        "pojedynczych pól?",
        [(1, "zbiór employer_accounts")],
        [
            slownik("AccountType", 20, "Kto prowadzi konto.", ["Firma", "Agencja rekrutacyjna", "Osoba prywatna",
                                                             "Instytucja publiczna"], (0, 1),
                    opis_nazwy="Nazwa rodzaju konta"),
            slownik("AccountStatus", 20, "Stan konta na platformie.", ["Aktywne", "Zawieszone przez platformę", "Usunięte"],
                    (0, 2), opis_nazwy="Nazwa stanu"),
            tabela("EmployerAccount", 5000000, "Konto na jednej platformie – to, co się nie zmienia.", [
                fk("SourcePlatform", "Platforma"),
                kol("ExternalAccountId", "VARCHAR2(50)", "Numer konta w serwisie"),
                fk("AccountType", "Kto prowadzi konto"),
                kol("FirstSeenAt", "TIMESTAMP", "Kiedy pierwszy raz dostaliśmy to konto"),
            ], (1, 1), unikalne=[("SourcePlatformKey", "ExternalAccountId")]),
            tabela("EmployerAccountVersion", 20000000, "Wersja danych konta – każda zmiana to nowy wiersz, aktualny jest "
                   "jeden.", [
                       fk("EmployerAccount", "Konto"),
                       kol("AccountName", "VARCHAR2(200)", "Nazwa konta"),
                       kol("DeclaredNIP", "VARCHAR2(10)", "NIP wpisany przez właściciela konta (niesprawdzony)", pusta=True),
                       kol("WebsiteURL", "VARCHAR2(200)", "Strona www podana w koncie", pusta=True),
                       fk("AccountStatus", "Stan konta w tej wersji"),
                       flaga("IsVerifiedByPlatform", "1 = platforma sama sprawdziła firmę"),
                       kol("ValidFrom", "TIMESTAMP", "Od kiedy dane są takie"),
                       kol("ValidTo", "TIMESTAMP", "Do kiedy (puste = wersja aktualna)", pusta=True),
                       flaga("IsCurrent", "1 = wersja aktualna"),
                       fk("RawRecord", "Rekord, z którego pochodzi ta wersja", pusta=True),
                   ], (1, 2), rodzaj="historia",
                   warunki=[po_kolei("ValidFrom", "ValidTo", ostro=True), zamkniety("IsCurrent", "ValidTo")],
                   unikalne_gdy=[("IsCurrent = 1", ("EmployerAccountKey",))]),
        ],
        zewnetrzne={"SourcePlatform": (1, 0), "RawRecord": (2, 2)},
    ),
    organizm(
        6, "B", "Firma w rejestrach publicznych",
        "Podmiot prawny stojący za ogłoszeniami, sprawdzony w rejestrach państwowych.",
        "Pracodawca to w szerszym kontekście podmiot prawny zapisany w rejestrze państwowym – to on odpowiada za "
        "ogłoszenie, a nie konto na platformie. Sprawdzamy go w rejestrach, żeby wykryć firmy fikcyjne, wykreślone "
        "albo założone tydzień temu.",
        [
            ("Podmiot ma różną formę prawną: spółka z o.o., spółka akcyjna, jednoosobowa działalność, fundacja, urząd, "
             "firma zagraniczna. Forma ma urzędowy kod z rejestru REGON (np. 117, 099) – zapisujemy go obok klucza, jako "
             "tekst.", ["LegalForm"]),
            ("Firma ma kilka numerów naraz (NIP, REGON, KRS), a firma zagraniczna – zupełnie inne. Dlatego numery są w "
             "osobnej tabeli, a nie w kolumnach NIP, REGON i KRS.", ["EmployerIdentifier", "IdentifierType"]),
            ("Sprawdzamy w kilku rejestrach i wielokrotnie w czasie; rejestr może firmy nie znaleźć albo podać inny "
             "status niż poprzednio.", ["PublicRegistry", "RegistryCheck"]),
            ("Firma prowadzi kilka rodzajów działalności (PKD), jeden jest główny, a działalności zmieniają się w czasie – "
             "przypisanie ma daty i flagę. Sama klasyfikacja też się zmienia (PKD 2007, PKD 2025).",
             ["PKDCode", "PKDClassification", "EmployerPKD"]),
            ("Status firmy zmienia się: aktywna, zawieszona, w likwidacji, wykreślona.", ["EmployerStatus"]),
        ],
        "Czy aktualny status firmy trzymać przy firmie (Employer.EmployerStatusKey – tak jest teraz), czy brać go zawsze "
        "z ostatniego sprawdzenia w RegistryCheck?",
        [(1, "zbiory employers, registry_snapshots"), (6, "słownik legal_form_dictionary")],
        [
            slownik("LegalForm", 99, "Forma prawna podmiotu.",
                    [("Spółka z ograniczoną odpowiedzialnością", "sp. z o.o.", "117"), ("Spółka akcyjna", "S.A.", "116"),
                     ("Jednoosobowa działalność gospodarcza", "JDG", "099"), ("Spółka cywilna", "s.c.", "019"),
                     ("Spółka jawna", "sp.j.", "118"), ("Fundacja", None, "048"), ("Stowarzyszenie", None, "155"),
                     ("Jednostka sektora publicznego", None, None), ("Firma zagraniczna", None, None)], (0, 0),
                    dlugosc=60, opis_nazwy="Pełna nazwa formy prawnej",
                    kolumny=[kol("LegalFormShortName", "VARCHAR2(20)", "Skrót, np. sp. z o.o.", pusta=True), _forma],
                    warunki=[_forma_ck]),
            slownik("PKDClassification", 9, "Wersja klasyfikacji PKD – wybierana z listy, a nie wpisywana.",
                    [("PKD 2007", "2008-01-01"), ("PKD 2025", "2025-01-01")], (3, 0), dlugosc=20,
                    opis_nazwy="Nazwa klasyfikacji",
                    kolumny=[kol("ValidFrom", "DATE", "Od kiedy obowiązuje")]),
            tabela("PKDCode", 2000, "Rodzaj działalności z klasyfikacji PKD.", [
                _pkd,
                kol("PKDName", "VARCHAR2(250)", "Nazwa działalności"),
                fk("PKDClassification", "Wersja klasyfikacji"),
            ], (2, 0), rodzaj="słownik", unikalne=[("PKDSymbol", "PKDClassificationKey")], warunki=[_pkd_ck]),
            tabela("EmployerIdentifier", 15000000, "Numer identyfikacyjny firmy – NIP, REGON, KRS albo numer zagraniczny.", [
                fk("Employer", "Firma"),
                fk("IdentifierType", "Rodzaj numeru"),
                kol("IdentifierValue", "VARCHAR2(30)", "Numer – tekst, bo może zaczynać się od zera"),
                flaga("IsChecksumValid", "1 = numer przeszedł kontrolę sumy kontrolnej"),
            ], (0, 1), unikalne=[("IdentifierTypeKey", "IdentifierValue")]),
            tabela("Employer", 5000000, "Podmiot prawny – jeden wiersz to jedna prawdziwa firma. Dla niego liczymy Trust "
                   "Score.", [
                       kol("OfficialName", "VARCHAR2(250)", "Nazwa urzędowa"),
                       fk("LegalForm", "Forma prawna"),
                       fk("Country", "Kraj rejestracji"),
                       fk("EmployerStatus", "Aktualny status"),
                       kol("RegistrationDate", "DATE", "Data wpisu do rejestru", pusta=True),
                   ], (1, 1)),
            tabela("EmployerPKD", 20000000, "Rodzaj działalności firmy – przypisanie w czasie firmy do kodu PKD.", [
                fk("Employer", "Firma"),
                fk("PKDCode", "Kod PKD"),
                flaga("IsMainActivity", "1 = działalność główna"),
                kol("ValidFrom", "DATE", "Od kiedy firma prowadzi tę działalność (puste = nie wiemy)", pusta=True),
                kol("ValidTo", "DATE", "Do kiedy (puste = nadal)", pusta=True),
                flaga("IsCurrent", "1 = działalność prowadzona teraz"),
            ], (2, 1), rodzaj="przypisanie",
                warunki=[po_kolei("ValidFrom", "ValidTo"), zamkniety("IsCurrent", "ValidTo")],
                unikalne_gdy=[("IsCurrent = 1", ("EmployerKey", "PKDCodeKey")),
                              ("IsCurrent = 1 AND IsMainActivity = 1", ("EmployerKey",))]),
            tabela("IdentifierType", 20, "Rodzaj numeru identyfikacyjnego.", [
                kol("IdentifierTypeName", "VARCHAR2(40)", "Nazwa rodzaju numeru", unikalna=True),
                kol("ValueFormat", "VARCHAR2(60)", "Jak wygląda poprawny numer"),
            ], (0, 2), rodzaj="słownik", wartosci=[("NIP", "10 cyfr, ostatnia to suma kontrolna"),
                                                   ("REGON", "9 albo 14 cyfr"), ("KRS", "10 cyfr"),
                                                   ("Numer VAT UE", "kod kraju i numer"),
                                                   ("Zagraniczny numer rejestrowy", "dowolny")]),
            tabela("RegistryCheck", 300000000, "Jedno sprawdzenie firmy w jednym rejestrze. Nowe sprawdzenie to nowy wiersz.", [
                fk("Employer", "Firma"),
                fk("PublicRegistry", "Rejestr"),
                kol("CheckedAt", "TIMESTAMP", "Kiedy sprawdzono"),
                flaga("WasFound", "1 = rejestr znalazł firmę"),
                fk("EmployerStatus", "Status podany przez rejestr", nazwa="ReportedStatusKey", pusta=True),
                kol("ReportedName", "VARCHAR2(250)", "Nazwa podana przez rejestr", pusta=True),
            ], (1, 2), rodzaj="zdarzenia"),
            slownik("EmployerStatus", 20, "Status firmy w rejestrze.",
                    ["Aktywna", "Zawieszona", "W likwidacji", "W upadłości", "Wykreślona", "Nieznaleziona w rejestrze"],
                    (2, 2), opis_nazwy="Nazwa statusu"),
            tabela("PublicRegistry", 20, "Rejestr państwowy, w którym sprawdzamy firmy.", [
                kol("PublicRegistryName", "VARCHAR2(60)", "Nazwa rejestru", unikalna=True),
                fk("IdentifierType", "Po jakim numerze pytamy rejestr"),
                kol("DailyQueryLimit", "NUMBER(7)", "Ile zapytań dziennie pozwala rejestr", pusta=True),
            ], (0, 3), rodzaj="słownik", wartosci=[("Krajowy Rejestr Sądowy (KRS)", 3, None), ("CEIDG", 1, None),
                                                   ("Rejestr REGON (GUS)", 2, None),
                                                   ("Biała lista podatników VAT", 1, None),
                                                   ("VIES – rejestr VAT UE", 4, None)]),
        ],
        zewnetrzne={"Country": (1, 0)},
    ),
    organizm(
        7, "B", "Powiązanie kont z firmą",
        "Które konta z różnych platform należą do tej samej firmy – z dowodami i historią zmian.",
        "Powiązanie to w szerszym kontekście twierdzenie: „to konto na tej platformie należy do tej firmy z rejestru”. "
        "Twierdzenie może być pewne albo tylko prawdopodobne, może się okazać błędne i trzeba umieć je cofnąć. Dzięki "
        "niemu jedna firma ma jeden Trust Score, choć ma konta na kilku platformach.",
        [
            ("Dopasowanie robimy różnymi sposobami: ten sam NIP (pewne), podobna nazwa i ta sama strona www "
             "(prawdopodobne), decyzja moderatora, potwierdzenie przez firmę.", ["MatchMethod", "AccountEmployerLink"]),
            ("Każde dopasowanie ma dowody różnego rodzaju: zgodny NIP, podobna nazwa, ta sama domena.",
             ["LinkEvidence", "EvidenceType"]),
            ("Konto agencji rekrutacyjnej publikuje ogłoszenia dla wielu klientów – wtedy łączymy dwie firmy ze sobą, z "
             "datą od, datą do i flagą „aktywne”.", ["AgencyClient"]),
            ("Błędne połączenie trzeba cofnąć, ale nie usunąć: powiązanie dostaje datę rozłączenia i flagę 0, a zmiana – "
             "wpis w historii z autorem (użytkownik z organizmu 19).", ["LinkChange", "LinkChangeType"]),
        ],
        "Czy relację agencja–klient (AgencyClient) trzymać tutaj, czy przy ogłoszeniu (ogłoszenie agencji wskazuje "
        "klienta)?",
        [(1, "zbiory employer_account_links, employer_merge_log")],
        [
            slownik("MatchMethod", 20, "Sposób, w jaki dopasowaliśmy konto do firmy.",
                    ["Ten sam NIP", "Podobna nazwa i ta sama strona www", "Decyzja moderatora", "Potwierdzenie przez firmę"],
                    (1, 0), opis_nazwy="Nazwa sposobu dopasowania"),
            tabela("LinkEvidence", 30000000, "Dowód, na którym opiera się powiązanie.", [
                fk("AccountEmployerLink", "Powiązanie"),
                fk("EvidenceType", "Rodzaj dowodu"),
                kol("EvidenceValue", "VARCHAR2(250)", "Treść dowodu, np. „ten sam NIP w koncie i w KRS”"),
            ], (0, 1)),
            tabela("AccountEmployerLink", 10000000, "Powiązanie konta na platformie z firmą z rejestru – przypisanie w "
                   "czasie; aktywne jest najwyżej jedno na konto.", [
                       fk("EmployerAccount", "Konto"),
                       fk("Employer", "Firma"),
                       fk("MatchMethod", "Sposób dopasowania"),
                       kol("MatchConfidence", "NUMBER(3,2)", "Pewność od 0 do 1"),
                       kol("LinkedAt", "TIMESTAMP", "Kiedy połączono"),
                       kol("UnlinkedAt", "TIMESTAMP", "Kiedy cofnięto (puste = obowiązuje)", pusta=True),
                       flaga("IsActive", "1 = powiązanie obowiązuje"),
                   ], (1, 1), rodzaj="przypisanie",
                   warunki=["MatchConfidence BETWEEN 0 AND 1", po_kolei("LinkedAt", "UnlinkedAt"),
                            zamkniety("IsActive", "UnlinkedAt")],
                   unikalne_gdy=[("IsActive = 1", ("EmployerAccountKey",))]),
            tabela("AgencyClient", 500000, "Agencja rekrutacyjna i firma, dla której rekrutuje – dwa klucze do tej samej "
                   "tabeli, przypisanie w czasie.", [
                       fk("Employer", "Agencja rekrutacyjna", nazwa="AgencyEmployerKey"),
                       fk("Employer", "Firma, dla której agencja rekrutuje", nazwa="ClientEmployerKey"),
                       kol("ValidFrom", "DATE", "Od kiedy"),
                       kol("ValidTo", "DATE", "Do kiedy (puste = nadal)", pusta=True),
                       flaga("IsActive", "1 = współpraca trwa"),
                   ], (2, 1), rodzaj="przypisanie", unikalne=[("AgencyEmployerKey", "ClientEmployerKey", "ValidFrom")],
                   warunki=["AgencyEmployerKey <> ClientEmployerKey", po_kolei("ValidFrom", "ValidTo"),
                            zamkniety("IsActive", "ValidTo")],
                   unikalne_gdy=[("IsActive = 1", ("AgencyEmployerKey", "ClientEmployerKey"))]),
            slownik("EvidenceType", 20, "Rodzaj dowodu powiązania.",
                    ["Zgodny NIP", "Podobna nazwa", "Ta sama domena strony www", "Ten sam adres",
                     "Dokument przesłany przez firmę"], (0, 2), opis_nazwy="Nazwa rodzaju dowodu"),
            tabela("LinkChange", 30000000, "Zmiana powiązania – historia połączeń i rozłączeń, z autorem.", [
                fk("AccountEmployerLink", "Powiązanie"),
                fk("LinkChangeType", "Co zmieniono"),
                kol("ChangedAt", "TIMESTAMP", "Kiedy"),
                kol("ChangeReason", "VARCHAR2(300)", "Dlaczego", pusta=True),
                fk("SystemUser", "Kto zmienił (puste = program)", pusta=True),
            ], (1, 2), rodzaj="zdarzenia"),
            slownik("LinkChangeType", 20, "Rodzaj zmiany powiązania.",
                    ["Połączono", "Rozłączono", "Przeniesiono do innej firmy", "Zmieniono pewność"], (2, 2),
                    opis_nazwy="Nazwa rodzaju zmiany"),
        ],
        zewnetrzne={"EmployerAccount": (0, 0), "Employer": (2, 0), "SystemUser": (1, 3)},
    ),
    # ───────────── C. OGŁOSZENIE ─────────────
    organizm(
        8, "C", "Ogłoszenie i miejsce pracy",
        "Samo ogłoszenie: kto je opublikował, kiedy, dla jakich poziomów, w jakich trybach i w których miejscowościach.",
        "Ogłoszenie to w szerszym kontekście oferta pracy opublikowana przez konto na platformie w określonym czasie. "
        "Samo ogłoszenie nie mówi jeszcze, czy praca naprawdę istnieje – dlatego zapisujemy je dokładnie, żeby później "
        "porównywać kolejne publikacje.",
        [
            ("Ogłoszenie bywa aktywne, wygasłe, zamknięte przed terminem, wstrzymane albo usunięte przez platformę.",
             ["PostingStatus"]),
            ("Jedno ogłoszenie dotyczy kilku miejscowości naraz, a w jednej miejscowości są tysiące ogłoszeń – relacja "
             "wiele do wielu.", ["Location", "PostingLocation"]),
            ("Jedno ogłoszenie szuka kilku poziomów naraz (np. Mid/Senior) i daje kilka trybów pracy (hybrydowa albo "
             "zdalna) – to też relacje wiele do wielu, a nie jedna kolumna.",
             ["SeniorityLevel", "PostingSeniority", "WorkMode", "PostingWorkMode"]),
            ("Kolejność poziomów pozwala wykryć ten sam etat ogłaszany raz jako Senior, raz jako Mid.", ["SeniorityLevel"]),
            ("Miejscowość i województwo mają urzędowe kody TERYT (SIMC i 02–32) – wybieramy je z listy, a nie wpisujemy.",
             ["Location", "Region"]),
        ],
        "Treść ogłoszenia jest w organizmie 11 (wersje treści). Czy tytuł też przenieść tam, czy zostawić go tutaj – tak "
        "jak teraz?",
        [(2, "zbiór job_postings")],
        [
            slownik("PostingStatus", 20, "Stan ogłoszenia.",
                    ["Aktywne", "Wygasłe", "Zamknięte przed terminem", "Usunięte przez platformę", "Wstrzymane"],
                    (1, 0), opis_nazwy="Nazwa stanu"),
            slownik("SeniorityLevel", 20, "Poziom stanowiska.",
                    [("Stażysta", 1), ("Junior", 2), ("Mid (samodzielny)", 3), ("Senior", 4), ("Ekspert", 5),
                     ("Kierownik", 6)], (0, 2), opis_nazwy="Nazwa poziomu",
                    kolumny=[kol("SeniorityRank", "NUMBER(2)", "Kolejność poziomów (1 = najniższy)")]),
            tabela("JobPosting", 100000000, "Ogłoszenie o pracę opublikowane przez konto na platformie.", [
                fk("EmployerAccount", "Konto, które opublikowało ogłoszenie"),
                kol("ExternalPostingId", "VARCHAR2(50)", "Numer ogłoszenia w serwisie"),
                kol("PostingTitle", "VARCHAR2(200)", "Tytuł (aktualny)"),
                fk("PostingStatus", "Stan ogłoszenia"),
                kol("VacancyCount", "NUMBER(3)", "Ilu osób szuka", pusta=True),
                kol("PublishedDate", "DATE", "Data pierwszej publikacji"),
                kol("ExpiryDate", "DATE", "Planowana data końca", pusta=True),
                fk("RawRecord", "Rekord, z którego powstało ogłoszenie", pusta=True),
            ], (1, 1), unikalne=[("EmployerAccountKey", "ExternalPostingId")],
                warunki=[po_kolei("PublishedDate", "ExpiryDate"), "VacancyCount > 0"]),
            tabela("PostingSeniority", 150000000, "Poziom stanowiska w ogłoszeniu – tabela łącząca, bo ogłoszenie bywa dla "
                   "kilku poziomów naraz.", [
                       fk("JobPosting", "Ogłoszenie"),
                       fk("SeniorityLevel", "Poziom"),
                   ], (0, 1), rodzaj="łącząca", unikalne=[("JobPostingKey", "SeniorityLevelKey")]),
            slownik("WorkMode", 20, "Tryb pracy.", ["Stacjonarna", "Hybrydowa", "Zdalna", "W terenie"], (2, 2),
                    dlugosc=30, opis_nazwy="Nazwa trybu pracy"),
            tabela("PostingWorkMode", 150000000, "Tryb pracy w ogłoszeniu – tabela łącząca, bo ogłoszenie daje kilka trybów "
                   "do wyboru.", [
                       fk("JobPosting", "Ogłoszenie"),
                       fk("WorkMode", "Tryb pracy"),
                   ], (2, 1), rodzaj="łącząca", unikalne=[("JobPostingKey", "WorkModeKey")]),
            tabela("PostingLocation", 200000000, "Miejsce pracy w ogłoszeniu – tabela łącząca ogłoszenia z miejscowościami.", [
                fk("JobPosting", "Ogłoszenie"),
                fk("Location", "Miejscowość"),
                flaga("IsMainLocation", "1 = główne miejsce pracy"),
            ], (1, 2), rodzaj="łącząca", unikalne=[("JobPostingKey", "LocationKey")],
                unikalne_gdy=[("IsMainLocation = 1", ("JobPostingKey",))]),
            tabela("Location", 200000, "Miejscowość – z urzędowym kodem TERYT, gdy leży w Polsce.", [
                kol("CityName", "VARCHAR2(80)", "Nazwa miejscowości"),
                _simc,
                fk("Region", "Województwo albo region (puste, gdy nie wiemy)", pusta=True),
                fk("Country", "Kraj"),
            ], (1, 3), rodzaj="słownik", warunki=[_simc_ck]),
            tabela("Region", 500, "Województwo albo region – wybierane z listy, a nie wpisywane.", [
                kol("RegionName", "VARCHAR2(80)", "Nazwa, np. małopolskie"),
                _woj,
                fk("Country", "Kraj"),
            ], (2, 3), rodzaj="słownik", unikalne=[("CountryKey", "RegionName"), ("CountryKey", "RegionCode")],
                warunki=[_woj_ck],
                wartosci=[(n, c, 1) for n, c in [
                    ("dolnośląskie", "02"), ("kujawsko-pomorskie", "04"), ("lubelskie", "06"), ("lubuskie", "08"),
                    ("łódzkie", "10"), ("małopolskie", "12"), ("mazowieckie", "14"), ("opolskie", "16"),
                    ("podkarpackie", "18"), ("podlaskie", "20"), ("pomorskie", "22"), ("śląskie", "24"),
                    ("świętokrzyskie", "26"), ("warmińsko-mazurskie", "28"), ("wielkopolskie", "30"),
                    ("zachodniopomorskie", "32")]]),
        ],
        zewnetrzne={"EmployerAccount": (0, 0), "RawRecord": (2, 0), "Country": (1, 4)},
    ),
    organizm(
        9, "C", "Warunki zatrudnienia",
        "Na jakiej umowie, za ile i z jakimi dodatkami – obietnica, którą firma składa w ogłoszeniu.",
        "Warunki to w szerszym kontekście obietnica, którą firma składa w ogłoszeniu: rodzaj umowy, wynagrodzenie i "
        "dodatki. Ich brak albo zmiana – w kolejnych publikacjach albo przy edycji tego samego ogłoszenia – to ważny "
        "sygnał dla Trust Score.",
        [
            ("Jedno ogłoszenie często daje do wyboru kilka umów, każdą z innymi widełkami (np. umowa o pracę 12–15 tys. zł "
             "brutto, B2B 15–19 tys. zł netto).", ["PostingSalary", "ContractType"]),
            ("Kwota bywa godzinowa, miesięczna albo roczna; brutto albo netto; w złotych, euro albo dolarach.",
             ["SalaryPeriod", "Currency"]),
            ("Brak widełek też jest informacją – firma podaje umowę, ale bez kwoty, dlatego kwoty mogą być puste.",
             ["PostingSalary"]),
            ("Firma zmienia widełki przy edycji ogłoszenia – stare zostają w historii (data od, data do, flaga), bo zmiana "
             "jest sygnałem.", ["PostingSalary"]),
            ("Benefity powtarzają się między ogłoszeniami i dają się pogrupować.",
             ["Benefit", "BenefitCategory", "PostingBenefit"]),
        ],
        "Czy przeliczać kwoty do jednej waluty i jednego okresu (np. złote miesięcznie brutto) w osobnej kolumnie, żeby "
        "łatwiej porównywać ogłoszenia?",
        [(2, "zbiór posting_features (widełki, umowa)")],
        [
            tabela("Currency", 300, "Waluta.", [
                _waluta,
                kol("CurrencyName", "VARCHAR2(40)", "Nazwa waluty"),
            ], (0, 0), rodzaj="słownik", warunki=[_waluta_ck],
                wartosci=[("PLN", "złoty"), ("EUR", "euro"), ("USD", "dolar amerykański"), ("GBP", "funt brytyjski")]),
            slownik("ContractType", 20, "Rodzaj umowy.",
                    ["Umowa o pracę", "Kontrakt B2B", "Umowa zlecenie", "Umowa o dzieło", "Staż lub praktyki",
                     "Umowa na zastępstwo"], (1, 0), opis_nazwy="Nazwa rodzaju umowy"),
            slownik("SalaryPeriod", 20, "Okres, za który podano kwotę.", ["Za godzinę", "Miesięcznie", "Rocznie", "Za projekt"],
                    (0, 1), dlugosc=20, opis_nazwy="Nazwa okresu"),
            tabela("PostingSalary", 300000000, "Umowa z widełkami w ogłoszeniu – kilka umów na ogłoszenie, z historią zmian.", [
                fk("JobPosting", "Ogłoszenie"),
                fk("ContractType", "Rodzaj umowy"),
                kol("SalaryFrom", "NUMBER(10,2)", "Widełki od (puste = nie podano)", pusta=True),
                kol("SalaryTo", "NUMBER(10,2)", "Widełki do", pusta=True),
                fk("Currency", "Waluta (puste, gdy brak kwoty)", pusta=True),
                fk("SalaryPeriod", "Za jaki okres (puste, gdy brak kwoty)", pusta=True),
                flaga("IsGross", "1 = kwota brutto, 0 = netto", pusta=True),
                kol("ValidFrom", "TIMESTAMP", "Od kiedy ogłoszenie podawało te warunki"),
                kol("ValidTo", "TIMESTAMP", "Do kiedy (puste = nadal)", pusta=True),
                flaga("IsCurrent", "1 = warunki aktualne"),
            ], (1, 1), rodzaj="historia",
                warunki=["SalaryFrom IS NULL OR SalaryTo IS NULL OR SalaryFrom <= SalaryTo",
                         "SalaryFrom >= 0 AND SalaryTo >= 0",
                         "(SalaryFrom IS NULL AND SalaryTo IS NULL) OR (CurrencyKey IS NOT NULL AND SalaryPeriodKey IS NOT NULL)",
                         po_kolei("ValidFrom", "ValidTo", ostro=True), zamkniety("IsCurrent", "ValidTo")],
                unikalne_gdy=[("IsCurrent = 1", ("JobPostingKey", "ContractTypeKey"))]),
            tabela("PostingBenefit", 500000000, "Benefit w ogłoszeniu – tabela łącząca ogłoszenia z benefitami.", [
                fk("JobPosting", "Ogłoszenie"),
                fk("Benefit", "Benefit"),
            ], (2, 1), rodzaj="łącząca", unikalne=[("JobPostingKey", "BenefitKey")]),
            tabela("Benefit", 1000, "Dodatek do pracy, np. prywatna opieka medyczna.", [
                kol("BenefitName", "VARCHAR2(80)", "Nazwa benefitu", unikalna=True),
                fk("BenefitCategory", "Grupa benefitu"),
            ], (2, 2), rodzaj="słownik", wartosci=[("Prywatna opieka medyczna", 1), ("Karta sportowa", 2),
                                                   ("Budżet szkoleniowy", 3), ("Elastyczne godziny pracy", 4),
                                                   ("Premia roczna", 5)]),
            slownik("BenefitCategory", 20, "Grupa benefitów.", ["Zdrowie", "Sport i rekreacja", "Rozwój", "Elastyczność",
                                                               "Finanse"], (2, 3), dlugosc=30, opis_nazwy="Nazwa grupy"),
        ],
        zewnetrzne={"JobPosting": (2, 0)},
    ),
    organizm(
        10, "C", "Wymagania i obowiązki",
        "Czego firma oczekuje od kandydata i co ma on robić – rozpisane na pola, żeby dało się porównywać.",
        "Wymaganie to w szerszym kontekście umiejętność albo cecha kandydata, której firma oczekuje – z określoną "
        "ważnością i poziomem. Rozpisane na pola pozwalają porównać kolejne publikacje tego samego stanowiska i wykryć "
        "sprzeczności, np. juniora z pięcioletnim doświadczeniem.",
        [
            ("Wymaganie jest konieczne albo tylko mile widziane.", ["RequirementLevel"]),
            ("Umiejętności są różnego rodzaju: technologia, język obcy, wykształcenie, certyfikat, uprawnienie (np. prawo "
             "jazdy) i umiejętności miękkie.", ["Skill", "SkillCategory"]),
            ("Każdy rodzaj ma inną skalę poziomów: języki A1–C2, technologie od podstawowego do zaawansowanego.",
             ["ProficiencyLevel"]),
            ("Firmy piszą to samo różnie: „JS”, „JavaScript”, „Java Script”.", ["SkillSynonym"]),
            ("Informację podała platforma w osobnym polu, znalazła ją reguła tekstowa albo model AI – zapisujemy, skąd "
             "jest.", ["ExtractionMethod"]),
            ("Obowiązki to zwykle zdania, a nie wartości ze słownika.", ["PostingResponsibility"]),
        ],
        "Czy obowiązki (PostingResponsibility) też rozbić na słownik, jak umiejętności, czy zostawić je jako zdania – tak "
        "jak teraz?",
        [(2, "zbiór posting_features"), (6, "słowniki skills_dictionary, seniority_dictionary")],
        [
            slownik("RequirementLevel", 9, "Ważność wymagania.", ["Wymagane", "Mile widziane"], (0, 0), dlugosc=20,
                    opis_nazwy="Nazwa ważności"),
            tabela("PostingResponsibility", 500000000, "Obowiązek opisany w ogłoszeniu.", [
                fk("JobPosting", "Ogłoszenie"),
                kol("ResponsibilityText", "VARCHAR2(400)", "Treść obowiązku"),
                fk("ExtractionMethod", "Skąd wiemy"),
            ], (2, 0)),
            tabela("ProficiencyLevel", 200, "Poziom znajomości – każda grupa umiejętności ma własną skalę.", [
                kol("ProficiencyLevelName", "VARCHAR2(40)", "Nazwa poziomu, np. B2"),
                fk("SkillCategory", "Dla jakiej grupy umiejętności"),
                kol("ProficiencyRank", "NUMBER(2)", "Kolejność w skali (1 = najniższy)"),
            ], (0, 1), rodzaj="słownik", unikalne=[("SkillCategoryKey", "ProficiencyLevelName")],
                wartosci=[("A2", 3, 2), ("B1", 3, 3), ("B2", 3, 4), ("C1", 3, 5), ("Podstawowy", 1, 1),
                          ("Średniozaawansowany", 1, 2), ("Zaawansowany", 1, 3)]),
            tabela("PostingRequirement", 500000000, "Wymaganie w ogłoszeniu.", [
                fk("JobPosting", "Ogłoszenie"),
                fk("Skill", "Umiejętność"),
                fk("RequirementLevel", "Wymagane czy mile widziane"),
                fk("ProficiencyLevel", "Poziom (bywa niepodany)", pusta=True),
                kol("MinYearsExperience", "NUMBER(2)", "Minimalne doświadczenie w latach", pusta=True),
                fk("ExtractionMethod", "Skąd wiemy"),
            ], (1, 1), unikalne=[("JobPostingKey", "SkillKey")], warunki=["MinYearsExperience >= 0"]),
            slownik("ExtractionMethod", 20, "Skąd pochodzi informacja.",
                    ["Pole z API platformy", "Reguła tekstowa", "Model AI", "Wpisane ręcznie"], (2, 1),
                    opis_nazwy="Nazwa źródła informacji"),
            slownik("SkillCategory", 20, "Grupa umiejętności.",
                    ["Technologia lub narzędzie", "Umiejętność miękka", "Język obcy", "Wykształcenie", "Certyfikat",
                     "Uprawnienie"], (0, 2), opis_nazwy="Nazwa grupy"),
            tabela("Skill", 50000, "Umiejętność albo kwalifikacja.", [
                kol("SkillName", "VARCHAR2(80)", "Nazwa", unikalna=True),
                fk("SkillCategory", "Grupa"),
            ], (1, 2), rodzaj="słownik", wartosci=[("SQL", 1), ("Język angielski", 3), ("Komunikatywność", 2),
                                                   ("Wykształcenie wyższe", 4), ("Prawo jazdy kat. B", 6)]),
            tabela("SkillSynonym", 500000, "Inny zapis tej samej umiejętności.", [
                fk("Skill", "Umiejętność"),
                kol("SynonymText", "VARCHAR2(80)", "Zapis spotykany w ogłoszeniach", unikalna=True),
            ], (2, 2), wartosci=[(2, "angielski"), (2, "English"), (1, "język SQL")]),
        ],
        zewnetrzne={"JobPosting": (1, 0)},
    ),
    organizm(
        11, "C", "Historia i treść ogłoszenia",
        "Co działo się z ogłoszeniem w czasie i jak zmieniała się jego treść.",
        "Ogłoszenie w szerszym kontekście nie jest jednym stanem, tylko historią: jest publikowane, edytowane, "
        "odświeżane, wygasa i wraca. Ta historia i zmiany treści są najmocniejszym dowodem na ghost job.",
        [
            ("Zdarzenia są różne: publikacja, edycja, odświeżenie (podbicie), wygaśnięcie, zamknięcie przed terminem, "
             "ponowna publikacja, usunięcie.", ["PostingEvent", "PostingEventType"]),
            ("O zdarzeniu mówi platforma albo wykrywamy je sami (np. ogłoszenie zniknęło bez komunikatu); zdarzenie "
             "wpisane ręcznie ma autora.", ["EventSource"]),
            ("Każda edycja zmienia treść – trzymamy każdą wersję, żeby widzieć, co firma zmieniła; aktualna jest jedna "
             "(flaga).", ["PostingVersion"]),
            ("Powtarzalne fragmenty bywają ogólne (klauzula RODO) albo typowe dla jednej firmy (jej stopka „O nas”). "
             "Zgoda na „przyszłe rekrutacje” to sygnał zbierania CV na zapas.",
             ["BoilerplatePattern", "BoilerplateType", "VersionBoilerplate"]),
        ],
        "Czy pełne teksty wersji trzymać w bazie (CLOB – tak jest teraz), czy tylko skróty i różnice między wersjami?",
        [(2, "zbiory posting_events, posting_texts_clean"), (6, "boilerplate_patterns i employer_boilerplate")],
        [
            slownik("EventSource", 9, "Kto powiedział nam o zdarzeniu.",
                    ["Zgłoszone przez platformę", "Wykryte przez nas", "Wpisane przez moderatora"], (0, 0),
                    opis_nazwy="Nazwa źródła zdarzenia"),
            slownik("PostingEventType", 20, "Rodzaj zdarzenia w życiu ogłoszenia.",
                    ["Opublikowano", "Edytowano treść", "Odświeżono (podbito)", "Wygasło", "Zamknięto przed terminem",
                     "Opublikowano ponownie", "Usunięto"], (0, 1), opis_nazwy="Nazwa zdarzenia"),
            tabela("PostingEvent", 1000000000, "Zdarzenie w życiu ogłoszenia – tylko dopisujemy, nic nie zmieniamy.", [
                fk("JobPosting", "Ogłoszenie"),
                fk("PostingEventType", "Co się stało"),
                fk("EventSource", "Skąd wiemy"),
                kol("OccurredAt", "TIMESTAMP", "Kiedy"),
                fk("DataDelivery", "W której dostawie przyszła informacja", pusta=True),
                fk("SystemUser", "Kto wpisał zdarzenie ręcznie (puste = platforma albo program)", pusta=True),
            ], (1, 1), rodzaj="zdarzenia"),
            tabela("PostingVersion", 300000000, "Wersja treści ogłoszenia – każda edycja to nowy wiersz, aktualna jest jedna.", [
                fk("JobPosting", "Ogłoszenie"),
                kol("VersionNumber", "NUMBER(3)", "Numer wersji (1, 2, 3…)"),
                kol("VersionTitle", "VARCHAR2(200)", "Tytuł w tej wersji"),
                kol("OriginalText", "CLOB", "Treść tak, jak przyszła"),
                kol("CleanText", "CLOB", "Treść bez stopek i klauzul", pusta=True),
                kol("TextHash", "VARCHAR2(64)", "Skrót treści – szybkie porównanie wersji"),
                kol("ValidFrom", "TIMESTAMP", "Od kiedy treść była taka"),
                kol("ValidTo", "TIMESTAMP", "Do kiedy (puste = aktualna)", pusta=True),
                flaga("IsCurrent", "1 = wersja aktualna"),
            ], (2, 1), rodzaj="historia", unikalne=[("JobPostingKey", "VersionNumber")],
                warunki=[po_kolei("ValidFrom", "ValidTo", ostro=True), zamkniety("IsCurrent", "ValidTo")],
                unikalne_gdy=[("IsCurrent = 1", ("JobPostingKey",))]),
            tabela("BoilerplatePattern", 100000, "Powtarzalny fragment tekstu do rozpoznania w ogłoszeniach.", [
                fk("BoilerplateType", "Rodzaj fragmentu"),
                kol("PatternText", "VARCHAR2(1000)", "Treść albo wzorzec fragmentu"),
                fk("Employer", "Firma, której to fragment (puste = wzorzec ogólny)", pusta=True),
            ], (3, 1)),
            tabela("VersionBoilerplate", 1000000000, "Fragment znaleziony w wersji ogłoszenia – tabela łącząca.", [
                fk("PostingVersion", "Wersja ogłoszenia"),
                fk("BoilerplatePattern", "Znaleziony fragment"),
            ], (2, 2), rodzaj="łącząca", unikalne=[("PostingVersionKey", "BoilerplatePatternKey")]),
            slownik("BoilerplateType", 20, "Rodzaj powtarzalnego fragmentu.",
                    ["Stopka „O nas”", "Klauzula RODO", "Zgoda na przyszłe rekrutacje", "Formatowanie HTML"], (3, 2),
                    opis_nazwy="Nazwa rodzaju fragmentu"),
        ],
        zewnetrzne={"DataDelivery": (1, 0), "JobPosting": (2, 0), "Employer": (3, 0), "SystemUser": (1, 2)},
    ),
    organizm(
        12, "C", "Podobne ogłoszenia i rodziny",
        "Które ogłoszenia są powtórkami i jak długo to samo stanowisko krąży po platformach.",
        "Podobieństwo to w szerszym kontekście relacja między dwoma ogłoszeniami, zmierzona konkretną metodą. Z wielu "
        "takich par powstaje rodzina – wszystkie publikacje tego samego stanowiska jednej firmy w czasie. Historia "
        "rodziny (ile razy wracała, jak długo była widoczna) to główny sygnał ghost joba.",
        [
            ("Powtórka bywa dokładną kopią, tą samą treścią innymi słowami, tym samym etatem z innym poziomem albo tym "
             "samym ogłoszeniem na innej platformie.", ["SimilarityType"]),
            ("Podobieństwo liczymy różnymi metodami (porównanie tekstu, wektory znaczenia z modelu AI, porównanie cech). "
             "Nazwę metody wybieramy z listy, a jej wersje zapisujemy osobno – z jednej wersji każdej metody korzystamy "
             "teraz (flaga).", ["SimilarityMethod", "SimilarityMethodVersion"]),
            ("Para to dwa ogłoszenia z tej samej tabeli, więc tabela ma dwa klucze obce do JobPosting.",
             ["SimilarityPair"]),
            ("Rodzina zbiera wiele ogłoszeń; po przeliczeniu ogłoszenie może przejść do innej rodziny – członkostwo ma daty "
             "i flagę, a historię rodziny liczymy co jakiś czas od nowa (stan na dany dzień).",
             ["PostingFamily", "FamilyMember", "FamilyLifecycle"]),
        ],
        "Czy ogłoszenie może należeć do kilku rodzin naraz? Teraz w danej chwili tylko do jednej (indeks unikalny wśród "
        "aktualnych członkostw w FamilyMember).",
        [(2, "zbiory similar_posting_pairs, posting_families, posting_lifecycles")],
        [
            slownik("SimilarityType", 20, "Rodzaj powtórki.",
                    ["Dokładna kopia", "Ta sama treść innymi słowami", "Ten sam etat z innym poziomem",
                     "To samo ogłoszenie na innej platformie"], (0, 0), opis_nazwy="Nazwa rodzaju powtórki"),
            slownik("SimilarityMethod", 20, "Metoda liczenia podobieństwa – nazwa wybierana z listy.",
                    ["Porównanie tekstu", "Wektory znaczenia (model AI)", "Porównanie cech ogłoszenia"], (2, 0),
                    dlugosc=60, opis_nazwy="Nazwa metody"),
            tabela("SimilarityMethodVersion", 200, "Wersja metody liczenia podobieństwa – z jednej wersji każdej metody "
                   "korzystamy teraz.", [
                       fk("SimilarityMethod", "Metoda"),
                       kol("VersionLabel", "VARCHAR2(20)", "Wersja, np. 1.0"),
                       kol("ValidFrom", "DATE", "Od kiedy używana"),
                       kol("ValidTo", "DATE", "Do kiedy (puste = nadal)", pusta=True),
                       flaga("IsCurrent", "1 = wersja używana teraz"),
                   ], (1, 0), rodzaj="historia", unikalne=[("SimilarityMethodKey", "VersionLabel")],
                   warunki=[po_kolei("ValidFrom", "ValidTo"), zamkniety("IsCurrent", "ValidTo")],
                   unikalne_gdy=[("IsCurrent = 1", ("SimilarityMethodKey",))],
                   wartosci=[(1, "1.0", "2026-11-01", None, 1), (2, "1.0", "2026-11-01", None, 1),
                             (3, "1.0", "2026-11-01", None, 1)]),
            tabela("SimilarityPair", 2000000000, "Para podobnych ogłoszeń – dwa klucze obce do tej samej tabeli.", [
                fk("JobPosting", "Pierwsze ogłoszenie (wcześniejsze)", nazwa="FirstJobPostingKey"),
                fk("JobPosting", "Drugie ogłoszenie", nazwa="SecondJobPostingKey"),
                fk("SimilarityType", "Rodzaj powtórki"),
                fk("SimilarityMethodVersion", "Metoda w konkretnej wersji"),
                kol("SimilarityScore", "NUMBER(4,3)", "Podobieństwo od 0 do 1"),
                kol("DetectedAt", "TIMESTAMP", "Kiedy wykryto"),
            ], (0, 1), unikalne=[("FirstJobPostingKey", "SecondJobPostingKey", "SimilarityMethodVersionKey")],
                warunki=["FirstJobPostingKey < SecondJobPostingKey", "SimilarityScore BETWEEN 0 AND 1"]),
            tabela("FamilyMember", 100000000, "Ogłoszenie w rodzinie – przypisanie w czasie; w danej chwili ogłoszenie jest "
                   "najwyżej w jednej rodzinie.", [
                       fk("PostingFamily", "Rodzina"),
                       fk("JobPosting", "Ogłoszenie"),
                       kol("AddedAt", "TIMESTAMP", "Kiedy dołączono do rodziny"),
                       kol("RemovedAt", "TIMESTAMP", "Kiedy przeniesiono do innej rodziny (puste = nadal)", pusta=True),
                       flaga("IsCurrent", "1 = członkostwo aktualne"),
                   ], (2, 1), rodzaj="przypisanie",
                   warunki=[po_kolei("AddedAt", "RemovedAt"), zamkniety("IsCurrent", "RemovedAt")],
                   unikalne_gdy=[("IsCurrent = 1", ("JobPostingKey",))]),
            tabela("PostingFamily", 30000000, "Rodzina ogłoszeń – to samo stanowisko jednej firmy w czasie.", [
                fk("Employer", "Firma"),
                kol("FamilyLabel", "VARCHAR2(200)", "Opis stanowiska, np. „Księgowa, Kraków”"),
                kol("FirstSeenDate", "DATE", "Pierwsza publikacja"),
                kol("LastSeenDate", "DATE", "Ostatnia publikacja"),
            ], (3, 1), warunki=["LastSeenDate >= FirstSeenDate"]),
            tabela("FamilyLifecycle", 1000000000, "Historia rodziny policzona na dany dzień.", [
                fk("PostingFamily", "Rodzina"),
                kol("CalculatedOn", "DATE", "Dzień obliczenia"),
                kol("PublicationCount", "NUMBER(4)", "Ile razy publikowano"),
                kol("VisibleDays", "NUMBER(5)", "Ile dni łącznie było widoczne"),
                kol("GapCount", "NUMBER(4)", "Ile razy znikało i wracało"),
                kol("RefreshCount", "NUMBER(5)", "Ile razy odświeżano"),
                kol("PlatformCount", "NUMBER(3)", "Na ilu platformach"),
                kol("SeniorityVariantCount", "NUMBER(2)", "Ile różnych poziomów stanowiska"),
            ], (3, 2), rodzaj="migawka", unikalne=[("PostingFamilyKey", "CalculatedOn")],
                warunki=["PublicationCount >= 0 AND VisibleDays >= 0 AND GapCount >= 0 AND RefreshCount >= 0 "
                         "AND PlatformCount >= 0 AND SeniorityVariantCount >= 0"]),
        ],
        zewnetrzne={"JobPosting": (1, 1), "Employer": (3, 0)},
    ),
    # ───────────── D. KANDYDAT I ZGŁOSZENIA ─────────────
    organizm(
        13, "D", "Kandydat, aplikacje i zgody",
        "Osoba znana tylko z pseudonimu, jej aplikacje potwierdzone przez platformę i jej zgody.",
        "Kandydat to w szerszym kontekście osoba, której nie znamy i nie chcemy znać – zapisujemy tylko to, co "
        "potrzebne, żeby potwierdzić, że naprawdę aplikowała. Aplikacja to fakt potwierdzony przez platformę, a zgoda "
        "to warunek, bez którego nie wolno nam np. wysyłać przypomnień.",
        [
            ("Kandydata znamy tylko jako pseudonim nadany przez platformę; ta sama osoba na dwóch platformach to dla nas "
             "dwa różne pseudonimy.", ["CandidatePseudonym"]),
            ("Aplikacja przechodzi przez stany: wysłana, wyświetlona, odrzucona automatycznie, zaproszenie na rozmowę, "
             "oferta, zatrudnienie, wycofana – jeśli platforma je zna. Aktualny stan oznacza flaga w historii.",
             ["ApplicationStatus", "ApplicationStatusChange"]),
            ("Zgoda dotyczy konkretnej rzeczy (przypomnienia, cechy urządzenia) i konkretnej wersji tekstu; można ją "
             "wycofać – każda decyzja to nowy wiersz, a aktualna wersja tekstu jest jedna.",
             ["ConsentType", "ConsentTextVersion", "Consent"]),
        ],
        "Czy aktualny stan aplikacji oznaczać flagą w historii stanów (tak jest teraz), czy osobną kolumną w Application?",
        [(3, "zbiory application_log, consents")],
        [
            tabela("CandidatePseudonym", 100000000, "Kandydat znany tylko z pseudonimu nadanego przez platformę.", [
                fk("SourcePlatform", "Platforma, która nadała pseudonim"),
                kol("PseudonymValue", "VARCHAR2(64)", "Ciąg znaków od platformy"),
                kol("FirstSeenAt", "TIMESTAMP", "Kiedy pierwszy raz się pojawił"),
            ], (0, 1), unikalne=[("SourcePlatformKey", "PseudonymValue")]),
            tabela("Application", 1000000000, "Aplikacja kandydata na ogłoszenie, potwierdzona przez platformę.", [
                fk("CandidatePseudonym", "Kandydat"),
                fk("JobPosting", "Ogłoszenie"),
                kol("AppliedAt", "TIMESTAMP", "Kiedy aplikował"),
                fk("DataDelivery", "W której dostawie przyszła informacja", pusta=True),
            ], (1, 1), unikalne=[("CandidatePseudonymKey", "JobPostingKey")]),
            tabela("Consent", 300000000, "Decyzja kandydata o zgodzie – udzielenie albo wycofanie to nowy wiersz.", [
                fk("CandidatePseudonym", "Kandydat"),
                fk("ConsentTextVersion", "Treść zgody, którą widział"),
                flaga("IsGranted", "1 = zgoda udzielona, 0 = wycofana"),
                kol("DecidedAt", "TIMESTAMP", "Kiedy"),
            ], (0, 2), rodzaj="historia"),
            tabela("ApplicationStatusChange", 5000000000, "Zmiana stanu aplikacji – historia; aktualny stan jest jeden.", [
                fk("Application", "Aplikacja"),
                fk("ApplicationStatus", "Nowy stan"),
                kol("ChangedAt", "TIMESTAMP", "Kiedy"),
                flaga("IsCurrent", "1 = stan aktualny"),
            ], (1, 2), rodzaj="historia", unikalne_gdy=[("IsCurrent = 1", ("ApplicationKey",))]),
            slownik("ApplicationStatus", 20, "Stan aplikacji.",
                    ["Wysłana", "Wyświetlona przez firmę", "Odrzucona automatycznie", "Zaproszenie na rozmowę",
                     "Oferta pracy", "Zatrudnienie", "Wycofana przez kandydata"], (2, 2), opis_nazwy="Nazwa stanu"),
            tabela("ConsentTextVersion", 200, "Wersja treści zgody, którą kandydat zobaczył; aktualna jest jedna na rodzaj "
                   "zgody.", [
                       fk("ConsentType", "Na co jest zgoda"),
                       kol("VersionLabel", "VARCHAR2(10)", "Oznaczenie wersji, np. 1.2"),
                       kol("ConsentText", "CLOB", "Pełna treść zgody"),
                       kol("ValidFrom", "DATE", "Od kiedy pokazywana"),
                       kol("ValidTo", "DATE", "Do kiedy (puste = nadal)", pusta=True),
                       flaga("IsCurrent", "1 = wersja pokazywana teraz"),
                   ], (0, 3), rodzaj="historia", unikalne=[("ConsentTypeKey", "VersionLabel")],
                   warunki=[po_kolei("ValidFrom", "ValidTo"), zamkniety("IsCurrent", "ValidTo")],
                   unikalne_gdy=[("IsCurrent = 1", ("ConsentTypeKey",))]),
            slownik("ConsentType", 20, "Na co kandydat się zgadza.",
                    ["Przypomnienia o wyniku rekrutacji", "Zbieranie cech urządzenia"], (1, 3), opis_nazwy="Nazwa zgody"),
        ],
        zewnetrzne={"SourcePlatform": (0, 0), "JobPosting": (1, 0), "DataDelivery": (2, 0)},
    ),
    organizm(
        14, "D", "Zgłoszenie wyniku rekrutacji",
        "Relacja kandydata o tym, co stało się po aplikacji, i przypomnienia, które go o to pytają.",
        "Zgłoszenie to w szerszym kontekście informacja od kandydata: co stało się po aplikacji. To pojedyncza, "
        "niesprawdzona informacja – dowodem staje się dopiero wiele zgłoszeń po weryfikacji (organizm 15).",
        [
            ("Wynik bywa różny: cisza, automatyczna odmowa, odmowa po rozmowie, wycofana oferta, zatrudnienie, "
             "nieaktualne ogłoszenie.", ["ReportOutcome"]),
            ("Ważne jest, na którym etapie rekrutacja się skończyła: po CV, po teście, po rozmowie, po ofercie.",
             ["RecruitmentStage"]),
            ("Kandydat zgłasza sam z siebie albo w odpowiedzi na przypomnienie; przypomnienie dotyczy aplikacji – pary "
             "kandydat i ogłoszenie – tak jak wizyta dotyczy lekarza w konkretnej placówce.",
             ["ReportChannel", "Reminder", "ReminderStatus"]),
        ],
        "Czy kandydat może zmienić swoje zgłoszenie (np. najpierw „cisza”, potem „zatrudnienie”) i czy to ma być nowy "
        "wiersz, czy poprawka starego?",
        [(3, "zbiory reports, reminders_sent")],
        [
            slownik("ReportOutcome", 20, "Wynik rekrutacji według kandydata.",
                    ["Brak odpowiedzi (cisza)", "Automatyczna odmowa", "Odmowa po rozmowie", "Oferta wycofana",
                     "Zatrudnienie", "Ogłoszenie było nieaktualne"], (0, 1), opis_nazwy="Nazwa wyniku"),
            tabela("RecruitmentReport", 500000000, "Zgłoszenie wyniku rekrutacji – tylko dopisujemy, nie poprawiamy.", [
                fk("CandidatePseudonym", "Kto zgłasza"),
                fk("JobPosting", "Którego ogłoszenia dotyczy"),
                fk("ReportOutcome", "Wynik"),
                fk("RecruitmentStage", "Na którym etapie się skończyło"),
                fk("ReportChannel", "Jak zgłoszono"),
                fk("Reminder", "Przypomnienie, po którym przyszło zgłoszenie", pusta=True),
                kol("ReportedAt", "TIMESTAMP", "Kiedy zgłoszono"),
            ], (1, 1), rodzaj="zdarzenia"),
            tabela("Reminder", 1000000000, "Przypomnienie wysłane kandydatowi przez platformę na naszą prośbę.", [
                fk("Application", "Aplikacja, o którą pytamy"),
                fk("ReminderStatus", "Co się stało z przypomnieniem"),
                kol("ReminderNumber", "NUMBER(1)", "Które to przypomnienie (1, 2…)"),
                kol("SentAt", "TIMESTAMP", "Kiedy zlecono"),
            ], (2, 1), unikalne=[("ApplicationKey", "ReminderNumber")], warunki=["ReminderNumber >= 1"]),
            slownik("RecruitmentStage", 20, "Etap rekrutacji.",
                    [("Po wysłaniu CV", 1), ("Po zadaniu lub teście", 2), ("Po pierwszej rozmowie", 3),
                     ("Po kolejnej rozmowie", 4), ("Po otrzymaniu oferty", 5)], (0, 2), opis_nazwy="Nazwa etapu",
                    kolumny=[kol("StageRank", "NUMBER(2)", "Kolejność etapów")]),
            slownik("ReportChannel", 9, "Jak przyszło zgłoszenie.", ["Formularz w widżecie", "Odpowiedź na przypomnienie"],
                    (1, 2), opis_nazwy="Nazwa kanału"),
            slownik("ReminderStatus", 20, "Los przypomnienia.",
                    ["Zlecone platformie", "Dostarczone", "Bez odpowiedzi", "Kandydat odpowiedział"], (2, 2),
                    opis_nazwy="Nazwa stanu przypomnienia"),
        ],
        zewnetrzne={"CandidatePseudonym": (0, 0), "JobPosting": (1, 0), "Application": (2, 0)},
    ),
    organizm(
        15, "D", "Weryfikacja zgłoszenia",
        "Niezależne sprawdzenia każdego zgłoszenia i ocena, czy liczy się do Trust Score.",
        "Weryfikacja to w szerszym kontekście zestaw niezależnych sprawdzeń, z których każde daje swój wynik, a na "
        "końcu jedna ocena: czy zgłoszenie liczy się do Trust Score. Dzięki temu konkurencja nie obniży oceny firmy "
        "fałszywymi skargami.",
        [
            ("Sprawdzenia są różnego rodzaju: człowiek czy bot (Cloudflare), dowód aplikacji, odcisk urządzenia, udział "
             "w fali zgłoszeń. Nowy rodzaj sprawdzenia to nowy wiersz, a nie nowa tabela.", ["CheckType", "ReportCheck"]),
            ("Sprawdzenie wychodzi pozytywnie albo negatywnie, może się nie udać (usługa nie działa) albo być "
             "przedwczesne.", ["CheckResult"]),
            ("Z jednego urządzenia przychodzą zgłoszenia z wielu pseudonimów; samo urządzenie zapisujemy tylko jako "
             "skrót i krótko.", ["DeviceFingerprint", "ReportDevice"]),
            ("Ocena kończy się różnie: przyjęte, do moderacji, odrzucone; zgłoszenie można ocenić ponownie – każda ocena "
             "to nowy wiersz, aktualna jest jedna, a ocenę wydaje program albo moderator.",
             ["ReportVerdict", "VerdictDecision"]),
            ("Reguły oceny mają wersje wybierane z listy – z jednej wersji korzystamy teraz.", ["VerdictRuleSet"]),
        ],
        "Czy wyniki wszystkich sprawdzeń trzymać w jednej tabeli ReportCheck – tak jest teraz – czy każde sprawdzenie w "
        "osobnej tabeli z własnymi kolumnami?",
        [(3, "zbiory bot_checks, device_fingerprints, report_verdicts, widok validated_reports")],
        [
            slownik("CheckType", 20, "Rodzaj sprawdzenia.",
                    ["Człowiek czy bot (Cloudflare)", "Dowód aplikacji", "Odcisk urządzenia", "Fala zgłoszeń"], (0, 0),
                    opis_nazwy="Nazwa sprawdzenia"),
            slownik("VerdictDecision", 9, "Decyzja o zgłoszeniu.", ["Przyjęte", "Do moderacji", "Odrzucone"], (2, 0),
                    dlugosc=20, opis_nazwy="Nazwa decyzji"),
            tabela("ReportCheck", 3000000000, "Wynik jednego sprawdzenia jednego zgłoszenia.", [
                fk("RecruitmentReport", "Zgłoszenie"),
                fk("CheckType", "Rodzaj sprawdzenia"),
                fk("CheckResult", "Wynik"),
                kol("CheckedAt", "TIMESTAMP", "Kiedy sprawdzono"),
                kol("CheckDetails", "VARCHAR2(400)", "Szczegóły, np. „aplikacja 34 dni temu”", pusta=True),
            ], (0, 1), rodzaj="zdarzenia"),
            tabela("ReportVerdict", 1000000000, "Ocena zgłoszenia – każda ponowna ocena to nowy wiersz, aktualna jest jedna.", [
                fk("RecruitmentReport", "Zgłoszenie"),
                fk("VerdictDecision", "Decyzja"),
                fk("VerdictRuleSet", "Według której wersji reguł"),
                kol("ReportWeight", "NUMBER(3,2)", "Waga od 0 do 1"),
                kol("DecidedAt", "TIMESTAMP", "Kiedy oceniono"),
                flaga("IsCurrent", "1 = ocena aktualna"),
                fk("SystemUser", "Kto ocenił (puste = program)", pusta=True),
            ], (2, 1), rodzaj="historia", warunki=["ReportWeight BETWEEN 0 AND 1"],
                unikalne_gdy=[("IsCurrent = 1", ("RecruitmentReportKey",))]),
            tabela("VerdictRuleSet", 200, "Wersja reguł oceny zgłoszeń – wybierana z listy; aktualna jest jedna.", [
                kol("VersionLabel", "VARCHAR2(20)", "Wersja, np. 1.0", unikalna=True),
                kol("RuleDescription", "VARCHAR2(300)", "Co mówią reguły"),
                kol("ValidFrom", "DATE", "Od kiedy obowiązują"),
                kol("ValidTo", "DATE", "Do kiedy (puste = nadal)", pusta=True),
                flaga("IsCurrent", "1 = reguły używane teraz"),
            ], (3, 1), rodzaj="historia", warunki=[po_kolei("ValidFrom", "ValidTo"), zamkniety("IsCurrent", "ValidTo")],
                unikalne_gdy=[("IsCurrent = 1", ())],
                wartosci=[("1.0", "Cztery sprawdzenia; przyjęte, gdy wszystkie są pozytywne", "2026-11-01", None, 1)]),
            slownik("CheckResult", 9, "Wynik sprawdzenia.", ["Pozytywny", "Negatywny", "Nie dało się sprawdzić",
                                                            "Za wcześnie"], (0, 2), dlugosc=30, opis_nazwy="Nazwa wyniku"),
            tabela("ReportDevice", 500000000, "Urządzenie, z którego wysłano zgłoszenie – tabela łącząca.", [
                fk("RecruitmentReport", "Zgłoszenie", unikalna=True),
                fk("DeviceFingerprint", "Urządzenie"),
            ], (1, 2), rodzaj="łącząca"),
            tabela("DeviceFingerprint", 100000000, "Urządzenie zapisane tylko jako skrót cech.", [
                kol("FingerprintHash", "VARCHAR2(64)", "Skrót cech urządzenia (bez samych cech)", unikalna=True),
                kol("FirstSeenAt", "TIMESTAMP", "Kiedy pierwszy raz"),
                kol("ExpiresAt", "DATE", "Kiedy usunąć – dane osobowe trzymamy krótko"),
            ], (1, 3)),
        ],
        zewnetrzne={"RecruitmentReport": (1, 1), "SystemUser": (2, 2)},
    ),
    organizm(
        16, "D", "Wykrywanie nadużyć",
        "Wzorce wielu podejrzanych zgłoszeń naraz – podejrzenie, które potwierdza albo odrzuca człowiek.",
        "Nadużycie to w szerszym kontekście nie jedno zgłoszenie, tylko wzorzec wielu zgłoszeń: atak konkurencji, firma "
        "chwaląca samą siebie, jedna osoba udająca wielu kandydatów. Alert to podejrzenie, które musi potwierdzić albo "
        "odrzucić człowiek.",
        [
            ("Wzorce są różne: fala negatywnych zgłoszeń na jedną firmę, fala pozytywnych zgłoszeń od samej firmy, jedno "
             "urządzenie z wieloma pseudonimami, zgłoszenia od pseudonimów bez aplikacji.", ["AlertType"]),
            ("Alert przechodzi przez stany: nowy, w moderacji, potwierdzone nadużycie, fałszywy alarm. Każda zmiana stanu "
             "to wpis w historii z autorem – aktualny stan jest jeden.", ["AlertStatus", "AlertStatusChange"]),
            ("Jeden alert obejmuje wiele zgłoszeń, a jedno zgłoszenie może trafić do kilku alertów – relacja wiele do "
             "wielu.", ["AlertReport"]),
        ],
        "Czy alert dotyczy zawsze jednej firmy (EmployerKey – tak jest teraz), czy może dotyczyć np. całej platformy?",
        [(3, "zbiór abuse_alerts")],
        [
            slownik("AlertType", 20, "Rodzaj podejrzanego wzorca.",
                    ["Fala negatywnych zgłoszeń", "Fala pozytywnych zgłoszeń od samej firmy",
                     "Jedno urządzenie, wiele pseudonimów", "Zgłoszenia bez aplikacji"], (0, 0), dlugosc=50,
                    opis_nazwy="Nazwa wzorca"),
            slownik("AlertStatus", 20, "Stan alertu.", ["Nowy", "W moderacji", "Potwierdzone nadużycie", "Fałszywy alarm"],
                    (3, 1), dlugosc=30, opis_nazwy="Nazwa stanu"),
            tabela("AbuseAlert", 1000000, "Alert o podejrzanej fali zgłoszeń dotyczącej jednej firmy.", [
                fk("Employer", "Firma"),
                fk("AlertType", "Rodzaj wzorca"),
                kol("WindowStart", "TIMESTAMP", "Początek okresu fali"),
                kol("WindowEnd", "TIMESTAMP", "Koniec okresu fali"),
                kol("DetectedAt", "TIMESTAMP", "Kiedy wykryto"),
                kol("ReportCount", "NUMBER(6)", "Ile zgłoszeń w fali"),
            ], (1, 1), warunki=["WindowEnd >= WindowStart"]),
            tabela("AlertStatusChange", 5000000, "Zmiana stanu alertu – historia z autorem; aktualny stan jest jeden.", [
                fk("AbuseAlert", "Alert"),
                fk("AlertStatus", "Nowy stan"),
                kol("ChangedAt", "TIMESTAMP", "Kiedy"),
                kol("ChangeComment", "VARCHAR2(300)", "Uzasadnienie", pusta=True),
                fk("SystemUser", "Kto zmienił (puste = program)", pusta=True),
                flaga("IsCurrent", "1 = stan aktualny"),
            ], (2, 1), rodzaj="historia", unikalne_gdy=[("IsCurrent = 1", ("AbuseAlertKey",))]),
            tabela("AlertReport", 50000000, "Zgłoszenie objęte alertem – tabela łącząca.", [
                fk("AbuseAlert", "Alert"),
                fk("RecruitmentReport", "Zgłoszenie"),
            ], (1, 2), rodzaj="łącząca", unikalne=[("AbuseAlertKey", "RecruitmentReportKey")]),
        ],
        zewnetrzne={"Employer": (1, 0), "RecruitmentReport": (0, 2), "SystemUser": (2, 2)},
    ),
    # ───────────── E. OCENA FIRMY ─────────────
    organizm(
        17, "E", "Sygnały o firmie",
        "Liczby opisujące zachowanie firmy, policzone na dany dzień – wejście do Trust Score.",
        "Sygnał to w szerszym kontekście jedna zmierzona liczba o firmie, np. „38% ogłoszeń to powtórki” albo „2 "
        "zatrudnienia na 100 aplikacji”. Sygnały liczymy z wielu organizmów naraz i zapisujemy jako stan na dany dzień – "
        "tak widać, jak firma zmienia się w czasie.",
        [
            ("Sygnałów jest wiele rodzajów, mają różne jednostki (%, dni, liczba), a dla jednych więcej znaczy lepiej, "
             "dla innych gorzej. Jednostkę wybieramy z listy, a nie wpisujemy.", ["SignalType", "MeasureUnit"]),
            ("Nowy rodzaj sygnału nie może wymagać zmiany tabel – dlatego wartości są w wierszach, a nie w osobnych "
             "kolumnach.", ["SignalValue"]),
            ("Sygnał z 2 zgłoszeń jest mniej wiarygodny niż z 200 – zapisujemy, na ilu danych się opiera.",
             ["SignalValue"]),
            ("Sygnały liczymy wiele razy; każdy stan to nowy wiersz z datą.", ["SignalSnapshot"]),
            ("Sygnały dzielą się na grupy: powtórki ogłoszeń, odpowiedzi firmy, przejrzystość ogłoszeń, dane z rejestrów.",
             ["SignalGroup"]),
        ],
        "Czy zapis sygnałów w wierszach (SignalType + SignalValue) jest dobry, czy lepsza będzie osobna kolumna dla "
        "każdego sygnału?",
        [(4, "zbiór employer_signals")],
        [
            slownik("SignalGroup", 20, "Grupa sygnałów.",
                    ["Powtórki ogłoszeń", "Odpowiedzi firmy na aplikacje", "Przejrzystość ogłoszeń", "Dane z rejestrów"],
                    (2, 0), opis_nazwy="Nazwa grupy"),
            tabela("SignalSnapshot", 1000000000, "Stan sygnałów jednej firmy na dany dzień.", [
                fk("Employer", "Firma"),
                kol("SnapshotDate", "DATE", "Na jaki dzień"),
            ], (0, 1), rodzaj="migawka", unikalne=[("EmployerKey", "SnapshotDate")]),
            tabela("SignalValue", 10000000000, "Wartość jednego sygnału w jednym stanie.", [
                fk("SignalSnapshot", "Stan na dany dzień"),
                fk("SignalType", "Rodzaj sygnału"),
                kol("SignalNumericValue", "NUMBER(12,4)", "Wartość"),
                kol("BasedOnCount", "NUMBER(7)", "Na ilu danych opiera się wartość", pusta=True),
            ], (1, 1), unikalne=[("SignalSnapshotKey", "SignalTypeKey")]),
            tabela("SignalType", 200, "Rodzaj sygnału z jednostką i kierunkiem.", [
                kol("SignalTypeName", "VARCHAR2(80)", "Nazwa sygnału", unikalna=True),
                fk("SignalGroup", "Grupa"),
                fk("MeasureUnit", "Jednostka"),
                flaga("HigherIsBetter", "1 = im więcej, tym lepiej dla firmy"),
                kol("SignalDescription", "VARCHAR2(300)", "Jak liczymy", pusta=True),
            ], (2, 1), rodzaj="słownik",
                wartosci=[("Odsetek ogłoszeń będących powtórkami", 1, 1, 0, None),
                          ("Średnia liczba publikacji jednego stanowiska", 1, 3, 0, None),
                          ("Zatrudnienia na 100 aplikacji", 2, 4, 1, None),
                          ("Zgłoszenia ciszy na 100 aplikacji", 2, 4, 0, None),
                          ("Odsetek ogłoszeń z widełkami", 3, 1, 1, None),
                          ("Wiek firmy w rejestrze", 4, 2, 1, None)]),
            slownik("MeasureUnit", 20, "Jednostka sygnału – wybierana z listy, a nie wpisywana.",
                    [("procent", "%"), ("dzień", "dni"), ("liczba", None), ("liczba na 100 aplikacji", "/100")], (2, 2),
                    opis_nazwy="Nazwa jednostki",
                    kolumny=[kol("MeasureUnitSymbol", "VARCHAR2(10)", "Skrót pokazywany przy wartości, np. %",
                                 pusta=True)]),
        ],
        zewnetrzne={"Employer": (0, 0)},
    ),
    organizm(
        18, "E", "Trust Score i publikacja",
        "Wynik firmy policzony konkretną metodą, z pewnością i powodami – oraz to, co wolno pokazać kandydatowi.",
        "Trust Score to w szerszym kontekście ocena wystawiona według konkretnej metody, w konkretnym dniu i na "
        "konkretnych danych – a nie stała cecha firmy. Dlatego każdy wynik ma metodę, pewność i powody, a to, co widzi "
        "kandydat, jest zapisane osobno od wyniku roboczego.",
        [
            ("Wynik liczymy różnymi metodami: na start wagami ustalonymi przez zespół, później wytrenowanym modelem; "
             "metody mają wersje, a używana teraz jest jedna.", ["ScoringMethod", "ScoringMethodType"]),
            ("Każda metoda daje inną wagę każdemu sygnałowi – relacja wiele do wielu z wartością.", ["ScoringWeight"]),
            ("Wynik ma pewność i 2–3 główne powody, które widzi kandydat i firma.", ["TrustScore", "ScoreReason"]),
            ("Nie każdy wynik wolno pokazać: przy małej pewności pokazujemy „za mało danych”, ostrzeżenie czeka na decyzję "
             "moderatora, a po odwołaniu wynik można wycofać. Dla firmy widoczna jest jedna aktualna publikacja.",
             ["PublishedScore", "PublicationStatus"]),
        ],
        "Czy wynik publiczny (PublishedScore) może się różnić od ostatniego wyniku roboczego (np. gdy jest wstrzymany), "
        "czy zawsze ma pokazywać ostatni?",
        [(4, "zbiory trust_score_history, published_trust_scores, model_registry")],
        [
            slownik("ScoringMethodType", 9, "Rodzaj metody liczenia wyniku.",
                    ["Wagi ustalone przez zespół", "Wytrenowany model"], (0, 0), opis_nazwy="Nazwa rodzaju metody"),
            tabela("ScoringMethod", 200, "Metoda liczenia wyniku w konkretnej wersji; używana teraz jest jedna.", [
                fk("ScoringMethodType", "Rodzaj metody"),
                kol("MethodVersion", "VARCHAR2(20)", "Wersja"),
                kol("ValidFrom", "DATE", "Od kiedy używana"),
                kol("ValidTo", "DATE", "Do kiedy (puste = obecna)", pusta=True),
                flaga("IsCurrent", "1 = metoda używana teraz"),
            ], (1, 0), rodzaj="historia", unikalne=[("ScoringMethodTypeKey", "MethodVersion")],
                warunki=[po_kolei("ValidFrom", "ValidTo"), zamkniety("IsCurrent", "ValidTo")],
                unikalne_gdy=[("IsCurrent = 1", ())],
                wartosci=[(1, "1.0", "2026-12-01", None, 1)]),
            tabela("ScoringWeight", 50000, "Waga sygnału w danej metodzie – tabela łącząca z wartością.", [
                fk("ScoringMethod", "Metoda"),
                fk("SignalType", "Sygnał"),
                kol("WeightValue", "NUMBER(5,3)", "Waga"),
            ], (2, 0), rodzaj="łącząca", unikalne=[("ScoringMethodKey", "SignalTypeKey")]),
            tabela("TrustScore", 2000000000, "Wynik roboczy – każde przeliczenie to nowy wiersz.", [
                fk("SignalSnapshot", "Na jakich danych liczono"),
                fk("ScoringMethod", "Jaką metodą"),
                kol("ScoreValue", "NUMBER(3)", "Wynik od 0 do 100"),
                kol("ScoreConfidence", "NUMBER(3,2)", "Pewność od 0 do 1"),
                kol("CalculatedAt", "TIMESTAMP", "Kiedy policzono"),
            ], (1, 1), rodzaj="historia", warunki=["ScoreValue BETWEEN 0 AND 100", "ScoreConfidence BETWEEN 0 AND 1"]),
            tabela("ScoreReason", 6000000000, "Powód wyniku pokazywany kandydatowi i firmie.", [
                fk("TrustScore", "Wynik"),
                fk("SignalType", "Którego sygnału dotyczy"),
                kol("ReasonRank", "NUMBER(1)", "Kolejność ważności"),
                kol("ReasonText", "VARCHAR2(300)", "Tekst, np. „to samo ogłoszenie 7 razy w 9 miesięcy”"),
            ], (2, 1), unikalne=[("TrustScoreKey", "ReasonRank")]),
            tabela("PublishedScore", 100000000, "Wynik pokazany publicznie – osobno od wyniku roboczego; dla firmy aktualna "
                   "jest jedna publikacja.", [
                       fk("Employer", "Której firmy dotyczy"),
                       fk("TrustScore", "Który wynik pokazujemy"),
                       fk("PublicationStatus", "Stan publikacji"),
                       kol("PublishedFrom", "TIMESTAMP", "Od kiedy"),
                       kol("PublishedTo", "TIMESTAMP", "Do kiedy (puste = widoczny teraz)", pusta=True),
                       flaga("IsCurrent", "1 = publikacja aktualna"),
                   ], (1, 2), rodzaj="historia",
                   warunki=[po_kolei("PublishedFrom", "PublishedTo"), zamkniety("IsCurrent", "PublishedTo")],
                   unikalne_gdy=[("IsCurrent = 1", ("EmployerKey",))]),
            slownik("PublicationStatus", 20, "Stan publikacji wyniku.",
                    ["Opublikowany", "Za mało danych", "Wstrzymany do decyzji moderatora", "Wycofany po odwołaniu"],
                    (2, 2), opis_nazwy="Nazwa stanu publikacji"),
        ],
        zewnetrzne={"SignalSnapshot": (0, 1), "SignalType": (3, 0), "Employer": (0, 2)},
    ),
    # ───────────── F. ZAPLECZE SYSTEMU ─────────────
    organizm(
        19, "F", "Użytkownicy systemu i role",
        "Kto pracuje w systemie: konta użytkowników, ich role i firmy, które reprezentują – z historią.",
        "Użytkownik systemu to w szerszym kontekście każda osoba, która loguje się do Ghost-Job Scanner: moderator, "
        "administrator, analityk, inspektor ochrony danych albo przedstawiciel firmy. Konto służy nie tylko do "
        "logowania: przy decyzjach (powiązania kont, alerty, oceny zgłoszeń) zapisujemy, kto je podjął, a przy firmie – "
        "kto może ją reprezentować, np. przy odwołaniu od oceny.",
        [
            ("Rola jest wybierana z listy, a nie wpisywana – nowa rola (np. „audytor”) to nowy wiersz, a literówka nie "
             "stworzy drugiej roli.", ["Role"]),
            ("Jedna osoba ma kilka ról naraz, a role zmieniają się w czasie – przypisanie ma datę od, datę do i flagę "
             "„aktualne”.", ["UserRole"]),
            ("Przedstawiciel może reprezentować kilka firm, a firma ma kilku przedstawicieli; gdy współpraca się kończy, "
             "nic nie usuwamy – zamykamy przypisanie datą i flagą.", ["EmployerRepresentative"]),
            ("Konta nie kasujemy – wyłączamy je flagą i datą, bo z kontem są związane decyzje, które muszą zostać w "
             "historii.", ["SystemUser"]),
        ],
        "Czy przedstawiciele firm mają być w tej samej tabeli użytkowników co personel (tak jest teraz, rozróżnia ich "
        "rola), czy w osobnej?",
        [(5, "panel firmy, moderacja i wnioski"), (6, "zbiór staff_accounts")],
        [
            slownik("Role", 20, "Rola użytkownika – decyduje, co wolno mu robić w systemie.",
                    [("Administrator", "Zarządza kontami i ustawieniami systemu"),
                     ("Moderator", "Rozstrzyga zgłoszenia, alerty i powiązania kont"),
                     ("Analityk danych", "Przegląda dane i wyniki, bez prawa zmian"),
                     ("Inspektor ochrony danych", "Obsługuje wnioski RODO"),
                     ("Przedstawiciel firmy", "Osoba z firmy, która może się odwołać od oceny")], (0, 0),
                    opis_nazwy="Nazwa roli",
                    kolumny=[kol("RoleDescription", "VARCHAR2(200)", "Co wolno tej roli")]),
            tabela("UserRole", 2000000, "Rola użytkownika – przypisanie w czasie; jedna osoba ma kilka ról.", [
                fk("SystemUser", "Użytkownik"),
                fk("Role", "Rola"),
                kol("ValidFrom", "DATE", "Od kiedy"),
                kol("ValidTo", "DATE", "Do kiedy (puste = nadal)", pusta=True),
                flaga("IsCurrent", "1 = rola aktualna"),
            ], (0, 1), rodzaj="przypisanie",
                warunki=[po_kolei("ValidFrom", "ValidTo"), zamkniety("IsCurrent", "ValidTo")],
                unikalne_gdy=[("IsCurrent = 1", ("SystemUserKey", "RoleKey"))]),
            tabela("SystemUser", 1000000, "Konto osoby, która loguje się do systemu – personel albo przedstawiciel firmy.", [
                kol("UserLogin", "VARCHAR2(100)", "Login, np. służbowy adres e-mail", unikalna=True),
                kol("DisplayName", "VARCHAR2(100)", "Imię i nazwisko albo nazwa wyświetlana"),
                kol("PasswordHash", "VARCHAR2(100)", "Skrót hasła (np. bcrypt) – nigdy samo hasło; puste przy logowaniu "
                    "przez zewnętrzny system", pusta=True),
                kol("CreatedAt", "TIMESTAMP", "Kiedy założono konto"),
                flaga("IsActive", "1 = konto aktywne, 0 = wyłączone"),
                kol("DeactivatedAt", "TIMESTAMP", "Kiedy wyłączono (puste = aktywne)", pusta=True),
            ], (1, 1), warunki=[po_kolei("CreatedAt", "DeactivatedAt"), zamkniety("IsActive", "DeactivatedAt")]),
            tabela("EmployerRepresentative", 2000000, "Przedstawiciel firmy – przypisanie w czasie użytkownika do firmy.", [
                fk("SystemUser", "Użytkownik"),
                fk("Employer", "Firma, którą reprezentuje"),
                kol("ValidFrom", "DATE", "Od kiedy"),
                kol("ValidTo", "DATE", "Do kiedy (puste = nadal)", pusta=True),
                flaga("IsCurrent", "1 = reprezentuje teraz"),
                kol("VerifiedAt", "TIMESTAMP", "Kiedy potwierdziliśmy, że ta osoba reprezentuje firmę", pusta=True),
            ], (2, 1), rodzaj="przypisanie",
                warunki=[po_kolei("ValidFrom", "ValidTo"), zamkniety("IsCurrent", "ValidTo")],
                unikalne_gdy=[("IsCurrent = 1", ("SystemUserKey", "EmployerKey"))]),
        ],
        zewnetrzne={"Employer": (2, 0)},
    ),
]
