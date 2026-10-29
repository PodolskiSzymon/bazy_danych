"""Organizmy tabel – osobne grupy powiązanych tabel, od źródła danych do Trust Score.

Konwencja jak na schemacie prowadzącego (Oracle SQL Developer Data Modeler):
- nazwa tabeli po angielsku, PascalCase, w liczbie pojedynczej, np. SourcePlatform,
- klucz główny <Tabela>Key typu NUMBER(n) – dopisuje go generator, w danych podaje się tylko liczbę cyfr,
- klucz obcy nazywa się tak samo jak klucz, do którego prowadzi (SourcePlatformKey),
- w słownikach nazwa wartości to <Tabela>Name (APITypeName, DataFormatName).

Każdy organizm odpowiada na dwa pytania: co to jest w szerszym kontekście i jakie mogą być warianty.
Wariant, który może się zmieniać albo powtarzać, dostaje własną tabelę (słownik, tabelę łączącą, historię).
Organizmy są na razie osobne: tabela z innego organizmu jest na diagramie szarą ramką.

Pola:
  poz         – miejsce na diagramie: (kolumna, wiersz) siatki, liczone od 0,
  zewnetrzne  – tabele z innych organizmów pokazane na diagramie i ich miejsca,
  wartosci    – przykładowe wiersze; w słownikach to lista wariantów (trafia też do SQL jako INSERT),
  rodzaj      – podpis tabeli: słownik, łącząca, historia, zdarzenia, migawka.

Po zmianie uruchom: python narzedzia/build_web.py (strona web/organizmy.html i pliki sql/organizmy/).
"""

# W bazie nazwa tabeli dostaje przedrostek numeru organizmu (ORG01_SourcePlatform), żeby tabele jednego organizmu
# stały na liście obok siebie. Kolumny i klucze zostają bez przedrostka (SourcePlatformKey). False = bez przedrostków.
PRZEDROSTEK_TABEL = True


def kol(nazwa, typ, opis, pusta=False, unikalna=False):
    return {"name": nazwa, "type": typ, "desc": opis, "null": pusta, "unique": unikalna}


def flaga(nazwa, opis, pusta=False):
    return {"name": nazwa, "type": "CHAR(1)", "desc": opis, "null": pusta, "flag": True}


def fk(tabela, opis, nazwa=None, pusta=False, unikalna=False):
    return {"ref": tabela, "name": nazwa or tabela + "Key", "desc": opis, "null": pusta, "unique": unikalna}


def tabela(nazwa, cyfry, opis, kolumny, poz, rodzaj=None, unikalne=(), warunki=(), wartosci=None):
    return {"name": nazwa, "digits": cyfry, "desc": opis, "cols": list(kolumny), "pos": poz, "kind": rodzaj,
            "unique": [list(u) for u in unikalne], "checks": list(warunki), "rows": wartosci}


def slownik(nazwa, opis, wartosci, poz, dlugosc=40, cyfry=2, kolumny=(), opis_nazwy="Nazwa wariantu"):
    cols = [kol(nazwa + "Name", f"VARCHAR2({dlugosc})", opis_nazwy, unikalna=True)] + list(kolumny)
    rows = [w if isinstance(w, tuple) else (w,) for w in wartosci]
    return tabela(nazwa, cyfry, opis, cols, poz, rodzaj="słownik", wartosci=rows)


def organizm(nr, etap, tytul, krotko, kontekst, warianty, pytanie, mapa, tabele, zewnetrzne=None):
    return {"id": nr, "stage": etap, "title": tytul, "short": krotko, "context": kontekst,
            "variants": [{"text": t, "tables": list(tb)} for t, tb in warianty], "question": pytanie,
            "map": [{"layer": w, "what": co} for w, co in mapa], "tables": tabele, "stubs": zewnetrzne or {}}


ETAPY = {
    "A": "Źródło danych",
    "B": "Firma",
    "C": "Ogłoszenie",
    "D": "Kandydat i zgłoszenia",
    "E": "Ocena firmy",
}

# Schemat pokazany przez prowadzącego – punkt wyjścia organizmów 1–3.
SCHEMAT_PROWADZACEGO = [
    ("SourcePlatform", "zostaje, organizm 1"),
    ("PlatformAPI", "zostaje, organizm 2; doszły sposób zabezpieczenia, kierunek i wersje"),
    ("APIType", "zostaje, organizm 2"),
    ("DataFormat", "zostaje, organizm 2; format konkretnej odpowiedzi jest też przy endpoincie"),
    ("PlatformAPIData", "rozbita na APIEndpoint → EndpointResponse → EndpointData, organizm 3 – brakowało endpointów"),
]

# Fragmenty mapy, które rozpiszemy po uwagach prowadzącego (te same zasady).
DO_ROZPISANIA = [
    ("Moderacja i odwołania firm", 5, "appeals, moderator_decisions, moderation_queue, case_files"),
    ("Wnioski RODO", 5, "privacy_requests"),
    ("Odznaka przy ofercie i raporty publiczne", 5, "badge_view_stats, public_reports"),
    ("Personel, role i dziennik audytu", 6, "staff_accounts, audit_log"),
    ("Parametry, harmonogram i kolejka zleceń", 6, "system_parameters, job_runs, task_queue, system_alerts"),
    ("Pamięć i koszty zapytań do AI", 6, "llm_cache, llm_usage_log"),
]

ORGANIZMY = [
    # ───────────── A. ŹRÓDŁO DANYCH ─────────────
    organizm(
        1, "A", "Platforma źródłowa",
        "Skąd w ogóle biorą się dane: serwis z ofertami pracy, jego adresy, kraje i umowa z nami.",
        "Platforma to w szerszym kontekście każde miejsce, w którym ktoś publikuje oferty pracy, a my możemy je "
        "odczytać – nie tylko portal taki jak pracuj.pl. Od niej zaczyna się każda informacja w systemie: konto firmy, "
        "ogłoszenie i aplikacja kandydata zawsze pochodzą z jakiejś platformy.",
        [
            ("Źródłem może być portal z ofertami pracy, serwis ogłoszeń drobnych, agregator ofert, serwis "
             "społecznościowy, urząd pracy albo strona kariery samej firmy.", ["PlatformType"]),
            ("Jedna platforma działa pod kilkoma adresami (pracuj.pl, it.pracuj.pl). Potrzebujemy ich wszystkich, bo "
             "po adresie sprawdzamy, czy nasz widżet działa na stronie partnera.", ["PlatformDomain"]),
            ("Jedna platforma działa w kilku krajach (OLX: Polska, Rumunia, Portugalia), a w jednym kraju działa "
             "wiele platform – to relacja wiele do wielu.", ["Country", "PlatformMarket"]),
            ("Platforma może być partnerem albo tylko obserwowanym źródłem, a umowa zmienia się w czasie "
             "(negocjacje → pilotaż → aktywna → rozwiązana), więc zamiast jednej kolumny „czy partner” jest historia umów.",
             ["PartnerAgreement", "AgreementStatus"]),
            ("Stron kariery firm mogą być tysiące, dlatego klucz platformy ma 4 cyfry, a nie 2.", ["SourcePlatform"]),
        ],
        "Czy strony kariery firm (systemy ATS) traktować jako jeden z rodzajów platformy – tak jest teraz – czy jako "
        "osobny organizm?",
        [(1, "źródło „Platformy”"), (6, "zbiór partners")],
        [
            slownik("PlatformType", "Rodzaj platformy – odpowiedź na pytanie, czym w szerszym kontekście jest źródło ofert.",
                    ["Portal z ofertami pracy", "Serwis ogłoszeń drobnych", "Agregator ofert", "Serwis społecznościowy",
                     "Publiczny urząd pracy", "Strona kariery firmy (ATS)"], (0, 0), opis_nazwy="Nazwa rodzaju platformy"),
            tabela("SourcePlatform", 4, "Platforma, z której pochodzą dane, np. pracuj.pl albo OLX – ta sama tabela co na "
                   "schemacie z zajęć.", [
                       kol("SourcePlatformName", "VARCHAR2(50)", "Nazwa platformy, np. pracuj.pl", unikalna=True),
                       kol("MainHomePage", "VARCHAR2(100)", "Adres strony głównej"),
                       fk("PlatformType", "Rodzaj platformy"),
                       kol("AddedDate", "DATE", "Kiedy dodaliśmy platformę jako źródło"),
                   ], (1, 0), wartosci=[("pracuj.pl", "https://www.pracuj.pl", 1, "2026-10-01"),
                                       ("OLX", "https://www.olx.pl", 2, "2026-10-01")]),
            tabela("PlatformDomain", 5, "Adres, pod którym działa platforma. Jedna platforma ma ich kilka.", [
                fk("SourcePlatform", "Platforma"),
                kol("DomainName", "VARCHAR2(100)", "Domena, np. it.pracuj.pl", unikalna=True),
                flaga("IsMainDomain", "Czy to główny adres platformy"),
            ], (2, 0)),
            tabela("PlatformMarket", 5, "Kraj, w którym platforma publikuje oferty – tabela łącząca platformy z krajami.", [
                fk("SourcePlatform", "Platforma"),
                fk("Country", "Kraj"),
                kol("LaunchDate", "DATE", "Od kiedy platforma działa w tym kraju", pusta=True),
            ], (0, 1), rodzaj="łącząca", unikalne=[("SourcePlatformKey", "CountryKey")]),
            tabela("PartnerAgreement", 5, "Umowa o współpracy z platformą. Każda zmiana warunków to nowy wiersz, więc "
                   "widać całą historię współpracy.", [
                       fk("SourcePlatform", "Platforma"),
                       fk("AgreementStatus", "Etap umowy"),
                       kol("SignedDate", "DATE", "Data podpisania", pusta=True),
                       kol("ValidFrom", "DATE", "Od kiedy obowiązuje"),
                       kol("ValidTo", "DATE", "Do kiedy obowiązuje (puste = bez końca)", pusta=True),
                       flaga("HasDataProcessingAgreement", "Czy podpisano umowę powierzenia danych osobowych (RODO)"),
                   ], (1, 1), rodzaj="historia", warunki=["ValidTo IS NULL OR ValidTo >= ValidFrom"]),
            slownik("AgreementStatus", "Etap umowy z platformą.",
                    ["Negocjacje", "Pilotaż", "Aktywna", "Zawieszona", "Rozwiązana"], (2, 1), dlugosc=30,
                    opis_nazwy="Nazwa etapu umowy"),
            tabela("Country", 3, "Kraj – słownik używany też w organizmach 6 i 8.", [
                kol("CountryCode", "CHAR(2)", "Kod kraju ISO, np. PL", unikalna=True),
                kol("CountryName", "VARCHAR2(60)", "Nazwa kraju"),
            ], (0, 2), rodzaj="słownik", wartosci=[("PL", "Polska"), ("DE", "Niemcy"), ("CZ", "Czechy"),
                                                   ("RO", "Rumunia"), ("PT", "Portugalia"), ("UA", "Ukraina")]),
        ],
    ),
    organizm(
        2, "A", "API platformy",
        "Jakim kanałem, w jakim formacie i z jakim zabezpieczeniem platforma przekazuje nam dane.",
        "API to w szerszym kontekście kanał wymiany danych między platformą a nami – techniczna umowa o tym, jak "
        "płyną dane: kto zaczyna, w jakim formacie i z jakim zabezpieczeniem. Jedna platforma może mieć kilka takich "
        "kanałów, a każdy kanał zmienia się w czasie (wersje).",
        [
            ("Kanał bywa różnego rodzaju: REST, GraphQL, SOAP, powiadomienia webhook, plik z eksportem, kanał RSS.",
             ["APIType"]),
            ("Dane płyną w dwie strony: my pytamy platformę (pull) albo platforma sama nam je wysyła (push).",
             ["APIDirection"]),
            ("Dane przychodzą w różnych formatach: JSON, XML, CSV. W PlatformAPI zostaje format domyślny, a format "
             "konkretnej odpowiedzi zapisujemy przy endpoincie (organizm 3).", ["DataFormat"]),
            ("Dostęp jest zabezpieczony różnie: klucz API, OAuth 2.0, certyfikat klienta, podpis HMAC.", ["AuthMethod"]),
            ("API ma wersje (v1, v2), a stare wersje platforma wyłącza. Każda wersja ma środowisko testowe i produkcyjne, "
             "każde z innym adresem i limitem zapytań.", ["APIVersion", "APIEnvironment", "EnvironmentType"]),
        ],
        "Na schemacie z zajęć PlatformAPI wskazuje jeden DataFormat. Zostawiliśmy go jako format domyślny, a format "
        "konkretnej odpowiedzi dodaliśmy przy endpoincie – czy tak może zostać?",
        [(6, "zbiór partners (wersja formatu, klucze)")],
        [
            slownik("APIType", "Rodzaj API – jak na schemacie z zajęć.",
                    ["REST", "GraphQL", "SOAP", "Webhook", "Eksport pliku", "Kanał RSS"], (1, 0), dlugosc=20,
                    opis_nazwy="Nazwa rodzaju API"),
            slownik("DataFormat", "Format danych – jak na schemacie z zajęć, z typem MIME.",
                    [("JSON", "application/json"), ("XML", "application/xml"), ("CSV", "text/csv"), ("HTML", "text/html")],
                    (2, 0), dlugosc=15, opis_nazwy="Nazwa formatu",
                    kolumny=[kol("MimeType", "VARCHAR2(60)", "Typ MIME, np. application/json")]),
            slownik("AuthMethod", "Sposób uwierzytelnienia przy połączeniu z API.",
                    ["Klucz API", "OAuth 2.0", "Certyfikat klienta (mTLS)", "Podpis HMAC", "Brak zabezpieczenia"], (0, 1),
                    opis_nazwy="Nazwa sposobu uwierzytelnienia"),
            tabela("PlatformAPI", 3, "Kanał wymiany danych z jedną platformą – tabela ze schematu z zajęć, rozszerzona.", [
                fk("SourcePlatform", "Platforma, do której należy API"),
                fk("APIType", "Rodzaj API"),
                fk("DataFormat", "Format domyślny"),
                fk("AuthMethod", "Jak się uwierzytelniamy"),
                fk("APIDirection", "Kto zaczyna przesyłanie danych"),
                kol("PlatformAPIName", "VARCHAR2(60)", "Nazwa API, np. „Partner API”"),
                kol("DocumentationURL", "VARCHAR2(200)", "Adres dokumentacji API", pusta=True),
            ], (1, 1)),
            slownik("APIDirection", "Kierunek przesyłania danych.",
                    ["My pobieramy dane (pull)", "Platforma wysyła dane (push)"], (2, 1), opis_nazwy="Nazwa kierunku"),
            tabela("APIVersion", 4, "Wersja API. Endpointy różnią się między wersjami, a stare wersje platforma wyłącza.", [
                fk("PlatformAPI", "API, którego to wersja"),
                kol("VersionLabel", "VARCHAR2(10)", "Oznaczenie wersji, np. v2"),
                kol("ReleaseDate", "DATE", "Kiedy wersja weszła"),
                kol("RetirementDate", "DATE", "Kiedy platforma wyłączy tę wersję", pusta=True),
            ], (1, 2), rodzaj="historia", unikalne=[("PlatformAPIKey", "VersionLabel")]),
            slownik("EnvironmentType", "Rodzaj środowiska API.", ["Testowe (sandbox)", "Produkcyjne"], (0, 3),
                    dlugosc=30, opis_nazwy="Nazwa środowiska"),
            tabela("APIEnvironment", 5, "Środowisko danej wersji API z własnym adresem i limitem zapytań.", [
                fk("APIVersion", "Wersja API"),
                fk("EnvironmentType", "Rodzaj środowiska"),
                kol("BaseURL", "VARCHAR2(200)", "Adres bazowy, np. https://api.platforma.example/v2"),
                kol("RequestLimitPerMinute", "NUMBER(6)", "Ile zapytań na minutę pozwala platforma", pusta=True),
            ], (1, 3), unikalne=[("APIVersionKey", "EnvironmentTypeKey")]),
        ],
        zewnetrzne={"SourcePlatform": (0, 0)},
    ),
    organizm(
        3, "A", "Endpointy i zwracane dane",
        "Jakie konkretne zapytania ma API i jakie pola zwraca każde z nich.",
        "Endpoint to w szerszym kontekście jedno konkretne zapytanie, które można wysłać do API, np. „podaj nowe "
        "ogłoszenia”. Każde API ma ich wiele i każdy zwraca co innego. Pola zwracane przez endpoint to dokładnie te "
        "dane, które potem trafiają do naszych tabel – dlatego opisujemy je pole po polu.",
        [
            ("Jedno API ma wiele endpointów (/jobs, /jobs/{id}/events, /companies) i każdy dotyczy czegoś innego: "
             "konta firmy, ogłoszenia, zdarzenia albo aplikacji.", ["APIEndpoint", "DataSubject"]),
            ("Endpoint działa przez różne metody HTTP: GET pobiera dane, POST je wysyła.", ["HTTPMethod"]),
            ("Ten sam endpoint zwraca różne odpowiedzi: 200 z danymi, 404 gdy czegoś nie ma, 429 gdy wysłaliśmy za dużo "
             "zapytań – i bywa dostępny w kilku formatach.", ["EndpointResponse"]),
            ("Zwracane dane są zagnieżdżone (salary → from, to, currency) i mają różne typy, dlatego pole może wskazywać "
             "pole nadrzędne w tej samej tabeli.", ["EndpointData", "FieldDataType"]),
            ("Każda platforma nazywa te same dane inaczej (salary_from, wynagrodzenie_min). Sprowadzamy je do jednej "
             "naszej nazwy.", ["CanonicalField", "FieldMapping"]),
        ],
        "Tabelę PlatformAPIData ze schematu z zajęć rozbiliśmy na APIEndpoint → EndpointResponse → EndpointData. Czy taki "
        "poziom szczegółu jest dobry?",
        [(1, "dane kont firm od platform"), (2, "ogłoszenia i zdarzenia od platform"), (3, "log aplikacji od platform")],
        [
            slownik("HTTPMethod", "Metoda HTTP endpointu.", ["GET", "POST", "PUT", "PATCH", "DELETE"], (1, 0),
                    dlugosc=10, opis_nazwy="Nazwa metody"),
            slownik("DataSubject", "Czego dotyczą dane z endpointu – łączy endpointy z dalszymi organizmami.",
                    ["Konto firmy", "Ogłoszenie", "Zdarzenie ogłoszenia", "Aplikacja kandydata", "Status aplikacji"],
                    (2, 0), opis_nazwy="Nazwa rodzaju danych"),
            tabela("APIEndpoint", 6, "Jedno zapytanie w danej wersji API.", [
                fk("APIVersion", "Wersja API"),
                fk("HTTPMethod", "Metoda HTTP"),
                fk("DataSubject", "Czego dotyczą zwracane dane"),
                kol("EndpointPath", "VARCHAR2(200)", "Ścieżka, np. /v2/jobs"),
                flaga("IsPaginated", "Czy wyniki są dzielone na strony"),
                kol("EndpointDescription", "VARCHAR2(300)", "Co robi endpoint", pusta=True),
            ], (1, 1), unikalne=[("APIVersionKey", "HTTPMethodKey", "EndpointPath")]),
            tabela("EndpointResponse", 7, "Jedna możliwa odpowiedź endpointu: kod HTTP i format.", [
                fk("APIEndpoint", "Endpoint"),
                kol("HTTPStatusCode", "NUMBER(3)", "Kod odpowiedzi HTTP, np. 200, 404, 429"),
                fk("DataFormat", "Format tej odpowiedzi"),
                flaga("IsErrorResponse", "Czy to odpowiedź z błędem"),
                kol("ResponseDescription", "VARCHAR2(200)", "Kiedy pojawia się ta odpowiedź", pusta=True),
            ], (1, 2), unikalne=[("APIEndpointKey", "HTTPStatusCode", "DataFormatKey")],
                warunki=["HTTPStatusCode BETWEEN 100 AND 599"]),
            slownik("FieldDataType", "Typ danych pola w odpowiedzi.",
                    ["Tekst", "Liczba całkowita", "Liczba dziesiętna", "Prawda / fałsz", "Data", "Data i godzina",
                     "Lista", "Obiekt"], (0, 3), dlugosc=30, opis_nazwy="Nazwa typu"),
            tabela("EndpointData", 8, "Jedno pole w odpowiedzi endpointu – odpowiednik PlatformAPIData ze schematu z zajęć.", [
                fk("EndpointResponse", "Odpowiedź, w której jest pole"),
                fk("EndpointData", "Pole nadrzędne, gdy pole jest zagnieżdżone", nazwa="ParentEndpointDataKey", pusta=True),
                kol("DataName", "VARCHAR2(50)", "Nazwa pola u platformy, np. salary_from"),
                kol("DataPath", "VARCHAR2(200)", "Pełna ścieżka pola, np. salary.from"),
                fk("FieldDataType", "Typ danych pola"),
                flaga("IsRequired", "Czy platforma zawsze podaje to pole"),
                kol("ExampleValue", "VARCHAR2(200)", "Przykładowa wartość", pusta=True),
            ], (1, 3), unikalne=[("EndpointResponseKey", "DataPath")]),
            tabela("CanonicalField", 4, "Nasza jedna nazwa danej, niezależna od platformy.", [
                kol("CanonicalFieldName", "VARCHAR2(60)", "Nazwa, np. „Wynagrodzenie od”", unikalna=True),
                fk("DataSubject", "Czego dotyczy"),
                kol("CanonicalFieldDescription", "VARCHAR2(300)", "Opis", pusta=True),
            ], (2, 4), rodzaj="słownik", wartosci=[("Wynagrodzenie od", 2, "Dolna granica widełek"),
                                                   ("Rodzaj umowy", 2, None), ("NIP firmy", 1, "NIP wpisany w koncie firmy"),
                                                   ("Data aplikacji", 4, None)]),
            tabela("FieldMapping", 8, "Przypisanie pola platformy do naszej nazwy, z regułą przeliczenia.", [
                fk("EndpointData", "Pole platformy"),
                fk("CanonicalField", "Nasza nazwa"),
                kol("TransformationRule", "VARCHAR2(300)", "Jak przeliczyć wartość, np. „grosze na złote: /100”", pusta=True),
            ], (1, 4), unikalne=[("EndpointDataKey", "CanonicalFieldKey")]),
        ],
        zewnetrzne={"APIVersion": (0, 0), "DataFormat": (0, 2)},
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
            slownik("DeliveryMode", "Sposób, w jaki dane do nas trafiły.",
                    ["Pobranie według harmonogramu", "Powiadomienie od platformy (webhook)", "Plik z eksportem",
                     "Ręczne doładowanie historii"], (0, 0), opis_nazwy="Nazwa sposobu dostawy"),
            slownik("DeliveryStatus", "Wynik dostawy.", ["W toku", "Zakończona", "Zakończona częściowo", "Nieudana"],
                    (2, 0), dlugosc=30, opis_nazwy="Nazwa wyniku"),
            tabela("DataDelivery", 10, "Jedna dostawa danych jednym endpointem.", [
                fk("APIEndpoint", "Którym endpointem przyszły dane"),
                fk("DeliveryMode", "Sposób dostawy"),
                fk("DeliveryStatus", "Wynik dostawy"),
                kol("StartedAt", "TIMESTAMP", "Początek"),
                kol("FinishedAt", "TIMESTAMP", "Koniec", pusta=True),
                kol("RecordsReceived", "NUMBER(7)", "Ile rekordów przyszło", pusta=True),
                kol("RecordsAccepted", "NUMBER(7)", "Ile rekordów przyjęliśmy", pusta=True),
            ], (1, 1), rodzaj="zdarzenia", warunki=["RecordsAccepted <= RecordsReceived",
                                                    "FinishedAt IS NULL OR FinishedAt >= StartedAt"]),
            tabela("RawRecord", 12, "Rekord dokładnie w takiej postaci, w jakiej przyszedł od platformy.", [
                fk("DataDelivery", "Dostawa"),
                kol("ExternalRecordId", "VARCHAR2(100)", "Numer rekordu u platformy"),
                kol("RecordPayload", "CLOB", "Treść rekordu bez zmian (np. JSON)"),
                kol("PayloadHash", "VARCHAR2(64)", "Skrót SHA-256 treści – do wykrywania duplikatów"),
                kol("ReceivedAt", "TIMESTAMP", "Kiedy rekord przyszedł"),
            ], (0, 2)),
            tabela("DeliveryError", 10, "Błąd dostawy albo pojedynczego rekordu.", [
                fk("DataDelivery", "Dostawa"),
                fk("RawRecord", "Którego rekordu dotyczy (puste = całej dostawy)", pusta=True),
                fk("ErrorType", "Rodzaj błędu"),
                kol("ErrorMessage", "VARCHAR2(400)", "Treść błędu", pusta=True),
                kol("OccurredAt", "TIMESTAMP", "Kiedy wystąpił"),
            ], (1, 2), rodzaj="zdarzenia"),
            slownik("ErrorType", "Rodzaj błędu przy odbiorze danych.",
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
            ("Platforma może konto zawiesić albo usunąć.", ["AccountStatus"]),
            ("Dane konta zmieniają się w czasie – firma może zmienić nazwę, żeby uciec od złych opinii. Każda zmiana to "
             "nowy wiersz z datami.", ["EmployerAccountVersion"]),
            ("Numer konta jest unikalny tylko w obrębie jednej platformy, dlatego klucz unikalny to platforma + numer.",
             ["EmployerAccount"]),
        ],
        "Czy historię zmian konta trzymać jako wersje całego wiersza – tak jest teraz – czy jako dziennik zmian "
        "pojedynczych pól?",
        [(1, "zbiór employer_accounts")],
        [
            slownik("AccountType", "Kto prowadzi konto.", ["Firma", "Agencja rekrutacyjna", "Osoba prywatna",
                                                         "Instytucja publiczna"], (0, 0), opis_nazwy="Nazwa rodzaju konta"),
            slownik("AccountStatus", "Stan konta na platformie.", ["Aktywne", "Zawieszone przez platformę", "Usunięte"],
                    (2, 0), opis_nazwy="Nazwa stanu"),
            tabela("EmployerAccount", 8, "Konto na jednej platformie.", [
                fk("SourcePlatform", "Platforma"),
                kol("ExternalAccountId", "VARCHAR2(50)", "Numer konta w serwisie"),
                fk("AccountType", "Kto prowadzi konto"),
                fk("AccountStatus", "Stan konta"),
                flaga("IsVerifiedByPlatform", "Czy platforma sama sprawdziła firmę"),
                kol("FirstSeenAt", "TIMESTAMP", "Kiedy pierwszy raz dostaliśmy to konto"),
            ], (1, 1), unikalne=[("SourcePlatformKey", "ExternalAccountId")]),
            tabela("EmployerAccountVersion", 9, "Wersja danych konta – każda zmiana to nowy wiersz.", [
                fk("EmployerAccount", "Konto"),
                kol("AccountName", "VARCHAR2(200)", "Nazwa konta"),
                kol("DeclaredNIP", "VARCHAR2(10)", "NIP wpisany przez właściciela konta (niesprawdzony)", pusta=True),
                kol("WebsiteURL", "VARCHAR2(200)", "Strona www podana w koncie", pusta=True),
                kol("ValidFrom", "TIMESTAMP", "Od kiedy dane są takie"),
                kol("ValidTo", "TIMESTAMP", "Do kiedy (puste = wersja aktualna)", pusta=True),
                fk("RawRecord", "Rekord, z którego pochodzi ta wersja", pusta=True),
            ], (1, 2), rodzaj="historia", warunki=["ValidTo IS NULL OR ValidTo > ValidFrom"]),
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
             "firma zagraniczna.", ["LegalForm"]),
            ("Firma ma kilka numerów naraz (NIP, REGON, KRS), a firma zagraniczna – zupełnie inne. Dlatego numery są w "
             "osobnej tabeli, a nie w kolumnach NIP, REGON i KRS.", ["EmployerIdentifier", "IdentifierType"]),
            ("Sprawdzamy w kilku rejestrach i wielokrotnie w czasie; rejestr może firmy nie znaleźć albo podać inny "
             "status niż poprzednio.", ["PublicRegistry", "RegistryCheck"]),
            ("Firma prowadzi kilka rodzajów działalności (PKD), jeden jest główny – relacja wiele do wielu. Sama "
             "klasyfikacja też się zmienia (PKD 2007, PKD 2025).", ["PKDCode", "EmployerPKD"]),
            ("Status firmy zmienia się: aktywna, zawieszona, w likwidacji, wykreślona.", ["EmployerStatus"]),
        ],
        "Czy aktualny status firmy trzymać przy firmie (Employer.EmployerStatusKey – tak jest teraz), czy brać go zawsze "
        "z ostatniego sprawdzenia w RegistryCheck?",
        [(1, "zbiory employers, registry_snapshots"), (6, "słownik legal_form_dictionary")],
        [
            slownik("LegalForm", "Forma prawna podmiotu.",
                    [("Spółka z ograniczoną odpowiedzialnością", "sp. z o.o."), ("Spółka akcyjna", "S.A."),
                     ("Jednoosobowa działalność gospodarcza", "JDG"), ("Spółka cywilna", "s.c."),
                     ("Spółka jawna", "sp.j."), ("Fundacja", None), ("Stowarzyszenie", None),
                     ("Jednostka sektora publicznego", None), ("Firma zagraniczna", None)], (0, 0), dlugosc=60,
                    opis_nazwy="Pełna nazwa formy prawnej",
                    kolumny=[kol("LegalFormShortName", "VARCHAR2(20)", "Skrót, np. sp. z o.o.", pusta=True)]),
            tabela("PKDCode", 4, "Rodzaj działalności z klasyfikacji PKD.", [
                kol("PKDSymbol", "VARCHAR2(7)", "Symbol, np. 78.10.Z"),
                kol("PKDName", "VARCHAR2(250)", "Nazwa działalności"),
                kol("ClassificationVersion", "VARCHAR2(10)", "Wersja klasyfikacji, np. PKD 2007 albo PKD 2025"),
            ], (2, 0), rodzaj="słownik", unikalne=[("PKDSymbol", "ClassificationVersion")]),
            tabela("EmployerIdentifier", 9, "Numer identyfikacyjny firmy – NIP, REGON, KRS albo numer zagraniczny.", [
                fk("Employer", "Firma"),
                fk("IdentifierType", "Rodzaj numeru"),
                kol("IdentifierValue", "VARCHAR2(30)", "Numer"),
                flaga("IsChecksumValid", "Czy numer przeszedł kontrolę sumy kontrolnej"),
            ], (0, 1), unikalne=[("IdentifierTypeKey", "IdentifierValue")]),
            tabela("Employer", 8, "Podmiot prawny – jeden wiersz to jedna prawdziwa firma. Dla niego liczymy Trust Score.", [
                kol("OfficialName", "VARCHAR2(250)", "Nazwa urzędowa"),
                fk("LegalForm", "Forma prawna"),
                fk("Country", "Kraj rejestracji"),
                fk("EmployerStatus", "Aktualny status"),
                kol("RegistrationDate", "DATE", "Data wpisu do rejestru", pusta=True),
            ], (1, 1)),
            tabela("EmployerPKD", 9, "Rodzaj działalności firmy – tabela łącząca firmy z kodami PKD.", [
                fk("Employer", "Firma"),
                fk("PKDCode", "Kod PKD"),
                flaga("IsMainActivity", "Czy to działalność główna"),
            ], (2, 1), rodzaj="łącząca", unikalne=[("EmployerKey", "PKDCodeKey")]),
            tabela("IdentifierType", 2, "Rodzaj numeru identyfikacyjnego.", [
                kol("IdentifierTypeName", "VARCHAR2(40)", "Nazwa rodzaju numeru", unikalna=True),
                kol("ValueFormat", "VARCHAR2(60)", "Jak wygląda poprawny numer"),
            ], (0, 2), rodzaj="słownik", wartosci=[("NIP", "10 cyfr, ostatnia to suma kontrolna"),
                                                   ("REGON", "9 albo 14 cyfr"), ("KRS", "10 cyfr"),
                                                   ("Numer VAT UE", "kod kraju i numer"),
                                                   ("Zagraniczny numer rejestrowy", "dowolny")]),
            tabela("RegistryCheck", 10, "Jedno sprawdzenie firmy w jednym rejestrze. Nowe sprawdzenie to nowy wiersz.", [
                fk("Employer", "Firma"),
                fk("PublicRegistry", "Rejestr"),
                kol("CheckedAt", "TIMESTAMP", "Kiedy sprawdzono"),
                flaga("WasFound", "Czy rejestr znalazł firmę"),
                fk("EmployerStatus", "Status podany przez rejestr", nazwa="ReportedStatusKey", pusta=True),
                kol("ReportedName", "VARCHAR2(250)", "Nazwa podana przez rejestr", pusta=True),
            ], (1, 2), rodzaj="historia"),
            slownik("EmployerStatus", "Status firmy w rejestrze.",
                    ["Aktywna", "Zawieszona", "W likwidacji", "W upadłości", "Wykreślona", "Nieznaleziona w rejestrze"],
                    (2, 2), opis_nazwy="Nazwa statusu"),
            tabela("PublicRegistry", 2, "Rejestr państwowy, w którym sprawdzamy firmy.", [
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
            ("Konto agencji rekrutacyjnej publikuje ogłoszenia dla wielu klientów – wtedy łączymy dwie firmy ze sobą.",
             ["AgencyClient"]),
            ("Błędne połączenie trzeba cofnąć, a każda zmiana musi zostać w historii.", ["LinkChange", "LinkChangeType"]),
        ],
        "Czy relację agencja–klient (AgencyClient) trzymać tutaj, czy przy ogłoszeniu (ogłoszenie agencji wskazuje "
        "klienta)?",
        [(1, "zbiory employer_account_links, employer_merge_log")],
        [
            slownik("MatchMethod", "Sposób, w jaki dopasowaliśmy konto do firmy.",
                    ["Ten sam NIP", "Podobna nazwa i ta sama strona www", "Decyzja moderatora", "Potwierdzenie przez firmę"],
                    (1, 0), opis_nazwy="Nazwa sposobu dopasowania"),
            tabela("LinkEvidence", 10, "Dowód, na którym opiera się powiązanie.", [
                fk("AccountEmployerLink", "Powiązanie"),
                fk("EvidenceType", "Rodzaj dowodu"),
                kol("EvidenceValue", "VARCHAR2(250)", "Treść dowodu, np. „ten sam NIP w koncie i w KRS”"),
            ], (0, 1)),
            tabela("AccountEmployerLink", 9, "Powiązanie konta na platformie z firmą z rejestru.", [
                fk("EmployerAccount", "Konto"),
                fk("Employer", "Firma"),
                fk("MatchMethod", "Sposób dopasowania"),
                kol("MatchConfidence", "NUMBER(3,2)", "Pewność od 0 do 1"),
                kol("LinkedAt", "TIMESTAMP", "Kiedy połączono"),
                kol("UnlinkedAt", "TIMESTAMP", "Kiedy cofnięto (puste = obowiązuje)", pusta=True),
            ], (1, 1), warunki=["MatchConfidence BETWEEN 0 AND 1", "UnlinkedAt IS NULL OR UnlinkedAt >= LinkedAt"]),
            tabela("AgencyClient", 8, "Agencja rekrutacyjna i firma, dla której rekrutuje – dwa klucze do tej samej tabeli.", [
                fk("Employer", "Agencja rekrutacyjna", nazwa="AgencyEmployerKey"),
                fk("Employer", "Firma, dla której agencja rekrutuje", nazwa="ClientEmployerKey"),
                kol("ValidFrom", "DATE", "Od kiedy"),
                kol("ValidTo", "DATE", "Do kiedy (puste = nadal)", pusta=True),
            ], (2, 1), rodzaj="łącząca", unikalne=[("AgencyEmployerKey", "ClientEmployerKey", "ValidFrom")],
                warunki=["AgencyEmployerKey <> ClientEmployerKey"]),
            slownik("EvidenceType", "Rodzaj dowodu powiązania.",
                    ["Zgodny NIP", "Podobna nazwa", "Ta sama domena strony www", "Ten sam adres",
                     "Dokument przesłany przez firmę"], (0, 2), opis_nazwy="Nazwa rodzaju dowodu"),
            tabela("LinkChange", 10, "Zmiana powiązania – historia połączeń i rozłączeń.", [
                fk("AccountEmployerLink", "Powiązanie"),
                fk("LinkChangeType", "Co zmieniono"),
                kol("ChangedAt", "TIMESTAMP", "Kiedy"),
                kol("ChangeReason", "VARCHAR2(300)", "Dlaczego", pusta=True),
            ], (1, 2), rodzaj="historia"),
            slownik("LinkChangeType", "Rodzaj zmiany powiązania.",
                    ["Połączono", "Rozłączono", "Przeniesiono do innej firmy", "Zmieniono pewność"], (2, 2),
                    opis_nazwy="Nazwa rodzaju zmiany"),
        ],
        zewnetrzne={"EmployerAccount": (0, 0), "Employer": (2, 0)},
    ),
    # ───────────── C. OGŁOSZENIE ─────────────
    organizm(
        8, "C", "Ogłoszenie i miejsce pracy",
        "Samo ogłoszenie: kto je opublikował, kiedy, na jakim poziomie, w jakim trybie i w których miastach.",
        "Ogłoszenie to w szerszym kontekście oferta pracy opublikowana przez konto na platformie w określonym czasie. "
        "Samo ogłoszenie nie mówi jeszcze, czy praca naprawdę istnieje – dlatego zapisujemy je dokładnie, żeby później "
        "porównywać kolejne publikacje.",
        [
            ("Ogłoszenie bywa aktywne, wygasłe, zamknięte przed terminem, wstrzymane albo usunięte przez platformę.",
             ["PostingStatus"]),
            ("Jedno ogłoszenie dotyczy kilku miast naraz, a w jednym mieście są tysiące ogłoszeń – relacja wiele do "
             "wielu.", ["Location", "PostingLocation"]),
            ("Praca bywa stacjonarna, hybrydowa, zdalna albo w terenie.", ["WorkMode"]),
            ("Poziom stanowiska: od stażysty do kierownika. Kolejność poziomów pozwala wykryć ten sam etat ogłaszany raz "
             "jako Senior, raz jako Mid.", ["SeniorityLevel"]),
            ("Jedno ogłoszenie może szukać kilku osób.", ["JobPosting"]),
        ],
        "Treść ogłoszenia jest w organizmie 11 (wersje treści). Czy tytuł też przenieść tam, czy zostawić go tutaj – tak "
        "jak teraz?",
        [(2, "zbiór job_postings")],
        [
            slownik("PostingStatus", "Stan ogłoszenia.",
                    ["Aktywne", "Wygasłe", "Zamknięte przed terminem", "Usunięte przez platformę", "Wstrzymane"],
                    (1, 0), opis_nazwy="Nazwa stanu"),
            slownik("SeniorityLevel", "Poziom stanowiska.",
                    [("Stażysta", 1), ("Junior", 2), ("Mid (samodzielny)", 3), ("Senior", 4), ("Ekspert", 5),
                     ("Kierownik", 6)], (0, 1), opis_nazwy="Nazwa poziomu",
                    kolumny=[kol("SeniorityRank", "NUMBER(2)", "Kolejność poziomów (1 = najniższy)")]),
            tabela("JobPosting", 10, "Ogłoszenie o pracę opublikowane przez konto na platformie.", [
                fk("EmployerAccount", "Konto, które opublikowało ogłoszenie"),
                kol("ExternalPostingId", "VARCHAR2(50)", "Numer ogłoszenia w serwisie"),
                kol("PostingTitle", "VARCHAR2(200)", "Tytuł (aktualny)"),
                fk("PostingStatus", "Stan ogłoszenia"),
                fk("SeniorityLevel", "Poziom stanowiska (bywa niepodany)", pusta=True),
                fk("WorkMode", "Tryb pracy (bywa niepodany)", pusta=True),
                kol("VacancyCount", "NUMBER(3)", "Ilu osób szuka", pusta=True),
                kol("PublishedDate", "DATE", "Data pierwszej publikacji"),
                kol("ExpiryDate", "DATE", "Planowana data końca", pusta=True),
                fk("RawRecord", "Rekord, z którego powstało ogłoszenie", pusta=True),
            ], (1, 1), unikalne=[("EmployerAccountKey", "ExternalPostingId")],
                warunki=["ExpiryDate IS NULL OR ExpiryDate >= PublishedDate", "VacancyCount > 0"]),
            slownik("WorkMode", "Tryb pracy.", ["Stacjonarna", "Hybrydowa", "Zdalna", "W terenie"], (2, 1),
                    dlugosc=30, opis_nazwy="Nazwa trybu pracy"),
            tabela("PostingLocation", 11, "Miejsce pracy w ogłoszeniu – tabela łącząca ogłoszenia z miejscowościami.", [
                fk("JobPosting", "Ogłoszenie"),
                fk("Location", "Miejscowość"),
                flaga("IsMainLocation", "Czy to główne miejsce pracy"),
            ], (1, 2), rodzaj="łącząca", unikalne=[("JobPostingKey", "LocationKey")]),
            tabela("Location", 6, "Miejscowość.", [
                kol("CityName", "VARCHAR2(80)", "Miejscowość"),
                kol("RegionName", "VARCHAR2(80)", "Województwo albo region", pusta=True),
                fk("Country", "Kraj"),
            ], (1, 3), unikalne=[("CityName", "RegionName", "CountryKey")]),
        ],
        zewnetrzne={"EmployerAccount": (0, 0), "RawRecord": (2, 0), "Country": (2, 3)},
    ),
    organizm(
        9, "C", "Warunki zatrudnienia",
        "Na jakiej umowie, za ile i z jakimi dodatkami – obietnica, którą firma składa w ogłoszeniu.",
        "Warunki to w szerszym kontekście obietnica, którą firma składa w ogłoszeniu: rodzaj umowy, wynagrodzenie i "
        "dodatki. Ich brak albo zmiana między kolejnymi publikacjami tego samego stanowiska to ważny sygnał dla Trust "
        "Score.",
        [
            ("Jedno ogłoszenie często daje do wyboru kilka umów, każdą z innymi widełkami (np. umowa o pracę 12–15 tys. zł "
             "brutto, B2B 15–19 tys. zł netto).", ["PostingSalary", "ContractType"]),
            ("Kwota bywa godzinowa, miesięczna albo roczna; brutto albo netto; w złotych, euro albo dolarach.",
             ["SalaryPeriod", "Currency"]),
            ("Brak widełek też jest informacją – firma podaje umowę, ale bez kwoty, dlatego kwoty mogą być puste.",
             ["PostingSalary"]),
            ("Benefity powtarzają się między ogłoszeniami i dają się pogrupować.",
             ["Benefit", "BenefitCategory", "PostingBenefit"]),
        ],
        "Czy przeliczać kwoty do jednej waluty i jednego okresu (np. złote miesięcznie brutto) w osobnej kolumnie, żeby "
        "łatwiej porównywać ogłoszenia?",
        [(2, "zbiór posting_features (widełki, umowa)")],
        [
            tabela("Currency", 3, "Waluta.", [
                kol("CurrencyCode", "CHAR(3)", "Kod waluty ISO, np. PLN", unikalna=True),
                kol("CurrencyName", "VARCHAR2(40)", "Nazwa waluty"),
            ], (0, 0), rodzaj="słownik", wartosci=[("PLN", "złoty"), ("EUR", "euro"), ("USD", "dolar amerykański"),
                                                   ("GBP", "funt brytyjski")]),
            slownik("ContractType", "Rodzaj umowy.",
                    ["Umowa o pracę", "Kontrakt B2B", "Umowa zlecenie", "Umowa o dzieło", "Staż lub praktyki",
                     "Umowa na zastępstwo"], (1, 0), opis_nazwy="Nazwa rodzaju umowy"),
            slownik("SalaryPeriod", "Okres, za który podano kwotę.", ["Za godzinę", "Miesięcznie", "Rocznie", "Za projekt"],
                    (0, 1), dlugosc=20, opis_nazwy="Nazwa okresu"),
            tabela("PostingSalary", 11, "Umowa z widełkami w ogłoszeniu – jedno ogłoszenie może mieć kilka takich wierszy.", [
                fk("JobPosting", "Ogłoszenie"),
                fk("ContractType", "Rodzaj umowy"),
                kol("SalaryFrom", "NUMBER(10,2)", "Widełki od (puste = nie podano)", pusta=True),
                kol("SalaryTo", "NUMBER(10,2)", "Widełki do", pusta=True),
                fk("Currency", "Waluta (puste, gdy brak kwoty)", pusta=True),
                fk("SalaryPeriod", "Za jaki okres (puste, gdy brak kwoty)", pusta=True),
                flaga("IsGross", "Czy kwota jest brutto", pusta=True),
            ], (1, 1), unikalne=[("JobPostingKey", "ContractTypeKey")],
                warunki=["SalaryFrom IS NULL OR SalaryTo IS NULL OR SalaryFrom <= SalaryTo"]),
            tabela("PostingBenefit", 11, "Benefit w ogłoszeniu – tabela łącząca ogłoszenia z benefitami.", [
                fk("JobPosting", "Ogłoszenie"),
                fk("Benefit", "Benefit"),
            ], (2, 1), rodzaj="łącząca", unikalne=[("JobPostingKey", "BenefitKey")]),
            tabela("Benefit", 4, "Dodatek do pracy, np. prywatna opieka medyczna.", [
                kol("BenefitName", "VARCHAR2(80)", "Nazwa benefitu", unikalna=True),
                fk("BenefitCategory", "Grupa benefitu"),
            ], (2, 2), rodzaj="słownik", wartosci=[("Prywatna opieka medyczna", 1), ("Karta sportowa", 2),
                                                   ("Budżet szkoleniowy", 3), ("Elastyczne godziny pracy", 4),
                                                   ("Premia roczna", 5)]),
            slownik("BenefitCategory", "Grupa benefitów.", ["Zdrowie", "Sport i rekreacja", "Rozwój", "Elastyczność",
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
            slownik("RequirementLevel", "Ważność wymagania.", ["Wymagane", "Mile widziane"], (0, 0), dlugosc=20,
                    opis_nazwy="Nazwa ważności"),
            tabela("PostingResponsibility", 11, "Obowiązek opisany w ogłoszeniu.", [
                fk("JobPosting", "Ogłoszenie"),
                kol("ResponsibilityText", "VARCHAR2(400)", "Treść obowiązku"),
                fk("ExtractionMethod", "Skąd wiemy"),
            ], (2, 0)),
            tabela("ProficiencyLevel", 3, "Poziom znajomości – każda grupa umiejętności ma własną skalę.", [
                kol("ProficiencyLevelName", "VARCHAR2(40)", "Nazwa poziomu, np. B2"),
                fk("SkillCategory", "Dla jakiej grupy umiejętności"),
                kol("ProficiencyRank", "NUMBER(2)", "Kolejność w skali (1 = najniższy)"),
            ], (0, 1), rodzaj="słownik", unikalne=[("SkillCategoryKey", "ProficiencyLevelName")],
                wartosci=[("A2", 3, 2), ("B1", 3, 3), ("B2", 3, 4), ("C1", 3, 5), ("Podstawowy", 1, 1),
                          ("Średniozaawansowany", 1, 2), ("Zaawansowany", 1, 3)]),
            tabela("PostingRequirement", 11, "Wymaganie w ogłoszeniu.", [
                fk("JobPosting", "Ogłoszenie"),
                fk("Skill", "Umiejętność"),
                fk("RequirementLevel", "Wymagane czy mile widziane"),
                fk("ProficiencyLevel", "Poziom (bywa niepodany)", pusta=True),
                kol("MinYearsExperience", "NUMBER(2)", "Minimalne doświadczenie w latach", pusta=True),
                fk("ExtractionMethod", "Skąd wiemy"),
            ], (1, 1), unikalne=[("JobPostingKey", "SkillKey")]),
            slownik("ExtractionMethod", "Skąd pochodzi informacja.",
                    ["Pole z API platformy", "Reguła tekstowa", "Model AI", "Wpisane ręcznie"], (2, 1),
                    opis_nazwy="Nazwa źródła informacji"),
            slownik("SkillCategory", "Grupa umiejętności.",
                    ["Technologia lub narzędzie", "Umiejętność miękka", "Język obcy", "Wykształcenie", "Certyfikat",
                     "Uprawnienie"], (0, 2), opis_nazwy="Nazwa grupy"),
            tabela("Skill", 6, "Umiejętność albo kwalifikacja.", [
                kol("SkillName", "VARCHAR2(80)", "Nazwa", unikalna=True),
                fk("SkillCategory", "Grupa"),
            ], (1, 2), rodzaj="słownik", wartosci=[("SQL", 1), ("Język angielski", 3), ("Komunikatywność", 2),
                                                   ("Wykształcenie wyższe", 4), ("Prawo jazdy kat. B", 6)]),
            tabela("SkillSynonym", 7, "Inny zapis tej samej umiejętności.", [
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
            ("O zdarzeniu mówi platforma albo wykrywamy je sami (np. ogłoszenie zniknęło bez komunikatu).",
             ["EventSource"]),
            ("Każda edycja zmienia treść – trzymamy każdą wersję, żeby widzieć, co firma zmieniła.", ["PostingVersion"]),
            ("Powtarzalne fragmenty bywają ogólne (klauzula RODO) albo typowe dla jednej firmy (jej stopka „O nas”). "
             "Zgoda na „przyszłe rekrutacje” to sygnał zbierania CV na zapas.",
             ["BoilerplatePattern", "BoilerplateType", "VersionBoilerplate"]),
        ],
        "Czy pełne teksty wersji trzymać w bazie (CLOB – tak jest teraz), czy tylko skróty i różnice między wersjami?",
        [(2, "zbiory posting_events, posting_texts_clean"), (6, "boilerplate_patterns i employer_boilerplate")],
        [
            slownik("EventSource", "Kto powiedział nam o zdarzeniu.",
                    ["Zgłoszone przez platformę", "Wykryte przez nas", "Wpisane przez moderatora"], (0, 0),
                    opis_nazwy="Nazwa źródła zdarzenia"),
            slownik("PostingEventType", "Rodzaj zdarzenia w życiu ogłoszenia.",
                    ["Opublikowano", "Edytowano treść", "Odświeżono (podbito)", "Wygasło", "Zamknięto przed terminem",
                     "Opublikowano ponownie", "Usunięto"], (0, 1), opis_nazwy="Nazwa zdarzenia"),
            tabela("PostingEvent", 12, "Zdarzenie w życiu ogłoszenia – tylko dopisujemy, nic nie zmieniamy.", [
                fk("JobPosting", "Ogłoszenie"),
                fk("PostingEventType", "Co się stało"),
                fk("EventSource", "Skąd wiemy"),
                kol("OccurredAt", "TIMESTAMP", "Kiedy"),
                fk("DataDelivery", "W której dostawie przyszła informacja", pusta=True),
            ], (1, 1), rodzaj="zdarzenia"),
            tabela("PostingVersion", 11, "Wersja treści ogłoszenia – każda edycja to nowy wiersz.", [
                fk("JobPosting", "Ogłoszenie"),
                kol("VersionNumber", "NUMBER(3)", "Numer wersji (1, 2, 3…)"),
                kol("VersionTitle", "VARCHAR2(200)", "Tytuł w tej wersji"),
                kol("OriginalText", "CLOB", "Treść tak, jak przyszła"),
                kol("CleanText", "CLOB", "Treść bez stopek i klauzul", pusta=True),
                kol("TextHash", "VARCHAR2(64)", "Skrót treści – szybkie porównanie wersji"),
                kol("ValidFrom", "TIMESTAMP", "Od kiedy treść była taka"),
                kol("ValidTo", "TIMESTAMP", "Do kiedy (puste = aktualna)", pusta=True),
            ], (2, 1), rodzaj="historia", unikalne=[("JobPostingKey", "VersionNumber")]),
            tabela("BoilerplatePattern", 6, "Powtarzalny fragment tekstu do rozpoznania w ogłoszeniach.", [
                fk("BoilerplateType", "Rodzaj fragmentu"),
                kol("PatternText", "VARCHAR2(1000)", "Treść albo wzorzec fragmentu"),
                fk("Employer", "Firma, której to fragment (puste = wzorzec ogólny)", pusta=True),
            ], (3, 1)),
            tabela("VersionBoilerplate", 12, "Fragment znaleziony w wersji ogłoszenia – tabela łącząca.", [
                fk("PostingVersion", "Wersja ogłoszenia"),
                fk("BoilerplatePattern", "Znaleziony fragment"),
            ], (2, 2), rodzaj="łącząca", unikalne=[("PostingVersionKey", "BoilerplatePatternKey")]),
            slownik("BoilerplateType", "Rodzaj powtarzalnego fragmentu.",
                    ["Stopka „O nas”", "Klauzula RODO", "Zgoda na przyszłe rekrutacje", "Formatowanie HTML"], (3, 2),
                    opis_nazwy="Nazwa rodzaju fragmentu"),
        ],
        zewnetrzne={"DataDelivery": (1, 0), "JobPosting": (2, 0), "Employer": (3, 0)},
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
            ("Podobieństwo liczymy różnymi metodami (porównanie tekstu, wektory znaczenia z modelu AI, porównanie cech), "
             "a metody się zmieniają – zapisujemy wersję, żeby móc przeliczyć wszystko od nowa.", ["SimilarityMethod"]),
            ("Para to dwa ogłoszenia z tej samej tabeli, więc tabela ma dwa klucze obce do JobPosting.",
             ["SimilarityPair"]),
            ("Rodzina zbiera wiele ogłoszeń, a jej historię liczymy co jakiś czas od nowa (stan na dany dzień).",
             ["PostingFamily", "FamilyMember", "FamilyLifecycle"]),
        ],
        "Czy ogłoszenie może należeć do kilku rodzin naraz? Teraz może tylko do jednej (klucz unikalny w FamilyMember).",
        [(2, "zbiory similar_posting_pairs, posting_families, posting_lifecycles")],
        [
            slownik("SimilarityType", "Rodzaj powtórki.",
                    ["Dokładna kopia", "Ta sama treść innymi słowami", "Ten sam etat z innym poziomem",
                     "To samo ogłoszenie na innej platformie"], (0, 0), opis_nazwy="Nazwa rodzaju powtórki"),
            tabela("SimilarityMethod", 3, "Metoda liczenia podobieństwa w konkretnej wersji.", [
                kol("SimilarityMethodName", "VARCHAR2(60)", "Nazwa metody"),
                kol("MethodVersion", "VARCHAR2(20)", "Wersja metody"),
                kol("ValidFrom", "DATE", "Od kiedy używana"),
            ], (1, 0), rodzaj="słownik", unikalne=[("SimilarityMethodName", "MethodVersion")],
                wartosci=[("Porównanie tekstu", "1.0", "2026-11-01"), ("Wektory znaczenia (model AI)", "1.0", "2026-11-01"),
                          ("Porównanie cech ogłoszenia", "1.0", "2026-11-01")]),
            tabela("SimilarityPair", 12, "Para podobnych ogłoszeń – dwa klucze obce do tej samej tabeli.", [
                fk("JobPosting", "Pierwsze ogłoszenie (wcześniejsze)", nazwa="FirstJobPostingKey"),
                fk("JobPosting", "Drugie ogłoszenie", nazwa="SecondJobPostingKey"),
                fk("SimilarityType", "Rodzaj powtórki"),
                fk("SimilarityMethod", "Metoda"),
                kol("SimilarityScore", "NUMBER(4,3)", "Podobieństwo od 0 do 1"),
                kol("DetectedAt", "TIMESTAMP", "Kiedy wykryto"),
            ], (0, 1), unikalne=[("FirstJobPostingKey", "SecondJobPostingKey", "SimilarityMethodKey")],
                warunki=["FirstJobPostingKey < SecondJobPostingKey", "SimilarityScore BETWEEN 0 AND 1"]),
            tabela("FamilyMember", 11, "Ogłoszenie w rodzinie – tabela łącząca.", [
                fk("PostingFamily", "Rodzina"),
                fk("JobPosting", "Ogłoszenie (najwyżej w jednej rodzinie)", unikalna=True),
                kol("AddedAt", "TIMESTAMP", "Kiedy dołączono do rodziny"),
            ], (2, 1), rodzaj="łącząca"),
            tabela("PostingFamily", 9, "Rodzina ogłoszeń – to samo stanowisko jednej firmy w czasie.", [
                fk("Employer", "Firma"),
                kol("FamilyLabel", "VARCHAR2(200)", "Opis stanowiska, np. „Księgowa, Kraków”"),
                kol("FirstSeenDate", "DATE", "Pierwsza publikacja"),
                kol("LastSeenDate", "DATE", "Ostatnia publikacja"),
            ], (3, 1), warunki=["LastSeenDate >= FirstSeenDate"]),
            tabela("FamilyLifecycle", 10, "Historia rodziny policzona na dany dzień.", [
                fk("PostingFamily", "Rodzina"),
                kol("CalculatedOn", "DATE", "Dzień obliczenia"),
                kol("PublicationCount", "NUMBER(4)", "Ile razy publikowano"),
                kol("VisibleDays", "NUMBER(5)", "Ile dni łącznie było widoczne"),
                kol("GapCount", "NUMBER(4)", "Ile razy znikało i wracało"),
                kol("RefreshCount", "NUMBER(5)", "Ile razy odświeżano"),
                kol("PlatformCount", "NUMBER(3)", "Na ilu platformach"),
                kol("SeniorityVariantCount", "NUMBER(2)", "Ile różnych poziomów stanowiska"),
            ], (3, 2), rodzaj="migawka", unikalne=[("PostingFamilyKey", "CalculatedOn")]),
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
             "oferta, zatrudnienie, wycofana – jeśli platforma je zna.", ["ApplicationStatus", "ApplicationStatusChange"]),
            ("Zgoda dotyczy konkretnej rzeczy (przypomnienia, cechy urządzenia) i konkretnej wersji tekstu; można ją "
             "wycofać – każda decyzja to nowy wiersz.", ["ConsentType", "ConsentTextVersion", "Consent"]),
        ],
        "Czy trzymać ostatni status aplikacji w tabeli Application (szybciej), czy tylko w historii "
        "ApplicationStatusChange – tak jest teraz?",
        [(3, "zbiory application_log, consents")],
        [
            tabela("CandidatePseudonym", 10, "Kandydat znany tylko z pseudonimu nadanego przez platformę.", [
                fk("SourcePlatform", "Platforma, która nadała pseudonim"),
                kol("PseudonymValue", "VARCHAR2(64)", "Ciąg znaków od platformy"),
                kol("FirstSeenAt", "TIMESTAMP", "Kiedy pierwszy raz się pojawił"),
            ], (0, 1), unikalne=[("SourcePlatformKey", "PseudonymValue")]),
            tabela("Application", 12, "Aplikacja kandydata na ogłoszenie, potwierdzona przez platformę.", [
                fk("CandidatePseudonym", "Kandydat"),
                fk("JobPosting", "Ogłoszenie"),
                kol("AppliedAt", "TIMESTAMP", "Kiedy aplikował"),
                fk("DataDelivery", "W której dostawie przyszła informacja", pusta=True),
            ], (1, 1), unikalne=[("CandidatePseudonymKey", "JobPostingKey")]),
            tabela("Consent", 11, "Decyzja kandydata o zgodzie – udzielenie albo wycofanie to nowy wiersz.", [
                fk("CandidatePseudonym", "Kandydat"),
                fk("ConsentTextVersion", "Treść zgody, którą widział"),
                flaga("IsGranted", "T = zgoda udzielona, N = wycofana"),
                kol("DecidedAt", "TIMESTAMP", "Kiedy"),
            ], (0, 2), rodzaj="historia"),
            tabela("ApplicationStatusChange", 12, "Zmiana stanu aplikacji – historia.", [
                fk("Application", "Aplikacja"),
                fk("ApplicationStatus", "Nowy stan"),
                kol("ChangedAt", "TIMESTAMP", "Kiedy"),
            ], (1, 2), rodzaj="historia"),
            slownik("ApplicationStatus", "Stan aplikacji.",
                    ["Wysłana", "Wyświetlona przez firmę", "Odrzucona automatycznie", "Zaproszenie na rozmowę",
                     "Oferta pracy", "Zatrudnienie", "Wycofana przez kandydata"], (2, 2), opis_nazwy="Nazwa stanu"),
            tabela("ConsentTextVersion", 4, "Wersja treści zgody, którą kandydat zobaczył.", [
                fk("ConsentType", "Na co jest zgoda"),
                kol("VersionLabel", "VARCHAR2(10)", "Oznaczenie wersji, np. 1.2"),
                kol("ConsentText", "CLOB", "Pełna treść zgody"),
                kol("ValidFrom", "DATE", "Od kiedy pokazywana"),
            ], (0, 3), rodzaj="historia", unikalne=[("ConsentTypeKey", "VersionLabel")]),
            slownik("ConsentType", "Na co kandydat się zgadza.",
                    ["Przypomnienia o wyniku rekrutacji", "Zbieranie cech urządzenia"], (1, 3), opis_nazwy="Nazwa zgody"),
        ],
        zewnetrzne={"SourcePlatform": (0, 0), "JobPosting": (1, 0), "DataDelivery": (2, 0)},
    ),
    organizm(
        14, "D", "Zgłoszenie wyniku rekrutacji",
        "Relacja kandydata o tym, co stało się po aplikacji, i przypomnienia, które go o to pytają.",
        "Zgłoszenie to w szerszym kontekście relacja świadka: kandydat mówi, co stało się po aplikacji. To pojedyncza, "
        "niesprawdzona informacja – dowodem staje się dopiero wiele zgłoszeń po weryfikacji (organizm 15).",
        [
            ("Wynik bywa różny: cisza, automatyczna odmowa, odmowa po rozmowie, wycofana oferta, zatrudnienie, "
             "nieaktualne ogłoszenie.", ["ReportOutcome"]),
            ("Ważne jest, na którym etapie rekrutacja się skończyła: po CV, po teście, po rozmowie, po ofercie.",
             ["RecruitmentStage"]),
            ("Kandydat zgłasza sam z siebie albo w odpowiedzi na przypomnienie; przypomnień bywa kilka i różnie się "
             "kończą.", ["ReportChannel", "Reminder", "ReminderStatus"]),
        ],
        "Czy kandydat może zmienić swoje zgłoszenie (np. najpierw „cisza”, potem „zatrudnienie”) i czy to ma być nowy "
        "wiersz, czy poprawka starego?",
        [(3, "zbiory reports, reminders_sent")],
        [
            slownik("ReportOutcome", "Wynik rekrutacji według kandydata.",
                    ["Brak odpowiedzi (cisza)", "Automatyczna odmowa", "Odmowa po rozmowie", "Oferta wycofana",
                     "Zatrudnienie", "Ogłoszenie było nieaktualne"], (0, 1), opis_nazwy="Nazwa wyniku"),
            tabela("RecruitmentReport", 11, "Zgłoszenie wyniku rekrutacji – tylko dopisujemy, nie poprawiamy.", [
                fk("CandidatePseudonym", "Kto zgłasza"),
                fk("JobPosting", "Którego ogłoszenia dotyczy"),
                fk("ReportOutcome", "Wynik"),
                fk("RecruitmentStage", "Na którym etapie się skończyło"),
                fk("ReportChannel", "Jak zgłoszono"),
                fk("Reminder", "Przypomnienie, po którym przyszło zgłoszenie", pusta=True),
                kol("ReportedAt", "TIMESTAMP", "Kiedy zgłoszono"),
            ], (1, 1), rodzaj="zdarzenia"),
            tabela("Reminder", 11, "Przypomnienie wysłane kandydatowi przez platformę na naszą prośbę.", [
                fk("Application", "Aplikacja, o którą pytamy"),
                fk("ReminderStatus", "Co się stało z przypomnieniem"),
                kol("ReminderNumber", "NUMBER(1)", "Które to przypomnienie (1, 2…)"),
                kol("SentAt", "TIMESTAMP", "Kiedy zlecono"),
            ], (2, 1), unikalne=[("ApplicationKey", "ReminderNumber")]),
            slownik("RecruitmentStage", "Etap rekrutacji.",
                    [("Po wysłaniu CV", 1), ("Po zadaniu lub teście", 2), ("Po pierwszej rozmowie", 3),
                     ("Po kolejnej rozmowie", 4), ("Po otrzymaniu oferty", 5)], (0, 2), opis_nazwy="Nazwa etapu",
                    kolumny=[kol("StageRank", "NUMBER(2)", "Kolejność etapów")]),
            slownik("ReportChannel", "Jak przyszło zgłoszenie.", ["Formularz w widżecie", "Odpowiedź na przypomnienie"],
                    (1, 2), opis_nazwy="Nazwa kanału"),
            slownik("ReminderStatus", "Los przypomnienia.",
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
            ("Ocena kończy się różnie: przyjęte, do moderacji, odrzucone; zgłoszenie można ocenić ponownie, gdy przyjdą "
             "nowe dane – każda ocena to nowy wiersz.", ["ReportVerdict", "VerdictDecision"]),
        ],
        "Czy wyniki wszystkich sprawdzeń trzymać w jednej tabeli ReportCheck – tak jest teraz – czy każde sprawdzenie w "
        "osobnej tabeli z własnymi kolumnami?",
        [(3, "zbiory bot_checks, device_fingerprints, report_verdicts, widok validated_reports")],
        [
            slownik("CheckType", "Rodzaj sprawdzenia.",
                    ["Człowiek czy bot (Cloudflare)", "Dowód aplikacji", "Odcisk urządzenia", "Fala zgłoszeń"], (0, 0),
                    opis_nazwy="Nazwa sprawdzenia"),
            slownik("VerdictDecision", "Decyzja o zgłoszeniu.", ["Przyjęte", "Do moderacji", "Odrzucone"], (2, 0),
                    dlugosc=20, opis_nazwy="Nazwa decyzji"),
            tabela("ReportCheck", 12, "Wynik jednego sprawdzenia jednego zgłoszenia.", [
                fk("RecruitmentReport", "Zgłoszenie"),
                fk("CheckType", "Rodzaj sprawdzenia"),
                fk("CheckResult", "Wynik"),
                kol("CheckedAt", "TIMESTAMP", "Kiedy sprawdzono"),
                kol("CheckDetails", "VARCHAR2(400)", "Szczegóły, np. „aplikacja 34 dni temu”", pusta=True),
            ], (0, 1), rodzaj="zdarzenia"),
            tabela("ReportVerdict", 11, "Ocena zgłoszenia – każda ponowna ocena to nowy wiersz.", [
                fk("RecruitmentReport", "Zgłoszenie"),
                fk("VerdictDecision", "Decyzja"),
                kol("ReportWeight", "NUMBER(3,2)", "Waga od 0 do 1"),
                kol("RuleSetVersion", "VARCHAR2(20)", "Wersja reguł oceny"),
                kol("DecidedAt", "TIMESTAMP", "Kiedy oceniono"),
            ], (2, 1), rodzaj="historia", warunki=["ReportWeight BETWEEN 0 AND 1"]),
            slownik("CheckResult", "Wynik sprawdzenia.", ["Pozytywny", "Negatywny", "Nie dało się sprawdzić",
                                                         "Za wcześnie"], (0, 2), dlugosc=30, opis_nazwy="Nazwa wyniku"),
            tabela("ReportDevice", 11, "Urządzenie, z którego wysłano zgłoszenie – tabela łącząca.", [
                fk("RecruitmentReport", "Zgłoszenie", unikalna=True),
                fk("DeviceFingerprint", "Urządzenie"),
            ], (1, 2), rodzaj="łącząca"),
            tabela("DeviceFingerprint", 10, "Urządzenie zapisane tylko jako skrót cech.", [
                kol("FingerprintHash", "VARCHAR2(64)", "Skrót cech urządzenia (bez samych cech)", unikalna=True),
                kol("FirstSeenAt", "TIMESTAMP", "Kiedy pierwszy raz"),
                kol("ExpiresAt", "DATE", "Kiedy usunąć – dane osobowe trzymamy krótko"),
            ], (1, 3)),
        ],
        zewnetrzne={"RecruitmentReport": (1, 1)},
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
            ("Alert przechodzi przez stany: nowy, w moderacji, potwierdzone nadużycie, fałszywy alarm.", ["AlertStatus"]),
            ("Jeden alert obejmuje wiele zgłoszeń, a jedno zgłoszenie może trafić do kilku alertów – relacja wiele do "
             "wielu.", ["AlertReport"]),
        ],
        "Czy alert dotyczy zawsze jednej firmy (EmployerKey – tak jest teraz), czy może dotyczyć np. całej platformy?",
        [(3, "zbiór abuse_alerts")],
        [
            slownik("AlertType", "Rodzaj podejrzanego wzorca.",
                    ["Fala negatywnych zgłoszeń", "Fala pozytywnych zgłoszeń od samej firmy",
                     "Jedno urządzenie, wiele pseudonimów", "Zgłoszenia bez aplikacji"], (0, 0), dlugosc=50,
                    opis_nazwy="Nazwa wzorca"),
            slownik("AlertStatus", "Stan alertu.", ["Nowy", "W moderacji", "Potwierdzone nadużycie", "Fałszywy alarm"],
                    (2, 0), dlugosc=30, opis_nazwy="Nazwa stanu"),
            tabela("AbuseAlert", 9, "Alert o podejrzanej fali zgłoszeń dotyczącej jednej firmy.", [
                fk("Employer", "Firma"),
                fk("AlertType", "Rodzaj wzorca"),
                fk("AlertStatus", "Stan"),
                kol("WindowStart", "TIMESTAMP", "Początek okresu fali"),
                kol("WindowEnd", "TIMESTAMP", "Koniec okresu fali"),
                kol("DetectedAt", "TIMESTAMP", "Kiedy wykryto"),
                kol("ReportCount", "NUMBER(6)", "Ile zgłoszeń w fali"),
            ], (1, 1), warunki=["WindowEnd >= WindowStart"]),
            tabela("AlertReport", 11, "Zgłoszenie objęte alertem – tabela łącząca.", [
                fk("AbuseAlert", "Alert"),
                fk("RecruitmentReport", "Zgłoszenie"),
            ], (1, 2), rodzaj="łącząca", unikalne=[("AbuseAlertKey", "RecruitmentReportKey")]),
        ],
        zewnetrzne={"Employer": (1, 0), "RecruitmentReport": (2, 2)},
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
             "dla innych gorzej.", ["SignalType"]),
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
            slownik("SignalGroup", "Grupa sygnałów.",
                    ["Powtórki ogłoszeń", "Odpowiedzi firmy na aplikacje", "Przejrzystość ogłoszeń", "Dane z rejestrów"],
                    (2, 0), opis_nazwy="Nazwa grupy"),
            tabela("SignalSnapshot", 10, "Stan sygnałów jednej firmy na dany dzień.", [
                fk("Employer", "Firma"),
                kol("SnapshotDate", "DATE", "Na jaki dzień"),
            ], (0, 1), rodzaj="migawka", unikalne=[("EmployerKey", "SnapshotDate")]),
            tabela("SignalValue", 12, "Wartość jednego sygnału w jednym stanie.", [
                fk("SignalSnapshot", "Stan na dany dzień"),
                fk("SignalType", "Rodzaj sygnału"),
                kol("SignalNumericValue", "NUMBER(12,4)", "Wartość"),
                kol("BasedOnCount", "NUMBER(7)", "Na ilu danych opiera się wartość", pusta=True),
            ], (1, 1), unikalne=[("SignalSnapshotKey", "SignalTypeKey")]),
            tabela("SignalType", 3, "Rodzaj sygnału z jednostką i kierunkiem.", [
                kol("SignalTypeName", "VARCHAR2(80)", "Nazwa sygnału", unikalna=True),
                fk("SignalGroup", "Grupa"),
                kol("SignalUnit", "VARCHAR2(20)", "Jednostka, np. %, dni, liczba"),
                flaga("HigherIsBetter", "T = im więcej, tym lepiej dla firmy"),
                kol("SignalDescription", "VARCHAR2(300)", "Jak liczymy", pusta=True),
            ], (2, 1), rodzaj="słownik",
                wartosci=[("Odsetek ogłoszeń będących powtórkami", 1, "%", "N", None),
                          ("Średnia liczba publikacji jednego stanowiska", 1, "liczba", "N", None),
                          ("Zatrudnienia na 100 aplikacji", 2, "liczba", "T", None),
                          ("Zgłoszenia ciszy na 100 aplikacji", 2, "liczba", "N", None),
                          ("Odsetek ogłoszeń z widełkami", 3, "%", "T", None),
                          ("Wiek firmy w rejestrze", 4, "dni", "T", None)]),
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
             "metody mają wersje.", ["ScoringMethod", "ScoringMethodType"]),
            ("Każda metoda daje inną wagę każdemu sygnałowi – relacja wiele do wielu z wartością.", ["ScoringWeight"]),
            ("Wynik ma pewność i 2–3 główne powody, które widzi kandydat i firma.", ["TrustScore", "ScoreReason"]),
            ("Nie każdy wynik wolno pokazać: przy małej pewności pokazujemy „za mało danych”, ostrzeżenie czeka na decyzję "
             "moderatora, a po odwołaniu wynik można wycofać.", ["PublishedScore", "PublicationStatus"]),
        ],
        "Czy wynik publiczny (PublishedScore) może się różnić od ostatniego wyniku roboczego (np. gdy jest wstrzymany), "
        "czy zawsze ma pokazywać ostatni?",
        [(4, "zbiory trust_score_history, published_trust_scores, model_registry")],
        [
            slownik("ScoringMethodType", "Rodzaj metody liczenia wyniku.",
                    ["Wagi ustalone przez zespół", "Wytrenowany model"], (0, 0), opis_nazwy="Nazwa rodzaju metody"),
            tabela("ScoringMethod", 4, "Metoda liczenia wyniku w konkretnej wersji.", [
                fk("ScoringMethodType", "Rodzaj metody"),
                kol("MethodVersion", "VARCHAR2(20)", "Wersja"),
                kol("ValidFrom", "DATE", "Od kiedy używana"),
                kol("ValidTo", "DATE", "Do kiedy (puste = obecna)", pusta=True),
            ], (1, 0), rodzaj="historia", unikalne=[("ScoringMethodTypeKey", "MethodVersion")],
                wartosci=[(1, "1.0", "2026-12-01", None)]),
            tabela("ScoringWeight", 6, "Waga sygnału w danej metodzie – tabela łącząca z wartością.", [
                fk("ScoringMethod", "Metoda"),
                fk("SignalType", "Sygnał"),
                kol("WeightValue", "NUMBER(5,3)", "Waga"),
            ], (2, 0), rodzaj="łącząca", unikalne=[("ScoringMethodKey", "SignalTypeKey")]),
            tabela("TrustScore", 11, "Wynik roboczy – każde przeliczenie to nowy wiersz.", [
                fk("SignalSnapshot", "Na jakich danych liczono"),
                fk("ScoringMethod", "Jaką metodą"),
                kol("ScoreValue", "NUMBER(3)", "Wynik od 0 do 100"),
                kol("ScoreConfidence", "NUMBER(3,2)", "Pewność od 0 do 1"),
                kol("CalculatedAt", "TIMESTAMP", "Kiedy policzono"),
            ], (1, 1), rodzaj="historia", warunki=["ScoreValue BETWEEN 0 AND 100", "ScoreConfidence BETWEEN 0 AND 1"]),
            tabela("ScoreReason", 12, "Powód wyniku pokazywany kandydatowi i firmie.", [
                fk("TrustScore", "Wynik"),
                fk("SignalType", "Którego sygnału dotyczy"),
                kol("ReasonRank", "NUMBER(1)", "Kolejność ważności"),
                kol("ReasonText", "VARCHAR2(300)", "Tekst, np. „to samo ogłoszenie 7 razy w 9 miesięcy”"),
            ], (2, 1), unikalne=[("TrustScoreKey", "ReasonRank")]),
            tabela("PublishedScore", 10, "Wynik pokazany publicznie – osobno od wyniku roboczego.", [
                fk("TrustScore", "Który wynik pokazujemy"),
                fk("PublicationStatus", "Stan publikacji"),
                kol("PublishedFrom", "TIMESTAMP", "Od kiedy"),
                kol("PublishedTo", "TIMESTAMP", "Do kiedy (puste = widoczny teraz)", pusta=True),
            ], (1, 2), rodzaj="historia", warunki=["PublishedTo IS NULL OR PublishedTo >= PublishedFrom"]),
            slownik("PublicationStatus", "Stan publikacji wyniku.",
                    ["Opublikowany", "Za mało danych", "Wstrzymany do decyzji moderatora", "Wycofany po odwołaniu"],
                    (2, 2), opis_nazwy="Nazwa stanu publikacji"),
        ],
        zewnetrzne={"SignalSnapshot": (0, 1), "SignalType": (3, 0)},
    ),
]
