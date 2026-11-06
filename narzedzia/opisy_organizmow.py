"""Opisy organizmów na stronie web/organizmy.html – każdy organizm dwa razy:

- „dla każdego” – prostym językiem, bez wiedzy o bazach danych: o czym jest organizm, przykład i opis każdej tabeli,
- „dla technicznych” – krótko: decyzje projektowe i ich skutki oraz to, czego baza jeszcze nie pilnuje.

Relacje, liczby i zależności między organizmami generator wylicza sam z organizmy.py.
W tekstach technicznych `tak` oznacza kod (nazwę kolumny, fragment SQL).
Generator ostrzega, gdy opis pomija tabelę organizmu albo opisuje tabelę, której nie ma.
Po zmianie uruchom: python narzedzia/build_web.py
"""

WSTEP = {
    "lede": "Każdy z 17 organizmów opisany dwa razy: prostym językiem – dla osób, które nie znają baz danych – i krótko "
            "dla osób technicznych, z decyzjami projektowymi i ich skutkami.",
    "po_co": [
        "Ghost-Job Scanner wykrywa widmowe ogłoszenia o pracę (ang. ghost jobs). To ogłoszenia, za którymi nie stoi "
        "prawdziwa chęć zatrudnienia: firma zbiera CV na zapas, chce wyglądać na rozwijającą się albo nie zdjęła "
        "ogłoszenia, choć stanowisko dawno obsadziła. Zbieranie CV bez zamiaru zatrudnienia nazywa się CV harvesting.",
        "Platformy z ogłoszeniami, np. pracuj.pl albo OLX, przekazują nam dane o kontach firm, ogłoszeniach i "
        "aplikacjach. Kandydaci mówią nam, co stało się po aplikacji: cisza, odmowa, rozmowa albo zatrudnienie. Z tych "
        "danych liczymy dla każdej firmy Trust Score – ocenę wiarygodności od 0 do 100 – i pokazujemy ją przy ogłoszeniu.",
        "Baza danych to miejsce, w którym system to wszystko zapisuje. Podzieliliśmy ją na organizmy – grupy tabel, z "
        "których każda opisuje jedną część systemu. Idą w kolejności, w jakiej płyną dane: od platformy, która je "
        "dostarcza, do oceny firmy. Organizm 1 powstał z połączenia dawnych organizmów 1–3 (platforma, API i endpointy), "
        "dlatego po numerze 1 jest od razu 4. Ostatni, 19, opisuje użytkowników systemu i ich role.",
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
     "końcówką Key, np. SourcePlatformKey. Nic nie znaczy – to tylko numer 1, 2, 3…"),
    ("Rozmiar klucza", "Ile cyfr może mieć numer wiersza. Wynika z tego, ile wierszy może mieć tabela: dla 20 rodzajów "
     "wystarczą 2 cyfry, dla 5 000 platform – 4 cyfry. Za duży klucz marnuje miejsce w każdej tabeli, która go wskazuje."),
    ("Kod urzędowy", "Numer nadany przez urząd albo normę, np. kod województwa 12 albo kod formy prawnej 099. Zapisujemy "
     "go jako tekst, bo może zaczynać się od zera, i nie używamy go jako numeru wiersza."),
    ("Odwołanie do innej tabeli (klucz obcy)", "Kolumna, w której zapisujemy numer wiersza z innej tabeli, np. przy "
     "adresie strony – numer platformy, do której ten adres należy. Baza nie pozwoli wpisać numeru, którego nie ma."),
    ("Lista wariantów (słownik)", "Mała tabela z dozwolonymi wartościami, np. etapy umowy. Wartość wybiera się z tej "
     "listy, zamiast wpisywać tekst, więc ta sama rzecz jest zawsze zapisana tak samo i literówka nie stworzy nowej."),
    ("Tabela łącząca", "Tabela z parami, potrzebna, gdy jedna rzecz może mieć wiele drugich i odwrotnie – np. platforma "
     "działa w wielu krajach, a w jednym kraju działa wiele platform (relacja wiele do wielu)."),
    ("Flaga", "Kolumna, która ma tylko dwie wartości: 1 (tak) albo 0 (nie), np. „czy to adres główny”."),
    ("Przypisanie w czasie", "Tabela łącząca z datą od, datą do i flagą „aktualne”, np. przedstawiciel i firma, którą "
     "reprezentuje. Gdy przypisanie się kończy, nie usuwamy go, tylko wpisujemy datę końca i flagę 0."),
    ("Historia", "Tabela, w której zmiana nie nadpisuje starych danych, tylko dodaje nowy wiersz z datą „od kiedy” i "
     "„do kiedy”. Aktualny wiersz ma flagę 1 i puste „do kiedy”."),
    ("Jeden aktualny", "Reguła, której pilnuje baza: wśród wierszy jednej rzeczy tylko jeden może mieć flagę 1, np. "
     "platforma ma jedną aktualną umowę."),
    ("Dziennik zdarzeń", "Tabela, do której tylko dopisujemy: każdy wiersz to coś, co stało się w danej chwili."),
    ("Stan na dany dzień", "Wiersz z wynikami policzonymi w konkretnym dniu. Kolejne liczenie dodaje nowy wiersz."),
    ("Wartość unikalna", "Wartość, która nie może się powtórzyć w tabeli, np. nazwa platformy."),
    ("Warunek poprawności", "Reguła, której baza pilnuje przy każdym zapisie, np. data końca nie może być wcześniejsza "
     "niż data początku."),
    ("Organizm", "Kilka tabel, które razem opisują jedną część systemu."),
    ("Przedrostek ORG06_", "Początek nazwy tabeli w bazie Oracle: ORG i numer organizmu. Dzięki niemu tabele jednego "
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
    "F": "Kto pracuje w systemie: konta użytkowników, role i przedstawiciele firm.",
}

# Wnioski z uwag prowadzącego do projektu innego zespołu (system przychodni) – co zmieniliśmy u siebie.
WNIOSKI_WSTEP = ("Na zajęciach prowadzący omawiał projekt innego zespołu (przychodnia: pacjenci, lekarze, specjalizacje, "
                 "kliniki, użytkownicy). Każdą jego uwagę sprawdziliśmy na naszym modelu.")
WNIOSKI = [
    ("Klucz nie może mieć znaczenia, a kod to osobna kolumna tekstowa",
     "Prowadzący: kod specjalizacji nie może być kluczem, bo klucz nic nie znaczy; kod jest tekstem, bo zaczyna się od "
     "zera. U nas kluczem jest zawsze numer `<Tabela>Key`, a kody urzędowe są osobnymi kolumnami tekstowymi z "
     "warunkiem na format: forma prawna (REGON, np. 117 i 099), województwo (TERYT, 02–32), miejscowość (TERYT SIMC), "
     "kraj, waluta, symbol PKD. Kod odpowiedzi HTTP też jest teraz tekstem.",
     ["LegalForm", "Region", "Location", "Country", "Currency", "PKDCode", "EndpointResponse"]),
    ("Rozmiar klucza wynika z tego, ile może być wierszy",
     "Prowadzący: INTEGER na specjalizacje to „4 miliardy specjalizacji – trochę dużo”. Przy każdej tabeli zapisaliśmy "
     "szacunek, ile wierszy może mieć, i z niego wynika liczba cyfr klucza: do 9 wariantów → `NUMBER(1)`, do 20 → "
     "`NUMBER(2)`, do 5 000 platform → `NUMBER(4)`, do miliarda dostaw → `NUMBER(10)`. Szacunek jest na każdej karcie "
     "tabeli.", []),
    ("Relacje jak w życiu: najpierw bez słów technicznych",
     "Prowadzący: lekarz może mieć kilka specjalizacji (chirurg i onkolog), więc kolumna „specjalizacja” w tabeli "
     "lekarza to błąd. U nas tak samo: platforma bywa kilku rodzajów naraz (OLX: ogłoszenia drobne i portal z ofertami), "
     "ogłoszenie szuka kilku poziomów (Mid/Senior) i daje kilka trybów pracy (hybrydowa albo zdalna) – to teraz tabele "
     "łączące zamiast jednej kolumny.",
     ["PlatformClassification", "PostingSeniority", "PostingWorkMode"]),
    ("Przypisanie w czasie: data od, data do i flaga 0/1 – nic nie usuwamy",
     "Prowadzący: lekarz zmienia kliniki; usunięcie rekordu znaczyłoby, że „tego nie było”, więc są daty początku i końca "
     "oraz flaga – aktualne może być tylko jedno. Dodaliśmy flagę i datę końca wszędzie, gdzie coś się zmienia: domeny i "
     "rynki platformy, umowy, wersje API, wersje konta, działalności firmy, powiązania kont, agencje, widełki, wersje "
     "treści, członkostwo w rodzinach, wersje metod i reguł, publikacje wyniku, role. Baza pilnuje „jednego aktualnego” "
     "indeksem unikalnym warunkowym.",
     ["PartnerAgreement", "PlatformDomain", "PlatformMarket", "EmployerPKD", "AccountEmployerLink", "AgencyClient",
      "PostingSalary", "FamilyMember", "PublishedScore", "UserRole"]),
    ("Flaga to 0 albo 1",
     "Wszystkie flagi są teraz liczbą `NUMBER(1)` z warunkiem `IN (0, 1)`: 1 = tak, 0 = nie (wcześniej T/N).", []),
    ("Para ma własny klucz, gdy coś się do niej odwołuje",
     "Prowadzący: wizyta jest u lekarza w konkretnej klinice, więc tabela lekarz–klinika ma własny klucz. U nas tak samo: "
     "przypomnienie dotyczy aplikacji (para kandydat – ogłoszenie), a dowód – powiązania (para konto – firma).",
     ["Reminder", "Application", "LinkEvidence", "AccountEmployerLink"]),
    ("Wartość wybierana z listy, a nie wpisywana",
     "Prowadzący: rola wpisywana z palca daje dwie „pielęgniarki” przez literówkę – rolę się wybiera. Zamieniliśmy na "
     "słowniki wszystko, co było wpisywanym tekstem o powtarzalnych wartościach: jednostkę sygnału, województwo, wersję "
     "klasyfikacji PKD, nazwę metody podobieństwa i wersję reguł oceny.",
     ["MeasureUnit", "Region", "PKDClassification", "SimilarityMethod", "VerdictRuleSet"]),
    ("Użytkownicy i role",
     "Prowadzący poprawiał tabelę użytkowników z rolą wpisywaną tekstem. Dodaliśmy organizm 19: konta użytkowników, role "
     "z listy, role przypisane w czasie (jedna osoba ma kilka ról) i przedstawicieli firm. Decyzje moderatorów mają teraz "
     "autora.", ["SystemUser", "Role", "UserRole", "EmployerRepresentative", "AlertStatusChange"]),
    ("Spójne nazewnictwo",
     "Wszystkie tabele po angielsku, w liczbie pojedynczej (nie „pacjenci” obok „lekarz”), klucze z końcówką Key.", []),
]

KONWENCJE = [
    "Tabele po angielsku w PascalCase, w liczbie pojedynczej; w bazie z przedrostkiem organizmu, np. "
    "`ORG01_SourcePlatform`.",
    "Klucz główny `<Tabela>Key NUMBER(n)` bez znaczenia; n = liczba cyfr szacowanej największej liczby wierszy (do 20 → "
    "`NUMBER(2)`, do 5 000 → `NUMBER(4)`). Klucz obcy nazywa się jak klucz, do którego prowadzi; wyjątek: kilka kluczy "
    "do tej samej tabeli, np. `AgencyEmployerKey` i `ClientEmployerKey`.",
    "Kody urzędowe (kraj, waluta, forma prawna, TERYT, PKD, kod HTTP) to osobne kolumny `CHAR`/`VARCHAR2` z CHECK "
    "`REGEXP_LIKE` na format – nigdy klucz.",
    "Słowniki: `<Tabela>Name` z UNIQUE i wiersze startowe (INSERT w skrypcie organizmu).",
    "Flagi `NUMBER(1)` z CHECK `IN (0, 1)`.",
    "Zmiany w czasie: `ValidFrom`, `ValidTo`, `IsCurrent`; CHECK `ValidTo >= ValidFrom` i `IsCurrent = 1 OR ValidTo IS NOT "
    "NULL`; „jeden aktualny” – unikalny indeks funkcyjny `…_UX` na `CASE WHEN IsCurrent = 1 THEN … END`.",
    "Nazwy ograniczeń: nazwa tabeli w bazie i końcówka `_PK`, `_UN`, `_CK`, `_FK`, `_UX`.",
    "Relacje: N:1 – wiele wierszy tej tabeli wskazuje jeden wiersz tabeli nadrzędnej; 1:1 – klucz obcy z UNIQUE; "
    "M:N – przez tabelę łączącą albo przypisanie w czasie.",
    "Oracle AI Database 26ai (Autonomous Database, schemat GHOSTJOB); skrypty w `sql/organizmy/`.",
]

# Decyzje wspólne dla wszystkich organizmów: (decyzja, skutek).
WSPOLNE = [
    ("Organizm 1 połączony z dawnych 1–3, pozostałe na razie osobne (klucze między nimi czekają w pliku 99)",
     "źródło danych działa jako całość z kluczami obcymi; pozostałe organizmy da się założyć, poprawić i usunąć osobno, "
     "a spójności między nimi baza pilnuje dopiero po uruchomieniu pliku 99."),
    ("Klucze bez znaczenia, rozmiar z szacunku liczby wierszy",
     "kod urzędowy może się zmienić albo powtórzyć, numer wiersza – nie; klucz obcy jest tak mały, jak się da, co ma "
     "znaczenie w tabelach z miliardami wierszy."),
    ("Warianty w słownikach zamiast tekstu w kolumnach",
     "nowy wariant to INSERT, bez zmiany schematu; wartość jest wybierana, więc nie ma literówek."),
    ("Zmiany w czasie przez nowe wiersze z `ValidFrom`/`ValidTo`/`IsCurrent` – bez usuwania",
     "pełny audyt i stan na dowolny dzień; „jeden aktualny” pilnuje unikalny indeks funkcyjny, a nienakładanie się "
     "okresów nadal wymaga wyzwalacza albo programu."),
    ("Klucze `NUMBER(n)` bez IDENTITY i sekwencji",
     "wiersze startowe mają klucze 1, 2, 3…; zanim programy zaczną dopisywać dane, trzeba dodać "
     "`GENERATED BY DEFAULT ON NULL AS IDENTITY` albo sekwencje (do decyzji)."),
    ("Flagi `NUMBER(1)` 0/1 zamiast typu BOOLEAN",
     "działa w każdej wersji Oracle i w starym Data Modeler; od wersji 23ai jest też BOOLEAN – do rozważenia."),
    ("Tabele „tylko do dopisywania” (zdarzenia, historia)",
     "schemat tego nie wymusza; wymusimy to kontami programów z uprawnieniami INSERT i SELECT bez UPDATE i DELETE "
     "(zasada „program = osoba = konto w bazie”)."),
    ("Indeksy tylko z kluczy głównych, unikalnych i warunkowych",
     "Oracle nie zakłada indeksów na kluczach obcych sam – przed testami wydajności trzeba je dodać, zwłaszcza tam, "
     "gdzie usuwamy albo zmieniamy wiersze nadrzędne."),
]

# Opisy organizmów. Klucz to numer organizmu.
#   o_czym   – akapity „o czym jest ten organizm”,
#   przyklad – ciąg dalszy wspólnego przykładu,
#   tabele   – (tabela, nazwa po polsku, opis) – każda tabela organizmu dokładnie raz; przykład na danych
#              do każdej tabeli jest w przyklady.py,
#   skrot    – jedno-dwa zdania dla technicznych,
#   decyzje  – (decyzja, skutek),
#   luki     – czego baza jeszcze nie pilnuje.
OPISY = {
    1: {
        "o_czym": [
            "Ghost-Job Scanner sam nie publikuje ogłoszeń o pracę. Wszystko, co wie – jakie firmy mają konta, jakie "
            "ogłoszenia publikują i kto na nie aplikował – dostaje od serwisów z ofertami pracy. Takie serwisy "
            "nazywamy platformami. Ten organizm opisuje całe źródło danych: platformy, kanały, którymi przekazują nam "
            "dane (API), wersje tych kanałów i dokładnie to, co każde zapytanie zwraca – pole po polu.",
            "To rozwinięty schemat z zajęć (SourcePlatform, PlatformAPI, APIType, DataFormat, PlatformAPIData). "
            "Wcześniej były to trzy osobne organizmy, teraz to jeden: wszystkie jego tabele są połączone kluczami. Od "
            "tego organizmu zaczyna się cała baza – przy każdej informacji w systemie można zapytać, z której platformy "
            "i którym zapytaniem przyszła, i odpowiedź zawsze prowadzi tutaj.",
        ],
        "przyklad": "Portal pracuj.pl jest platformą rodzaju „Portal z ofertami pracy”, działa pod adresami pracuj.pl "
                    "(główny) i it.pracuj.pl i publikuje oferty w Polsce. OLX jest dwóch rodzajów naraz: głównie „Serwis "
                    "ogłoszeń drobnych”, a dodatkowo „Portal z ofertami pracy” (dział OLX Praca), i działa w Polsce, "
                    "Rumunii i Portugalii. Załóżmy, że z pracuj.pl w październiku zaczęliśmy rozmowy, w listopadzie "
                    "ruszył pilotaż, a od stycznia umowa jest aktywna – to trzy wiersze w historii umów, z których "
                    "aktualny jest tylko ostatni. pracuj.pl udostępnia nam „Partner API” rodzaju REST: dane w formacie "
                    "JSON, logowanie kluczem API, to my pytamy o dane. API ma starszą wersję v1, wyłączaną 30 czerwca, i "
                    "wersję v2, z której korzystamy teraz. Wersja v2 ma endpoint GET /v2/jobs, który zwraca nowe "
                    "ogłoszenia: gdy wszystko jest w porządku, odpowiada kodem 200 i danymi w JSON, a gdy wyślemy za dużo "
                    "zapytań – kodem 429. W odpowiedzi 200 jest pole salary, a w nim pola from, to i currency. Pole "
                    "salary.from przypisujemy do naszej nazwy „Wynagrodzenie od” – tak samo jak pole wynagrodzenie_min "
                    "z innej platformy.",
        "tabele": [
            ("SourcePlatform", "Lista platform",
             "Jeden wiersz to jeden serwis, z którego bierzemy dane, np. pracuj.pl albo OLX. Zapisujemy nazwę platformy "
             "(nie może się powtórzyć), adres strony głównej i datę, od której zbieramy z niej dane. To ta sama tabela, "
             "którą prowadzący pokazał na zajęciach. Rodzaju platformy już tu nie ma – jest w osobnej tabeli, bo "
             "platforma bywa kilku rodzajów. Numer platformy ma do 4 cyfr, bo szacujemy do 5 000 platform: platformą "
             "jest też strona kariery pojedynczej firmy."),
            ("PlatformType", "Rodzaje platform",
             "Sześć rodzajów: portal z ofertami pracy, serwis ogłoszeń drobnych, agregator ofert (serwis, który zbiera "
             "oferty z innych serwisów), serwis społecznościowy, publiczny urząd pracy i strona kariery firmy. Rodzaje "
             "są w osobnej tabeli, żeby każdy był zawsze zapisany tak samo i żeby nowy rodzaj można było dopisać jednym "
             "wierszem, bez przebudowy bazy."),
            ("PlatformClassification", "Rodzaje każdej platformy",
             "Jedna platforma bywa kilku rodzajów naraz: OLX to serwis ogłoszeń drobnych i portal z ofertami pracy. Jedna "
             "kolumna „rodzaj” w tabeli platform by nie wystarczyła – tak jak jedna kolumna „specjalizacja” u lekarza, "
             "który ma ich kilka. Jeden wiersz to para „platforma – rodzaj”. Jeden rodzaj oznaczamy jako główny (flaga 1) "
             "i baza pilnuje, żeby główny był tylko jeden."),
            ("PlatformDomain", "Adresy stron platform",
             "Jedna platforma działa pod kilkoma adresami, np. pracuj.pl i it.pracuj.pl; jeden jest główny. Adres może "
             "przestać działać albo przejść do innej platformy, więc go nie usuwamy, tylko zamykamy: zapisujemy datę od, "
             "datę do i flagę „aktualny” (1 albo 0). Baza pilnuje, żeby ten sam adres był aktualny tylko w jednym "
             "wierszu i żeby platforma miała najwyżej jeden aktualny adres główny. Adresy są potrzebne, bo nasz widżet "
             "sprawdza, na jakiej stronie go otwarto – po adresie rozpoznajemy platformę."),
            ("Country", "Kraje",
             "Lista krajów z dwuliterowym kodem, np. PL – Polska, DE – Niemcy. Kod jest tekstem i nie jest numerem "
             "wiersza. Z tej samej listy korzystają organizm 6 (kraj, w którym firma jest zarejestrowana) i organizm 8 "
             "(kraj miejsca pracy)."),
            ("PlatformMarket", "Kraje, w których działa platforma",
             "Jedna platforma może działać w kilku krajach (OLX: Polska, Rumunia, Portugalia), a w jednym kraju działa "
             "wiele platform – to relacja wiele do wielu. Platforma może też z kraju wyjść, więc jeden wiersz to para "
             "„platforma – kraj” z datą od, datą do i flagą „działa tu teraz”. Para może być aktualna tylko raz."),
            ("PartnerAgreement", "Historia umów z platformą",
             "Platforma może być naszym partnerem albo tylko źródłem, które obserwujemy bez umowy. Umowa przechodzi przez "
             "etapy, dlatego nie ma tu jednej kolumny „czy partner”, tylko historia: każdy etap to nowy wiersz z datą "
             "„od kiedy”, „do kiedy” i flagą „aktualny”. Zapisujemy też datę podpisania i to, czy podpisano umowę "
             "powierzenia danych osobowych, której wymaga RODO. Baza nie przyjmie daty końca wcześniejszej niż data "
             "początku, wymaga daty końca w etapie, który już nie trwa, i pozwala tylko na jeden aktualny etap."),
            ("AgreementStatus", "Etapy umowy", "Pięć etapów: negocjacje, pilotaż, aktywna, zawieszona, rozwiązana."),
            ("PlatformAPI", "Kanały wymiany danych (API)",
             "Jeden wiersz to jedno API jednej platformy, np. „Partner API” pracuj.pl. Jedna platforma może mieć kilka "
             "API. Przy każdym zapisujemy: do której platformy należy, jakiego jest rodzaju, w jakim formacie domyślnie "
             "przesyła dane, jak się do niego logujemy, kto zaczyna przesyłanie, nazwę API i adres jego dokumentacji. To "
             "tabela ze schematu prowadzącego, uzupełniona o zabezpieczenie i kierunek."),
            ("APIType", "Rodzaje API",
             "Sześć rodzajów: REST, GraphQL i SOAP (trzy różne sposoby zadawania pytań programowi platformy), webhook "
             "(platforma sama wysyła nam powiadomienie, gdy coś się zmieni), eksport pliku (dostajemy gotowy plik z "
             "danymi) i kanał RSS (lista nowych ogłoszeń, którą można regularnie odczytywać)."),
            ("DataFormat", "Formaty danych",
             "Cztery formaty: JSON, XML, CSV i HTML – różne sposoby zapisu danych w tekście. Przy każdym jest jego "
             "oficjalne oznaczenie, tzw. typ MIME (np. application/json). W API zapisujemy format domyślny, a format "
             "konkretnej odpowiedzi – przy możliwej odpowiedzi endpointu."),
            ("AuthMethod", "Sposoby zabezpieczenia dostępu",
             "Sposób, w jaki nasz program udowadnia platformie, że wolno mu pobrać dane: klucz API (tajny ciąg znaków "
             "dołączany do zapytania), OAuth 2.0 (program najpierw dostaje tymczasowy klucz z osobnego serwera), "
             "certyfikat klienta (plik, który potwierdza tożsamość naszego serwera), podpis HMAC (każde zapytanie jest "
             "podpisane tajnym kluczem) albo brak zabezpieczenia. Samych kluczy i haseł nie zapisujemy w tej bazie."),
            ("APIDirection", "Kierunek przesyłania danych",
             "Dwa warianty: „my pobieramy dane” – nasz program sam pyta platformę, np. co godzinę – albo „platforma "
             "wysyła dane” – platforma sama przekazuje nam nowe dane, gdy się pojawią. Wariantów będzie najwyżej kilka, "
             "więc numer ma jedną cyfrę."),
            ("APIVersion", "Wersje API",
             "Platformy co jakiś czas wydają nową wersję API, a starą po pewnym czasie wyłączają. Jeden wiersz to jedna "
             "wersja, np. v2: zapisujemy jej oznaczenie, datę wprowadzenia, datę wyłączenia (jeśli platforma ją "
             "ogłosiła) i flagę „z tej wersji korzystamy teraz”. W jednym API tylko jedna wersja może mieć tę flagę, a "
             "dwie wersje nie mogą mieć tego samego oznaczenia. Wersja jest ważna, bo różne wersje mają różne endpointy."),
            ("APIEnvironment", "Środowiska wersji API",
             "Ta sama wersja API działa zwykle w dwóch miejscach: w środowisku testowym z danymi próbnymi i w "
             "produkcyjnym z prawdziwymi danymi. Jeden wiersz to jedno środowisko jednej wersji: zapisujemy adres "
             "bazowy (początek adresu wszystkich zapytań, np. https://api.platforma.example/v2) i limit, czyli ile "
             "zapytań na minutę platforma pozwala wysłać. Wersja może mieć tylko jedno środowisko danego rodzaju."),
            ("EnvironmentType", "Rodzaje środowisk", "Dwa warianty: testowe (sandbox) i produkcyjne."),
            ("APIEndpoint", "Endpointy",
             "Jeden wiersz to jeden endpoint w jednej wersji API. Zapisujemy ścieżkę (np. /v2/jobs), metodę HTTP, rodzaj "
             "zwracanych danych, to, czy wyniki są dzielone na strony (wtedy trzeba pobrać kolejne strony), i krótki "
             "opis. W jednej wersji API nie może być dwóch endpointów z tą samą ścieżką i metodą."),
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
             "przyjść np. w JSON i w XML). Kod zapisujemy jako tekst, bo to kod, a nie liczba do liczenia; baza sprawdza "
             "tylko, czy to trzy cyfry od 100 do 599. Zapisujemy też, czy to odpowiedź z błędem i kiedy się pojawia."),
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
        "skrot": "Połączone dawne ORG01–ORG03: SourcePlatform (PK NUMBER(4)) → PlatformAPI → APIVersion → APIEndpoint → "
                 "EndpointResponse → EndpointData, ze słownikami, rodzajami platform M:N, historią domen, rynków i umów "
                 "oraz modelem kanonicznym pól. Prowadzą do niego klucze z ORG04 (APIEndpoint), ORG05 i ORG13 "
                 "(SourcePlatform) oraz ORG06 i ORG08 (Country).",
        "decyzje": [
            ("Połączenie dawnych organizmów 1–3 w jeden (przedrostek `ORG01_`)",
             "klucze obce między platformą, API i endpointami są założone w bazie – schemat z zajęć działa jako całość; "
             "w pliku 99 zostały tylko klucze do innych organizmów."),
            ("Rodzaj platformy jako M:N (`PlatformClassification`) zamiast kolumny `SourcePlatform.PlatformTypeKey`",
             "platforma może mieć kilka rodzajów; jeden główny pilnuje indeks `CASE WHEN IsMainType = 1 THEN "
             "SourcePlatformKey END`."),
            ("Domeny, rynki i umowy z `ValidFrom`, `ValidTo` i `IsCurrent`",
             "nic nie usuwamy; „jeden aktualny” pilnują indeksy `…_UX`, a CHECK `IsCurrent = 1 OR ValidTo IS NOT NULL` "
             "wymusza datę końca w wierszu zamkniętym."),
            ("`APIVersion.IsInUse` z indeksem „jedna na API”",
             "program wie, z której wersji korzysta; przejście v1 → v2 to zmiana dwóch flag, bez kasowania wersji."),
            ("`HTTPStatusCode CHAR(3)` z `REGEXP_LIKE` zamiast `NUMBER(3)`",
             "kod jest tekstem, a format pilnuje CHECK; grupy odpowiedzi (4xx) przez `SUBSTR(HTTPStatusCode, 1, 1)`."),
            ("`ParentEndpointDataKey` – klucz EndpointData do samej siebie",
             "drzewo pól JSON/XML dowolnej głębokości; hierarchię czytamy przez `CONNECT BY` albo rekurencyjne `WITH`, a "
             "`DataPath` (UQ w odpowiedzi) pozwala znaleźć pole bez rekurencji."),
            ("Model kanoniczny: `CanonicalField` + `FieldMapping` (EndpointData M:N CanonicalField z regułą)",
             "dane z różnych platform są porównywalne; `TransformationRule` wykonuje program, baza go nie sprawdza."),
            ("Rozmiary kluczy z szacunku liczby wierszy",
             "od `NUMBER(1)` (APIDirection, do 9 wariantów) do `NUMBER(8)` (EndpointData i FieldMapping, do 30 mln "
             "wierszy)."),
        ],
        "luki": [
            "Okresy tej samej domeny, rynku czy umowy nie powinny na siebie nachodzić – indeks pilnuje tylko „jednego "
            "aktualnego”, nienakładanie się dat wymaga wyzwalacza albo programu.",
            "Pole nadrzędne powinno należeć do tej samej odpowiedzi, a drzewo pól nie może mieć cykli – wymaga "
            "wyzwalacza.",
            "Przypisanie pola do naszej nazwy powinno łączyć dane tego samego rodzaju (DataSubject endpointu = "
            "DataSubject nazwy) – nie jest wymuszone.",
            "`VersionLabel` to tekst (v1, v2, v10) – kolejność wersji brać z `ReleaseDate`.",
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
             "Jeden wiersz to jedno przyjęcie danych jednym endpointem (endpoint z organizmu 1). Zapisujemy sposób "
             "dostawy, wynik, czas rozpoczęcia i zakończenia oraz to, ile rekordów przyszło i ile przyjęliśmy. Wiersz "
             "powstaje na początku dostawy i jest uzupełniany, gdy dostawa się kończy. Baza pilnuje dwóch rzeczy: "
             "przyjętych rekordów nie może być więcej niż otrzymanych, a koniec nie może być wcześniej niż początek. "
             "Dostaw może być nawet miliard, więc numer ma 10 cyfr."),
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
        "skrot": "Warstwa pochodzenia danych: DataDelivery (N:1 APIEndpoint z ORG01) 1:N RawRecord i 1:N DeliveryError. "
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
            ("Klucze `NUMBER(10)` i `NUMBER(12)`",
             "dostaw może być do miliarda, surowych rekordów do 100 mld – to największe tabele modelu."),
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
            "Zapisujemy też każdą zmianę danych konta: nazwy, NIP-u, strony, stanu konta. Firma może zmienić nazwę konta, "
            "żeby kandydaci nie kojarzyli jej ze złymi opiniami, a platforma może konto zawiesić i przywrócić – stare "
            "dane zostają w historii.",
        ],
        "przyklad": "Na pracuj.pl ogłoszenia firmy Przykład Logistyka publikuje konto numer 77120, prowadzone przez "
                    "firmę. Pierwszy raz dostaliśmy to konto 3 listopada. Pierwsza wersja jego danych: nazwa „Przykład "
                    "Logistyka”, NIP 1234563218, strona przyklad-logistyka.pl, stan „Aktywne”, platforma nie sprawdzała "
                    "firmy. 20 listopada właściciel zmienia nazwę na „PL Logistics Kraków”. Pierwsza wersja dostaje datę "
                    "końca i flagę 0, a druga wersja – z nową nazwą – flagę 1. Na OLX to samo ogłoszenie publikuje inne "
                    "konto, „Praca od zaraz – Kraków”, prowadzone przez agencję rekrutacyjną – dla nas to osobne konto.",
        "tabele": [
            ("EmployerAccount", "Konta na platformach",
             "Jeden wiersz to jedno konto na jednej platformie (platforma z organizmu 1). Zapisujemy tylko to, co się nie "
             "zmienia: numer konta w serwisie, kto prowadzi konto i kiedy pierwszy raz je dostaliśmy. Numer konta jest "
             "unikalny tylko w obrębie jednej platformy – na dwóch platformach mogą być konta o tym samym numerze – "
             "dlatego baza pilnuje, żeby nie powtórzyła się para „platforma + numer konta”."),
            ("AccountType", "Rodzaje kont",
             "Kto prowadzi konto: firma, agencja rekrutacyjna, osoba prywatna albo instytucja publiczna."),
            ("AccountStatus", "Stany konta",
             "Trzy warianty: aktywne, zawieszone przez platformę, usunięte. Stan jest zapisany w wersji danych konta, "
             "bo platforma może konto zawiesić i potem przywrócić – stary stan zostaje w historii."),
            ("EmployerAccountVersion", "Historia danych konta",
             "Każda zmiana nazwy, NIP-u, strony www, stanu konta albo tego, czy platforma sprawdziła firmę, to nowy wiersz "
             "z datą „od kiedy”, „do kiedy” i flagą „aktualna”. Baza pilnuje, żeby konto miało tylko jedną aktualną "
             "wersję, a wersja zamknięta miała datę końca. NIP zapisujemy dokładnie tak, jak wpisał go właściciel konta "
             "– nikt go jeszcze nie sprawdził. Przy wersji zapisujemy też surowy rekord z organizmu 4, z którego ją "
             "odczytaliśmy."),
        ],
        "skrot": "EmployerAccount (N:1 SourcePlatform z ORG01) jako trwały identyfikator konta i EmployerAccountVersion "
                 "jako historia wszystkich zmiennych atrybutów (nazwa, NIP, www, stan, weryfikacja) z flagą aktualnej "
                 "wersji i odnośnikiem do RawRecord (ORG04). Konto wskazują ORG07 i ORG08.",
        "decyzje": [
            ("Klucz naturalny UQ(SourcePlatformKey, ExternalAccountId)",
             "powtórna dostawa tego samego konta trafia w istniejący wiersz (`MERGE` po kluczu naturalnym)."),
            ("Stan konta i `IsVerifiedByPlatform` w wersji, nie w koncie",
             "historia zawieszeń i przywróceń zostaje; konto zawieszone i przywrócone to trzy wersje."),
            ("`IsCurrent` z indeksem „jedna aktualna wersja na konto”",
             "aktualne dane to `IsCurrent = 1`, bez szukania najnowszej daty; widok „konto + aktualna wersja” to proste "
             "złączenie."),
            ("`DeclaredNIP` jako niesprawdzony tekst bez CHECK formatu",
             "błędne wpisy zostają (same są sygnałem); sprawdzenie i dopasowanie do firmy są w ORG06 i ORG07."),
            ("`RawRecordKey` w wersji (opcjonalny)",
             "każdą wersję da się odtworzyć ze źródła; wersje wpisane ręcznie mają NULL."),
        ],
        "luki": [
            "Okresy wersji jednego konta nie powinny na siebie nachodzić – jedną aktualną wymusza indeks, nienakładanie "
            "się dat wymaga wyzwalacza.",
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
        "przyklad": "Firma „Przykład Logistyka sp. z o.o.” to spółka z ograniczoną odpowiedzialnością (kod formy "
                    "prawnej w rejestrze REGON: 117) zarejestrowana w Polsce 12 marca 2019 roku, o statusie „Aktywna”. "
                    "Ma trzy numery: NIP, REGON i KRS – każdy to osobny wiersz na liście numerów. Według klasyfikacji PKD "
                    "2007 prowadzi dwa rodzaje działalności: główną 52.10.B (magazynowanie i przechowywanie towarów) i "
                    "dodatkową 49.41.Z (transport drogowy towarów). 5 listopada sprawdziliśmy ją w KRS: rejestr ją "
                    "znalazł i podał status „Aktywna”. 5 grudnia KRS podał już „W likwidacji”. To nowy wiersz w "
                    "sprawdzeniach, a status firmy zmieniamy na „W likwidacji”. Agencja „Kadry Przykład sp. z o.o.” to w "
                    "bazie osobna firma, z główną działalnością 78.10.Z (wyszukiwanie miejsc pracy i pozyskiwanie "
                    "pracowników).",
        "tabele": [
            ("Employer", "Firmy",
             "Jeden wiersz to jeden prawdziwy podmiot prawny, niezależnie od tego, ile ma kont na platformach. "
             "Zapisujemy nazwę urzędową, formę prawną, kraj rejestracji (z listy krajów w organizmie 1), aktualny status "
             "i datę wpisu do rejestru. Dla tego wiersza liczymy Trust Score (organizmy 17 i 18)."),
            ("LegalForm", "Formy prawne",
             "Pełna nazwa, skrót i urzędowy kod z rejestru REGON, np. „Spółka z ograniczoną odpowiedzialnością” – „sp. z "
             "o.o.” – 117. Kod jest tekstem, bo zaczyna się od zera (019, 048, 099) – zapisany jako liczba straciłby to "
             "zero – i nie jest numerem wiersza: numerem zostaje LegalFormKey, który nic nie znaczy. Tak radził "
             "prowadzący przy kodach specjalizacji lekarskich. Na liście są też spółka akcyjna, jednoosobowa "
             "działalność gospodarcza, spółka cywilna, spółka jawna, fundacja, stowarzyszenie, jednostka sektora "
             "publicznego i firma zagraniczna (dwie ostatnie bez jednego kodu)."),
            ("EmployerStatus", "Statusy firmy",
             "Sześć wariantów: aktywna, zawieszona, w likwidacji, w upadłości, wykreślona i nieznaleziona w rejestrze."),
            ("EmployerIdentifier", "Numery identyfikacyjne firm",
             "Firma ma zwykle kilka numerów naraz (NIP, REGON, KRS), a firma zagraniczna – zupełnie inne. Dlatego numery "
             "nie są trzema kolumnami w tabeli firm, tylko osobnymi wierszami: jeden wiersz to jeden numer jednego "
             "rodzaju. Numer zapisujemy jako tekst, bo może zaczynać się od zera. Zapisujemy też, czy numer przeszedł "
             "kontrolę sumy kontrolnej – ostatnia cyfra NIP-u jest wyliczana z pozostałych, więc można sprawdzić, czy "
             "ktoś nie pomylił się przy wpisywaniu. Ten sam numer tego samego rodzaju nie może należeć do dwóch firm."),
            ("IdentifierType", "Rodzaje numerów",
             "Pięć wariantów z opisem, jak wygląda poprawny numer: NIP (10 cyfr), REGON (9 albo 14 cyfr), KRS "
             "(10 cyfr), numer VAT UE (kod kraju i numer) i zagraniczny numer rejestrowy."),
            ("EmployerPKD", "Działalności firm",
             "Jedna firma prowadzi kilka rodzajów działalności, a ten sam rodzaj prowadzi wiele firm, więc to osobna "
             "tabela par „firma – kod PKD”. Działalności firmy zmieniają się w czasie, dlatego para ma datę od, datę do i "
             "flagę „prowadzona teraz”. Baza pilnuje, żeby ta sama działalność nie była aktualna dwa razy i żeby firma "
             "miała najwyżej jedną aktualną działalność główną."),
            ("PKDCode", "Kody PKD",
             "Kody Polskiej Klasyfikacji Działalności z nazwą, np. 52.10.B – magazynowanie i przechowywanie pozostałych "
             "towarów. Symbol jest tekstem w formacie NN.NN.X, a baza sprawdza ten format. Przy kodzie zapisujemy, z "
             "której wersji klasyfikacji pochodzi. Ten sam symbol może być w dwóch wersjach klasyfikacji, ale nie dwa "
             "razy w jednej."),
            ("PKDClassification", "Wersje klasyfikacji PKD",
             "Dwie wersje: PKD 2007 (obowiązuje od 2008 roku) i PKD 2025 (od 2025 roku). Wersję wybieramy z tej listy, "
             "zamiast wpisywać tekst „PKD 2007” przy każdym kodzie – inaczej ktoś wpisałby „PKD2007” i baza miałaby "
             "dwie różne wersje tej samej klasyfikacji."),
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
                 "przypisanie w czasie, historia sprawdzeń w rejestrach, kody urzędowe jako tekst; Country z ORG01. "
                 "Employer ma najwięcej przychodzących kluczy w modelu (ORG07, ORG11, ORG12, ORG16–ORG19).",
        "decyzje": [
            ("`LegalFormCode CHAR(3)` (kod REGON) obok `LegalFormKey`",
             "kod urzędowy z zerem na początku jest tekstem z CHECK `REGEXP_LIKE(LegalFormCode, '^[0-9]{3}$')`; klucz "
             "zostaje bez znaczenia, więc zmiana kodów przez GUS nie zmienia kluczy w innych tabelach."),
            ("Identyfikatory w `EmployerIdentifier` z UQ(IdentifierTypeKey, IdentifierValue) zamiast kolumn NIP, REGON i "
             "KRS",
             "firmy zagraniczne i nowe rodzaje numerów bez zmiany schematu; ten sam numer nie trafi do dwóch firm, więc "
             "zdublowane firmy wychodzą przy imporcie."),
            ("Status bieżący w `Employer.EmployerStatusKey`, historia w `RegistryCheck.ReportedStatusKey`",
             "szybki odczyt statusu bez agregacji, ale ryzyko rozjazdu z ostatnim sprawdzeniem (pytanie do "
             "prowadzącego); usunie je wyzwalacz po INSERT do RegistryCheck albo widok zamiast kolumny."),
            ("`PKDClassification` jako słownik i `EmployerPKD` jako przypisanie w czasie",
             "przejście na PKD 2025 nie nadpisuje historii; jedną aktualną działalność główną pilnuje indeks `CASE WHEN "
             "IsCurrent = 1 AND IsMainActivity = 1 THEN EmployerKey END`."),
            ("`PublicRegistry.DailyQueryLimit` i `IdentifierTypeKey`",
             "program sprawdzający wie, po jakim numerze pytać rejestr i ile zapytań dziennie mu wolno."),
            ("`IsChecksumValid` jako flaga ustalana przy imporcie",
             "błędny numer zostaje zapisany (sam jest sygnałem), a łatwo go odfiltrować."),
        ],
        "luki": [
            "Zgodność `Employer.EmployerStatusKey` z ostatnim sprawdzeniem w RegistryCheck – wyzwalacz albo widok.",
            "Rodzaj numeru dozwolony dla kraju firmy (np. NIP tylko w Polsce) – nie jest sprawdzany.",
            "Przejście kodów PKD 2007 → PKD 2025 wymagałoby osobnej tabeli odpowiedników (na razie brak).",
        ],
    },
    7: {
        "o_czym": [
            "Ta sama firma może mieć konta na kilku platformach – na pracuj.pl, na OLX i na swojej stronie kariery. Ten "
            "organizm zapisuje, które konto należy do której firmy z rejestru. Takie powiązanie to twierdzenie: może być "
            "pewne (ten sam NIP) albo tylko prawdopodobne (podobna nazwa), a czasem okazuje się błędne i trzeba je "
            "cofnąć. Dlatego przy powiązaniu zapisujemy, jak je ustaliliśmy, jak bardzo jesteśmy pewni, na jakich "
            "dowodach się opiera, kiedy obowiązywało i kto je zmieniał.",
            "Dzięki powiązaniom firma ma jeden Trust Score, choć publikuje z wielu kont. Tutaj zapisujemy też, dla "
            "jakich firm rekrutuje agencja rekrutacyjna.",
        ],
        "przyklad": "Konto 77120 z pracuj.pl podaje NIP 1234563218 i stronę przyklad-logistyka.pl. Ten sam NIP ma w "
                    "rejestrze firma „Przykład Logistyka sp. z o.o.”. Łączymy konto z firmą sposobem „Ten sam NIP”, z "
                    "pewnością 0,98, i zapisujemy dwa dowody: zgodny NIP i tę samą domenę strony www. Konto „Praca od "
                    "zaraz – Kraków” z OLX też podaje ten NIP, więc najpierw łączymy je z tą samą firmą. Moderator "
                    "zauważa jednak, że to konto agencji „Kadry Przykład sp. z o.o.”, która tylko rekrutuje dla tej "
                    "firmy. Stare powiązanie dostaje datę rozłączenia i flagę 0, powstaje nowe – konta z agencją – z "
                    "flagą 1, a w historii zmian zapisujemy „Przeniesiono do innej firmy”, powód i to, który moderator to "
                    "zrobił. W tabeli agencji i klientów zapisujemy, że Kadry Przykład rekrutuje dla Przykład Logistyka "
                    "od 1 listopada.",
        "tabele": [
            ("AccountEmployerLink", "Powiązania kont z firmami",
             "Jeden wiersz to jedno twierdzenie „to konto należy do tej firmy” – konto z organizmu 5, firma z "
             "organizmu 6. Zapisujemy sposób dopasowania, pewność od 0 do 1, kiedy połączyliśmy, kiedy cofnęliśmy i "
             "flagę „obowiązuje”. Cofniętego powiązania nie usuwamy. Baza pilnuje, żeby pewność była w zakresie 0–1, "
             "data cofnięcia nie była wcześniejsza niż data połączenia i żeby konto miało w danej chwili najwyżej jedno "
             "obowiązujące powiązanie."),
            ("MatchMethod", "Sposoby dopasowania",
             "Cztery warianty: ten sam NIP (pewne), podobna nazwa i ta sama strona www (prawdopodobne), decyzja "
             "moderatora i potwierdzenie przez samą firmę."),
            ("LinkEvidence", "Dowody powiązania",
             "Jedno powiązanie może opierać się na kilku dowodach. Jeden wiersz to jeden dowód: jego rodzaj i treść, "
             "np. „ten sam NIP w koncie i w KRS”. Dowód wskazuje powiązanie – czyli parę konto i firma – a nie samo "
             "konto. Dzięki temu moderator widzi, dlaczego system tak zdecydował."),
            ("EvidenceType", "Rodzaje dowodów",
             "Pięć wariantów: zgodny NIP, podobna nazwa, ta sama domena strony www, ten sam adres i dokument przesłany "
             "przez firmę."),
            ("LinkChange", "Historia zmian powiązań",
             "Każda zmiana powiązania to nowy wiersz: co zmieniono, kiedy, dlaczego i kto to zrobił (użytkownik z "
             "organizmu 19; puste, gdy zmienił program). Nic nie znika – nawet błędne połączenie zostaje w historii "
             "razem z datą i powodem cofnięcia."),
            ("LinkChangeType", "Rodzaje zmian",
             "Cztery warianty: połączono, rozłączono, przeniesiono do innej firmy i zmieniono pewność."),
            ("AgencyClient", "Agencje i ich klienci",
             "Agencja rekrutacyjna publikuje ogłoszenia dla wielu firm. Agencja jest w bazie zwykłą firmą z organizmu 6, "
             "więc ta tabela łączy dwie firmy ze sobą: jeden wiersz mówi „agencja A rekrutuje dla firmy B od … do …”, z "
             "flagą „współpraca trwa”. Baza nie pozwoli zapisać firmy jako agencji samej siebie, daty końca wcześniejszej "
             "niż data początku ani dwóch trwających współprac tej samej pary."),
        ],
        "skrot": "AccountEmployerLink jako przypisanie w czasie (EmployerAccount z ORG05 ↔ Employer z ORG06) z pewnością, "
                 "dowodami 1:N i dziennikiem zmian z autorem (SystemUser z ORG19); AgencyClient jako relacja "
                 "Employer–Employer w czasie (dwa klucze do tej samej tabeli).",
        "decyzje": [
            ("Powiązanie z `MatchConfidence` (0–1) i `MatchMethod`",
             "przechowujemy też powiązania niepewne; Trust Score może brać pod uwagę tylko powiązania powyżej progu "
             "pewności."),
            ("Cofnięcie przez `UnlinkedAt` i `IsActive = 0` zamiast DELETE",
             "historia powiązań zostaje; jedno obowiązujące powiązanie na konto pilnuje indeks `CASE WHEN IsActive = 1 "
             "THEN EmployerAccountKey END`."),
            ("`LinkChange` jako osobny dziennik z `SystemUserKey`",
             "audyt decyzji z autorem; „przeniesienie” to dwa wiersze AccountEmployerLink (stary z `IsActive = 0` i "
             "nowy) plus wpis w LinkChange."),
            ("`AgencyClient`: AgencyEmployerKey i ClientEmployerKey → Employer, CHECK agencja <> klient, flaga `IsActive`",
             "agencja to zwykły Employer, a jej rola wynika z relacji, nie z flagi; ta sama para może wracać w "
             "kolejnych okresach, ale trwa najwyżej jedna współpraca naraz."),
            ("`LinkEvidence` jako dane",
             "pewność można przeliczyć, gdy zmienią się reguły dopasowania."),
        ],
        "luki": [
            "Okresy tej samej pary agencja–klient nie powinny na siebie nachodzić – wyzwalacz (jedną trwającą wymusza "
            "indeks).",
            "Klucz do SystemUser (ORG19) jest w pliku 99 – do czasu połączenia organizmów baza nie sprawdza, czy autor "
            "istnieje.",
        ],
    },
    8: {
        "o_czym": [
            "Ten organizm opisuje samo ogłoszenie o pracę: które konto je opublikowało, kiedy, jaki ma tytuł i stan, "
            "jakich poziomów stanowiska dotyczy, w jakich trybach się pracuje, ilu osób firma szuka i w których "
            "miejscowościach.",
            "Samo ogłoszenie nie mówi jeszcze, czy praca naprawdę istnieje. Zapisujemy je dokładnie, żeby później "
            "porównywać kolejne publikacje tego samego stanowiska (organizmy 11 i 12) i zestawiać je ze zgłoszeniami "
            "kandydatów (organizmy 13–16). Warunki zatrudnienia i wymagania są w osobnych organizmach 9 i 10.",
        ],
        "przyklad": "Konto 77120 z pracuj.pl publikuje 3 listopada ogłoszenie numer 1004567 „Magazynier/ka – praca od "
                    "zaraz”. Ogłoszenie jest aktywne, firma szuka 3 osób, a ogłoszenie ma wygasnąć 3 grudnia. Poziomu "
                    "stanowiska firma nie podała, więc tabela poziomów nie ma dla niego wierszy. Tryb pracy to "
                    "„Stacjonarna” – jeden wiersz w trybach ogłoszenia. Miejsca pracy to Kraków (główne; województwo "
                    "małopolskie, kod TERYT 12) i Wieliczka. Przy ogłoszeniu zapisujemy surowy rekord z dostawy z "
                    "3 listopada, z którego je odczytaliśmy.",
        "tabele": [
            ("JobPosting", "Ogłoszenia",
             "Jeden wiersz to jedno ogłoszenie opublikowane przez jedno konto (konto z organizmu 5). Zapisujemy numer "
             "ogłoszenia w serwisie, aktualny tytuł, stan, liczbę poszukiwanych osób, datę pierwszej publikacji, "
             "planowaną datę końca i surowy rekord, z którego powstało (organizm 4). Poziomów i trybów pracy tu nie ma, "
             "bo jedno ogłoszenie ma ich kilka – są w osobnych tabelach. Baza pilnuje, żeby data końca nie była przed "
             "datą publikacji, a liczba osób była większa od zera."),
            ("PostingStatus", "Stany ogłoszenia",
             "Pięć wariantów: aktywne, wygasłe, zamknięte przed terminem, usunięte przez platformę i wstrzymane."),
            ("SeniorityLevel", "Poziomy stanowiska",
             "Sześć poziomów, od stażysty, przez juniora, mida i seniora, do eksperta i kierownika. Każdy poziom ma numer "
             "kolejności (1 = najniższy). Dzięki temu da się wykryć ten sam etat ogłaszany raz jako Senior, a raz jako "
             "Mid."),
            ("PostingSeniority", "Poziomy w ogłoszeniu",
             "Ogłoszenie często szuka kilku poziomów naraz, np. „Mid/Senior”, a jednego poziomu szukają tysiące ogłoszeń "
             "– to relacja wiele do wielu, jak lekarz z kilkoma specjalizacjami. Jeden wiersz to para „ogłoszenie – "
             "poziom”. Gdy firma nie podała poziomu, ogłoszenie nie ma tu wierszy."),
            ("WorkMode", "Tryby pracy", "Cztery warianty: stacjonarna, hybrydowa, zdalna i w terenie."),
            ("PostingWorkMode", "Tryby pracy w ogłoszeniu",
             "Ogłoszenie daje często kilka trybów do wyboru, np. „hybrydowa albo zdalna”. Jeden wiersz to para "
             "„ogłoszenie – tryb pracy”."),
            ("PostingLocation", "Miejsca pracy w ogłoszeniu",
             "Jedno ogłoszenie może dotyczyć kilku miejscowości, a w jednej miejscowości są tysiące ogłoszeń. Dlatego "
             "to osobna tabela par „ogłoszenie – miejscowość”. Jedną miejscowość oznaczamy jako główne miejsce pracy, a "
             "baza pilnuje, żeby główna była tylko jedna."),
            ("Location", "Miejscowości",
             "Miejscowość z krajem (z organizmu 1) i województwem albo regionem, jeśli je znamy. Polska miejscowość ma "
             "urzędowy identyfikator z rejestru TERYT (SIMC), np. 0950463 dla Krakowa – tekst, bo zaczyna się od zera. "
             "Identyfikator nie może się powtórzyć, dzięki czemu dwie wsie o tej samej nazwie w jednym województwie "
             "też się zmieszczą."),
            ("Region", "Województwa i regiony",
             "Lista województw z kodem TERYT, np. 12 – małopolskie, 14 – mazowieckie; za granicą regiony bez kodu. "
             "Województwo wybieramy z listy, a nie wpisujemy – inaczej „Małopolska” i „małopolskie” byłyby dwoma "
             "różnymi regionami. W jednym kraju nazwa i kod nie mogą się powtórzyć."),
        ],
        "skrot": "JobPosting (N:1 EmployerAccount z ORG05, opcjonalnie RawRecord z ORG04) z bieżącymi atrybutami "
                 "ogłoszenia; poziomy, tryby pracy i lokalizacje jako M:N; Location z kodem TERYT SIMC i Region z kodem "
                 "województwa (oba N:1 Country z ORG01). JobPosting to najczęściej wskazywana tabela modelu "
                 "(ORG09–ORG14).",
        "decyzje": [
            ("Ogłoszenie przypięte do konta, nie do firmy",
             "firmę ustala się przez AccountEmployerLink (ORG07), więc przeniesienie konta do innej firmy nie wymaga "
             "zmian w ogłoszeniach."),
            ("Poziom i tryb pracy jako M:N (`PostingSeniority`, `PostingWorkMode`) zamiast kolumn w JobPosting",
             "„Mid/Senior” i „hybrydowa albo zdalna” zapisujemy bez łączenia tekstów; brak informacji to brak wierszy, "
             "a nie NULL."),
            ("`SIMCCode CHAR(7)` UNIQUE i `RegionCode CHAR(2)` z REGEXP CHECK",
             "jednoznaczne miejscowości bez sztucznego UQ na nazwie; kody urzędowe są tekstem i nie są kluczem."),
            ("`SeniorityLevel.SeniorityRank`",
             "poziomy porównujemy liczbowo; to podstawa licznika `SeniorityVariantCount` w ORG12."),
            ("`PostingTitle` przechowuje tylko bieżący tytuł; wersje treści i tytułów są w ORG11",
             "tytuł jest zapisany dwa razy (tu i w `PostingVersion.VersionTitle`) – pytanie do prowadzącego."),
        ],
        "luki": [
            "`ExternalPostingId` jest unikalny w obrębie konta, a nie całej platformy – pełna unikalność wymagałaby "
            "SourcePlatformKey w JobPosting albo wyzwalacza.",
            "Region miejscowości powinien leżeć w tym samym kraju co miejscowość – wymaga wyzwalacza.",
            "`PostingStatusKey` powinien wynikać z ostatniego zdarzenia w ORG11 – program musi aktualizować oba miejsca.",
        ],
    },
    9: {
        "o_czym": [
            "Warunki zatrudnienia to obietnica, którą firma składa w ogłoszeniu: na jakiej umowie, za ile i z jakimi "
            "dodatkami. Ten organizm zapisuje te informacje osobno dla każdego ogłoszenia, razem z historią zmian "
            "widełek.",
            "Warunki są ważne dla oceny firmy. Brak widełek wynagrodzenia albo ich zmiana – między kolejnymi publikacjami "
            "albo przy edycji tego samego ogłoszenia – to sygnały, które liczymy w organizmie 17.",
        ],
        "przyklad": "Ogłoszenie „Magazynier/ka” na pracuj.pl daje do wyboru dwie umowy: umowę o pracę za 5 200–6 000 zł "
                    "brutto miesięcznie albo umowę zlecenie za 32–36 zł brutto za godzinę. To dwa wiersze – po jednym "
                    "na każdą umowę – oba z flagą „aktualne”. 24 listopada firma obniża widełki umowy o pracę do "
                    "4 800–5 500 zł: stary wiersz dostaje datę końca i flagę 0, a nowy – flagę 1. Benefity to prywatna "
                    "opieka medyczna (grupa „Zdrowie”) i karta sportowa (grupa „Sport i rekreacja”). Ogłoszenie agencji "
                    "na OLX podaje tylko „umowa o pracę”, bez kwoty – zapisujemy umowę z pustymi kwotami, bo brak "
                    "widełek też jest informacją.",
        "tabele": [
            ("PostingSalary", "Umowy i wynagrodzenia w ogłoszeniu",
             "Jeden wiersz to jeden rodzaj umowy w jednym ogłoszeniu (ogłoszenie z organizmu 8) z widełkami: kwota od, "
             "kwota do, waluta, okres (np. miesięcznie), to, czy kwota jest brutto, oraz daty od–do i flaga "
             "„aktualne”. Jedno ogłoszenie może mieć kilka umów, ale każdy rodzaj umowy jest aktualny tylko raz. Kwoty "
             "mogą być puste, gdy firma nie podała widełek. Baza pilnuje, żeby kwoty nie były ujemne, kwota „od” nie "
             "była większa niż „do”, a podana kwota miała walutę i okres."),
            ("ContractType", "Rodzaje umów",
             "Sześć wariantów: umowa o pracę, kontrakt B2B, umowa zlecenie, umowa o dzieło, staż lub praktyki i umowa na "
             "zastępstwo."),
            ("Currency", "Waluty",
             "Waluta z trzyliterowym kodem ISO, np. PLN – złoty, EUR – euro, USD – dolar amerykański, GBP – funt "
             "brytyjski. Kod jest tekstem, a baza sprawdza, że to trzy wielkie litery."),
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
        "skrot": "PostingSalary (N:1 JobPosting z ORG08) – wiele umów na ogłoszenie, każda z widełkami i historią "
                 "(`ValidFrom`/`ValidTo`/`IsCurrent`); benefity jako M:N JobPosting–Benefit przez PostingBenefit; "
                 "słowniki walut (kod ISO), rodzajów umów, okresów i grup benefitów.",
        "decyzje": [
            ("Historia widełek w `PostingSalary` zamiast nadpisywania",
             "zmiana kwot przy edycji ogłoszenia zostaje w danych (to sygnał); jeden aktualny wiersz na rodzaj umowy "
             "pilnuje indeks `CASE WHEN IsCurrent = 1 THEN JobPostingKey END, CASE WHEN IsCurrent = 1 THEN "
             "ContractTypeKey END`."),
            ("Opcjonalne kwoty, waluta, okres i `IsGross` z CHECK kompletności",
             "„umowa bez widełek” da się zapisać, ale kwota bez waluty albo okresu już nie: `(SalaryFrom IS NULL AND "
             "SalaryTo IS NULL) OR (CurrencyKey IS NOT NULL AND SalaryPeriodKey IS NOT NULL)`."),
            ("Brak przeliczenia do wspólnej waluty i okresu",
             "porównania wymagają przeliczenia w zapytaniu albo dodatkowych kolumn (pytanie do prowadzącego); kursów "
             "walut nie modelujemy."),
            ("Benefit jako słownik z grupą",
             "benefity są porównywalne między firmami; nowe nazwy z tekstu ogłoszeń trzeba dopisać do słownika albo "
             "przypisywać jak SkillSynonym w ORG10."),
        ],
        "luki": [
            "Benefity (tu) oraz wymagania i obowiązki (ORG10) nie mają historii zmian – przy edycji ogłoszenia program "
            "je nadpisuje (do decyzji: czy też je wersjonować).",
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
             "jest wymagana, czy mile widziana, na jakim poziomie (jeśli podano), ile lat doświadczenia (jeśli podano, "
             "nie mniej niż zero) i skąd to wiemy. Ta sama umiejętność może wystąpić w ogłoszeniu tylko raz."),
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
            ("`MinYearsExperience` obok poziomów z ORG08, z CHECK `MinYearsExperience >= 0`",
             "sprzeczności typu junior + 5 lat wykrywa zwykłe zapytanie."),
            ("Obowiązki jako zdania (`PostingResponsibility`)",
             "pełna informacja, ale bez porównań słownikowych – pytanie do prowadzącego."),
        ],
        "luki": [
            "Poziom wymagania powinien należeć do skali grupy danej umiejętności (`ProficiencyLevel.SkillCategoryKey = "
            "Skill.SkillCategoryKey`) – wymaga wyzwalacza albo klucza złożonego.",
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
                    "pierwszą od 3 do 24 listopada (flaga 0) i drugą od 24 listopada (flaga 1). W drugiej wersji program "
                    "znalazł trzy powtarzalne fragmenty: ogólną klauzulę RODO, stopkę „O nas” tej konkretnej firmy i "
                    "zgodę na przyszłe rekrutacje.",
        "tabele": [
            ("PostingEvent", "Zdarzenia ogłoszenia",
             "Jeden wiersz to jedno zdarzenie w życiu ogłoszenia (ogłoszenie z organizmu 8): co się stało, kiedy, skąd o "
             "tym wiemy, w której dostawie przyszła informacja (organizm 4) i – jeśli zdarzenie wpisał człowiek – kto "
             "(użytkownik z organizmu 19). Do tej tabeli tylko dopisujemy: niczego nie zmieniamy ani nie usuwamy."),
            ("PostingEventType", "Rodzaje zdarzeń",
             "Siedem wariantów: opublikowano, edytowano treść, odświeżono (podbito – ogłoszenie wraca na górę listy), "
             "wygasło, zamknięto przed terminem, opublikowano ponownie i usunięto."),
            ("EventSource", "Źródła informacji o zdarzeniu",
             "Kto powiedział nam o zdarzeniu: platforma, my sami (np. ogłoszenie zniknęło bez żadnego komunikatu) albo "
             "moderator."),
            ("PostingVersion", "Wersje treści ogłoszenia",
             "Każda edycja to nowy wiersz z numerem wersji (1, 2, 3…). Zapisujemy tytuł w tej wersji, treść dokładnie "
             "taką, jaka przyszła, treść oczyszczoną (bez stopek i klauzul), skrót treści do szybkiego porównania wersji, "
             "daty „od kiedy” i „do kiedy” treść była taka oraz flagę „aktualna”. W jednym ogłoszeniu numer wersji nie "
             "może się powtórzyć, aktualna jest jedna wersja, a koniec wersji musi być później niż jej początek."),
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
        "skrot": "Oś czasu ogłoszenia: PostingEvent (dziennik zdarzeń, tylko INSERT, opcjonalnie z DataDelivery z ORG04 i "
                 "SystemUser z ORG19) i PostingVersion (wersje treści w CLOB ze skrótem, okresami i flagą aktualnej); "
                 "powtarzalne fragmenty przez BoilerplatePattern (ogólny albo firmowy – Employer z ORG06) i "
                 "VersionBoilerplate (M:N).",
        "decyzje": [
            ("PostingEvent tylko do dopisywania",
             "pełna oś czasu dla sygnałów (odświeżenia, zniknięcia, powroty); stan bieżący w "
             "`JobPosting.PostingStatusKey` (ORG08) trzeba aktualizować razem z dopisaniem zdarzenia."),
            ("`EventSource` i `SystemUserKey` w zdarzeniu",
             "odróżniamy zdarzenia od platformy, wykryte przez nas i wpisane ręcznie – z autorem; mają różną "
             "wiarygodność."),
            ("PostingVersion z UQ(JobPostingKey, VersionNumber), `TextHash`, `CleanText` i `IsCurrent`",
             "wersje porównujemy po skrócie; aktualną treść czytamy po fladze (indeks „jedna aktualna na ogłoszenie”); "
             "pełne teksty w CLOB kosztują miejsce (pytanie do prowadzącego)."),
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
             "Jeden wiersz to dwa ogłoszenia (oba z organizmu 8), które są do siebie podobne: rodzaj powtórki, metoda w "
             "konkretnej wersji, którą to policzyliśmy, podobieństwo od 0 do 1 i data wykrycia. Para jest zapisywana "
             "tylko raz – wcześniejsze ogłoszenie jest zawsze pierwsze – a ta sama para policzona tą samą wersją metody "
             "nie może się powtórzyć."),
            ("SimilarityType", "Rodzaje powtórek",
             "Cztery warianty: dokładna kopia, ta sama treść innymi słowami, ten sam etat z innym poziomem i to samo "
             "ogłoszenie na innej platformie."),
            ("SimilarityMethod", "Metody liczenia podobieństwa",
             "Trzy metody: porównanie tekstu, wektory znaczenia (model AI) i porównanie cech ogłoszenia. Nazwa metody "
             "jest wybierana z tej listy – wcześniej była wpisywana przy każdej wersji, więc literówka mogła stworzyć "
             "„nową” metodę."),
            ("SimilarityMethodVersion", "Wersje metod",
             "Metody się zmieniają, więc każda ma wersje, np. 1.0, z datą od, datą do i flagą „używana teraz”. Z jednej "
             "wersji każdej metody korzystamy w danej chwili. Dzięki wersjom wszystko można przeliczyć od nowa i porównać "
             "wyniki starej i nowej wersji."),
            ("PostingFamily", "Rodziny ogłoszeń",
             "Jedna rodzina to jedno stanowisko jednej firmy (firma z organizmu 6) w czasie, np. „Księgowa, Kraków”. "
             "Zapisujemy opis stanowiska oraz datę pierwszej i ostatniej publikacji. Ostatnia nie może być wcześniejsza "
             "niż pierwsza."),
            ("FamilyMember", "Ogłoszenia w rodzinach",
             "Jeden wiersz to jedno ogłoszenie w jednej rodzinie, z datą dołączenia, datą przeniesienia i flagą "
             "„aktualne”. Po przeliczeniu rodzin ogłoszenie może przejść do innej rodziny – stare członkostwo zamykamy, "
             "a nie usuwamy. W danej chwili ogłoszenie jest najwyżej w jednej rodzinie (pytanie do prowadzącego, czy "
             "tak zostawić)."),
            ("FamilyLifecycle", "Historia rodziny na dany dzień",
             "Wynik obliczeń dla rodziny w konkretnym dniu: ile razy publikowano, ile dni łącznie było widoczne, ile "
             "razy znikało i wracało, ile razy odświeżano, na ilu platformach i z iloma różnymi poziomami stanowiska. "
             "Każde obliczenie to nowy wiersz, więc widać, jak rodzina zmienia się w czasie. Jednego dnia rodzina ma "
             "jeden wiersz, a liczby nie mogą być ujemne."),
        ],
        "skrot": "Podobieństwo jako relacja dwóch ogłoszeń (SimilarityPair: dwa klucze do JobPosting z ORG08, CHECK "
                 "First < Second) liczona metodą w wersji (SimilarityMethod 1:N SimilarityMethodVersion); rodziny "
                 "PostingFamily (Employer z ORG06) przez FamilyMember jako przypisanie w czasie i stany na dzień w "
                 "FamilyLifecycle.",
        "decyzje": [
            ("CHECK `FirstJobPostingKey < SecondJobPostingKey` + UQ(First, Second, MethodVersion)",
             "para zapisana raz, bez lustrzanych duplikatów; zapytanie „podobne do X” musi sprawdzać obie kolumny, więc "
             "potrzebne indeksy na obu."),
            ("Słownik `SimilarityMethod` + `SimilarityMethodVersion` z `IsCurrent`",
             "nazwa metody bez literówek; wyniki różnych wersji istnieją obok siebie, a „jedna używana wersja na metodę” "
             "pilnuje indeks."),
            ("`FamilyMember` jako przypisanie w czasie (`AddedAt`, `RemovedAt`, `IsCurrent`) zamiast UNIQUE na "
             "`JobPostingKey`",
             "przeniesienie ogłoszenia do innej rodziny nie kasuje historii; „najwyżej jedna rodzina naraz” pilnuje "
             "indeks `CASE WHEN IsCurrent = 1 THEN JobPostingKey END`."),
            ("`FamilyLifecycle` jako stan na dzień z UQ(PostingFamilyKey, CalculatedOn) i CHECK liczników >= 0",
             "trend bez przeliczania historii; liczniki to wynik obliczeń programu (świadoma denormalizacja)."),
            ("`PostingFamily.FirstSeenDate` i `LastSeenDate`",
             "dane wyliczalne z członków rodziny trzymane dla wygody – program aktualizuje je przy dodaniu ogłoszenia."),
        ],
        "luki": [
            "Ogłoszenia jednej rodziny powinny pochodzić z kont powiązanych z firmą rodziny (ścieżka przez ORG05 i "
            "ORG07) – reguła tylko w programie.",
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
                    "4 listopada. Aplikacja ma dwa stany: „Wysłana” (4 listopada, flaga 0) i „Wyświetlona przez firmę” "
                    "(6 listopada, flaga 1 – stan aktualny). 4 listopada osoba zgodziła się też na przypomnienia o "
                    "wyniku rekrutacji – zapisujemy, że widziała treść zgody w wersji 1.2. Gdyby później wycofała zgodę, "
                    "powstałby nowy wiersz „wycofana”, a stary zostałby bez zmian.",
        "tabele": [
            ("CandidatePseudonym", "Kandydaci (pseudonimy)",
             "Jeden wiersz to jeden pseudonim nadany przez jedną platformę (platforma z organizmu 1) i data, kiedy "
             "pierwszy raz się pojawił. Ta sama osoba na dwóch platformach to dla nas dwa różne pseudonimy – celowo ich "
             "nie łączymy. Na jednej platformie pseudonim nie może się powtórzyć."),
            ("Application", "Aplikacje",
             "Jeden wiersz to jedna aplikacja jednego pseudonimu na jedno ogłoszenie (ogłoszenie z organizmu 8), "
             "potwierdzona przez platformę: kiedy wysłano aplikację i w której dostawie przyszła ta informacja "
             "(organizm 4). Ten sam pseudonim może zaaplikować na jedno ogłoszenie tylko raz. Aplikacja ma własny numer, "
             "bo odwołują się do niej przypomnienia – jak wizyta do lekarza w konkretnej placówce."),
            ("ApplicationStatusChange", "Historia stanów aplikacji",
             "Każda zmiana stanu aplikacji to nowy wiersz: nowy stan, data i flaga „aktualny”. Stan aktualny ma flagę 1 i "
             "baza pilnuje, żeby w jednej aplikacji był tylko jeden taki wiersz – dlatego nie trzeba go powtarzać przy "
             "aplikacji (pytanie do prowadzącego)."),
            ("ApplicationStatus", "Stany aplikacji",
             "Siedem wariantów: wysłana, wyświetlona przez firmę, odrzucona automatycznie, zaproszenie na rozmowę, "
             "oferta pracy, zatrudnienie i wycofana przez kandydata – jeśli platforma je zna."),
            ("Consent", "Decyzje o zgodach",
             "Jeden wiersz to jedna decyzja kandydata: udzielenie albo wycofanie zgody (flaga 1 albo 0), z datą i wersją "
             "treści zgody, którą kandydat widział. Każda decyzja to nowy wiersz, więc zawsze da się wykazać, na co i "
             "kiedy kandydat się zgodził – tego wymaga RODO."),
            ("ConsentTextVersion", "Wersje treści zgód",
             "Pełna treść zgody w konkretnej wersji (np. 1.2), z datą od, datą do i flagą „pokazywana teraz”. Gdy "
             "zmieniamy treść, powstaje nowa wersja, a stara zostaje. W jednym rodzaju zgody oznaczenie wersji nie może "
             "się powtórzyć, a pokazywana jest jedna wersja."),
            ("ConsentType", "Rodzaje zgód",
             "Na co kandydat się zgadza: przypomnienia o wyniku rekrutacji albo zbieranie cech urządzenia (potrzebne do "
             "sprawdzenia zgłoszenia w organizmie 15)."),
        ],
        "skrot": "Minimum danych: kandydat tylko jako CandidatePseudonym (UQ w obrębie SourcePlatform z ORG01); "
                 "Application (N:1 JobPosting z ORG08, opcjonalnie DataDelivery z ORG04) z historią stanów i flagą "
                 "aktualnego; zgody jako dziennik decyzji wskazujący wersję tekstu.",
        "decyzje": [
            ("Brak danych osobowych – tylko pseudonim od platformy",
             "mniejsze ryzyko RODO i mniej do usuwania na wniosek; ta sama osoba na dwóch platformach to dwa pseudonimy "
             "– świadomie."),
            ("UQ(CandidatePseudonymKey, JobPostingKey) w Application",
             "jedna aplikacja osoby na ogłoszenie; ponowna aplikacja na to samo ogłoszenie po „Opublikowano ponownie” "
             "się nie zmieści – trzeba zdecydować, czy to potrzebne."),
            ("Stan aplikacji tylko w historii, z `IsCurrent` i indeksem „jeden aktualny na aplikację”",
             "stan bieżący to `IsCurrent = 1`, bez `ROW_NUMBER()`; program przy nowym stanie zmienia flagę poprzedniego "
             "na 0."),
            ("Consent → ConsentTextVersion z `IsCurrent`",
             "rozliczalność RODO: wiadomo, na jaką treść wyrażono zgodę; wycofanie to nowy wiersz `IsGranted = 0`; "
             "pokazywaną wersję tekstu pilnuje indeks „jedna na rodzaj zgody”."),
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
             "to jedno przypomnienie do jednej aplikacji (organizm 13), czyli do pary „kandydat – ogłoszenie”: jego "
             "numer (od 1), stan i data zlecenia. Ta sama aplikacja nie może mieć dwóch przypomnień o tym samym numerze."),
            ("ReminderStatus", "Stany przypomnienia",
             "Cztery warianty: zlecone platformie, dostarczone, bez odpowiedzi i „kandydat odpowiedział”."),
        ],
        "skrot": "RecruitmentReport – zdarzenie od kandydata (CandidatePseudonym z ORG13) o ogłoszeniu (JobPosting z "
                 "ORG08) z wynikiem, etapem i kanałem, opcjonalnie powiązane z Reminder; Reminder (N:1 Application z "
                 "ORG13 – para kandydat i ogłoszenie) z numerem i stanem.",
        "decyzje": [
            ("Zgłoszenia tylko do dopisywania",
             "zmiana zdania to nowy wiersz; do oceny bierzemy ostatnie zgłoszenie pary (pseudonim, ogłoszenie) albo "
             "wszystkie – pytanie do prowadzącego."),
            ("Zgłoszenie wskazuje pseudonim i ogłoszenie, a nie Application",
             "zgłoszenie może przyjść, zanim platforma potwierdzi aplikację (ORG15: wynik „Za wcześnie”) albo bez niej "
             "(ORG15 je odrzuci); powiązanie z aplikacją to złączenie po (pseudonim, ogłoszenie)."),
            ("`RecruitmentStage.StageRank`",
             "zestawienia typu „na którym etapie firmy milkną” bez porównywania tekstów."),
            ("Reminder z UQ(ApplicationKey, ReminderNumber) i CHECK `ReminderNumber >= 1`",
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
            "Na końcu zgłoszenie dostaje ocenę: przyjęte, do moderacji albo odrzucone, z wagą od 0 do 1, według "
            "konkretnej wersji reguł. Ocenę wydaje program albo moderator. Tylko przyjęte zgłoszenia liczą się do Trust "
            "Score. Dzięki temu konkurencja nie obniży oceny firmy fałszywymi skargami, a firma nie podniesie jej sama "
            "sobie.",
        ],
        "przyklad": "Zgłoszenie z 5 grudnia przechodzi cztery sprawdzenia, wszystkie z wynikiem „Pozytywny”: usługa "
                    "Cloudflare potwierdza, że wysłał je człowiek; platforma potwierdziła aplikację sprzed 31 dni; z "
                    "tego urządzenia nie przyszły inne zgłoszenia; nie ma fali zgłoszeń o tej firmie. Program ocenia je "
                    "według reguł w wersji 1.0: „Przyjęte”, waga 0,9, flaga „aktualna ocena”. Urządzenie zapisujemy "
                    "tylko jako skrót jego cech, z datą usunięcia za 90 dni.",
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
             "wersja reguł, data, flaga „aktualna” i – jeśli oceniał człowiek – kto (użytkownik z organizmu 19). "
             "Zgłoszenie można ocenić ponownie, gdy przyjdą nowe dane albo zmienią się reguły – wtedy powstaje nowy "
             "wiersz z flagą 1, a stary dostaje flagę 0 i zostaje."),
            ("VerdictDecision", "Decyzje",
             "Trzy warianty: przyjęte, do moderacji (decyduje człowiek) i odrzucone."),
            ("VerdictRuleSet", "Wersje reguł oceny",
             "Reguły, według których program ocenia zgłoszenia, np. wersja 1.0: „cztery sprawdzenia; przyjęte, gdy "
             "wszystkie są pozytywne”. Wersję wybieramy z tej listy – wcześniej była wpisywanym tekstem. Każda wersja ma "
             "datę od, datę do i flagę „używana teraz”, a używana jest tylko jedna."),
            ("DeviceFingerprint", "Urządzenia (jako skróty)",
             "Urządzenie zapisujemy tylko jako skrót jego cech (np. rodzaju przeglądarki i rozdzielczości ekranu). Ze "
             "skrótu nie da się odtworzyć tych cech, ale identyczne urządzenia mają identyczny skrót. Zapisujemy też, "
             "kiedy urządzenie pojawiło się pierwszy raz i kiedy trzeba je usunąć – dane osobowe trzymamy krótko."),
            ("ReportDevice", "Urządzenie zgłoszenia",
             "Przypisuje zgłoszeniu urządzenie, z którego je wysłano. Jedno zgłoszenie ma najwyżej jedno urządzenie, a "
             "z jednego urządzenia może przyjść wiele zgłoszeń – tak wykrywamy jedną osobę udającą wielu kandydatów."),
        ],
        "skrot": "Weryfikacja jako zestaw niezależnych testów (ReportCheck: zgłoszenie × rodzaj × wynik) i historia ocen "
                 "(ReportVerdict z wagą, flagą aktualnej, wersją reguł z VerdictRuleSet i autorem z ORG19) dla "
                 "RecruitmentReport z ORG14; urządzenia jako skróty z terminem usunięcia.",
        "decyzje": [
            ("Jedna tabela `ReportCheck` dla wszystkich rodzajów sprawdzeń",
             "nowe sprawdzenie bez zmiany schematu; szczegóły jako tekst (`CheckDetails`) zamiast osobnych kolumn – "
             "pytanie do prowadzącego."),
            ("`ReportVerdict` jako historia z `IsCurrent` i indeksem „jedna aktualna ocena na zgłoszenie”",
             "ponowna ocena nie nadpisuje poprzedniej; do Trust Score bierzemy `IsCurrent = 1`."),
            ("Słownik `VerdictRuleSet` zamiast wpisywanej z palca wersji reguł",
             "wersja reguł bez literówek, z okresem obowiązywania; „jedna używana wersja” pilnuje indeks `CASE WHEN "
             "IsCurrent = 1 THEN 1 END`."),
            ("`ReportVerdict.SystemUserKey` (opcjonalny)",
             "wiadomo, czy ocenił program (NULL), czy moderator – i który."),
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
            "Alert to tylko podejrzenie. Potwierdzić albo odrzucić je musi człowiek – moderator. Każda zmiana stanu "
            "alertu zostaje w historii razem z tym, kto ją zrobił. Dopiero potwierdzony alert wpływa na oceny "
            "zgłoszeń.",
        ],
        "przyklad": "8 grudnia między 20:00 a 23:00 przychodzi 12 negatywnych zgłoszeń o Przykład Logistyka z jednego "
                    "urządzenia, ale od 12 różnych pseudonimów. Program tworzy alert „Jedno urządzenie, wiele "
                    "pseudonimów” z okresem 20:00–23:00 i liczbą 12 zgłoszeń, a w historii stanów – wpis „Nowy” (bez "
                    "autora, bo zrobił to program). Wszystkie 12 zgłoszeń zapisujemy przy alercie. Moderator przejmuje "
                    "alert (wpis „W moderacji” z jego kontem) i potwierdza nadużycie (wpis „Potwierdzone nadużycie” – "
                    "teraz to on ma flagę „aktualny”). Te 12 zgłoszeń dostaje w organizmie 15 nową ocenę „Odrzucone”, "
                    "więc nie obniży wyniku firmy.",
        "tabele": [
            ("AbuseAlert", "Alerty o nadużyciach",
             "Jeden wiersz to jeden alert o jednej firmie (firma z organizmu 6): rodzaj podejrzanego wzorca, początek i "
             "koniec okresu, w którym przyszły zgłoszenia, data wykrycia i liczba zgłoszeń. Stanu alertu tu nie ma – "
             "jest w historii stanów. Baza pilnuje, żeby koniec okresu nie był przed jego początkiem."),
            ("AlertType", "Rodzaje podejrzanych wzorców",
             "Cztery warianty: fala negatywnych zgłoszeń o jednej firmie, fala pozytywnych zgłoszeń od samej firmy, "
             "jedno urządzenie z wieloma pseudonimami i zgłoszenia od pseudonimów bez aplikacji."),
            ("AlertStatus", "Stany alertu",
             "Cztery warianty: nowy, w moderacji, potwierdzone nadużycie i fałszywy alarm."),
            ("AlertStatusChange", "Historia stanów alertu",
             "Każda zmiana stanu alertu to nowy wiersz: nowy stan, kiedy, uzasadnienie i kto zmienił (użytkownik z "
             "organizmu 19; puste, gdy program). Aktualny stan ma flagę 1 i baza pilnuje, żeby był tylko jeden."),
            ("AlertReport", "Zgłoszenia objęte alertem",
             "Jeden alert obejmuje wiele zgłoszeń, a jedno zgłoszenie może trafić do kilku alertów. Dlatego to osobna "
             "tabela par „alert – zgłoszenie” (zgłoszenie z organizmu 14). Para nie może się powtórzyć."),
        ],
        "skrot": "AbuseAlert (N:1 Employer z ORG06) – wykryty wzorzec w oknie czasowym; stan w AlertStatusChange (historia "
                 "z autorem z ORG19 i flagą aktualnego); AlertReport jako M:N AbuseAlert–RecruitmentReport (ORG14).",
        "decyzje": [
            ("Alert zawsze dotyczy firmy (`EmployerKey` wymagany)",
             "proste zestawienia dla firmy; wzorce na poziomie platformy albo samego urządzenia nie mają gdzie trafić – "
             "pytanie do prowadzącego."),
            ("Stan alertu jako historia `AlertStatusChange` z `SystemUserKey` i `IsCurrent`",
             "wiadomo, kto i kiedy zmienił stan i dlaczego; aktualny stan pilnuje indeks „jeden na alert”."),
            ("`AlertReport` M:N z UQ(AbuseAlertKey, RecruitmentReportKey)",
             "to samo zgłoszenie może należeć do kilku alertów (ten sam atak wykryty dwoma wzorcami)."),
            ("`ReportCount` zapisany w alercie",
             "liczba z chwili wykrycia – może się rozjechać z liczbą wierszy AlertReport, jeśli zgłoszenia dochodzą "
             "później."),
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
             "Rodzaj sygnału z nazwą, grupą, jednostką, kierunkiem (flaga: czy więcej znaczy lepiej dla firmy) i "
             "opisem, jak go liczymy. Na start: odsetek ogłoszeń będących powtórkami, średnia liczba publikacji jednego "
             "stanowiska, zatrudnienia na 100 aplikacji, zgłoszenia ciszy na 100 aplikacji, odsetek ogłoszeń z widełkami "
             "i wiek firmy w rejestrze."),
            ("SignalGroup", "Grupy sygnałów",
             "Cztery grupy: powtórki ogłoszeń, odpowiedzi firmy na aplikacje, przejrzystość ogłoszeń i dane z "
             "rejestrów."),
            ("MeasureUnit", "Jednostki",
             "Cztery jednostki: procent (%), dzień (dni), liczba i liczba na 100 aplikacji. Jednostkę wybieramy z tej "
             "listy – wcześniej była wpisywana tekstem, więc „%”, „proc.” i „procent” byłyby trzema różnymi "
             "jednostkami."),
        ],
        "skrot": "Sygnały w modelu EAV: SignalSnapshot (Employer z ORG06 × dzień, UQ) 1:N SignalValue (SignalType × "
                 "wartość × liczba danych); SignalType z jednostką ze słownika MeasureUnit, kierunkiem "
                 "(`HigherIsBetter`) i grupą. ORG18 wskazuje SignalSnapshot i SignalType.",
        "decyzje": [
            ("Wartości w wierszach (EAV) zamiast kolumny na sygnał",
             "nowy sygnał bez `ALTER TABLE`; koszt: wszystkie wartości jako NUMBER(12,4) i zapytania z `PIVOT` do "
             "zestawień (pytanie do prowadzącego)."),
            ("UQ(EmployerKey, SnapshotDate) i UQ(SignalSnapshotKey, SignalTypeKey)",
             "jeden stan firmy na dzień i jedna wartość sygnału w stanie; trend to porównanie stanów."),
            ("Słownik `MeasureUnit` zamiast wpisywanej z palca jednostki",
             "jednostka wybierana, a nie wpisywana; skrót do wyświetlania (`MeasureUnitSymbol`) w jednym miejscu."),
            ("`BasedOnCount`",
             "wiarygodność zależy od liczby danych – metoda w ORG18 może pomijać sygnały poniżej progu."),
            ("`HigherIsBetter` jako flaga w słowniku",
             "metoda punktowania nie musi znać znaczenia sygnału – kierunek jest daną."),
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
            "uzasadnionym odwołaniu firmy wynik można wycofać. Dla jednej firmy widoczna jest zawsze jedna aktualna "
            "publikacja.",
        ],
        "przyklad": "1 grudnia liczymy wynik firmy Przykład Logistyka metodą „Wagi ustalone przez zespół” w wersji 1.0 – "
                    "jedynej z flagą „używana teraz” – na stanie sygnałów z tego dnia. Każdy z sześciu sygnałów ma w tej "
                    "metodzie swoją wagę. Wynik: 41 na 100, pewność 0,72. Trzy powody, od najważniejszego: „to samo "
                    "ogłoszenie 7 razy w 9 miesięcy”, „38% ogłoszeń to powtórki” i „34 na 100 aplikacji kończy się "
                    "ciszą”. Pewność wystarcza, więc od 1 grudnia wynik jest pokazywany ze stanem „Opublikowany” i flagą "
                    "„aktualna publikacja”. Gdyby firma się odwołała i miała rację, ta publikacja dostałaby datę końca i "
                    "flagę 0, a nowy wiersz – stan „Wycofany po odwołaniu”.",
        "tabele": [
            ("TrustScore", "Wyniki (robocze)",
             "Jeden wiersz to jedno policzenie wyniku: na jakim stanie sygnałów (organizm 17), jaką metodą, wynik od 0 "
             "do 100, pewność od 0 do 1 i kiedy policzono. Każde przeliczenie to nowy wiersz, więc widać historię "
             "oceny firmy. Baza pilnuje zakresów 0–100 i 0–1."),
            ("ScoringMethod", "Metody liczenia wyniku",
             "Metoda w konkretnej wersji, z rodzajem, datami „od kiedy” i „do kiedy” była używana i flagą „używana "
             "teraz”. Na start: „Wagi ustalone przez zespół” w wersji 1.0. W jednym rodzaju metody wersja nie może się "
             "powtórzyć, a używana jest tylko jedna metoda naraz."),
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
             "Jeden wiersz to jeden okres pokazywania wyniku dla jednej firmy (firma z organizmu 6): który wynik, w jakim "
             "stanie publikacji, od kiedy, do kiedy i flaga „aktualna”. Zapis jest osobno od wyniku roboczego, więc "
             "publikację można wstrzymać albo wycofać bez kasowania obliczeń. Baza pilnuje, żeby firma miała tylko jedną "
             "aktualną publikację."),
            ("PublicationStatus", "Stany publikacji",
             "Cztery warianty: opublikowany, za mało danych, wstrzymany do decyzji moderatora i wycofany po odwołaniu."),
        ],
        "skrot": "TrustScore to wynik metody (ScoringMethod z wersją i flagą używanej) na stanie sygnałów (SignalSnapshot "
                 "z ORG17); wagi jako M:N metoda–SignalType (ScoringWeight); powody 1:N z rangą; publikacja oddzielona "
                 "od wyniku roboczego (PublishedScore z firmą z ORG06, okresem i flagą aktualnej).",
        "decyzje": [
            ("Wynik wskazuje stan sygnałów i metodę",
             "pełna odtwarzalność: wiadomo, na jakich danych i jaką wersją metody policzono wynik; przeliczenie to nowy "
             "wiersz."),
            ("`ScoringMethod.IsCurrent` z indeksem `CASE WHEN IsCurrent = 1 THEN 1 END`",
             "w danej chwili używana jest jedna metoda w całym systemie; zmiana metody to dwie flagi."),
            ("`ScoringWeight` jako M:N z wartością",
             "metoda to dane, a nie kod; nowa wersja metody to nowe wagi, stare zostają."),
            ("`ScoreReason` z UQ(TrustScoreKey, ReasonRank) i kluczem do SignalType",
             "powody w ustalonej kolejności, powiązane z sygnałem, z którego wynikają."),
            ("`PublishedScore` z `EmployerKey` i `IsCurrent`",
             "publikacja „opisuje firmę”, więc ma klucz firmy; jedną aktualną publikację na firmę pilnuje indeks `CASE "
             "WHEN IsCurrent = 1 THEN EmployerKey END`."),
            ("CHECK `ScoreValue` 0–100 i `ScoreConfidence` 0–1",
             "próg pewności dla „Za mało danych” to reguła programu, nie bazy."),
        ],
        "luki": [
            "`PublishedScore.EmployerKey` powinien być tą samą firmą co w stanie sygnałów wyniku (TrustScore → "
            "SignalSnapshot → Employer) – wymaga wyzwalacza.",
            "Wagi i powody powinny dotyczyć sygnałów obecnych w stanie, z którego liczono wynik – reguła programu.",
        ],
    },
    19: {
        "o_czym": [
            "Do Ghost-Job Scanner logują się ludzie: moderatorzy, administratorzy, analitycy, inspektor ochrony danych i "
            "przedstawiciele firm. Ten organizm zapisuje ich konta, role i to, którą firmę reprezentuje dana osoba.",
            "Konto służy nie tylko do logowania. Przy decyzjach w innych organizmach – połączeniu konta z firmą, ocenie "
            "zgłoszenia, zmianie stanu alertu, ręcznie wpisanym zdarzeniu – zapisujemy, kto je podjął. Rola decyduje, co "
            "wolno danej osobie. Kandydaci nie mają tu kont – znamy ich tylko z pseudonimów (organizm 13).",
        ],
        "przyklad": "Konto „moderator1@ghostjob.example” należy do osoby z zespołu moderacji. Od 1 listopada ma rolę "
                    "„Moderator”, a od 1 grudnia także „Analityk danych” – dwa wiersze ról, oba aktualne. To konto "
                    "zapisujemy przy przeniesieniu konta OLX do agencji (organizm 7) i przy potwierdzeniu nadużycia "
                    "(organizm 16). Osoba z działu HR firmy Przykład Logistyka zakłada konto, żeby odwołać się od "
                    "oceny: dostaje rolę „Przedstawiciel firmy”, a w tabeli przedstawicieli – wiersz „reprezentuje "
                    "Przykład Logistyka od 10 grudnia”, z datą, kiedy to potwierdziliśmy. Gdy ta osoba przestanie tam "
                    "pracować, wiersz dostanie datę końca i flagę 0 – nie usuwamy go, bo jej odwołanie musi zostać w "
                    "historii.",
        "tabele": [
            ("SystemUser", "Konta użytkowników",
             "Jeden wiersz to jedno konto osoby, która loguje się do systemu: login (np. służbowy e-mail – nie może się "
             "powtórzyć), nazwa wyświetlana, skrót hasła, data założenia, flaga „aktywne” i data wyłączenia. Samego hasła "
             "nigdy nie zapisujemy – tylko jego skrót. Konta nie usuwamy, bo są z nim związane decyzje w innych tabelach; "
             "wyłączone konto ma flagę 0 i datę wyłączenia."),
            ("Role", "Role",
             "Pięć ról z opisem, co im wolno: administrator, moderator, analityk danych, inspektor ochrony danych i "
             "przedstawiciel firmy. Rolę wybieramy z listy, a nie wpisujemy – inaczej, jak mówił prowadzący, literówka "
             "zrobiłaby z jednej roli dwie. Nowa rola, np. „audytor”, to jeden nowy wiersz."),
            ("UserRole", "Role użytkowników",
             "Jedna osoba ma kilka ról naraz, a rola może się skończyć. Dlatego to przypisanie w czasie: para "
             "„użytkownik – rola” z datą od, datą do i flagą „aktualna”. Baza pilnuje, żeby ta sama rola nie była "
             "aktualna dwa razy u jednej osoby i żeby rola zamknięta miała datę końca."),
            ("EmployerRepresentative", "Przedstawiciele firm",
             "Osoba może reprezentować kilka firm (np. pracownik agencji), a firma (z organizmu 6) ma kilku "
             "przedstawicieli. Jeden wiersz to para „użytkownik – firma” z datą od, datą do, flagą „reprezentuje teraz” i "
             "datą, kiedy potwierdziliśmy, że ta osoba naprawdę reprezentuje firmę. Gdy przestaje, nie usuwamy wiersza, "
             "tylko go zamykamy – tak jak lekarz, który odchodzi z kliniki."),
        ],
        "skrot": "Nowy organizm z uwag prowadzącego o tabeli użytkowników: SystemUser (konto z flagą aktywności) ↔ Role "
                 "przez UserRole (przypisanie w czasie) i SystemUser ↔ Employer (ORG06) przez EmployerRepresentative. "
                 "SystemUser wskazują ORG07 (LinkChange), ORG11 (PostingEvent), ORG15 (ReportVerdict) i ORG16 "
                 "(AlertStatusChange).",
        "decyzje": [
            ("Rola jako słownik i M:N `UserRole` zamiast kolumny tekstowej „rola” w koncie",
             "nowa rola bez zmiany schematu, bez literówek; jedna osoba ma kilka ról, a ich historia zostaje."),
            ("Personel i przedstawiciele firm w jednej tabeli `SystemUser`",
             "jedno logowanie i jeden klucz autora decyzji w całym modelu; rodzaj osoby wynika z roli (pytanie do "
             "prowadzącego)."),
            ("`PasswordHash` zamiast hasła, puste przy logowaniu zewnętrznym",
             "wyciek tabeli nie ujawnia haseł; gdy zespół wybierze logowanie przez zewnętrzny system, kolumna zostaje "
             "pusta."),
            ("Wyłączanie kont flagą `IsActive` i `DeactivatedAt` zamiast DELETE",
             "klucze obce z decyzji w ORG07, ORG11, ORG15 i ORG16 dalej wskazują istniejące konto."),
            ("`EmployerRepresentative.VerifiedAt`",
             "przedstawiciel niepotwierdzony nie powinien móc składać odwołań – reguła panelu firmy (moderacja i "
             "odwołania, do rozpisania)."),
        ],
        "luki": [
            "Uprawnienia ról (co wolno której roli) są na razie tylko opisem w `RoleDescription` – rozpiszemy je razem "
            "z kontami programów i GRANT-ami.",
            "Dziennik audytu (kto co zmienił w każdej tabeli) jest jeszcze do rozpisania (warstwa 6).",
        ],
    },
}
