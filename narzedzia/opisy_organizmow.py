"""Opisy organizmów na stronie web/organizmy.html – każdy organizm dwa razy:

- „dla każdego” – prostym językiem, bez wiedzy o bazach danych: o czym jest organizm, przykład i opis każdej tabeli,
- „dla technicznych” – krótko: decyzje projektowe i ich skutki oraz to, czego baza jeszcze nie pilnuje.

Relacje, liczby i zależności między organizmami generator wylicza sam z organizmy.py.
W tekstach technicznych `tak` oznacza kod (nazwę kolumny, fragment SQL).
Generator ostrzega, gdy opis pomija tabelę organizmu albo opisuje tabelę, której nie ma.
Po zmianie uruchom: python narzedzia/build_web.py
"""

WSTEP = {
    "lede": "Każdy z 18 organizmów opisany dwa razy: prostym językiem – dla osób, które nie znają baz danych – i krótko "
            "dla osób technicznych, z decyzjami projektowymi i ich skutkami.",
    "po_co": [
        "Ghost-Job Scanner wykrywa widmowe ogłoszenia o pracę (ang. ghost jobs). To ogłoszenia, za którymi nie stoi "
        "prawdziwa chęć zatrudnienia: firma zbiera CV na zapas, chce wyglądać na rozwijającą się albo nie zdjęła "
        "ogłoszenia, choć stanowisko dawno obsadziła. Zbieranie CV bez zamiaru zatrudnienia nazywa się CV harvesting.",
        "Platformy z ogłoszeniami, np. pracuj.pl albo OLX, przekazują nam dane o kontach firm, ogłoszeniach i "
        "aplikacjach. Kandydaci mówią nam, co stało się po aplikacji: cisza, odmowa, rozmowa albo zatrudnienie. Z tych "
        "danych liczymy dla każdej firmy Trust Score – ocenę wiarygodności od 0 do 100 – i pokazujemy ją przy ogłoszeniu.",
        "Baza danych to miejsce, w którym system to wszystko zapisuje. Podzieliliśmy ją na 18 organizmów – grup tabel, "
        "z których każda opisuje jedną część systemu. Idą w kolejności, w jakiej płyną dane: od platformy, która je "
        "dostarcza, do oceny firmy.",
    ],
    "przyklad": "W każdym opisie wracamy do tego samego zmyślonego przykładu. Firma „Przykład Logistyka sp. z o.o.” z "
                "Krakowa co miesiąc publikuje na pracuj.pl to samo ogłoszenie „Magazynier/ka”, a agencja „Kadry Przykład” "
                "publikuje je też na OLX. Jedna osoba aplikuje, przez miesiąc nie dostaje odpowiedzi i zgłasza to przez "
                "nasz widżet. Nazwy firm są zmyślone. pracuj.pl i OLX to prawdziwe serwisy, ale umowy z nimi i wszystkie "
                "liczby w przykładach są wymyślone.",
}

SLOWNICZEK = [
    ("Baza danych", "Miejsce, w którym system zapisuje informacje w uporządkowany sposób – w tabelach."),
    ("Tabela", "Lista rzeczy jednego rodzaju, np. lista platform albo lista ogłoszeń."),
    ("Wiersz", "Jedna rzecz z tej listy, np. jedna platforma."),
    ("Kolumna", "Jedna cecha zapisywana dla każdej rzeczy, np. nazwa platformy albo data publikacji."),
    ("Numer wiersza (klucz główny)", "Unikalny numer, po którym baza rozpoznaje wiersz. Nazywa się tak jak tabela, z "
     "końcówką Key, np. SourcePlatformKey."),
    ("Odwołanie do innej tabeli (klucz obcy)", "Kolumna, w której zapisujemy numer wiersza z innej tabeli, np. przy "
     "adresie strony – numer platformy, do której ten adres należy. Baza nie pozwoli wpisać numeru, którego nie ma."),
    ("Lista wariantów (słownik)", "Mała tabela z dozwolonymi wartościami, np. etapy umowy. Inne tabele wskazują wiersz "
     "z tej listy, zamiast wpisywać tekst, więc ta sama rzecz jest zawsze zapisana tak samo."),
    ("Tabela łącząca", "Tabela z parami, potrzebna, gdy jedna rzecz może mieć wiele drugich i odwrotnie – np. platforma "
     "działa w wielu krajach, a w jednym kraju działa wiele platform (relacja wiele do wielu)."),
    ("Historia", "Tabela, w której zmiana nie nadpisuje starych danych, tylko dodaje nowy wiersz z datą „od kiedy” i "
     "„do kiedy”. Puste „do kiedy” oznacza, że wiersz jest aktualny."),
    ("Dziennik zdarzeń", "Tabela, do której tylko dopisujemy: każdy wiersz to coś, co stało się w danej chwili."),
    ("Stan na dany dzień", "Wiersz z wynikami policzonymi w konkretnym dniu. Kolejne liczenie dodaje nowy wiersz."),
    ("Wartość unikalna", "Wartość, która nie może się powtórzyć w tabeli, np. nazwa platformy."),
    ("Warunek poprawności", "Reguła, której baza pilnuje przy każdym zapisie, np. data końca nie może być wcześniejsza "
     "niż data początku."),
    ("Organizm", "Kilka tabel, które razem opisują jedną część systemu."),
    ("Przedrostek ORG03_", "Początek nazwy tabeli w bazie Oracle: ORG i numer organizmu. Dzięki niemu tabele jednego "
     "organizmu stoją na liście obok siebie."),
    ("Platforma", "Serwis z ofertami pracy, z którego dostajemy dane, np. pracuj.pl albo OLX."),
    ("API", "Zestaw adresów internetowych dla programów, a nie dla ludzi. Program wysyła pod taki adres zapytanie i "
     "dostaje dane w ustalonym formacie."),
    ("Endpoint", "Jeden adres w API, pod który wysyła się jeden rodzaj zapytania, np. „podaj nowe ogłoszenia”."),
    ("Widżet", "Okienko z oceną firmy, które platforma wyświetla przy ogłoszeniu. Przez widżet kandydat może też "
     "zgłosić, co stało się po aplikacji."),
    ("Pseudonim", "Ciąg znaków, który platforma nadaje kandydatowi zamiast imienia i nazwiska. Tożsamość kandydata zna "
     "tylko platforma."),
    ("Skrót (hash)", "Krótki ciąg znaków obliczany z dłuższej treści. Ta sama treść daje zawsze ten sam skrót, ale ze "
     "skrótu nie da się odtworzyć treści."),
    ("Ghost job", "Ogłoszenie o pracę, za którym nie stoi prawdziwa chęć zatrudnienia, np. firma zbiera CV na zapas."),
    ("Trust Score", "Ocena wiarygodności firmy od 0 do 100, liczona z danych o jej ogłoszeniach i ze zgłoszeń kandydatów."),
]

# Etapy prostym językiem (numery organizmów dopisuje generator).
ETAPY_OPIS = {
    "A": "Skąd i jak przychodzą dane: platformy, ich API i endpointy oraz każda dostawa danych.",
    "B": "Kto stoi za ogłoszeniami: konta na platformach, prawdziwe firmy z rejestrów i powiązania między nimi.",
    "C": "Co firma publikuje: ogłoszenie, warunki zatrudnienia, wymagania, historia zmian i powtórki.",
    "D": "Co spotkało kandydatów: aplikacje, zgody, zgłoszenia wyników, ich sprawdzanie i wykrywanie nadużyć.",
    "E": "Jak z tych danych powstaje ocena firmy i co z niej widzi kandydat.",
}

KONWENCJE = [
    "Tabele po angielsku w PascalCase, w liczbie pojedynczej; w bazie z przedrostkiem organizmu, np. "
    "`ORG01_SourcePlatform`.",
    "Klucz główny `<Tabela>Key NUMBER(n)`; klucz obcy nazywa się jak klucz, do którego prowadzi. Wyjątek: kilka kluczy "
    "do tej samej tabeli, np. `AgencyEmployerKey` i `ClientEmployerKey`.",
    "Słowniki: `<Tabela>Name` z UNIQUE i wiersze startowe (INSERT w skrypcie organizmu).",
    "Flagi `CHAR(1)` z CHECK `IN ('T', 'N')`.",
    "Nazwy ograniczeń: nazwa tabeli w bazie i końcówka `_PK`, `_UN`, `_CK` albo `_FK`.",
    "Relacje: N:1 – wiele wierszy tej tabeli wskazuje jeden wiersz tabeli nadrzędnej; 1:1 – klucz obcy z UNIQUE; "
    "M:N – przez tabelę łączącą.",
    "Oracle AI Database 26ai (Autonomous Database, schemat GHOSTJOB); skrypty w `sql/organizmy/`.",
]

# Decyzje wspólne dla wszystkich organizmów: (decyzja, skutek).
WSPOLNE = [
    ("Organizmy bez kluczy obcych między sobą (41 kluczy czeka w pliku 99)",
     "każdy organizm da się założyć, poprawić i usunąć osobno; dopóki plik 99 nie jest uruchomiony, baza nie pilnuje "
     "spójności między organizmami."),
    ("Warianty w słownikach zamiast tekstu w kolumnach",
     "nowy wariant to INSERT, bez zmiany schematu; ta sama wartość jest zawsze zapisana tak samo."),
    ("Historia przez nowe wiersze z `ValidFrom`/`ValidTo` albo datą zdarzenia",
     "pełny audyt i stan na dowolny dzień; CHECK pilnuje tylko kolejności dat w jednym wierszu – nienakładanie się "
     "okresów i „jeden aktualny wiersz” wymagają wyzwalaczy albo unikalnych indeksów funkcyjnych."),
    ("Klucze `NUMBER(n)` bez IDENTITY i sekwencji",
     "wiersze startowe mają klucze 1, 2, 3…; zanim programy zaczną dopisywać dane, trzeba dodać "
     "`GENERATED BY DEFAULT ON NULL AS IDENTITY` albo sekwencje (do decyzji)."),
    ("Flagi `CHAR(1)` zamiast typu BOOLEAN",
     "działa w każdej wersji Oracle; od wersji 23ai jest też BOOLEAN – do rozważenia."),
    ("Tabele „tylko do dopisywania” (zdarzenia, historia)",
     "schemat tego nie wymusza; wymusimy to kontami programów z uprawnieniami INSERT i SELECT bez UPDATE i DELETE "
     "(zasada „program = osoba = konto w bazie”)."),
    ("Indeksy tylko z kluczy głównych i unikalnych",
     "Oracle nie zakłada indeksów na kluczach obcych sam – przed testami wydajności trzeba je dodać, zwłaszcza tam, "
     "gdzie usuwamy albo zmieniamy wiersze nadrzędne."),
]

# Opisy organizmów. Klucz to numer organizmu.
#   o_czym   – akapity „o czym jest ten organizm”,
#   przyklad – ciąg dalszy wspólnego przykładu,
#   tabele   – (tabela, nazwa po polsku, opis[, przykład na danych]) – każda tabela organizmu dokładnie raz;
#              przykład: {"wstep": tekst, "tabele": [(podpis, kolumny, wiersze)], "koniec": tekst},
#   skrot    – jedno-dwa zdania dla technicznych,
#   decyzje  – (decyzja, skutek),
#   luki     – czego baza jeszcze nie pilnuje.
OPISY = {
    1: {
        "o_czym": [
            "Ghost-Job Scanner sam nie publikuje ogłoszeń o pracę. Wszystko, co wie – jakie firmy mają konta, jakie "
            "ogłoszenia publikują i kto na nie aplikował – dostaje od serwisów z ofertami pracy. Takie serwisy "
            "nazywamy platformami. Ten organizm opisuje platformy: czym są, pod jakimi adresami działają, w jakich "
            "krajach i czy mamy z nimi podpisaną umowę.",
            "Od tego organizmu zaczyna się cała baza. Przy każdej informacji w systemie można zapytać, z której "
            "platformy przyszła, i odpowiedź zawsze prowadzi tutaj.",
        ],
        "przyklad": "Portal pracuj.pl to platforma rodzaju „Portal z ofertami pracy”. Działa pod dwoma adresami: "
                    "pracuj.pl (główny) i it.pracuj.pl, i publikuje oferty w Polsce. Załóżmy, że w październiku "
                    "zaczęliśmy z nim rozmowy o współpracy, w listopadzie ruszył pilotaż, a od stycznia umowa jest "
                    "aktywna. W bazie to: jeden wiersz na liście platform, dwa adresy, jedna para „pracuj.pl – Polska” "
                    "i trzy wiersze w historii umów, po jednym na każdy etap. OLX to platforma rodzaju „Serwis ogłoszeń "
                    "drobnych”, która działa w trzech krajach, więc ma trzy pary: z Polską, Rumunią i Portugalią.",
        "tabele": [
            ("SourcePlatform", "Lista platform",
             "Jeden wiersz to jeden serwis, z którego bierzemy dane, np. pracuj.pl albo OLX. Zapisujemy nazwę platformy "
             "(nie może się powtórzyć), adres strony głównej, rodzaj platformy i datę, od której zbieramy z niej dane. "
             "To ta sama tabela, którą prowadzący pokazał na zajęciach. Numer platformy może mieć do 4 cyfr, bo "
             "platformą jest też strona kariery pojedynczej firmy, a takich stron mogą być tysiące."),
            ("PlatformType", "Rodzaje platform",
             "Sześć rodzajów: portal z ofertami pracy, serwis ogłoszeń drobnych, agregator ofert (serwis, który zbiera "
             "oferty z innych serwisów), serwis społecznościowy, publiczny urząd pracy i strona kariery firmy. Każda "
             "platforma wskazuje jeden rodzaj. Rodzaje są w osobnej tabeli, żeby każdy był zawsze zapisany tak samo i "
             "żeby nowy rodzaj można było dopisać jednym wierszem, bez przebudowy bazy.",
             {"wstep": "Przykład na danych. Tabela rodzajów (PlatformType) ma 6 wierszy – każdy rodzaj ma swój numer:",
              "tabele": [
                  ("ORG01_PlatformType", ["PlatformTypeKey", "PlatformTypeName"],
                   [(1, "Portal z ofertami pracy"), (2, "Serwis ogłoszeń drobnych"), (3, "Agregator ofert"),
                    (4, "Serwis społecznościowy"), (5, "Publiczny urząd pracy"), (6, "Strona kariery firmy (ATS)")]),
                  ("ORG01_SourcePlatform – w kolumnie PlatformTypeKey jest tylko numer rodzaju",
                   ["SourcePlatformKey", "SourcePlatformName", "PlatformTypeKey", "co to znaczy"],
                   [(1, "pracuj.pl", 1, "portal z ofertami pracy"), (2, "OLX", 2, "serwis ogłoszeń drobnych")]),
              ],
              "koniec": "Gdy dojdzie np. strona „Kariera” jakiejś firmy, dostaje w SourcePlatform numer rodzaju 6. Gdy pojawi się zupełnie nowy rodzaj, np. aplikacja mobilna z ofertami pracy, wystarczy jeden nowy wiersz w PlatformType: 7 – „Aplikacja mobilna z ofertami”. Żadnej tabeli nie trzeba przebudowywać."}),
            ("PlatformDomain", "Adresy stron platform",
             "Jedna platforma może działać pod kilkoma adresami, np. pracuj.pl i it.pracuj.pl. Jeden wiersz to jeden "
             "adres; jeden z adresów platformy oznaczamy jako główny. Ten sam adres nie może należeć do dwóch "
             "platform. Adresy są potrzebne, bo nasz widżet sprawdza, na jakiej stronie go otwarto – po adresie "
             "rozpoznajemy platformę i to, czy jest naszym partnerem."),
            ("Country", "Kraje",
             "Lista krajów z dwuliterowym kodem, np. PL – Polska, DE – Niemcy. Z tej samej listy korzystają organizm 6 "
             "(kraj, w którym firma jest zarejestrowana) i organizm 8 (kraj miejsca pracy)."),
            ("PlatformMarket", "Kraje, w których działa platforma",
             "Jedna platforma może działać w kilku krajach (OLX: Polska, Rumunia, Portugalia), a w jednym kraju działa "
             "wiele platform. Jedna kolumna „kraj” nie wystarczy, dlatego jest osobna tabela: jeden wiersz to jedna para "
             "„platforma – kraj”, z datą, od kiedy platforma działa w tym kraju, jeśli ją znamy. Ta sama para nie może "
             "być zapisana dwa razy."),
            ("PartnerAgreement", "Historia umów z platformą",
             "Platforma może być naszym partnerem albo tylko źródłem, które obserwujemy bez umowy. Umowa przechodzi "
             "przez etapy, dlatego nie ma tu jednej kolumny „czy partner”, tylko historia: każdy etap to nowy wiersz z "
             "datą „od kiedy” i „do kiedy”. Puste „do kiedy” znaczy, że etap trwa. Zapisujemy też datę podpisania i "
             "to, czy podpisano umowę powierzenia danych osobowych, której wymaga RODO. Baza nie przyjmie daty końca "
             "wcześniejszej niż data początku."),
            ("AgreementStatus", "Etapy umowy", "Pięć etapów: negocjacje, pilotaż, aktywna, zawieszona, rozwiązana."),
        ],
        "skrot": "Korzeń całego modelu: SourcePlatform (PK NUMBER(4)), do którego prowadzą klucze z ORG02 "
                 "(PlatformAPI), ORG05 (EmployerAccount) i ORG13 (CandidatePseudonym). Wokół niego dwa słowniki, domeny "
                 "1:N, kraje M:N i historia umów z okresami ważności. Country jest wspólnym słownikiem dla ORG06 i ORG08.",
        "decyzje": [
            ("Partnerstwo jako historia `PartnerAgreement` (`ValidFrom`/`ValidTo` + AgreementStatus) zamiast flagi "
             "IsPartner",
             "pełny przebieg współpracy w danych; stan bieżący: `ValidTo IS NULL`, stan na dzień d: "
             "`ValidFrom <= d AND (ValidTo IS NULL OR ValidTo >= d)`."),
            ("Domeny w osobnej tabeli 1:N z UQ na `DomainName`",
             "domena należy do dokładnie jednej platformy; rozpoznanie platformy po adresie strony widżetu to odczyt po "
             "kluczu unikalnym."),
            ("Kraje przez tabelę łączącą `PlatformMarket` z UQ(SourcePlatformKey, CountryKey)",
             "dowolna liczba krajów na platformę bez zdublowanych par; `LaunchDate` opcjonalna."),
            ("`Country` jako słownik wspólny dla ORG01, ORG06 i ORG08",
             "jedna lista krajów w całej bazie; zmiana jej klucza dotyka trzech organizmów."),
            ("PK `NUMBER(4)` zamiast `NUMBER(2)` ze schematu z zajęć",
             "miejsce na tysiące stron kariery (ATS) jako osobnych platform; jeśli ATS-y trafią do osobnego organizmu "
             "(pytanie do prowadzącego), wystarczy mniej."),
        ],
        "luki": [
            "Najwyżej jedna domena główna na platformę – potrzebny unikalny indeks funkcyjny: `CREATE UNIQUE INDEX … ON "
            "PlatformDomain (CASE WHEN IsMainDomain = 'T' THEN SourcePlatformKey END)`.",
            "Okresy umów jednej platformy nie powinny na siebie nachodzić – CHECK widzi tylko jeden wiersz, więc "
            "potrzebny wyzwalacz albo kontrola w programie. Samo „najwyżej jedna umowa otwarta” wymusi unikalny indeks "
            "funkcyjny na `CASE WHEN ValidTo IS NULL THEN SourcePlatformKey END`.",
        ],
    },
    2: {
        "o_czym": [
            "Platforma może przekazywać nam dane na kilka sposobów. Najczęściej robi to przez API. API to zestaw "
            "adresów internetowych przeznaczonych dla programów, a nie dla ludzi: nasz program wysyła zapytanie pod "
            "taki adres i dostaje w odpowiedzi dane w ustalonym formacie, bez grafiki i reklam.",
            "Ten organizm opisuje kanały wymiany danych z platformą: jakiego są rodzaju, w jakim formacie przesyłają "
            "dane, jak są zabezpieczone, kto zaczyna przesyłanie, jakie mają wersje i pod jakimi adresami działają. "
            "Bez tego nie wiedzielibyśmy, jak połączyć się z platformą ani co zrobić, gdy platforma wyłączy starą "
            "wersję swojego API.",
        ],
        "przyklad": "Załóżmy, że pracuj.pl udostępnia nam „Partner API” rodzaju REST. Dane przychodzą domyślnie w "
                    "formacie JSON, a nasz program loguje się kluczem API. To my pytamy platformę o nowe dane (kierunek "
                    "„my pobieramy dane”). API ma dwie wersje: starszą v1, którą platforma wyłączy 30 czerwca, i nowszą "
                    "v2. Wersja v2 działa w dwóch środowiskach: testowym, w którym sprawdzamy nasz program na danych "
                    "próbnych (limit 60 zapytań na minutę), i produkcyjnym, z prawdziwymi danymi (limit 600 zapytań na "
                    "minutę). Każde środowisko ma inny adres.",
        "tabele": [
            ("PlatformAPI", "Kanały wymiany danych (API)",
             "Jeden wiersz to jedno API jednej platformy, np. „Partner API” pracuj.pl. Jedna platforma może mieć kilka "
             "API. Przy każdym zapisujemy: do której platformy należy (numer z organizmu 1), jakiego jest rodzaju, w "
             "jakim formacie domyślnie przesyła dane, jak się do niego logujemy, kto zaczyna przesyłanie, nazwę API i "
             "adres jego dokumentacji. To tabela ze schematu prowadzącego, uzupełniona o zabezpieczenie i kierunek."),
            ("APIType", "Rodzaje API",
             "Sześć rodzajów: REST, GraphQL i SOAP (trzy różne sposoby zadawania pytań programowi platformy), webhook "
             "(platforma sama wysyła nam powiadomienie, gdy coś się zmieni), eksport pliku (dostajemy gotowy plik z "
             "danymi) i kanał RSS (lista nowych ogłoszeń, którą można regularnie odczytywać)."),
            ("DataFormat", "Formaty danych",
             "Cztery formaty: JSON, XML, CSV i HTML – różne sposoby zapisu danych w tekście. Przy każdym jest jego "
             "oficjalne oznaczenie, tzw. typ MIME (np. application/json), które platforma podaje w odpowiedzi. W tabeli "
             "API zapisujemy format domyślny, a format konkretnej odpowiedzi – przy endpoincie w organizmie 3."),
            ("AuthMethod", "Sposoby zabezpieczenia dostępu",
             "Sposób, w jaki nasz program udowadnia platformie, że wolno mu pobrać dane: klucz API (tajny ciąg znaków "
             "dołączany do zapytania), OAuth 2.0 (program najpierw dostaje tymczasowy klucz z osobnego serwera), "
             "certyfikat klienta (plik, który potwierdza tożsamość naszego serwera), podpis HMAC (każde zapytanie jest "
             "podpisane tajnym kluczem) albo brak zabezpieczenia. Samych kluczy i haseł nie zapisujemy w tej bazie."),
            ("APIDirection", "Kierunek przesyłania danych",
             "Dwa warianty: „my pobieramy dane” – nasz program sam pyta platformę, np. co godzinę – albo „platforma "
             "wysyła dane” – platforma sama przekazuje nam nowe dane, gdy się pojawią."),
            ("APIVersion", "Wersje API",
             "Platformy co jakiś czas wydają nową wersję API, a starą po pewnym czasie wyłączają. Jeden wiersz to jedna "
             "wersja, np. v2: zapisujemy jej oznaczenie, datę wprowadzenia i datę wyłączenia, jeśli platforma ją "
             "ogłosiła. Jedno API nie może mieć dwóch wersji o tym samym oznaczeniu, a data wyłączenia nie może być "
             "wcześniejsza niż data wprowadzenia. Wersja jest ważna, bo różne wersje mają różne endpointy (organizm 3)."),
            ("APIEnvironment", "Środowiska wersji API",
             "Ta sama wersja API działa zwykle w dwóch miejscach: w środowisku testowym z danymi próbnymi i w "
             "produkcyjnym z prawdziwymi danymi. Jeden wiersz to jedno środowisko jednej wersji: zapisujemy adres "
             "bazowy (początek adresu wszystkich zapytań, np. https://api.platforma.example/v2) i limit, czyli ile "
             "zapytań na minutę platforma pozwala wysłać. Wersja może mieć tylko jedno środowisko danego rodzaju."),
            ("EnvironmentType", "Rodzaje środowisk", "Dwa warianty: testowe (sandbox) i produkcyjne."),
        ],
        "skrot": "Rozszerzona `PlatformAPI` ze schematu prowadzącego (N:1 do SourcePlatform z ORG01) z czterema "
                 "słownikami oraz hierarchią PlatformAPI 1:N APIVersion 1:N APIEnvironment. APIVersion jest punktem "
                 "zaczepienia endpointów w ORG03, a DataFormat używa też EndpointResponse (ORG03).",
        "decyzje": [
            ("`DataFormatKey` w PlatformAPI jako format domyślny, format konkretnej odpowiedzi w EndpointResponse (ORG03)",
             "API z kilkoma formatami (np. JSON i CSV) opisujemy bez zmiany tej tabeli; kolumna zostaje dla zgodności ze "
             "schematem z zajęć (pytanie do prowadzącego)."),
            ("Kierunek pull/push jako słownik `APIDirection`",
             "webhooki i odpytywanie mają te same struktury; harmonogram pobierania to osobny temat (warstwa 6, do "
             "rozpisania)."),
            ("Wersje jako wiersze `APIVersion` z UQ(PlatformAPIKey, VersionLabel) i `RetirementDate`",
             "endpointy są przypięte do wersji, więc przejście v1 → v2 to nowe wiersze zamiast zmiany starych; wersje "
             "do wyłączenia w ciągu 30 dni: `RetirementDate < SYSDATE + 30`."),
            ("Środowiska w `APIEnvironment` z UQ(APIVersionKey, EnvironmentTypeKey)",
             "najwyżej jedno środowisko testowe i jedno produkcyjne na wersję, każde z własnym `BaseURL` i limitem; "
             "`RequestLimitPerMinute` posłuży programowi do ograniczania tempa zapytań."),
            ("Brak kolumn na klucze API i hasła",
             "sekrety trzymamy poza bazą (np. w sejfie haseł w chmurze); w bazie jest tylko `AuthMethod`, więc wyciek "
             "danych z bazy nie daje dostępu do platform."),
        ],
        "luki": [
            "`VersionLabel` to tekst (v1, v2, v10), więc sortowanie po nim jest alfabetyczne – kolejność wersji brać z "
            "`ReleaseDate`.",
        ],
    },
    3: {
        "o_czym": [
            "API platformy składa się z wielu endpointów. Endpoint to jeden adres w API, pod który nasz program wysyła "
            "jeden rodzaj zapytania, np. „podaj nowe ogłoszenia” albo „podaj dane konta firmy”. Ten organizm opisuje "
            "każdy endpoint i dokładnie to, co zwraca – pole po polu.",
            "Na schemacie z zajęć tę rolę pełniła jedna tabela PlatformAPIData. Brakowało w niej endpointów, więc "
            "rozbiliśmy ją na trzy poziomy: endpoint → możliwa odpowiedź → pole w odpowiedzi. Zapisujemy tu też, które "
            "pole platformy odpowiada której naszej nazwie danej. To ważne, bo każda platforma nazywa te same dane "
            "inaczej, a my chcemy je porównywać.",
        ],
        "przyklad": "Wersja v2 „Partner API” ma endpoint GET /v2/jobs, który zwraca nowe ogłoszenia podzielone na "
                    "strony. Gdy wszystko jest w porządku, odpowiada kodem 200 i danymi w formacie JSON. Gdy wyślemy za "
                    "dużo zapytań, odpowiada kodem 429 – to odpowiedź z błędem. Odpowiedź 200 zawiera m.in. pole salary, "
                    "a w nim trzy pola: from, to i currency. Pole salary.from to liczba dziesiętna, na przykład 5200. W "
                    "tabeli przypisań zapisujemy, że salary.from z pracuj.pl to nasze pole „Wynagrodzenie od”. Jeśli "
                    "inna platforma podaje tę samą informację jako wynagrodzenie_min, ją też przypisujemy do "
                    "„Wynagrodzenie od”.",
        "tabele": [
            ("APIEndpoint", "Endpointy",
             "Jeden wiersz to jeden endpoint w jednej wersji API (wersja pochodzi z organizmu 2). Zapisujemy ścieżkę "
             "(np. /v2/jobs), metodę HTTP, rodzaj zwracanych danych, to, czy wyniki są dzielone na strony (wtedy trzeba "
             "pobrać kolejne strony), i krótki opis. W jednej wersji API nie może być dwóch endpointów z tą samą "
             "ścieżką i metodą."),
            ("HTTPMethod", "Metody HTTP",
             "Rodzaje zapytań w internecie: GET (pobierz dane), POST (wyślij nowe dane), PUT i PATCH (zmień dane), "
             "DELETE (usuń dane). Do pobierania danych najczęściej używamy GET."),
            ("DataSubject", "Rodzaje danych",
             "Czego dotyczą dane z endpointu: konto firmy, ogłoszenie, zdarzenie ogłoszenia (np. jego wygaśnięcie), "
             "aplikacja kandydata albo status aplikacji. Ta lista mówi, do którego organizmu trafią dane: konta firm do "
             "organizmu 5, ogłoszenia do 8, zdarzenia do 11, a aplikacje i ich statusy do 13."),
            ("EndpointResponse", "Możliwe odpowiedzi endpointu",
             "Ten sam endpoint odpowiada różnie: kodem 200 z danymi, kodem 404, gdy czegoś nie ma, kodem 429, gdy "
             "wysłaliśmy za dużo zapytań. Jeden wiersz to jedna możliwa odpowiedź: kod i format danych (ten sam kod może "
             "przyjść np. w JSON i w XML). Zapisujemy też, czy to odpowiedź z błędem i kiedy się pojawia. Baza przyjmie "
             "tylko kod od 100 do 599, bo tylko takie kody istnieją."),
            ("EndpointData", "Pola w odpowiedzi",
             "Odpowiednik tabeli PlatformAPIData ze schematu prowadzącego. Jeden wiersz to jedno pole w jednej "
             "odpowiedzi, np. salary_from. Zapisujemy nazwę pola u platformy, pełną ścieżkę (np. salary.from), typ "
             "danych, to, czy platforma zawsze podaje to pole, i przykładową wartość. Pola bywają zagnieżdżone – pole "
             "salary zawiera pola from, to i currency – dlatego pole może wskazywać swoje pole nadrzędne w tej samej "
             "tabeli. W jednej odpowiedzi ścieżka nie może się powtórzyć."),
            ("FieldDataType", "Typy danych pola",
             "Osiem typów: tekst, liczba całkowita, liczba dziesiętna, prawda/fałsz, data, data i godzina, lista (kilka "
             "wartości w jednym polu) i obiekt (pole, które zawiera inne pola)."),
            ("CanonicalField", "Nasze nazwy danych",
             "Nasza jedna nazwa danej, niezależna od platformy, np. „Wynagrodzenie od”, „Rodzaj umowy”, „NIP firmy”, "
             "„Data aplikacji”. Każda nazwa należy do jednego rodzaju danych (np. „NIP firmy” dotyczy konta firmy) i ma "
             "krótki opis. Nazwa nie może się powtórzyć."),
            ("FieldMapping", "Przypisania pól do naszych nazw",
             "Jeden wiersz mówi: „to pole tej platformy to nasza dana X”. Można dopisać regułę przeliczenia, gdy "
             "platforma podaje wartość inaczej niż my, np. „grosze na złote: podziel przez 100”. Ta sama para „pole – "
             "nasza nazwa” nie może się powtórzyć."),
        ],
        "skrot": "Rozbicie `PlatformAPIData` na trzy poziomy: APIEndpoint (N:1 APIVersion z ORG02) 1:N EndpointResponse "
                 "1:N EndpointData, plus warstwa mapowania pól platform na model kanoniczny (CanonicalField, "
                 "FieldMapping).",
        "decyzje": [
            ("Endpoint przypięty do `APIVersion`, UQ(APIVersionKey, HTTPMethodKey, EndpointPath)",
             "nowa wersja API to nowy komplet endpointów; stare zostają i pozwalają interpretować dane historyczne."),
            ("Odpowiedź jako osobny poziom z UQ(APIEndpointKey, HTTPStatusCode, DataFormatKey) i CHECK 100–599",
             "pola opisujemy osobno dla odpowiedzi 200 i dla odpowiedzi z błędem; ten sam kod w dwóch formatach to dwa "
             "wiersze."),
            ("`ParentEndpointDataKey` – opcjonalny klucz EndpointData do samej siebie",
             "drzewo pól JSON/XML dowolnej głębokości; hierarchię czytamy przez `CONNECT BY` albo rekurencyjne `WITH`, a "
             "`DataPath` (UQ w odpowiedzi) pozwala znaleźć pole bez rekurencji."),
            ("Model kanoniczny: `CanonicalField` + `FieldMapping` (EndpointData M:N CanonicalField z regułą)",
             "dane z różnych platform są porównywalne; `TransformationRule` to tekst – wykonuje go program, baza go nie "
             "sprawdza."),
            ("`DataSubject` wspólny dla endpointów i nazw kanonicznych",
             "wiadomo, który organizm (5, 8, 11, 13) zasila endpoint."),
        ],
        "luki": [
            "Pole nadrzędne powinno należeć do tej samej odpowiedzi, a drzewo nie może mieć cykli – wymaga wyzwalacza "
            "(albo klucza złożonego (EndpointResponseKey, ParentEndpointDataKey) z dodatkowym UNIQUE).",
            "Przypisanie powinno łączyć pole i nazwę kanoniczną tego samego rodzaju danych (DataSubject endpointu = "
            "DataSubject nazwy) – nie jest wymuszone.",
        ],
    },
    4: {
        "o_czym": [
            "Ten organizm zapisuje każde przyjęcie danych od platformy – nazywamy je dostawą. Przy dostawie wiemy, kiedy "
            "się zaczęła i skończyła, którym endpointem przyszły dane, w jaki sposób i czy wszystko się udało. Każdy "
            "otrzymany rekord – jedną porcję danych, np. jedno ogłoszenie – zapisujemy dokładnie w takiej postaci, w "
            "jakiej przyszedł.",
            "Dzięki temu o każdej informacji w bazie wiemy, z której dostawy pochodzi. A gdy znajdziemy błąd w naszym "
            "programie, możemy przetworzyć zapisane rekordy jeszcze raz, bez ponownego pobierania ich od platformy.",
        ],
        "przyklad": "3 listopada o 6:00 nasz program pobiera nowe ogłoszenia endpointem GET /v2/jobs (sposób „Pobranie "
                    "według harmonogramu”). Powstaje wiersz dostawy ze stanem „W toku”. Platforma przysyła 120 rekordów "
                    "i każdy zapisujemy bez zmian, razem z jego numerem u platformy i skrótem treści. Jednym z nich jest "
                    "ogłoszenie „Magazynier/ka” firmy Przykład Logistyka (numer 1004567). W dwóch rekordach brakuje "
                    "wymaganego pola, więc zapisujemy dwa błędy rodzaju „Brak wymaganego pola”, każdy przy swoim "
                    "rekordzie. Na koniec dostawa dostaje stan „Zakończona częściowo”: przyszło 120 rekordów, "
                    "przyjęliśmy 118.",
        "tabele": [
            ("DataDelivery", "Dostawy danych",
             "Jeden wiersz to jedno przyjęcie danych jednym endpointem (endpoint z organizmu 3). Zapisujemy sposób "
             "dostawy, wynik, czas rozpoczęcia i zakończenia oraz to, ile rekordów przyszło i ile przyjęliśmy. Wiersz "
             "powstaje na początku dostawy i jest uzupełniany, gdy dostawa się kończy. Baza pilnuje dwóch rzeczy: "
             "przyjętych rekordów nie może być więcej niż otrzymanych, a koniec nie może być wcześniej niż początek."),
            ("DeliveryMode", "Sposoby dostawy",
             "Cztery warianty: pobranie według harmonogramu (nasz program sam pyta o ustalonej porze), powiadomienie od "
             "platformy (webhook – platforma sama przysyła dane), plik z eksportem i ręczne doładowanie historii "
             "(jednorazowe wczytanie starszych danych)."),
            ("DeliveryStatus", "Wyniki dostawy",
             "Cztery warianty: w toku, zakończona, zakończona częściowo (część rekordów odrzucona) i nieudana."),
            ("RawRecord", "Surowe rekordy",
             "Jeden wiersz to jeden rekord z jednej dostawy, zapisany dokładnie tak, jak przysłała go platforma (np. "
             "tekst w formacie JSON). Zapisujemy numer rekordu u platformy, pełną treść, czas otrzymania i skrót "
             "treści. Skrót (SHA-256) to krótki ciąg znaków obliczany z treści: identyczne rekordy mają identyczny skrót, "
             "więc po nim szybko rozpoznajemy duplikaty. Treści nigdy nie zmieniamy. Z tej tabeli korzystają organizmy 5 "
             "i 8 – wersja danych konta i ogłoszenie wskazują rekord, z którego powstały."),
            ("DeliveryError", "Błędy przy odbiorze",
             "Błąd może dotyczyć całej dostawy (np. platforma odrzuciła nasz klucz API) – wtedy pole rekordu jest puste "
             "– albo jednego rekordu (np. brakuje w nim wymaganego pola). Zapisujemy rodzaj błędu, treść komunikatu i "
             "czas."),
            ("ErrorType", "Rodzaje błędów",
             "Sześć wariantów: brak wymaganego pola, zły format danych, odrzucony klucz API, przekroczony limit "
             "zapytań, brak odpowiedzi platformy i nieznana wersja API."),
        ],
        "skrot": "Warstwa pochodzenia danych: DataDelivery (N:1 APIEndpoint z ORG03) 1:N RawRecord i 1:N DeliveryError. "
                 "RawRecord to niezmienne źródło dla ORG05 (EmployerAccountVersion) i ORG08 (JobPosting); DataDelivery "
                 "wskazują też ORG11 i ORG13.",
        "decyzje": [
            ("Surowy rekord w `RecordPayload CLOB` bez zmian",
             "ponowne przetworzenie po poprawce programu bez ponownego pobierania; koszt to miejsce w bazie (pytanie do "
             "prowadzącego: CLOB czy plik i odnośnik). W Oracle 26ai można użyć typu `JSON` zamiast CLOB – z walidacją "
             "i indeksami JSON."),
            ("`PayloadHash` (SHA-256 jako VARCHAR2(64)) bez UNIQUE",
             "duplikaty wykrywamy bez porównywania CLOB-ów, a ten sam rekord w kolejnych dostawach zostaje zapisany "
             "(liczymy powtórzenia); potrzebny zwykły indeks na `PayloadHash`."),
            ("`DeliveryError.RawRecordKey` opcjonalny",
             "jedna tabela na błędy całej dostawy (NULL) i pojedynczych rekordów; statystyki błędów na dostawę bez "
             "złączeń z RawRecord."),
            ("Liczniki i czasy w `DataDelivery` z CHECK (`RecordsAccepted <= RecordsReceived`, "
             "`FinishedAt >= StartedAt`)",
             "jakość źródeł (odsetek przyjętych rekordów na endpoint i platformę) liczymy prostym GROUP BY."),
            ("`ExternalRecordId` bez UNIQUE",
             "kolejne wersje tego samego rekordu platformy to kolejne wiersze; „ostatnią” wybieramy po `ReceivedAt`."),
        ],
        "luki": [
            "Błąd rekordu powinien należeć do tej samej dostawy co rekord (`DeliveryError.DataDeliveryKey = "
            "RawRecord.DataDeliveryKey`) – wymaga wyzwalacza albo klucza złożonego.",
            "Liczniki w DataDelivery wpisuje program – baza nie sprawdza, czy zgadzają się z liczbą wierszy RawRecord.",
        ],
    },
    5: {
        "o_czym": [
            "Na każdej platformie ogłoszenia publikuje jakieś konto – profil z nazwą, a czasem z numerem NIP i adresem "
            "strony www. Ten organizm opisuje takie konta. Ważne: konto to jeszcze nie firma. Za kontem może stać "
            "firma, agencja rekrutacyjna, osoba prywatna albo urząd, a dane w koncie wpisał sam właściciel i nikt ich "
            "nie sprawdził. Którą prawdziwą firmę reprezentuje konto, ustalamy dopiero w organizmach 6 i 7.",
            "Zapisujemy też każdą zmianę danych konta. Firma może zmienić nazwę konta, żeby kandydaci nie kojarzyli jej "
            "ze złymi opiniami – stara nazwa zostaje w historii.",
        ],
        "przyklad": "Na pracuj.pl ogłoszenia firmy Przykład Logistyka publikuje konto numer 77120. Prowadzi je firma, "
                    "konto jest aktywne, a platforma nie sprawdzała tej firmy. Pierwszy raz dostaliśmy to konto "
                    "3 listopada. Pierwsza wersja jego danych: nazwa „Przykład Logistyka”, NIP 1234563218, strona "
                    "przyklad-logistyka.pl. 20 listopada właściciel zmienia nazwę na „PL Logistics Kraków”. Pierwsza "
                    "wersja dostaje datę końca 20 listopada, a od tej chwili obowiązuje druga wersja z nową nazwą. Na "
                    "OLX to samo ogłoszenie publikuje inne konto, „Praca od zaraz – Kraków”, prowadzone przez agencję "
                    "rekrutacyjną – dla nas to osobne konto.",
        "tabele": [
            ("EmployerAccount", "Konta na platformach",
             "Jeden wiersz to jedno konto na jednej platformie (platforma z organizmu 1). Zapisujemy numer konta w "
             "serwisie, kto prowadzi konto, stan konta, to, czy platforma sama sprawdziła firmę, i kiedy pierwszy raz "
             "dostaliśmy to konto. Numer konta jest unikalny tylko w obrębie jednej platformy – na dwóch platformach "
             "mogą być konta o tym samym numerze – dlatego baza pilnuje, żeby nie powtórzyła się para „platforma + "
             "numer konta”. Nazwy konta nie ma w tym wierszu, bo się zmienia – jest w wersjach."),
            ("AccountType", "Rodzaje kont",
             "Kto prowadzi konto: firma, agencja rekrutacyjna, osoba prywatna albo instytucja publiczna."),
            ("AccountStatus", "Stany konta", "Trzy warianty: aktywne, zawieszone przez platformę, usunięte."),
            ("EmployerAccountVersion", "Historia danych konta",
             "Każda zmiana nazwy, NIP-u albo strony www to nowy wiersz z datą „od kiedy” i „do kiedy”; aktualna wersja "
             "ma puste „do kiedy”. NIP zapisujemy dokładnie tak, jak wpisał go właściciel konta – nikt go jeszcze nie "
             "sprawdził. Przy wersji zapisujemy też surowy rekord z organizmu 4, z którego ją odczytaliśmy. Baza "
             "pilnuje, żeby koniec wersji był później niż jej początek."),
        ],
        "skrot": "EmployerAccount (N:1 SourcePlatform z ORG01) jako trwały identyfikator konta i EmployerAccountVersion "
                 "jako historia atrybutów z okresami ważności, z odnośnikiem do RawRecord (ORG04). Konto wskazują ORG07 "
                 "(AccountEmployerLink) i ORG08 (JobPosting).",
        "decyzje": [
            ("Klucz naturalny UQ(SourcePlatformKey, ExternalAccountId)",
             "powtórna dostawa tego samego konta trafia w istniejący wiersz (`MERGE` po kluczu naturalnym)."),
            ("Zmienne atrybuty (nazwa, NIP, www) tylko w `EmployerAccountVersion`",
             "aktualne dane wymagają złączenia z wersją `ValidTo IS NULL` – warto dodać widok „konto + aktualna "
             "wersja”; częste zmiany nazwy wykrywa zapytanie o liczbę wersji."),
            ("`DeclaredNIP` jako niesprawdzony tekst bez CHECK formatu",
             "błędne wpisy zostają (same są sygnałem); sprawdzenie i dopasowanie do firmy są w ORG06 i ORG07."),
            ("`RawRecordKey` w wersji (opcjonalny)",
             "każdą wersję da się odtworzyć ze źródła; wersje wpisane ręcznie mają NULL."),
        ],
        "luki": [
            "Wersje jednego konta nie powinny na siebie nachodzić, a aktualna powinna być jedna – „jedną aktualną” "
            "wymusi unikalny indeks funkcyjny na `CASE WHEN ValidTo IS NULL THEN EmployerAccountKey END`, nienakładanie "
            "się okresów wymaga wyzwalacza.",
        ],
    },
    6: {
        "o_czym": [
            "Ogłoszenie publikuje konto, ale odpowiada za nie firma – podmiot prawny wpisany do rejestru państwowego, "
            "np. do Krajowego Rejestru Sądowego (KRS) albo do CEIDG. Ten organizm opisuje takie firmy: ich nazwę "
            "urzędową, formę prawną, numery identyfikacyjne (NIP, REGON, KRS), rodzaje działalności i status. Każdą "
            "firmę sprawdzamy w rejestrach wiele razy, bo jej status może się zmienić.",
            "To dla firmy – a nie dla konta – liczymy Trust Score. Rejestry pozwalają wykryć firmy, których nie ma, "
            "które zostały wykreślone, są w likwidacji albo powstały tydzień przed opublikowaniem dziesiątek ogłoszeń.",
        ],
        "przyklad": "Firma „Przykład Logistyka sp. z o.o.” to spółka z ograniczoną odpowiedzialnością zarejestrowana w "
                    "Polsce 12 marca 2019 roku, o statusie „Aktywna”. Ma trzy numery: NIP, REGON i KRS – każdy to "
                    "osobny wiersz na liście numerów. Prowadzi dwa rodzaje działalności według PKD: główną 52.10.B "
                    "(magazynowanie i przechowywanie towarów) i dodatkową 49.41.Z (transport drogowy towarów). "
                    "5 listopada sprawdziliśmy ją w KRS: rejestr ją znalazł i podał status „Aktywna”. 5 grudnia KRS "
                    "podał już „W likwidacji”. To nowy wiersz w sprawdzeniach, a status firmy zmieniamy na „W "
                    "likwidacji”. Agencja „Kadry Przykład sp. z o.o.” to w bazie osobna firma, z główną działalnością "
                    "78.10.Z (wyszukiwanie miejsc pracy i pozyskiwanie pracowników).",
        "tabele": [
            ("Employer", "Firmy",
             "Jeden wiersz to jeden prawdziwy podmiot prawny, niezależnie od tego, ile ma kont na platformach. "
             "Zapisujemy nazwę urzędową, formę prawną, kraj rejestracji (z listy krajów w organizmie 1), aktualny status "
             "i datę wpisu do rejestru. Dla tego wiersza liczymy Trust Score (organizmy 17 i 18)."),
            ("LegalForm", "Formy prawne",
             "Pełna nazwa i skrót, np. „Spółka z ograniczoną odpowiedzialnością” – „sp. z o.o.”. Na liście są też "
             "spółka akcyjna, jednoosobowa działalność gospodarcza, spółka cywilna, spółka jawna, fundacja, "
             "stowarzyszenie, jednostka sektora publicznego i firma zagraniczna."),
            ("EmployerStatus", "Statusy firmy",
             "Sześć wariantów: aktywna, zawieszona, w likwidacji, w upadłości, wykreślona i nieznaleziona w rejestrze."),
            ("EmployerIdentifier", "Numery identyfikacyjne firm",
             "Firma ma zwykle kilka numerów naraz (NIP, REGON, KRS), a firma zagraniczna – zupełnie inne. Dlatego numery "
             "nie są trzema kolumnami w tabeli firm, tylko osobnymi wierszami: jeden wiersz to jeden numer jednego "
             "rodzaju. Zapisujemy też, czy numer przeszedł kontrolę sumy kontrolnej – ostatnia cyfra NIP-u jest "
             "wyliczana z pozostałych, więc można sprawdzić, czy ktoś nie pomylił się przy wpisywaniu. Ten sam numer "
             "tego samego rodzaju nie może należeć do dwóch firm."),
            ("IdentifierType", "Rodzaje numerów",
             "Pięć wariantów z opisem, jak wygląda poprawny numer: NIP (10 cyfr), REGON (9 albo 14 cyfr), KRS "
             "(10 cyfr), numer VAT UE (kod kraju i numer) i zagraniczny numer rejestrowy."),
            ("EmployerPKD", "Działalności firm",
             "Jedna firma prowadzi kilka rodzajów działalności, a ten sam rodzaj prowadzi wiele firm. Dlatego to osobna "
             "tabela par „firma – kod PKD”. Jedną działalność firmy oznaczamy jako główną."),
            ("PKDCode", "Kody PKD",
             "Kody Polskiej Klasyfikacji Działalności z nazwą, np. 52.10.B – magazynowanie i przechowywanie pozostałych "
             "towarów. Klasyfikacja bywa zmieniana (PKD 2007, PKD 2025), więc przy kodzie zapisujemy jej wersję. Ten sam "
             "symbol może być w dwóch wersjach klasyfikacji, ale nie dwa razy w jednej."),
            ("RegistryCheck", "Sprawdzenia w rejestrach",
             "Jeden wiersz to jedno sprawdzenie jednej firmy w jednym rejestrze, z datą. Zapisujemy, czy rejestr "
             "znalazł firmę, jaki podał status i jaką nazwę. Nowe sprawdzenie to zawsze nowy wiersz, więc widać, kiedy "
             "status się zmienił – np. kiedy firma weszła w likwidację."),
            ("PublicRegistry", "Rejestry państwowe",
             "Pięć rejestrów: Krajowy Rejestr Sądowy (KRS), CEIDG (rejestr jednoosobowych działalności), rejestr REGON "
             "prowadzony przez GUS, biała lista podatników VAT i VIES – unijny rejestr numerów VAT. Przy rejestrze "
             "zapisujemy, po jakim numerze się w nim wyszukuje i ile zapytań dziennie pozwala wysłać."),
        ],
        "skrot": "Employer jako podmiot prawny i cel Trust Score: identyfikatory w modelu „wiersz na numer”, PKD jako "
                 "M:N, historia sprawdzeń w rejestrach; Country z ORG01. Employer ma najwięcej przychodzących kluczy w "
                 "modelu (ORG07, ORG11, ORG12, ORG16, ORG17).",
        "decyzje": [
            ("Identyfikatory w `EmployerIdentifier` z UQ(IdentifierTypeKey, IdentifierValue) zamiast kolumn NIP, REGON i "
             "KRS",
             "firmy zagraniczne i nowe rodzaje numerów bez zmiany schematu; ten sam numer nie trafi do dwóch firm, więc "
             "zdublowane firmy wychodzą przy imporcie."),
            ("Status bieżący w `Employer.EmployerStatusKey`, historia w `RegistryCheck.ReportedStatusKey` (drugi klucz do "
             "EmployerStatus)",
             "szybki odczyt statusu bez agregacji, ale ryzyko rozjazdu z ostatnim sprawdzeniem (pytanie do "
             "prowadzącego); usunie je wyzwalacz po INSERT do RegistryCheck albo widok zamiast kolumny."),
            ("`PKDCode` z wersją klasyfikacji, UQ(PKDSymbol, ClassificationVersion)",
             "przejście na PKD 2025 nie nadpisuje historii; przejście kodów 2007 → 2025 wymagałoby osobnej tabeli (na "
             "razie brak)."),
            ("`PublicRegistry.DailyQueryLimit` i `IdentifierTypeKey`",
             "program sprawdzający wie, po jakim numerze pytać rejestr i ile zapytań dziennie mu wolno."),
            ("`IsChecksumValid` jako flaga ustalana przy imporcie",
             "błędny numer zostaje zapisany (sam jest sygnałem), a łatwo go odfiltrować."),
        ],
        "luki": [
            "Najwyżej jedna działalność główna na firmę (`IsMainActivity = 'T'`) – unikalny indeks funkcyjny.",
            "Zgodność `Employer.EmployerStatusKey` z ostatnim sprawdzeniem w RegistryCheck – wyzwalacz albo widok.",
            "Rodzaj numeru dozwolony dla kraju firmy (np. NIP tylko w Polsce) – nie jest sprawdzany.",
        ],
    },
    7: {
        "o_czym": [
            "Ta sama firma może mieć konta na kilku platformach – na pracuj.pl, na OLX i na swojej stronie kariery. Ten "
            "organizm zapisuje, które konto należy do której firmy z rejestru. Takie powiązanie to twierdzenie: może być "
            "pewne (ten sam NIP) albo tylko prawdopodobne (podobna nazwa), a czasem okazuje się błędne i trzeba je "
            "cofnąć. Dlatego przy powiązaniu zapisujemy, jak je ustaliliśmy, jak bardzo jesteśmy pewni, na jakich "
            "dowodach się opiera i jak się zmieniało.",
            "Dzięki powiązaniom firma ma jeden Trust Score, choć publikuje z wielu kont. Tutaj zapisujemy też, dla "
            "jakich firm rekrutuje agencja rekrutacyjna.",
        ],
        "przyklad": "Konto 77120 z pracuj.pl podaje NIP 1234563218 i stronę przyklad-logistyka.pl. Ten sam NIP ma w "
                    "rejestrze firma „Przykład Logistyka sp. z o.o.”. Łączymy konto z firmą sposobem „Ten sam NIP”, z "
                    "pewnością 0,98, i zapisujemy dwa dowody: zgodny NIP i tę samą domenę strony www. Konto „Praca od "
                    "zaraz – Kraków” z OLX też podaje ten NIP, więc najpierw łączymy je z tą samą firmą. Moderator "
                    "zauważa jednak, że to konto agencji „Kadry Przykład sp. z o.o.”, która tylko rekrutuje dla tej "
                    "firmy. Stare powiązanie dostaje datę rozłączenia, powstaje nowe – konta z agencją – a w historii "
                    "zmian zapisujemy „Przeniesiono do innej firmy” z powodem. W tabeli agencji i klientów zapisujemy, "
                    "że Kadry Przykład rekrutuje dla Przykład Logistyka od 1 listopada.",
        "tabele": [
            ("AccountEmployerLink", "Powiązania kont z firmami",
             "Jeden wiersz to jedno twierdzenie „to konto należy do tej firmy” – konto z organizmu 5, firma z "
             "organizmu 6. Zapisujemy sposób dopasowania, pewność od 0 do 1, kiedy połączyliśmy i kiedy cofnęliśmy "
             "powiązanie. Puste „kiedy cofnięto” znaczy, że powiązanie obowiązuje. Baza pilnuje, żeby pewność była w "
             "zakresie 0–1, a data cofnięcia nie była wcześniejsza niż data połączenia."),
            ("MatchMethod", "Sposoby dopasowania",
             "Cztery warianty: ten sam NIP (pewne), podobna nazwa i ta sama strona www (prawdopodobne), decyzja "
             "moderatora i potwierdzenie przez samą firmę."),
            ("LinkEvidence", "Dowody powiązania",
             "Jedno powiązanie może opierać się na kilku dowodach. Jeden wiersz to jeden dowód: jego rodzaj i treść, "
             "np. „ten sam NIP w koncie i w KRS”. Dzięki temu moderator widzi, dlaczego system tak zdecydował."),
            ("EvidenceType", "Rodzaje dowodów",
             "Pięć wariantów: zgodny NIP, podobna nazwa, ta sama domena strony www, ten sam adres i dokument przesłany "
             "przez firmę."),
            ("LinkChange", "Historia zmian powiązań",
             "Każda zmiana powiązania to nowy wiersz: co zmieniono, kiedy i dlaczego. Nic nie znika – nawet błędne "
             "połączenie zostaje w historii razem z datą i powodem cofnięcia."),
            ("LinkChangeType", "Rodzaje zmian",
             "Cztery warianty: połączono, rozłączono, przeniesiono do innej firmy i zmieniono pewność."),
            ("AgencyClient", "Agencje i ich klienci",
             "Agencja rekrutacyjna publikuje ogłoszenia dla wielu firm. Agencja jest w bazie zwykłą firmą z organizmu 6, "
             "więc ta tabela łączy dwie firmy ze sobą: jeden wiersz mówi „agencja A rekrutuje dla firmy B od … do …”. "
             "Baza nie pozwoli zapisać firmy jako agencji samej siebie ani daty końca wcześniejszej niż data początku."),
        ],
        "skrot": "AccountEmployerLink jako encja łącząca z atrybutami (EmployerAccount z ORG05 ↔ Employer z ORG06) – z "
                 "pewnością, dowodami 1:N i dziennikiem zmian; AgencyClient jako relacja Employer–Employer w czasie "
                 "(dwa klucze do tej samej tabeli).",
        "decyzje": [
            ("Powiązanie z `MatchConfidence` (0–1) i `MatchMethod`",
             "przechowujemy też powiązania niepewne; Trust Score może brać pod uwagę tylko powiązania powyżej progu "
             "pewności."),
            ("Cofnięcie przez `UnlinkedAt` zamiast DELETE",
             "historia powiązań zostaje; aktywne powiązania: `UnlinkedAt IS NULL`."),
            ("`LinkChange` jako osobny dziennik",
             "audyt decyzji; „przeniesienie” to dwa wiersze AccountEmployerLink (stary z `UnlinkedAt` i nowy) plus wpis w "
             "LinkChange."),
            ("`AgencyClient`: AgencyEmployerKey i ClientEmployerKey → Employer, CHECK agencja <> klient, "
             "UQ(AgencyEmployerKey, ClientEmployerKey, ValidFrom)",
             "agencja to zwykły Employer, a jej rola wynika z relacji, nie z flagi; ta sama para może wracać w "
             "kolejnych okresach."),
            ("`LinkEvidence` jako dane",
             "pewność można przeliczyć, gdy zmienią się reguły dopasowania."),
        ],
        "luki": [
            "Najwyżej jedno aktywne powiązanie konta – unikalny indeks funkcyjny na "
            "`CASE WHEN UnlinkedAt IS NULL THEN EmployerAccountKey END`.",
            "Okresy tej samej pary agencja–klient nie powinny na siebie nachodzić – wyzwalacz.",
            "`LinkChange` nie zapisuje, kto dokonał zmiany (program czy moderator) – do dodania razem z personelem i "
            "dziennikiem audytu (warstwa 6, do rozpisania).",
        ],
    },
    8: {
        "o_czym": [
            "Ten organizm opisuje samo ogłoszenie o pracę: które konto je opublikowało, kiedy, jaki ma tytuł i stan, "
            "jakiego poziomu stanowiska dotyczy, w jakim trybie się pracuje, ilu osób firma szuka i w których "
            "miejscowościach.",
            "Samo ogłoszenie nie mówi jeszcze, czy praca naprawdę istnieje. Zapisujemy je dokładnie, żeby później "
            "porównywać kolejne publikacje tego samego stanowiska (organizmy 11 i 12) i zestawiać je ze zgłoszeniami "
            "kandydatów (organizmy 13–16). Warunki zatrudnienia i wymagania są w osobnych organizmach 9 i 10.",
        ],
        "przyklad": "Konto 77120 z pracuj.pl publikuje 3 listopada ogłoszenie numer 1004567 „Magazynier/ka – praca od "
                    "zaraz”. Ogłoszenie jest aktywne, poziom stanowiska nie jest podany, praca jest stacjonarna, firma "
                    "szuka 3 osób, a ogłoszenie ma wygasnąć 3 grudnia. Miejsca pracy to Kraków (główne) i Wieliczka. "
                    "Przy ogłoszeniu zapisujemy surowy rekord z dostawy z 3 listopada, z którego je odczytaliśmy.",
        "tabele": [
            ("JobPosting", "Ogłoszenia",
             "Jeden wiersz to jedno ogłoszenie opublikowane przez jedno konto (konto z organizmu 5). Zapisujemy numer "
             "ogłoszenia w serwisie, aktualny tytuł, stan, poziom stanowiska i tryb pracy (jeśli firma je podała), "
             "liczbę poszukiwanych osób, datę pierwszej publikacji, planowaną datę końca i surowy rekord, z którego "
             "powstało (organizm 4). Baza pilnuje, żeby data końca nie była przed datą publikacji, a liczba osób była "
             "większa od zera."),
            ("PostingStatus", "Stany ogłoszenia",
             "Pięć wariantów: aktywne, wygasłe, zamknięte przed terminem, usunięte przez platformę i wstrzymane."),
            ("SeniorityLevel", "Poziomy stanowiska",
             "Sześć poziomów, od stażysty, przez juniora, mida i seniora, do eksperta i kierownika. Każdy poziom ma numer "
             "kolejności (1 = najniższy). Dzięki temu da się wykryć ten sam etat ogłaszany raz jako Senior, a raz jako "
             "Mid."),
            ("WorkMode", "Tryby pracy", "Cztery warianty: stacjonarna, hybrydowa, zdalna i w terenie."),
            ("PostingLocation", "Miejsca pracy w ogłoszeniu",
             "Jedno ogłoszenie może dotyczyć kilku miejscowości, a w jednej miejscowości są tysiące ogłoszeń. Dlatego "
             "to osobna tabela par „ogłoszenie – miejscowość”. Jedną miejscowość oznaczamy jako główne miejsce pracy."),
            ("Location", "Miejscowości",
             "Miejscowość z województwem albo regionem i krajem (kraj z organizmu 1). Ta sama trójka „miejscowość, "
             "region, kraj” nie może się powtórzyć."),
        ],
        "skrot": "JobPosting (N:1 EmployerAccount z ORG05, opcjonalnie RawRecord z ORG04) z bieżącymi atrybutami "
                 "ogłoszenia; słowniki stanu, poziomu (z rangą) i trybu pracy; lokalizacje M:N przez PostingLocation; "
                 "Location N:1 Country (ORG01). JobPosting to najczęściej wskazywana tabela modelu (ORG09–ORG14).",
        "decyzje": [
            ("Ogłoszenie przypięte do konta, nie do firmy",
             "firmę ustala się przez AccountEmployerLink (ORG07), więc przeniesienie konta do innej firmy nie wymaga "
             "zmian w ogłoszeniach."),
            ("UQ(EmployerAccountKey, ExternalPostingId)",
             "powtórny import trafia w istniejący wiersz (`MERGE`)."),
            ("`SeniorityLevel.SeniorityRank`",
             "poziomy porównujemy liczbowo; to podstawa licznika `SeniorityVariantCount` w ORG12."),
            ("Opcjonalne `SeniorityLevelKey`, `WorkModeKey`, `VacancyCount` i `ExpiryDate`",
             "brak informacji to NULL, a sam brak liczy się do sygnałów przejrzystości (ORG17)."),
            ("`PostingTitle` przechowuje tylko bieżący tytuł; wersje treści i tytułów są w ORG11",
             "tytuł jest zapisany dwa razy (tu i w `PostingVersion.VersionTitle`) – pytanie do prowadzącego."),
        ],
        "luki": [
            "Najwyżej jedno miejsce główne na ogłoszenie (`IsMainLocation = 'T'`) – unikalny indeks funkcyjny.",
            "`ExternalPostingId` jest unikalny w obrębie konta, a nie całej platformy – pełna unikalność wymagałaby "
            "SourcePlatformKey w JobPosting albo wyzwalacza.",
            "Dwie miejscowości o tej samej nazwie w jednym województwie się nie zmieszczą – do rozważenia kod TERYT.",
            "`PostingStatusKey` powinien wynikać z ostatniego zdarzenia w ORG11 – program musi aktualizować oba miejsca.",
        ],
    },
    9: {
        "o_czym": [
            "Warunki zatrudnienia to obietnica, którą firma składa w ogłoszeniu: na jakiej umowie, za ile i z jakimi "
            "dodatkami. Ten organizm zapisuje te informacje osobno dla każdego ogłoszenia.",
            "Warunki są ważne dla oceny firmy. Brak widełek wynagrodzenia albo ich zmiana między kolejnymi publikacjami "
            "tego samego stanowiska to sygnały, które liczymy w organizmie 17.",
        ],
        "przyklad": "Ogłoszenie „Magazynier/ka” na pracuj.pl daje do wyboru dwie umowy: umowę o pracę za 5 200–6 000 zł "
                    "brutto miesięcznie albo umowę zlecenie za 32–36 zł brutto za godzinę. To dwa wiersze – po jednym "
                    "na każdą umowę. Benefity to prywatna opieka medyczna (grupa „Zdrowie”) i karta sportowa (grupa "
                    "„Sport i rekreacja”). Ogłoszenie agencji na OLX podaje tylko „umowa o pracę”, bez kwoty – "
                    "zapisujemy umowę z pustymi kwotami, bo brak widełek też jest informacją.",
        "tabele": [
            ("PostingSalary", "Umowy i wynagrodzenia w ogłoszeniu",
             "Jeden wiersz to jeden rodzaj umowy w jednym ogłoszeniu (ogłoszenie z organizmu 8) z widełkami: kwota od, "
             "kwota do, waluta, okres (np. miesięcznie) i to, czy kwota jest brutto. Jedno ogłoszenie może mieć kilka "
             "takich wierszy, ale każdy rodzaj umowy tylko raz. Kwoty mogą być puste, gdy firma nie podała widełek. Baza "
             "pilnuje, żeby kwota „od” nie była większa niż kwota „do”."),
            ("ContractType", "Rodzaje umów",
             "Sześć wariantów: umowa o pracę, kontrakt B2B, umowa zlecenie, umowa o dzieło, staż lub praktyki i umowa na "
             "zastępstwo."),
            ("Currency", "Waluty",
             "Waluta z trzyliterowym kodem, np. PLN – złoty, EUR – euro, USD – dolar amerykański, GBP – funt "
             "brytyjski."),
            ("SalaryPeriod", "Okresy wynagrodzenia",
             "Za jaki okres podano kwotę: za godzinę, miesięcznie, rocznie albo za projekt."),
            ("PostingBenefit", "Benefity w ogłoszeniu",
             "Jedno ogłoszenie oferuje kilka benefitów, a ten sam benefit pojawia się w wielu ogłoszeniach. Dlatego to "
             "osobna tabela par „ogłoszenie – benefit”. Para nie może się powtórzyć."),
            ("Benefit", "Benefity",
             "Dodatek do pracy, np. prywatna opieka medyczna, karta sportowa, budżet szkoleniowy, elastyczne godziny "
             "pracy, premia roczna. Każdy benefit należy do jednej grupy. Nazwa nie może się powtórzyć."),
            ("BenefitCategory", "Grupy benefitów",
             "Pięć grup: zdrowie, sport i rekreacja, rozwój, elastyczność i finanse."),
        ],
        "skrot": "PostingSalary (N:1 JobPosting z ORG08) – wiele umów na ogłoszenie, każda z własnymi widełkami; "
                 "benefity jako M:N JobPosting–Benefit przez PostingBenefit; słowniki walut, rodzajów umów, okresów i "
                 "grup benefitów.",
        "decyzje": [
            ("Wiersz na rodzaj umowy, UQ(JobPostingKey, ContractTypeKey)",
             "„umowa o pracę 12–15 tys. brutto albo B2B 15–19 tys. netto” to dwa wiersze; każdy rodzaj umowy raz na "
             "ogłoszenie."),
            ("Opcjonalne kwoty, waluta, okres i `IsGross`",
             "„umowa bez widełek” da się zapisać (to sygnał przejrzystości), ale baza nie pilnuje kompletności (kwota "
             "bez waluty)."),
            ("Brak przeliczenia do wspólnej waluty i okresu",
             "porównania wymagają przeliczenia w zapytaniu albo dodatkowych kolumn (pytanie do prowadzącego); kursów "
             "walut nie modelujemy."),
            ("Benefit jako słownik z grupą",
             "benefity są porównywalne między firmami; nowe nazwy z tekstu ogłoszeń trzeba dopisać do słownika albo "
             "przypisywać jak SkillSynonym w ORG10."),
        ],
        "luki": [
            "Kompletność widełek (`(SalaryFrom IS NULL AND SalaryTo IS NULL) OR (CurrencyKey IS NOT NULL AND "
            "SalaryPeriodKey IS NOT NULL)`) i kwoty nieujemne – brak CHECK (do decyzji).",
        ],
    },
    10: {
        "o_czym": [
            "Ten organizm zapisuje, czego firma oczekuje od kandydata i co kandydat ma robić w pracy. Wymagania nie są "
            "zapisane jako jeden długi tekst, tylko rozpisane na pola: która umiejętność, czy jest konieczna, na jakim "
            "poziomie i ile lat doświadczenia.",
            "Dzięki temu można porównać kolejne publikacje tego samego stanowiska i wykryć sprzeczności, np. ogłoszenie "
            "dla juniora, które wymaga pięciu lat doświadczenia. Przy każdej informacji zapisujemy też, skąd ją mamy: z "
            "osobnego pola od platformy, z reguły tekstowej czy z modelu AI.",
        ],
        "przyklad": "W ogłoszeniu „Magazynier/ka” wymagane jest prawo jazdy kategorii B (grupa „Uprawnienie”) i "
                    "uprawnienia UDT na wózek widłowy z co najmniej rokiem doświadczenia. Mile widziany jest język "
                    "angielski na poziomie B1 i komunikatywność. Firma napisała „angielski komunikatywny” – w tabeli "
                    "innych zapisów „angielski” prowadzi do umiejętności „Język angielski”. Wymagania z tekstu znalazł "
                    "model AI. Obowiązki to dwa zdania: „Kompletowanie zamówień według listy” i „Rozładunek i "
                    "przyjmowanie dostaw”.",
        "tabele": [
            ("PostingRequirement", "Wymagania w ogłoszeniu",
             "Jeden wiersz to jedno wymaganie w jednym ogłoszeniu (ogłoszenie z organizmu 8): która umiejętność, czy "
             "jest wymagana, czy mile widziana, na jakim poziomie (jeśli podano), ile lat doświadczenia (jeśli podano) i "
             "skąd to wiemy. Ta sama umiejętność może wystąpić w ogłoszeniu tylko raz."),
            ("RequirementLevel", "Ważność wymagania", "Dwa warianty: wymagane i mile widziane."),
            ("Skill", "Umiejętności",
             "Umiejętność albo kwalifikacja, np. SQL, język angielski, komunikatywność, wykształcenie wyższe, prawo "
             "jazdy kat. B. Każda należy do jednej grupy. Nazwa nie może się powtórzyć."),
            ("SkillCategory", "Grupy umiejętności",
             "Sześć grup: technologia lub narzędzie, umiejętność miękka, język obcy, wykształcenie, certyfikat i "
             "uprawnienie (np. prawo jazdy)."),
            ("ProficiencyLevel", "Poziomy znajomości",
             "Każda grupa umiejętności ma własną skalę: języki od A1 do C2, technologie – podstawowy, "
             "średniozaawansowany, zaawansowany. Każdy poziom ma numer kolejności w skali (1 = najniższy), więc poziomy "
             "da się porównywać. W jednej grupie nazwa poziomu nie może się powtórzyć."),
            ("SkillSynonym", "Inne zapisy umiejętności",
             "Firmy piszą to samo różnie: „JS”, „JavaScript”, „Java Script”. Jeden wiersz to jeden spotykany zapis i "
             "umiejętność, do której prowadzi, np. „English” → „Język angielski”. Ten sam zapis może prowadzić tylko do "
             "jednej umiejętności."),
            ("ExtractionMethod", "Źródła informacji",
             "Skąd wiemy o wymaganiu albo obowiązku: z osobnego pola od platformy, z reguły tekstowej (program szuka "
             "określonych słów), z modelu AI albo z ręcznego wpisu."),
            ("PostingResponsibility", "Obowiązki w ogłoszeniu",
             "Obowiązki to zwykle zdania, a nie wartości z listy, więc zapisujemy je jako tekst: jeden wiersz to jedno "
             "zdanie z ogłoszenia i informacja, skąd je mamy."),
        ],
        "skrot": "Wymagania jako M:N JobPosting (ORG08) – Skill przez PostingRequirement z atrybutami (ważność, poziom, "
                 "lata doświadczenia, źródło informacji); słownik umiejętności z grupami, skalami poziomów dla każdej "
                 "grupy i synonimami; obowiązki jako tekst.",
        "decyzje": [
            ("PostingRequirement z UQ(JobPostingKey, SkillKey)",
             "umiejętność raz na ogłoszenie; porównanie wymagań kolejnych publikacji to porównanie zbiorów wierszy "
             "(np. `MINUS`)."),
            ("`ProficiencyLevel` dla każdej `SkillCategory`, z `ProficiencyRank`",
             "osobne skale dla języków i technologii, porównywalne liczbowo w obrębie grupy."),
            ("`SkillSynonym` z UQ na `SynonymText`",
             "zapisy sprowadzamy do jednej Skill; niejednoznaczny skrót (ten sam zapis dla dwóch umiejętności) trzeba "
             "rozstrzygnąć ręcznie."),
            ("`ExtractionMethod` przy wymaganiu i obowiązku",
             "sygnały można liczyć tylko z pewnych źródeł albo porównać jakość AI z regułami."),
            ("`MinYearsExperience` obok `SeniorityLevel` z ORG08",
             "sprzeczności typu junior + 5 lat wykrywa zwykłe zapytanie."),
            ("Obowiązki jako zdania (`PostingResponsibility`)",
             "pełna informacja, ale bez porównań słownikowych – pytanie do prowadzącego."),
        ],
        "luki": [
            "Poziom wymagania powinien należeć do skali grupy danej umiejętności (`ProficiencyLevel.SkillCategoryKey = "
            "Skill.SkillCategoryKey`) – wymaga wyzwalacza albo klucza złożonego.",
            "`MinYearsExperience >= 0` – brak CHECK.",
        ],
    },
    11: {
        "o_czym": [
            "Ogłoszenie to nie jeden stan, tylko historia: jest publikowane, edytowane, odświeżane, wygasa i wraca. Ten "
            "organizm zapisuje tę historię – każde zdarzenie z datą – oraz każdą wersję treści ogłoszenia.",
            "Ta historia jest najmocniejszym dowodem na ghost job. Ogłoszenie, które co tydzień jest odświeżane, co "
            "miesiąc wraca i ciągle zbiera CV, mówi o firmie więcej niż pojedyncza publikacja. Zapisujemy też "
            "powtarzalne fragmenty tekstu, np. zgodę na wykorzystanie CV w przyszłych rekrutacjach – to sygnał "
            "zbierania CV na zapas.",
        ],
        "przyklad": "Ogłoszenie „Magazynier/ka” ma takie zdarzenia: 3 listopada „Opublikowano” (zgłoszone przez "
                    "platformę w dostawie z 3 listopada), 10, 17 i 24 listopada „Odświeżono (podbito)”, 24 listopada "
                    "„Edytowano treść”, 3 grudnia „Wygasło” i 5 grudnia „Opublikowano ponownie”. Treść ma dwie wersje: "
                    "pierwszą od 3 do 24 listopada i drugą od 24 listopada. W drugiej wersji program znalazł trzy "
                    "powtarzalne fragmenty: ogólną klauzulę RODO, stopkę „O nas” tej konkretnej firmy i zgodę na "
                    "przyszłe rekrutacje.",
        "tabele": [
            ("PostingEvent", "Zdarzenia ogłoszenia",
             "Jeden wiersz to jedno zdarzenie w życiu ogłoszenia (ogłoszenie z organizmu 8): co się stało, kiedy, skąd o "
             "tym wiemy i – jeśli informacja przyszła od platformy – w której dostawie (organizm 4). Do tej tabeli tylko "
             "dopisujemy: niczego nie zmieniamy ani nie usuwamy."),
            ("PostingEventType", "Rodzaje zdarzeń",
             "Siedem wariantów: opublikowano, edytowano treść, odświeżono (podbito – ogłoszenie wraca na górę listy), "
             "wygasło, zamknięto przed terminem, opublikowano ponownie i usunięto."),
            ("EventSource", "Źródła informacji o zdarzeniu",
             "Kto powiedział nam o zdarzeniu: platforma, my sami (np. ogłoszenie zniknęło bez żadnego komunikatu) albo "
             "moderator."),
            ("PostingVersion", "Wersje treści ogłoszenia",
             "Każda edycja to nowy wiersz z numerem wersji (1, 2, 3…). Zapisujemy tytuł w tej wersji, treść dokładnie "
             "taką, jaka przyszła, treść oczyszczoną (bez stopek i klauzul), skrót treści do szybkiego porównania wersji "
             "oraz daty „od kiedy” i „do kiedy” treść była taka. W jednym ogłoszeniu numer wersji nie może się "
             "powtórzyć, a koniec wersji musi być później niż jej początek."),
            ("BoilerplatePattern", "Powtarzalne fragmenty tekstu",
             "Fragment, który powtarza się w wielu ogłoszeniach, np. klauzula RODO albo stopka „O nas”. Fragment może "
             "być ogólny albo należeć do jednej firmy (firma z organizmu 6). Zapisujemy jego rodzaj i treść albo wzorzec, "
             "po którym program go rozpoznaje."),
            ("BoilerplateType", "Rodzaje fragmentów",
             "Cztery warianty: stopka „O nas”, klauzula RODO, zgoda na przyszłe rekrutacje i formatowanie HTML."),
            ("VersionBoilerplate", "Fragmenty znalezione w wersjach",
             "Jedna wersja treści zawiera kilka fragmentów, a ten sam fragment występuje w wielu wersjach. Jeden wiersz "
             "to para „wersja – znaleziony fragment”."),
        ],
        "skrot": "Oś czasu ogłoszenia: PostingEvent (dziennik zdarzeń, tylko INSERT, opcjonalnie z DataDelivery z ORG04) "
                 "i PostingVersion (wersje treści w CLOB ze skrótem i okresami); rozpoznawanie powtarzalnych fragmentów "
                 "przez BoilerplatePattern (ogólny albo firmowy – Employer z ORG06) i VersionBoilerplate (M:N).",
        "decyzje": [
            ("PostingEvent tylko do dopisywania",
             "pełna oś czasu dla sygnałów (odświeżenia, zniknięcia, powroty); stan bieżący w "
             "`JobPosting.PostingStatusKey` (ORG08) trzeba aktualizować razem z dopisaniem zdarzenia."),
            ("`EventSource`",
             "odróżniamy zdarzenia zgłoszone przez platformę od wykrytych przez nas (ogłoszenie zniknęło z odpowiedzi "
             "API) – mają różną wiarygodność."),
            ("PostingVersion z UQ(JobPostingKey, VersionNumber), `TextHash` i `CleanText`",
             "wersje porównujemy po skrócie; `CleanText` to wejście do porównań w ORG12; pełne teksty w CLOB kosztują "
             "miejsce (pytanie do prowadzącego)."),
            ("Opcjonalny `BoilerplatePattern.EmployerKey`",
             "wzorce ogólne (NULL) i firmowe w jednej tabeli; dopasowanie wykonuje program, a wynik zapisuje w "
             "VersionBoilerplate."),
            ("Rodzaj „Zgoda na przyszłe rekrutacje” w `BoilerplateType`",
             "obecność fragmentu staje się sygnałem zbierania CV na zapas (ORG17)."),
        ],
        "luki": [
            "Zasada „tylko dopisujemy” nie jest wymuszona schematem – wymusimy ją uprawnieniami (konto programu z "
            "INSERT i SELECT bez UPDATE i DELETE) albo wyzwalaczem.",
            "Okresy wersji jednego ogłoszenia nie powinny na siebie nachodzić, a numery – iść po kolei; to wymaga "
            "wyzwalacza albo programu.",
        ],
    },
    12: {
        "o_czym": [
            "Ghost job rzadko jest jednym ogłoszeniem. Zwykle to samo stanowisko jest publikowane wiele razy: jako "
            "dokładna kopia, innymi słowami, z innym poziomem stanowiska albo na innej platformie. Ten organizm "
            "zapisuje pary podobnych ogłoszeń, a z nich buduje rodziny – rodzina to wszystkie publikacje tego samego "
            "stanowiska jednej firmy w czasie.",
            "Dla każdej rodziny co jakiś czas liczymy jej historię: ile razy ogłoszenie publikowano, ile dni było "
            "widoczne, ile razy znikało i wracało, na ilu platformach się pojawiło. To główne dane wejściowe do oceny "
            "firmy.",
        ],
        "przyklad": "Ogłoszenie „Magazynier/ka” z pracuj.pl i ogłoszenie agencji z OLX to „to samo ogłoszenie na innej "
                    "platformie” – podobieństwo 0,94 według metody „Wektory znaczenia (model AI)” w wersji 1.0. "
                    "Ogłoszenie z listopada i ogłoszenie z października na pracuj.pl to „ta sama treść innymi słowami” "
                    "– podobieństwo 0,88 według porównania tekstu. Wszystkie te ogłoszenia trafiają do jednej rodziny "
                    "„Magazynier/ka, Kraków” firmy Przykład Logistyka: pierwsza publikacja w marcu, ostatnia 5 grudnia. "
                    "Historia rodziny policzona 1 grudnia: 7 publikacji, 160 dni widoczności, 6 razy znikało i wracało, "
                    "31 odświeżeń, 2 platformy, 1 poziom stanowiska.",
        "tabele": [
            ("SimilarityPair", "Pary podobnych ogłoszeń",
             "Jeden wiersz to dwa ogłoszenia (oba z organizmu 8), które są do siebie podobne: rodzaj powtórki, metoda, "
             "którą to policzyliśmy, podobieństwo od 0 do 1 i data wykrycia. Para jest zapisywana tylko raz – "
             "wcześniejsze ogłoszenie jest zawsze pierwsze – a ta sama para policzona tą samą metodą nie może się "
             "powtórzyć."),
            ("SimilarityType", "Rodzaje powtórek",
             "Cztery warianty: dokładna kopia, ta sama treść innymi słowami, ten sam etat z innym poziomem i to samo "
             "ogłoszenie na innej platformie."),
            ("SimilarityMethod", "Metody liczenia podobieństwa",
             "Metoda w konkretnej wersji, np. porównanie tekstu 1.0, wektory znaczenia (model AI) 1.0, porównanie cech "
             "ogłoszenia 1.0, z datą, od kiedy jej używamy. Metody się zmieniają, więc zapisujemy wersję – dzięki temu "
             "wszystko można przeliczyć od nowa i porównać wyniki."),
            ("PostingFamily", "Rodziny ogłoszeń",
             "Jedna rodzina to jedno stanowisko jednej firmy (firma z organizmu 6) w czasie, np. „Księgowa, Kraków”. "
             "Zapisujemy opis stanowiska oraz datę pierwszej i ostatniej publikacji. Ostatnia nie może być wcześniejsza "
             "niż pierwsza."),
            ("FamilyMember", "Ogłoszenia w rodzinach",
             "Jeden wiersz to jedno ogłoszenie w jednej rodzinie, z datą dołączenia. Ogłoszenie może należeć najwyżej do "
             "jednej rodziny (pytanie do prowadzącego, czy tak zostawić)."),
            ("FamilyLifecycle", "Historia rodziny na dany dzień",
             "Wynik obliczeń dla rodziny w konkretnym dniu: ile razy publikowano, ile dni łącznie było widoczne, ile "
             "razy znikało i wracało, ile razy odświeżano, na ilu platformach i z iloma różnymi poziomami stanowiska. "
             "Każde obliczenie to nowy wiersz, więc widać, jak rodzina zmienia się w czasie. Jednego dnia rodzina ma "
             "jeden wiersz."),
        ],
        "skrot": "Podobieństwo jako relacja dwóch ogłoszeń (SimilarityPair: dwa klucze do JobPosting z ORG08, CHECK "
                 "First < Second) liczona metodą z wersją; rodziny PostingFamily (Employer z ORG06) przez FamilyMember "
                 "(ogłoszenie w najwyżej jednej rodzinie) i stany na dzień w FamilyLifecycle.",
        "decyzje": [
            ("CHECK `FirstJobPostingKey < SecondJobPostingKey` + UQ(First, Second, Method)",
             "para zapisana raz, bez lustrzanych duplikatów; zapytanie „podobne do X” musi sprawdzać obie kolumny, więc "
             "potrzebne indeksy na obu."),
            ("`SimilarityMethod` z wersją i `ValidFrom`",
             "wyniki różnych wersji metod istnieją obok siebie; przeliczenie nową wersją nie nadpisuje starych par."),
            ("UNIQUE na `FamilyMember.JobPostingKey`",
             "rodzina 1:N ogłoszenie, zapisane tabelą łączącą; przejście na M:N to usunięcie jednego UNIQUE (pytanie do "
             "prowadzącego)."),
            ("`FamilyLifecycle` jako stan na dzień z UQ(PostingFamilyKey, CalculatedOn)",
             "trend bez przeliczania historii; liczniki to wynik obliczeń programu (świadoma denormalizacja)."),
            ("`PostingFamily.FirstSeenDate` i `LastSeenDate`",
             "dane wyliczalne z członków rodziny trzymane dla wygody – program aktualizuje je przy dodaniu ogłoszenia."),
        ],
        "luki": [
            "Ogłoszenia jednej rodziny powinny pochodzić z kont powiązanych z firmą rodziny (ścieżka przez ORG05 i "
            "ORG07) – reguła tylko w programie.",
            "Liczniki w FamilyLifecycle nieujemne – brak CHECK.",
        ],
    },
    13: {
        "o_czym": [
            "Kandydat to osoba, której nie znamy i nie chcemy znać. System walczy z wyłudzaniem CV, więc sam nie "
            "przechowuje CV, imion, e-maili ani numerów telefonów. Kandydata znamy tylko jako pseudonim – ciąg znaków "
            "nadany przez platformę. Tożsamość zna wyłącznie platforma.",
            "Ten organizm zapisuje pseudonimy, aplikacje potwierdzone przez platformę i ich kolejne stany oraz zgody "
            "kandydatów. Aplikacja to fakt potwierdzony przez platformę – na jej podstawie sprawdzamy później, czy "
            "osoba, która zgłasza wynik rekrutacji, naprawdę aplikowała. Zgoda to warunek, bez którego nie wolno nam "
            "np. wysyłać przypomnień.",
        ],
        "przyklad": "Platforma pracuj.pl przekazuje nam pseudonim „c3f9a7e1…” – tak widzimy osobę, która 4 listopada "
                    "zaaplikowała na ogłoszenie „Magazynier/ka”. Informacja o aplikacji przyszła w dostawie z "
                    "4 listopada. Aplikacja ma dwa stany: „Wysłana” (4 listopada) i „Wyświetlona przez firmę” "
                    "(6 listopada). 4 listopada osoba zgodziła się też na przypomnienia o wyniku rekrutacji – "
                    "zapisujemy, że widziała treść zgody w wersji 1.2. Gdyby później wycofała zgodę, powstałby nowy "
                    "wiersz „wycofana”, a stary zostałby bez zmian.",
        "tabele": [
            ("CandidatePseudonym", "Kandydaci (pseudonimy)",
             "Jeden wiersz to jeden pseudonim nadany przez jedną platformę (platforma z organizmu 1) i data, kiedy "
             "pierwszy raz się pojawił. Ta sama osoba na dwóch platformach to dla nas dwa różne pseudonimy – celowo ich "
             "nie łączymy. Na jednej platformie pseudonim nie może się powtórzyć."),
            ("Application", "Aplikacje",
             "Jeden wiersz to jedna aplikacja jednego pseudonimu na jedno ogłoszenie (ogłoszenie z organizmu 8), "
             "potwierdzona przez platformę: kiedy wysłano aplikację i w której dostawie przyszła ta informacja "
             "(organizm 4). Ten sam pseudonim może zaaplikować na jedno ogłoszenie tylko raz."),
            ("ApplicationStatusChange", "Historia stanów aplikacji",
             "Każda zmiana stanu aplikacji to nowy wiersz: nowy stan i data. Aktualny stan to ostatni wiersz – dlatego "
             "nie zapisujemy go osobno przy aplikacji (pytanie do prowadzącego)."),
            ("ApplicationStatus", "Stany aplikacji",
             "Siedem wariantów: wysłana, wyświetlona przez firmę, odrzucona automatycznie, zaproszenie na rozmowę, "
             "oferta pracy, zatrudnienie i wycofana przez kandydata – jeśli platforma je zna."),
            ("Consent", "Decyzje o zgodach",
             "Jeden wiersz to jedna decyzja kandydata: udzielenie albo wycofanie zgody, z datą i wersją treści zgody, "
             "którą kandydat widział. Każda decyzja to nowy wiersz, więc zawsze da się wykazać, na co i kiedy kandydat "
             "się zgodził – tego wymaga RODO."),
            ("ConsentTextVersion", "Wersje treści zgód",
             "Pełna treść zgody w konkretnej wersji (np. 1.2) i data, od kiedy była pokazywana. Gdy zmieniamy treść, "
             "powstaje nowa wersja, a stara zostaje. W jednym rodzaju zgody oznaczenie wersji nie może się powtórzyć."),
            ("ConsentType", "Rodzaje zgód",
             "Na co kandydat się zgadza: przypomnienia o wyniku rekrutacji albo zbieranie cech urządzenia (potrzebne do "
             "sprawdzenia zgłoszenia w organizmie 15)."),
        ],
        "skrot": "Minimum danych: kandydat tylko jako CandidatePseudonym (UQ w obrębie SourcePlatform z ORG01); "
                 "Application (N:1 JobPosting z ORG08, opcjonalnie DataDelivery z ORG04) z historią stanów; zgody jako "
                 "dziennik decyzji wskazujący konkretną wersję tekstu.",
        "decyzje": [
            ("Brak danych osobowych – tylko pseudonim od platformy",
             "mniejsze ryzyko RODO i mniej do usuwania na wniosek; ta sama osoba na dwóch platformach to dwa pseudonimy "
             "– świadomie."),
            ("UQ(CandidatePseudonymKey, JobPostingKey) w Application",
             "jedna aplikacja osoby na ogłoszenie; ponowna aplikacja na to samo ogłoszenie po „Opublikowano ponownie” "
             "się nie zmieści – trzeba zdecydować, czy to potrzebne."),
            ("Stan aplikacji tylko w historii (`ApplicationStatusChange`)",
             "stan bieżący to ostatni wiersz (`ROW_NUMBER() OVER (… ORDER BY ChangedAt DESC)`); pytanie do prowadzącego "
             "o kolumnę z ostatnim stanem."),
            ("Consent → ConsentTextVersion, UQ(ConsentTypeKey, VersionLabel)",
             "rozliczalność RODO: wiadomo, na jaką treść wyrażono zgodę; wycofanie to nowy wiersz `IsGranted = 'N'`, "
             "stan bieżący – ostatnia decyzja."),
            ("`Application.DataDeliveryKey`",
             "pochodzenie potwierdzenia aplikacji – podstawa sprawdzenia „Dowód aplikacji” w ORG15."),
        ],
        "luki": [
            "Pseudonim aplikacji powinien pochodzić z tej samej platformy co ogłoszenie (platforma ogłoszenia jest dwa "
            "kroki dalej: JobPosting → EmployerAccount → SourcePlatform) – wymaga wyzwalacza.",
            "Wysyłanie przypomnień tylko przy aktualnej zgodzie to reguła programu (ORG14) – baza jej nie sprawdza.",
        ],
    },
    14: {
        "o_czym": [
            "Zgłoszenie to informacja od kandydata o tym, co stało się po aplikacji: cisza, odmowa, rozmowa, oferta "
            "albo zatrudnienie. Kandydat wysyła je przez nasz widżet – sam z siebie albo w odpowiedzi na "
            "przypomnienie. Ten organizm zapisuje zgłoszenia i przypomnienia.",
            "Pojedyncze zgłoszenie nie jest jeszcze dowodem – to jedna, niesprawdzona informacja. Dowodem staje się "
            "dopiero wiele zgłoszeń po sprawdzeniu w organizmie 15. Zbieramy też sukcesy: każda firma komuś odmawia, "
            "więc liczy się odsetek, a nie same porażki.",
        ],
        "przyklad": "30 dni po aplikacji, 4 grudnia, prosimy platformę o wysłanie przypomnienia numer 1 do osoby z "
                    "pseudonimem „c3f9a7e1…”. Przypomnienie zostaje dostarczone, a osoba odpowiada. 5 grudnia "
                    "przychodzi zgłoszenie: wynik „Brak odpowiedzi (cisza)”, etap „Po wysłaniu CV”, kanał „Odpowiedź na "
                    "przypomnienie”. Przy zgłoszeniu zapisujemy, po którym przypomnieniu przyszło, a stan przypomnienia "
                    "zmienia się na „Kandydat odpowiedział”.",
        "tabele": [
            ("RecruitmentReport", "Zgłoszenia wyniku rekrutacji",
             "Jeden wiersz to jedno zgłoszenie: kto zgłasza (pseudonim z organizmu 13), którego ogłoszenia dotyczy "
             "(organizm 8), jaki był wynik, na którym etapie rekrutacja się skończyła, jak przyszło zgłoszenie, po "
             "którym przypomnieniu (jeśli po przypomnieniu) i kiedy. Zgłoszeń tylko przybywa – niczego nie poprawiamy. "
             "Jeśli kandydat zmieni zdanie, przychodzi nowe zgłoszenie."),
            ("ReportOutcome", "Wyniki rekrutacji",
             "Sześć wariantów: brak odpowiedzi (cisza), automatyczna odmowa, odmowa po rozmowie, oferta wycofana, "
             "zatrudnienie i „ogłoszenie było nieaktualne”."),
            ("RecruitmentStage", "Etapy rekrutacji",
             "Pięć etapów w kolejności: po wysłaniu CV, po zadaniu lub teście, po pierwszej rozmowie, po kolejnej "
             "rozmowie i po otrzymaniu oferty. Numer kolejności pozwala policzyć, na którym etapie firmy najczęściej "
             "przestają odpowiadać."),
            ("ReportChannel", "Kanały zgłoszenia",
             "Dwa warianty: formularz w widżecie (kandydat zgłasza sam z siebie) i odpowiedź na przypomnienie."),
            ("Reminder", "Przypomnienia",
             "Przypomnienie wysyła platforma na naszą prośbę – my nie znamy danych kontaktowych kandydata. Jeden wiersz "
             "to jedno przypomnienie do jednej aplikacji (organizm 13): jego numer (1, 2…), stan i data zlecenia. Ta "
             "sama aplikacja nie może mieć dwóch przypomnień o tym samym numerze."),
            ("ReminderStatus", "Stany przypomnienia",
             "Cztery warianty: zlecone platformie, dostarczone, bez odpowiedzi i „kandydat odpowiedział”."),
        ],
        "skrot": "RecruitmentReport – zdarzenie od kandydata (CandidatePseudonym z ORG13) o ogłoszeniu (JobPosting z "
                 "ORG08) z wynikiem, etapem i kanałem, opcjonalnie powiązane z Reminder; Reminder (N:1 Application z "
                 "ORG13) z numerem i stanem.",
        "decyzje": [
            ("Zgłoszenia tylko do dopisywania",
             "zmiana zdania to nowy wiersz; do oceny bierzemy ostatnie zgłoszenie pary (pseudonim, ogłoszenie) albo "
             "wszystkie – pytanie do prowadzącego."),
            ("Zgłoszenie wskazuje pseudonim i ogłoszenie, a nie Application",
             "zgłoszenie bez potwierdzonej aplikacji też zostaje zapisane (ORG15 odrzuci je za brak dowodu); powiązanie "
             "z aplikacją to złączenie po (pseudonim, ogłoszenie)."),
            ("`RecruitmentStage.StageRank`",
             "zestawienia typu „na którym etapie firmy milkną” bez porównywania tekstów."),
            ("Reminder z UQ(ApplicationKey, ReminderNumber)",
             "kolejne przypomnienia ponumerowane bez duplikatów; wysyła je platforma, więc nie przechowujemy kontaktu."),
        ],
        "luki": [
            "Przypomnienie wolno zlecić tylko przy aktualnej zgodzie na przypomnienia (ORG13) – reguła programu.",
            "`ReminderKey` zgłoszenia powinien należeć do aplikacji tego samego pseudonimu i ogłoszenia – wymaga "
            "wyzwalacza.",
            "Zasada „tylko dopisujemy” do wymuszenia uprawnieniami, jak w ORG11.",
        ],
    },
    15: {
        "o_czym": [
            "Każde zgłoszenie od kandydata sprawdzamy kilkoma niezależnymi sprawdzeniami: czy wysłał je człowiek, a nie "
            "program (bot), czy ta osoba naprawdę aplikowała, czy z tego samego urządzenia nie przyszło wiele zgłoszeń "
            "z różnych pseudonimów i czy zgłoszenie nie jest częścią nagłej fali zgłoszeń o tej firmie. Każde "
            "sprawdzenie daje swój wynik.",
            "Na końcu zgłoszenie dostaje ocenę: przyjęte, do moderacji albo odrzucone, z wagą od 0 do 1. Tylko przyjęte "
            "zgłoszenia liczą się do Trust Score. Dzięki temu konkurencja nie obniży oceny firmy fałszywymi skargami, a "
            "firma nie podniesie jej sama sobie.",
        ],
        "przyklad": "Zgłoszenie z 5 grudnia przechodzi cztery sprawdzenia, wszystkie z wynikiem „Pozytywny”: usługa "
                    "Cloudflare potwierdza, że wysłał je człowiek; platforma potwierdziła aplikację sprzed 31 dni; z "
                    "tego urządzenia nie przyszły inne zgłoszenia; nie ma fali zgłoszeń o tej firmie. Ocena: "
                    "„Przyjęte”, waga 0,9, według reguł w wersji 1.0. Urządzenie zapisujemy tylko jako skrót jego cech, "
                    "z datą usunięcia za 90 dni.",
        "tabele": [
            ("ReportCheck", "Wyniki sprawdzeń",
             "Jeden wiersz to wynik jednego sprawdzenia jednego zgłoszenia (zgłoszenie z organizmu 14): rodzaj "
             "sprawdzenia, wynik, data i szczegóły, np. „aplikacja 34 dni temu”. Nowy rodzaj sprawdzenia to nowy wiersz "
             "na liście rodzajów, a nie nowa tabela."),
            ("CheckType", "Rodzaje sprawdzeń",
             "Cztery warianty: człowiek czy bot (sprawdza to usługa Cloudflare), dowód aplikacji (czy platforma "
             "potwierdziła aplikację), odcisk urządzenia (czy z tego urządzenia nie przyszło wiele zgłoszeń z różnych "
             "pseudonimów) i fala zgłoszeń (czy nie przyszło nagle bardzo dużo zgłoszeń o jednej firmie)."),
            ("CheckResult", "Wyniki sprawdzenia",
             "Cztery warianty: pozytywny (zgłoszenie przeszło sprawdzenie), negatywny (nie przeszło), „nie dało się "
             "sprawdzić” (np. usługa nie działała) i „za wcześnie” (np. platforma jeszcze nie przesłała potwierdzenia "
             "aplikacji)."),
            ("ReportVerdict", "Oceny zgłoszeń",
             "Jeden wiersz to jedna ocena zgłoszenia: decyzja, waga od 0 do 1 (ile zgłoszenie znaczy dla Trust Score), "
             "wersja reguł oceny i data. Zgłoszenie można ocenić ponownie, gdy przyjdą nowe dane albo zmienią się "
             "reguły – wtedy powstaje nowy wiersz, a stary zostaje."),
            ("VerdictDecision", "Decyzje",
             "Trzy warianty: przyjęte, do moderacji (decyduje człowiek) i odrzucone."),
            ("DeviceFingerprint", "Urządzenia (jako skróty)",
             "Urządzenie zapisujemy tylko jako skrót jego cech (np. rodzaju przeglądarki i rozdzielczości ekranu). Ze "
             "skrótu nie da się odtworzyć tych cech, ale identyczne urządzenia mają identyczny skrót. Zapisujemy też, "
             "kiedy urządzenie pojawiło się pierwszy raz i kiedy trzeba je usunąć – dane osobowe trzymamy krótko."),
            ("ReportDevice", "Urządzenie zgłoszenia",
             "Przypisuje zgłoszeniu urządzenie, z którego je wysłano. Jedno zgłoszenie ma najwyżej jedno urządzenie, a "
             "z jednego urządzenia może przyjść wiele zgłoszeń – tak wykrywamy jedną osobę udającą wielu kandydatów."),
        ],
        "skrot": "Weryfikacja jako zestaw niezależnych testów (ReportCheck: zgłoszenie × rodzaj × wynik) i ocen z wersją "
                 "reguł (ReportVerdict z wagą) dla RecruitmentReport z ORG14; urządzenia jako skróty z terminem "
                 "usunięcia, przypisane zgłoszeniu przez ReportDevice.",
        "decyzje": [
            ("Jedna tabela `ReportCheck` dla wszystkich rodzajów sprawdzeń",
             "nowe sprawdzenie bez zmiany schematu; szczegóły jako tekst (`CheckDetails`) zamiast osobnych kolumn – "
             "pytanie do prowadzącego."),
            ("`ReportVerdict` jako historia z `RuleSetVersion`",
             "ponowna ocena nie nadpisuje poprzedniej; do Trust Score bierzemy ostatnią (najnowsze `DecidedAt`)."),
            ("`ReportWeight` 0–1 (CHECK)",
             "zgłoszenia mogą liczyć się częściowo zamiast tak/nie."),
            ("`DeviceFingerprint` tylko jako skrót z `ExpiresAt`",
             "nie przechowujemy cech urządzenia; usuwanie po terminie wymaga zadania okresowego (`DBMS_SCHEDULER`), a "
             "przed usunięciem urządzenia trzeba usunąć jego wiersze ReportDevice (albo dodać `ON DELETE CASCADE`)."),
            ("UNIQUE na `ReportDevice.RecruitmentReportKey`",
             "urządzenie 1:N zgłoszenia – podstawa wzorca „jedno urządzenie, wiele pseudonimów” w ORG16."),
        ],
        "luki": [
            "Ocena „Przyjęte” powinna wymagać kompletu sprawdzeń – reguła programu, baza tego nie sprawdza.",
            "Termin `ExpiresAt` sam niczego nie usuwa – potrzebne zadanie okresowe.",
        ],
    },
    16: {
        "o_czym": [
            "Nadużycie to nie jedno zgłoszenie, tylko wzorzec wielu zgłoszeń naraz: atak konkurencji, która zasypuje "
            "firmę negatywnymi zgłoszeniami, firma, która chwali samą siebie, albo jedna osoba udająca wielu kandydatów. "
            "Ten organizm zapisuje alerty – podejrzenia takich wzorców – i zgłoszenia, których dotyczą.",
            "Alert to tylko podejrzenie. Potwierdzić albo odrzucić je musi człowiek – moderator. Dopiero potwierdzony "
            "alert wpływa na oceny zgłoszeń.",
        ],
        "przyklad": "8 grudnia między 20:00 a 23:00 przychodzi 12 negatywnych zgłoszeń o Przykład Logistyka z jednego "
                    "urządzenia, ale od 12 różnych pseudonimów. Program tworzy alert „Jedno urządzenie, wiele "
                    "pseudonimów” ze stanem „Nowy”, okresem 20:00–23:00 i liczbą 12 zgłoszeń. Wszystkie 12 zgłoszeń "
                    "zapisujemy przy alercie. Moderator przejmuje alert („W moderacji”) i potwierdza nadużycie "
                    "(„Potwierdzone nadużycie”). Te 12 zgłoszeń dostaje w organizmie 15 nową ocenę „Odrzucone”, więc "
                    "nie obniży wyniku firmy.",
        "tabele": [
            ("AbuseAlert", "Alerty o nadużyciach",
             "Jeden wiersz to jeden alert o jednej firmie (firma z organizmu 6): rodzaj podejrzanego wzorca, stan, "
             "początek i koniec okresu, w którym przyszły zgłoszenia, data wykrycia i liczba zgłoszeń. Baza pilnuje, "
             "żeby koniec okresu nie był przed jego początkiem."),
            ("AlertType", "Rodzaje podejrzanych wzorców",
             "Cztery warianty: fala negatywnych zgłoszeń o jednej firmie, fala pozytywnych zgłoszeń od samej firmy, "
             "jedno urządzenie z wieloma pseudonimami i zgłoszenia od pseudonimów bez aplikacji."),
            ("AlertStatus", "Stany alertu",
             "Cztery warianty: nowy, w moderacji, potwierdzone nadużycie i fałszywy alarm."),
            ("AlertReport", "Zgłoszenia objęte alertem",
             "Jeden alert obejmuje wiele zgłoszeń, a jedno zgłoszenie może trafić do kilku alertów. Dlatego to osobna "
             "tabela par „alert – zgłoszenie” (zgłoszenie z organizmu 14). Para nie może się powtórzyć."),
        ],
        "skrot": "AbuseAlert (N:1 Employer z ORG06) – wykryty wzorzec w oknie czasowym ze stanem obsługi; AlertReport "
                 "jako M:N AbuseAlert–RecruitmentReport (ORG14).",
        "decyzje": [
            ("Alert zawsze dotyczy firmy (`EmployerKey` wymagany)",
             "proste zestawienia dla firmy; wzorce na poziomie platformy albo samego urządzenia nie mają gdzie trafić – "
             "pytanie do prowadzącego."),
            ("`AlertReport` M:N z UQ(AbuseAlertKey, RecruitmentReportKey)",
             "to samo zgłoszenie może należeć do kilku alertów (ten sam atak wykryty dwoma wzorcami)."),
            ("`ReportCount` zapisany w alercie",
             "liczba z chwili wykrycia – może się rozjechać z liczbą wierszy AlertReport, jeśli zgłoszenia dochodzą "
             "później."),
            ("`AlertStatus` jako bieżący stan bez historii",
             "nie wiadomo, kto i kiedy zmienił stan – decyzje moderatorów trafią do organizmu moderacji (warstwa 5, do "
             "rozpisania)."),
        ],
        "luki": [
            "Zgłoszenia w alercie powinny dotyczyć ogłoszeń firmy z alertu (ścieżka przez ORG08, ORG05 i ORG07) – "
            "reguła programu.",
            "Potwierdzenie nadużycia nie zmienia samo ocen w ORG15 – program musi dopisać nowe ReportVerdict.",
        ],
    },
    17: {
        "o_czym": [
            "Sygnał to jedna zmierzona liczba o firmie, np. „38% ogłoszeń to powtórki” albo „0,5 zatrudnienia na 100 "
            "aplikacji”. Sygnały liczymy z danych z wielu organizmów naraz: z historii ogłoszeń, rodzin, zgłoszeń "
            "kandydatów i rejestrów.",
            "Wszystkie sygnały firmy policzone jednego dnia tworzą jej stan na ten dzień. Każde kolejne liczenie to "
            "nowy stan, więc widać, jak firma zmienia się w czasie. Przy każdej wartości zapisujemy też, na ilu danych "
            "się opiera – sygnał z 2 zgłoszeń jest mniej wiarygodny niż z 200.",
        ],
        "przyklad": "Stan firmy Przykład Logistyka na 1 grudnia: odsetek ogłoszeń będących powtórkami – 38% (z "
                    "21 ogłoszeń), średnia liczba publikacji jednego stanowiska – 4,2, zatrudnienia na 100 aplikacji – "
                    "0,5 (z 410 aplikacji), zgłoszenia ciszy na 100 aplikacji – 34 (z 410 aplikacji), odsetek ogłoszeń "
                    "z widełkami – 86% i wiek firmy w rejestrze – 2821 dni. Dla powtórek i ciszy więcej znaczy gorzej, a "
                    "dla zatrudnień, widełek i wieku firmy – lepiej.",
        "tabele": [
            ("SignalSnapshot", "Stany sygnałów na dany dzień",
             "Jeden wiersz to stan jednej firmy (firma z organizmu 6) na jeden dzień. Sam wiersz zawiera tylko firmę i "
             "datę – wartości sygnałów są w osobnej tabeli. Firma ma najwyżej jeden stan na dzień."),
            ("SignalValue", "Wartości sygnałów",
             "Jeden wiersz to wartość jednego sygnału w jednym stanie, np. „odsetek ogłoszeń będących powtórkami = 38”, "
             "i to, na ilu danych się opiera. W jednym stanie każdy sygnał występuje raz. Dzięki zapisowi w wierszach "
             "nowy rodzaj sygnału nie wymaga przebudowy tabel."),
            ("SignalType", "Rodzaje sygnałów",
             "Rodzaj sygnału z nazwą, grupą, jednostką (%, dni, liczba), kierunkiem (czy więcej znaczy lepiej dla "
             "firmy) i opisem, jak go liczymy. Na start: odsetek ogłoszeń będących powtórkami, średnia liczba publikacji "
             "jednego stanowiska, zatrudnienia na 100 aplikacji, zgłoszenia ciszy na 100 aplikacji, odsetek ogłoszeń z "
             "widełkami i wiek firmy w rejestrze."),
            ("SignalGroup", "Grupy sygnałów",
             "Cztery grupy: powtórki ogłoszeń, odpowiedzi firmy na aplikacje, przejrzystość ogłoszeń i dane z "
             "rejestrów."),
        ],
        "skrot": "Sygnały w modelu EAV: SignalSnapshot (Employer z ORG06 × dzień, UQ) 1:N SignalValue (SignalType × "
                 "wartość × liczba danych); SignalType z jednostką, kierunkiem (`HigherIsBetter`) i grupą. ORG18 "
                 "wskazuje SignalSnapshot i SignalType.",
        "decyzje": [
            ("Wartości w wierszach (EAV) zamiast kolumny na sygnał",
             "nowy sygnał bez `ALTER TABLE`; koszt: wszystkie wartości jako NUMBER(12,4) i zapytania z `PIVOT` do "
             "zestawień (pytanie do prowadzącego)."),
            ("UQ(EmployerKey, SnapshotDate) i UQ(SignalSnapshotKey, SignalTypeKey)",
             "jeden stan firmy na dzień i jedna wartość sygnału w stanie; trend to porównanie stanów."),
            ("`BasedOnCount`",
             "wiarygodność zależy od liczby danych – metoda w ORG18 może pomijać sygnały poniżej progu."),
            ("`HigherIsBetter` jako dana",
             "metoda punktowania nie musi znać znaczenia sygnału – kierunek jest zapisany w słowniku."),
        ],
        "luki": [
            "Sygnały nie mają wersji sposobu liczenia – zmiana definicji zmienia znaczenie starych wartości; warto dodać "
            "wersję do SignalType albo SignalValue.",
        ],
    },
    18: {
        "o_czym": [
            "Trust Score to ocena wiarygodności firmy od 0 do 100. Nie jest stałą cechą firmy, tylko wynikiem "
            "policzonym konkretną metodą, w konkretnym dniu, na konkretnym stanie sygnałów z organizmu 17. Dlatego przy "
            "każdym wyniku zapisujemy metodę, pewność (od 0 do 1) i 2–3 najważniejsze powody, które zobaczy kandydat i "
            "firma.",
            "To, co widzi kandydat, zapisujemy osobno od wyniku roboczego. Nie każdy wynik wolno od razu pokazać: przy "
            "małej pewności pokazujemy „za mało danych”, ostrzeżenie może czekać na decyzję moderatora, a po "
            "uzasadnionym odwołaniu firmy wynik można wycofać.",
        ],
        "przyklad": "1 grudnia liczymy wynik firmy Przykład Logistyka metodą „Wagi ustalone przez zespół” w wersji 1.0, "
                    "na stanie sygnałów z tego dnia. Każdy z sześciu sygnałów ma w tej metodzie swoją wagę. Wynik: 41 na "
                    "100, pewność 0,72. Trzy powody, od najważniejszego: „to samo ogłoszenie 7 razy w 9 miesięcy”, "
                    "„38% ogłoszeń to powtórki” i „34 na 100 aplikacji kończy się ciszą”. Pewność wystarcza, więc od "
                    "1 grudnia wynik jest pokazywany ze stanem „Opublikowany”. Gdyby firma się odwołała i miała rację, "
                    "ta publikacja dostałaby datę końca, a nowy wiersz – stan „Wycofany po odwołaniu”.",
        "tabele": [
            ("TrustScore", "Wyniki (robocze)",
             "Jeden wiersz to jedno policzenie wyniku: na jakim stanie sygnałów (organizm 17), jaką metodą, wynik od 0 "
             "do 100, pewność od 0 do 1 i kiedy policzono. Każde przeliczenie to nowy wiersz, więc widać historię "
             "oceny firmy. Baza pilnuje zakresów 0–100 i 0–1."),
            ("ScoringMethod", "Metody liczenia wyniku",
             "Metoda w konkretnej wersji, z rodzajem i datami „od kiedy” i „do kiedy” była używana. Na start: „Wagi "
             "ustalone przez zespół” w wersji 1.0. W jednym rodzaju metody wersja nie może się powtórzyć, a data końca "
             "nie może być wcześniejsza niż data początku."),
            ("ScoringMethodType", "Rodzaje metod",
             "Dwa warianty: wagi ustalone przez zespół (na start) i wytrenowany model (później, gdy będzie dość "
             "danych)."),
            ("ScoringWeight", "Wagi sygnałów",
             "Każda metoda daje każdemu sygnałowi inną wagę. Jeden wiersz to waga jednego sygnału (rodzaj sygnału z "
             "organizmu 17) w jednej metodzie. W jednej metodzie sygnał ma jedną wagę."),
            ("ScoreReason", "Powody wyniku",
             "2–3 powody wyniku, pokazywane kandydatowi i firmie, np. „to samo ogłoszenie 7 razy w 9 miesięcy”. Każdy "
             "powód ma numer kolejności i wskazuje sygnał, z którego wynika. W jednym wyniku numer powodu nie może się "
             "powtórzyć."),
            ("PublishedScore", "Wyniki pokazane publicznie",
             "Jeden wiersz to jeden okres pokazywania wyniku: który wynik, w jakim stanie publikacji, od kiedy i do "
             "kiedy. Puste „do kiedy” znaczy, że wynik jest widoczny teraz. Zapis jest osobno od wyniku roboczego, więc "
             "publikację można wstrzymać albo wycofać bez kasowania obliczeń."),
            ("PublicationStatus", "Stany publikacji",
             "Cztery warianty: opublikowany, za mało danych, wstrzymany do decyzji moderatora i wycofany po odwołaniu."),
        ],
        "skrot": "TrustScore to wynik metody (ScoringMethod z wersją) na stanie sygnałów (SignalSnapshot z ORG17); wagi "
                 "jako M:N metoda–SignalType (ScoringWeight); powody 1:N z rangą i kluczem do SignalType; publikacja "
                 "oddzielona od wyniku roboczego (PublishedScore z okresami i stanem).",
        "decyzje": [
            ("Wynik wskazuje stan sygnałów i metodę",
             "pełna odtwarzalność: wiadomo, na jakich danych i jaką wersją metody policzono wynik; przeliczenie to nowy "
             "wiersz."),
            ("`ScoringWeight` jako M:N z wartością",
             "metoda to dane, a nie kod; nowa wersja metody to nowe wagi, stare zostają."),
            ("`ScoreReason` z UQ(TrustScoreKey, ReasonRank) i kluczem do SignalType",
             "powody w ustalonej kolejności, powiązane z sygnałem, z którego wynikają."),
            ("`PublishedScore` osobno od `TrustScore`",
             "publikację można wstrzymać lub wycofać bez kasowania wyniku; kandydat widzi wiersz z "
             "`PublishedTo IS NULL` i stanem „Opublikowany”."),
            ("CHECK `ScoreValue` 0–100 i `ScoreConfidence` 0–1",
             "próg pewności dla „Za mało danych” to reguła programu, nie bazy."),
        ],
        "luki": [
            "Najwyżej jedna aktualna publikacja na firmę – firma jest dwa kroki dalej (TrustScore → SignalSnapshot → "
            "Employer), więc unikalny indeks nie wystarczy; potrzebny wyzwalacz albo EmployerKey w PublishedScore.",
            "Wagi i powody powinny dotyczyć sygnałów obecnych w stanie, z którego liczono wynik – reguła programu.",
        ],
    },
}
