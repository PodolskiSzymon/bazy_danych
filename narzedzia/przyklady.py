"""Przykład na danych przy każdej tabeli – jeden spójny zestaw wierszy dla całej bazy.

Wiersze idą za wspólnym przykładem z opisów: firma „Przykład Logistyka sp. z o.o.” z Krakowa, agencja „Kadry
Przykład”, ogłoszenie „Magazynier/ka” na pracuj.pl i OLX, osoba, która aplikuje i zgłasza ciszę. Klucze obce
wskazują na wiersze z tego samego zestawu, więc całość da się wstawić do bazy i sprawdzić (generator robi z niej
skrypt INSERT).

p(tabela, wstęp, koniec, ...):
  wiersze   – krotki w kolejności kolumn tabeli, z kluczem głównym na początku; dla tabel z wierszami startowymi
              (słowników) pomijamy je – przykład bierze wiersze startowe, a „dodatkowe” dopisuje do nich,
  pokaz     – które kolumny pokazać (domyślnie wszystkie oprócz CLOB),
  znaczy    – zdanie przy każdym pokazanym wierszu (kolumna „co to znaczy”),
  ile       – ile pierwszych wierszy pokazać (reszta jako „… i jeszcze N wierszy”),
  klucze    – pokaż tylko wiersze o tych kluczach.
Daty: 'RRRR-MM-DD', daty z godziną: 'RRRR-MM-DD GG:MM'. Nazwy firm i wszystkie liczby są wymyślone; adresy API
mają domenę .example, bo też są wymyślone.
"""
from datetime import datetime, timedelta

PRZYKLADY = {}


def p(tabela, wstep, koniec, wiersze=None, pokaz=None, dodatkowe=None, znaczy=None, ile=None, klucze=None):
    PRZYKLADY[tabela] = {"wstep": wstep, "koniec": koniec, "wiersze": wiersze, "pokaz": pokaz,
                         "dodatkowe": dodatkowe or [], "znaczy": znaczy, "ile": ile, "klucze": klucze}


# Jak podpisać numer klucza obcego, np. „1 (pracuj.pl)”. {Kolumna>} = podpis wiersza, na który kolumna wskazuje.
# Bez wpisu: pierwsza kolumna z końcówką Name; pusty napis = sam numer.
ETYKIETY = {
    "APIVersion": "{PlatformAPIKey>} {VersionLabel}",
    "APIEndpoint": "{HTTPMethodKey>} {EndpointPath}",
    "EndpointResponse": "{APIEndpointKey>} → {HTTPStatusCode}",
    "EndpointData": "{DataPath}",
    "DataDelivery": "{StartedAt}",
    "RawRecord": "rekord {ExternalRecordId}",
    "EmployerAccount": "{SourcePlatformKey>} {ExternalAccountId}",
    "Currency": "{CurrencyCode}",
    "PKDCode": "{PKDSymbol}",
    "JobPosting": "{PostingTitle}",
    "PostingVersion": "wersja {VersionNumber}",
    "BoilerplatePattern": "{BoilerplateTypeKey>}",
    "SimilarityMethodVersion": "{SimilarityMethodKey>} {VersionLabel}",
    "PostingFamily": "{FamilyLabel}",
    "CandidatePseudonym": "{PseudonymValue}",
    "Application": "",
    "ConsentTextVersion": "wersja {VersionLabel}",
    "Reminder": "przypomnienie {ReminderNumber}",
    "RecruitmentReport": "",
    "VerdictRuleSet": "wersja {VersionLabel}",
    "DeviceFingerprint": "{FingerprintHash}",
    "AbuseAlert": "",
    "SignalSnapshot": "stan z {SnapshotDate}",
    "ScoringMethod": "wersja {MethodVersion}",
    "TrustScore": "wynik {ScoreValue}",
    "SystemUser": "{DisplayName}",
}


# ───────────── 1. Źródło danych: platforma, API i endpointy ─────────────
p("PlatformType", "Przykład na danych – cała lista rodzajów:",
  "Numer rodzaju (`PlatformTypeKey`) to zwykły numer wiersza. Tabela `PlatformClassification` zapisuje tylko ten "
  "numer: pracuj.pl ma rodzaj 1, a OLX – rodzaje 2 i 1. Nowy rodzaj, np. aplikacja mobilna z ofertami, to jeden nowy "
  "wiersz: 7 – „Aplikacja mobilna z ofertami”. Żadnej tabeli nie trzeba przebudowywać.")
p("PlatformClassification", "Przykład na danych – rodzaje dwóch platform:",
  "OLX ma dwa wiersze, bo jest dwóch rodzajów naraz – jak lekarz, który jest chirurgiem i onkologiem. Rodzaj główny "
  "(`IsMainType` = 1) może być tylko jeden: drugiego wiersza OLX z flagą 1 baza nie przyjmie. Nie przyjmie też drugi "
  "raz tej samej pary „platforma – rodzaj”.",
  znaczy=["pracuj.pl to portal z ofertami pracy", "OLX to głównie serwis ogłoszeń drobnych…",
          "…a dodatkowo portal z ofertami pracy (dział OLX Praca)"])
p("SourcePlatform", "Przykład na danych – dwie platformy, z których bierzemy dane:",
  "Inne tabele nie powtarzają nazwy platformy, tylko zapisują jej numer: `SourcePlatformKey` = 1 znaczy pracuj.pl w "
  "każdej tabeli bazy – w adresach, umowach, API, kontach firm i pseudonimach kandydatów. Drugiej platformy o nazwie "
  "„OLX” baza nie przyjmie.")
p("PlatformDomain", "Przykład na danych – adresy dwóch platform:",
  "pracuj.pl ma dwa aktualne adresy, ale główny jest jeden (`IsMainDomain` = 1). Załóżmy, że 15 października OLX "
  "przestał używać adresu praca.olx.pl: nie usuwamy go, tylko zamykamy – data końca i flaga 0. Dzięki temu wiemy, "
  "skąd przychodziły dane przed tą datą. Drugiego aktualnego wiersza z adresem olx.pl baza nie przyjmie.",
  wiersze=[(1, 1, "pracuj.pl", 1, "2026-10-01", None, 1),
           (2, 1, "it.pracuj.pl", 0, "2026-10-01", None, 1),
           (3, 2, "olx.pl", 1, "2026-10-01", None, 1),
           (4, 2, "praca.olx.pl", 0, "2026-10-01", "2026-10-15", 0)])
p("PlatformMarket", "Przykład na danych – w jakich krajach działają dwie platformy:",
  "Para „OLX – Portugalia” nie ma daty początku, bo nie wiemy, od kiedy OLX tam działa – ta kolumna może być pusta. "
  "Załóżmy, że pracuj.pl publikował też oferty na Ukrainie, ale z końcem października przestał: ten wiersz dostał "
  "datę końca i flagę 0. Gdy pracuj.pl tam wróci, powstanie nowy wiersz z flagą 1.",
  wiersze=[(1, 1, 1, "2026-10-01", None, 1),
           (2, 2, 1, "2026-10-01", None, 1),
           (3, 2, 4, "2026-10-01", None, 1),
           (4, 2, 5, None, None, 1),
           (5, 1, 6, "2026-10-01", "2026-10-31", 0)])
p("PartnerAgreement", "Przykład na danych – trzy etapy umowy z pracuj.pl:",
  "Tak jak w przykładzie prowadzącego z lekarzem, który przechodzi między klinikami: dwa wiersze są zamknięte (flaga 0 "
  "i data końca), jeden jest aktualny (flaga 1). Starych etapów nie usuwamy. Gdyby ktoś chciał dać flagę 1 drugiemu "
  "wierszowi pracuj.pl, baza tego nie przyjmie. Umowę powierzenia danych (`HasDataProcessingAgreement` = 1) "
  "podpisaliśmy przed pilotażem, bo od pilotażu dostajemy pseudonimy kandydatów.",
  wiersze=[(1, 1, 1, None, "2026-10-01", "2026-10-31", 0, 0),
           (2, 1, 2, "2026-10-30", "2026-11-01", "2026-12-31", 0, 1),
           (3, 1, 3, "2026-12-20", "2027-01-01", None, 1, 1)],
  pokaz=["PartnerAgreementKey", "SourcePlatformKey", "AgreementStatusKey", "ValidFrom", "ValidTo", "IsCurrent",
         "HasDataProcessingAgreement"])
p("AgreementStatus", "Przykład na danych – lista etapów umowy:",
  "Historia umowy z pracuj.pl (`PartnerAgreement`) używa trzech pierwszych: 1 – Negocjacje, 2 – Pilotaż, 3 – Aktywna. "
  "Gdy umowa zostanie zawieszona, powstanie nowy wiersz z etapem 4, a etap 3 dostanie datę końca.")
p("Country", "Przykład na danych – lista krajów:",
  "Kod kraju (`CountryCode`) to tekst z dokładnie dwiema wielkimi literami – „pl” albo „P1” baza odrzuci. Numerem "
  "wiersza jest `CountryKey`, a nie kod: tabele `PlatformMarket`, `Employer` i `Location` zapisują `CountryKey` = 1, "
  "czyli Polskę.")
p("APIType", "Przykład na danych – lista rodzajów API:",
  "API pracuj.pl (`PlatformAPI`, wiersz 1) ma rodzaj 1 – REST, a kanał ofert OLX (wiersz 2) – rodzaj 6 – kanał RSS.")
p("DataFormat", "Przykład na danych – lista formatów:",
  "Ani nazwa, ani typ MIME nie mogą się powtórzyć. API pracuj.pl przesyła domyślnie JSON (1), a kanał OLX – XML (2). "
  "Ten sam numer formatu zapisujemy przy każdej możliwej odpowiedzi endpointu (`EndpointResponse`).")
p("AuthMethod", "Przykład na danych – lista sposobów zabezpieczenia:",
  "API pracuj.pl wymaga klucza API (1), a kanał ofert OLX nie ma zabezpieczenia (5). Samego klucza nie ma w bazie – "
  "jest tylko informacja, jakim sposobem się logujemy.")
p("PlatformAPI", "Przykład na danych – dwa kanały wymiany danych:",
  "Każda kolumna z końcówką Key to numer z innej tabeli – w nawiasie jest to, co ten numer znaczy. pracuj.pl ma "
  "„Partner API”: REST, JSON, klucz API, to my pytamy o dane. OLX nie ma z nami umowy, więc czytamy jego publiczny "
  "kanał ofert w XML, bez zabezpieczenia. Gdy pracuj.pl doda drugie API, będzie to po prostu trzeci wiersz z "
  "`SourcePlatformKey` = 1.",
  wiersze=[(1, 1, 1, 1, 1, 1, "Partner API", "https://api.pracuj.example/docs"),
           (2, 2, 6, 2, 5, 1, "Kanał ofert pracy", None)],
  pokaz=["PlatformAPIKey", "SourcePlatformKey", "APITypeKey", "DataFormatKey", "AuthMethodKey", "APIDirectionKey",
         "PlatformAPIName"])
p("APIDirection", "Przykład na danych – oba kierunki:",
  "Oba kanały z przykładu (`PlatformAPI`) mają kierunek 1 – sami pytamy o dane. Powiadomienie wysyłane przez "
  "platformę (webhook) miałoby kierunek 2.")
p("APIVersion", "Przykład na danych – wersje obu kanałów:",
  "„Partner API” pracuj.pl ma dwie wersje. Z v2 korzystamy teraz (`IsInUse` = 1), a v1 platforma wyłączy 30 czerwca "
  "2027. Drugiej używanej wersji tego samego API baza nie przyjmie, a daty wyłączenia wcześniejszej niż data wydania – "
  "też nie. Nazwa „v1” może się powtórzyć w API innej platformy, ale w jednym API jest tylko raz.",
  wiersze=[(1, 1, "v1", "2023-03-01", "2027-06-30", 0),
           (2, 1, "v2", "2025-09-01", None, 1),
           (3, 2, "1.0", "2024-05-01", None, 1)])
p("EnvironmentType", "Przykład na danych – oba rodzaje środowisk:",
  "Wersja v2 API pracuj.pl ma oba środowiska (`APIEnvironment`): testowe (1) i produkcyjne (2).")
p("APIEnvironment", "Przykład na danych – środowiska wersji API pracuj.pl (adresy są wymyślone):",
  "Wersja v2 ma osobny adres testowy i produkcyjny, każdy z własnym limitem zapytań na minutę. Wersja v1 ma już tylko "
  "środowisko produkcyjne. Para „wersja – rodzaj środowiska” nie może się powtórzyć: drugiego środowiska "
  "produkcyjnego dla v2 baza nie przyjmie.",
  wiersze=[(1, 2, 1, "https://sandbox.api.pracuj.example/v2", 60),
           (2, 2, 2, "https://api.pracuj.example/v2", 600),
           (3, 1, 2, "https://api.pracuj.example/v1", 300)])
p("HTTPMethod", "Przykład na danych – lista metod:",
  "Endpointy z przykładu (`APIEndpoint`) to głównie GET – pobranie danych. Prośba o przypomnienie dla kandydata to "
  "POST – wysłanie danych do platformy.")
p("DataSubject", "Przykład na danych – lista rodzajów danych:",
  "Endpoint /v2/jobs zwraca ogłoszenia (2), a /v2/applications – aplikacje kandydatów (4). Ten sam numer jest przy "
  "naszych nazwach pól (`CanonicalField`): „Wynagrodzenie od” dotyczy ogłoszenia.")
p("APIEndpoint", "Przykład na danych – endpointy obu kanałów:",
  "Ogłoszenia w wersji v2 są pod /v2/jobs, a w starej v1 – pod /v1/offers, dlatego endpoint należy do wersji, a nie do "
  "całego API. Ta sama ścieżka z tą samą metodą może być w jednej wersji tylko raz. `IsPaginated` = 1 znaczy, że "
  "wyniki przychodzą stronami, więc program musi pobrać kolejne strony.",
  wiersze=[(1, 2, 1, 2, "/v2/jobs", 1, "Nowe i zmienione ogłoszenia"),
           (2, 2, 1, 1, "/v2/employers/{id}", 0, "Dane jednego konta firmy"),
           (3, 2, 1, 4, "/v2/applications", 1, "Aplikacje z pseudonimem kandydata"),
           (4, 2, 2, 4, "/v2/applications/{id}/reminders", 0, "Prośba o przypomnienie dla kandydata"),
           (5, 1, 1, 2, "/v1/offers", 1, "Ogłoszenia – stara wersja"),
           (6, 3, 1, 2, "/praca/rss", 0, "Kanał nowych ofert pracy OLX")],
  pokaz=["APIEndpointKey", "APIVersionKey", "HTTPMethodKey", "DataSubjectKey", "EndpointPath", "IsPaginated"])
p("EndpointResponse", "Przykład na danych – możliwe odpowiedzi trzech endpointów:",
  "GET /v2/jobs może odpowiedzieć na trzy sposoby: 200 (są dane), 429 (za dużo zapytań) albo 401 (zły klucz). Kod "
  "HTTP jest tekstem z trzech cyfr, a nie liczbą – to kod, a nie ilość. Przy odpowiedzi z błędem "
  "(`IsErrorResponse` = 1) program wie, że ma zapisać błąd dostawy, a nie szukać danych.",
  wiersze=[(1, 1, "200", 1, 0, "Lista ogłoszeń"),
           (2, 1, "429", 1, 1, "Za dużo zapytań – trzeba poczekać"),
           (3, 1, "401", 1, 1, "Odrzucony klucz API"),
           (4, 3, "200", 1, 0, "Lista aplikacji"),
           (5, 6, "200", 2, 0, "Lista ofert w XML")])
p("FieldDataType", "Przykład na danych – lista typów pól:",
  "W odpowiedzi GET /v2/jobs (`EndpointData`) pole salary ma typ 8 – Obiekt, bo zawiera inne pola, a salary.from – "
  "typ 3 – Liczba dziesiętna.")
p("EndpointData", "Przykład na danych – pola w odpowiedziach (tu jest pętla z diagramu):",
  "Pole salary to obiekt, w którym są pola from, to i currency. Każde z nich wskazuje na salary przez "
  "`ParentEndpointDataKey` = 3 – to klucz obcy do tej samej tabeli, dlatego na diagramie linia wychodzi z tabeli i do "
  "niej wraca. Pola na najwyższym poziomie mają tę kolumnę pustą, dlatego linia jest przerywana. Ścieżka "
  "(`DataPath`) nie może się powtórzyć w jednej odpowiedzi.",
  wiersze=[(1, 1, None, "id", "id", 1, 1, "1004567"),
           (2, 1, None, "title", "title", 1, 1, "Magazynier/ka – praca od zaraz"),
           (3, 1, None, "salary", "salary", 8, 0, None),
           (4, 1, 3, "from", "salary.from", 3, 0, "5200"),
           (5, 1, 3, "to", "salary.to", 3, 0, "6000"),
           (6, 1, 3, "currency", "salary.currency", 1, 0, "PLN"),
           (7, 4, None, "applied_at", "applied_at", 6, 1, "2026-11-04T17:20:00Z"),
           (8, 5, None, "wynagrodzenie_min", "wynagrodzenie_min", 2, 0, "500000")],
  pokaz=["EndpointDataKey", "EndpointResponseKey", "ParentEndpointDataKey", "DataName", "DataPath", "FieldDataTypeKey",
         "ExampleValue"])
p("CanonicalField", "Przykład na danych – nasze nazwy pól:",
  "Nasza nazwa jest jedna, niezależnie od platformy: „Wynagrodzenie od” (1) to i salary.from z pracuj.pl, i "
  "wynagrodzenie_min z OLX – zobacz `FieldMapping`.")
p("FieldMapping", "Przykład na danych – trzy pola platform przypisane do naszych nazw:",
  "Dwa różne pola – salary.from z pracuj.pl i wynagrodzenie_min z OLX – prowadzą do jednej naszej nazwy "
  "„Wynagrodzenie od”. OLX podaje kwotę w groszach, więc zapisujemy regułę przeliczenia. Dalsze organizmy korzystają "
  "już tylko z naszych nazw i nie muszą wiedzieć, jak nazywa je każda platforma.",
  wiersze=[(1, 4, 1, None),
           (2, 8, 1, "grosze na złote: /100"),
           (3, 7, 4, "czas UTC na czas polski")])

# ───────────── 4. Odbiór danych z platformy ─────────────
p("DeliveryMode", "Przykład na danych – lista sposobów dostawy:",
  "Wszystkie dostawy z przykładu (`DataDelivery`) mają sposób 1 – sami pobieramy dane o ustalonej porze.")
p("DeliveryStatus", "Przykład na danych – lista wyników dostawy:",
  "Dostawa z 3 listopada o 6:00 skończyła się wynikiem 3 – Zakończona częściowo (2 ze 120 rekordów odrzucone), a ta o "
  "7:00 – wynikiem 4 – Nieudana (`DataDelivery`).")
p("DataDelivery", "Przykład na danych – cztery dostawy z pracuj.pl:",
  "Dostawa 1 to poranne pobranie ogłoszeń: przyszło 120 rekordów, przyjęliśmy 118. Dostawa 2 godzinę później się nie "
  "udała (za dużo zapytań) – też ją zapisujemy, żeby wiedzieć, że wtedy nie mamy danych. Dostawy 3 i 4 to aplikacje "
  "kandydatów. Baza nie przyjmie więcej przyjętych rekordów niż otrzymanych ani końca przed początkiem.",
  wiersze=[(1, 1, 1, 3, "2026-11-03 06:00", "2026-11-03 06:02", 120, 118),
           (2, 1, 1, 4, "2026-11-03 07:00", "2026-11-03 07:00", 0, 0),
           (3, 3, 1, 2, "2026-11-04 19:00", "2026-11-04 19:01", 35, 35),
           (4, 3, 1, 2, "2026-11-05 19:00", "2026-11-05 19:01", 28, 28)],
  pokaz=["DataDeliveryKey", "APIEndpointKey", "DeliveryStatusKey", "StartedAt", "FinishedAt", "RecordsReceived",
         "RecordsAccepted"])
p("RawRecord", "Przykład na danych – cztery surowe rekordy (treść i skrót skrócone):",
  "Rekord 1 to ogłoszenie „Magazynier/ka” firmy Przykład Logistyka. Rekordom 2 i 3 brakuje wymaganych pól – i tak je "
  "zapisujemy, a błędy są w `DeliveryError`. Po skrócie treści (`PayloadHash`) program poznaje, że platforma "
  "przysłała drugi raz dokładnie to samo.",
  wiersze=[(1, 1, "1004567", '{"id": "1004567", "title": "Magazynier/ka – praca od zaraz", "salary": {…}}',
            "9f2c41ab…e07d", "2026-11-03 06:01"),
           (2, 1, "1004568", '{"id": "1004568", "title": null, …}', "51d0c8e2…a913", "2026-11-03 06:01"),
           (3, 1, "1004571", '{"id": "1004571", "employer_id": null, …}', "07be33f1…c4d2", "2026-11-03 06:01"),
           (4, 3, "APP-88213", '{"candidate": "c3f9a7e1…", "job_id": "1004567", …}', "d41e9b07…5a6c",
            "2026-11-04 19:00")],
  pokaz=["RawRecordKey", "DataDeliveryKey", "ExternalRecordId", "RecordPayload", "PayloadHash", "ReceivedAt"])
p("DeliveryError", "Przykład na danych – trzy błędy:",
  "Błędy 1 i 2 dotyczą pojedynczych rekordów z dostawy 1. Błąd 3 dotyczy całej dostawy 2, dlatego `RawRecordKey` "
  "jest pusty – żaden rekord nie przyszedł.",
  wiersze=[(1, 1, 2, 1, "Brak pola title", "2026-11-03 06:01"),
           (2, 1, 3, 1, "Brak pola employer_id", "2026-11-03 06:01"),
           (3, 2, None, 4, "Odpowiedź 429: za dużo zapytań", "2026-11-03 07:00")])
p("ErrorType", "Przykład na danych – lista rodzajów błędów:",
  "W przykładzie (`DeliveryError`) są dwa błędy rodzaju 1 – brak wymaganego pola – i jeden rodzaju 4 – przekroczony "
  "limit zapytań.")

# ───────────── 5. Konto firmy na platformie ─────────────
p("AccountType", "Przykład na danych – lista rodzajów konta:",
  "Konto 77120 na pracuj.pl ma rodzaj 1 – Firma, a konto „Praca od zaraz – Kraków” na OLX – rodzaj 2 – Agencja "
  "rekrutacyjna (`EmployerAccount`).")
p("AccountStatus", "Przykład na danych – lista stanów konta:",
  "Wszystkie wersje kont z przykładu (`EmployerAccountVersion`) mają stan 1 – Aktywne. Gdyby platforma zawiesiła "
  "konto, powstałaby nowa wersja ze stanem 2.")
p("EmployerAccount", "Przykład na danych – trzy konta na platformach:",
  "Konto 1 i konto 3 mają ten sam numer 77120, ale na różnych platformach – to dwa różne konta, więc baza je przyjmie. "
  "Nie przyjmie drugiego konta 77120 na pracuj.pl. Nazwy konta tu nie ma, bo nazwa się zmienia – jest w wersjach "
  "konta.",
  wiersze=[(1, 1, "77120", 1, "2026-11-03 06:01"),
           (2, 2, "3108842", 2, "2026-11-03 09:15"),
           (3, 2, "77120", 3, "2026-11-05 12:40")])
p("EmployerAccountVersion", "Przykład na danych – wersje danych trzech kont:",
  "20 listopada konto 77120 zmieniło nazwę: pierwsza wersja dostała datę końca i flagę 0, a druga – z nową nazwą – "
  "flagę 1. Konto z OLX też podaje NIP 1234563218 – na tej podstawie organizm 7 połączy je z firmą. Drugiej aktualnej "
  "wersji tego samego konta baza nie przyjmie.",
  wiersze=[(1, 1, "Przykład Logistyka", "1234563218", "przyklad-logistyka.pl", 1, 0, "2026-11-03 06:01",
            "2026-11-20 10:00", 0, 1),
           (2, 1, "PL Logistics Kraków", "1234563218", "przyklad-logistyka.pl", 1, 0, "2026-11-20 10:00", None, 1, None),
           (3, 2, "Praca od zaraz – Kraków", "1234563218", None, 1, 0, "2026-11-03 09:15", None, 1, None),
           (4, 3, "Konto prywatne", None, None, 1, 0, "2026-11-05 12:40", None, 1, None)],
  pokaz=["EmployerAccountVersionKey", "EmployerAccountKey", "AccountName", "DeclaredNIP", "ValidFrom", "ValidTo",
         "IsCurrent"])

# ───────────── 6. Firma w rejestrach publicznych ─────────────
p("LegalForm", "Przykład na danych – cała lista form prawnych:",
  "`LegalFormKey` to zwykły numer wiersza. Kod 099 zapisany jako liczba zamieniłby się w 99, dlatego kod jest tekstem, "
  "a baza sprawdza, że ma dokładnie trzy cyfry. Dwie ostatnie formy nie mają jednego kodu, więc kolumna jest pusta. "
  "Firma Przykład Logistyka (`Employer`) ma formę 1 – spółka z o.o.")
p("PKDClassification", "Przykład na danych – dwie wersje klasyfikacji:",
  "Wszystkie kody w przykładzie (`PKDCode`) są z klasyfikacji 1 – PKD 2007. Kody z PKD 2025 będą osobnymi wierszami z "
  "`PKDClassificationKey` = 2, bo ten sam symbol może w nowej klasyfikacji znaczyć co innego.")
p("PKDCode", "Przykład na danych – trzy kody działalności:",
  "Symbol ma stały format: dwie cyfry, kropka, dwie cyfry, kropka, wielka litera – inny baza odrzuci. Symbol nie jest "
  "kluczem: kluczem jest `PKDCodeKey`, bo ten sam symbol może się pojawić w dwóch wersjach klasyfikacji.",
  wiersze=[(1, "52.10.B", "Magazynowanie i przechowywanie pozostałych towarów", 1),
           (2, "49.41.Z", "Transport drogowy towarów", 1),
           (3, "78.10.Z", "Działalność związana z wyszukiwaniem miejsc pracy i pozyskiwaniem pracowników", 1)])
p("EmployerIdentifier", "Przykład na danych – numery dwóch firm:",
  "Przykład Logistyka ma trzy numery, więc ma trzy wiersze – a nie trzy kolumny. Numer KRS 0000123456 zaczyna się od "
  "zer, dlatego numer jest tekstem. Ten sam numer tego samego rodzaju może być w bazie tylko raz: drugiego wiersza z "
  "NIP-em 1234563218 baza nie przyjmie.",
  wiersze=[(1, 1, 1, "1234563218", 1),
           (2, 1, 2, "123456785", 1),
           (3, 1, 3, "0000123456", 1),
           (4, 2, 1, "9876543210", 1)])
p("Employer", "Przykład na danych – dwie firmy:",
  "To dwie osobne firmy, choć jedna rekrutuje dla drugiej (organizm 7). Status Przykład Logistyka to teraz „W "
  "likwidacji” – zmienił się po sprawdzeniu w KRS 5 grudnia, a poprzedni status widać w historii sprawdzeń "
  "(`RegistryCheck`).",
  wiersze=[(1, "Przykład Logistyka sp. z o.o.", 1, 1, 3, "2019-03-12"),
           (2, "Kadry Przykład sp. z o.o.", 1, 1, 1, "2015-06-01")])
p("EmployerPKD", "Przykład na danych – działalności dwóch firm:",
  "Przykład Logistyka ma działalność główną (magazynowanie) i dodatkową (transport). Kadry Przykład kiedyś też "
  "zajmowała się transportem, ale od 2021 roku już nie – ten wiersz jest zamknięty, a nie usunięty. Główna "
  "działalność może być tylko jedna, a ta sama para „firma – kod” może być aktualna tylko raz.",
  wiersze=[(1, 1, 1, 1, "2019-03-12", None, 1),
           (2, 1, 2, 0, "2019-03-12", None, 1),
           (3, 2, 3, 1, "2015-06-01", None, 1),
           (4, 2, 2, 0, "2015-06-01", "2020-12-31", 0)])
p("IdentifierType", "Przykład na danych – lista rodzajów numerów:",
  "Numery z przykładu (`EmployerIdentifier`) są trzech rodzajów: NIP (1), REGON (2) i KRS (3). Opis formatu "
  "(`ValueFormat`) mówi programowi, jak sprawdzić numer.")
p("RegistryCheck", "Przykład na danych – trzy sprawdzenia firmy Przykład Logistyka:",
  "5 listopada KRS podał status „Aktywna”, a 5 grudnia – „W likwidacji”. Drugie sprawdzenie to nowy wiersz, pierwsze "
  "zostaje bez zmian, więc widać, kiedy status się zmienił. Biała lista VAT nie podaje statusu z naszej listy, więc "
  "ta kolumna jest pusta.",
  wiersze=[(1, 1, 1, "2026-11-05 10:00", 1, 1, "PRZYKŁAD LOGISTYKA SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ"),
           (2, 1, 4, "2026-11-05 10:01", 1, None, "PRZYKŁAD LOGISTYKA SP. Z O.O."),
           (3, 1, 1, "2026-12-05 10:00", 1, 3,
            "PRZYKŁAD LOGISTYKA SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ W LIKWIDACJI")],
  pokaz=["RegistryCheckKey", "EmployerKey", "PublicRegistryKey", "CheckedAt", "WasFound", "ReportedStatusKey"])
p("EmployerStatus", "Przykład na danych – lista statusów:",
  "Firma Przykład Logistyka (`Employer`) ma teraz status 3 – W likwidacji, a Kadry Przykład – 1 – Aktywna. Z tej samej "
  "listy zapisujemy, co podał rejestr przy sprawdzeniu.")
p("PublicRegistry", "Przykład na danych – lista rejestrów:",
  "Przy każdym rejestrze jest rodzaj numeru, po którym w nim szukamy: KRS – po numerze KRS (3), CEIDG i białą listę – "
  "po NIP (1). Limit zapytań na dzień jest pusty, bo go jeszcze nie znamy.")

# ───────────── 7. Powiązanie kont z firmą ─────────────
p("MatchMethod", "Przykład na danych – lista sposobów powiązania:",
  "Konto 77120 połączyliśmy z firmą sposobem 1 – Ten sam NIP, a konto z OLX z agencją – sposobem 3 – Decyzja "
  "moderatora (`AccountEmployerLink`).")
p("LinkEvidence", "Przykład na danych – dowody przy trzech powiązaniach:",
  "Powiązanie 1 ma dwa dowody, a powiązania 2 i 3 – po jednym. Dowód należy do powiązania (pary „konto – firma”), a "
  "nie do samego konta: gdy konto przenosimy do innej firmy, dowody starego powiązania zostają przy nim.",
  wiersze=[(1, 1, 1, "NIP 1234563218 w koncie i w rejestrze"),
           (2, 1, 3, "przyklad-logistyka.pl"),
           (3, 2, 1, "NIP 1234563218 w koncie i w rejestrze"),
           (4, 3, 4, "Adres w koncie to adres agencji z KRS")])
p("AccountEmployerLink", "Przykład na danych – powiązania dwóch kont:",
  "Konto z OLX najpierw połączyliśmy z Przykład Logistyka, bo podało ten sam NIP. 6 listopada moderator przeniósł je "
  "do agencji Kadry Przykład: stare powiązanie dostało datę rozłączenia i flagę 0, nowe – flagę 1. Konto może mieć "
  "tylko jedno aktywne powiązanie, a pewność (`MatchConfidence`) musi być między 0 a 1.",
  wiersze=[(1, 1, 1, 1, 0.98, "2026-11-03 06:05", None, 1),
           (2, 2, 1, 1, 0.9, "2026-11-03 09:20", "2026-11-06 14:00", 0),
           (3, 2, 2, 3, 1.0, "2026-11-06 14:00", None, 1)])
p("AgencyClient", "Przykład na danych – agencja i jej klient:",
  "Oba klucze prowadzą do tej samej tabeli firm: `AgencyEmployerKey` = 2 to agencja, a `ClientEmployerKey` = 1 – "
  "firma, dla której agencja rekrutuje. Baza nie przyjmie wiersza, w którym firma byłaby agencją sama dla siebie. Gdy "
  "współpraca się skończy, wiersz dostanie datę końca i flagę 0.",
  wiersze=[(1, 2, 1, "2026-11-01", None, 1)])
p("EvidenceType", "Przykład na danych – lista rodzajów dowodu:",
  "W przykładzie (`LinkEvidence`) są dowody trzech rodzajów: zgodny NIP (1), ta sama domena (3) i ten sam adres (4).")
p("LinkChange", "Przykład na danych – historia zmian powiązań:",
  "Pierwsze dwa połączenia zrobił program, dlatego `SystemUserKey` jest pusty. Przeniesienie konta z OLX zrobił "
  "moderator (użytkownik 1) – zapisujemy, kto to zrobił i dlaczego. Wierszy w tej tabeli się nie poprawia ani nie "
  "usuwa.",
  wiersze=[(1, 1, 1, "2026-11-03 06:05", None, None),
           (2, 2, 1, "2026-11-03 09:20", None, None),
           (3, 2, 3, "2026-11-06 14:00", "Konto należy do agencji Kadry Przykład, która rekrutuje dla tej firmy", 1),
           (4, 3, 1, "2026-11-06 14:00", "Nowe powiązanie z agencją", 1)])
p("LinkChangeType", "Przykład na danych – lista rodzajów zmiany:",
  "W historii z przykładu (`LinkChange`) są trzy zmiany rodzaju 1 – Połączono i jedna rodzaju 3 – Przeniesiono do "
  "innej firmy.")

# ───────────── 8. Ogłoszenie i miejsce pracy ─────────────
p("PostingStatus", "Przykład na danych – lista stanów ogłoszenia:",
  "Ogłoszenie „Magazynier/ka” z listopada (`JobPosting`) ma stan 1 – Aktywne, a to samo stanowisko z października – "
  "stan 2 – Wygasłe.")
p("SeniorityLevel", "Przykład na danych – lista poziomów:",
  "Kolejność (`SeniorityRank`) pozwala porównać poziomy: Mid (3) jest wyżej niż Junior (2). Ogłoszenie "
  "„Specjalista/ka ds. planowania transportu” (`PostingSeniority`) szuka dwóch poziomów naraz: 2 i 3.")
p("JobPosting", "Przykład na danych – cztery ogłoszenia:",
  "Ogłoszenia 1, 3 i 4 opublikowało to samo konto 77120 z pracuj.pl, a ogłoszenie 2 – konto agencji na OLX. Agencja "
  "nie podała liczby osób ani daty końca, więc te kolumny są puste. Poziomów i trybów pracy tu nie ma, bo ogłoszenie "
  "może mieć ich kilka – są w osobnych tabelach.",
  wiersze=[(1, 1, "1004567", "Magazynier/ka – praca od zaraz", 1, 3, "2026-11-03", "2026-12-03", 1),
           (2, 2, "889120", "Magazynier/ka od zaraz – Kraków", 1, None, "2026-11-03", None, None),
           (3, 1, "1001890", "Magazynier/ka", 2, 3, "2026-10-02", "2026-11-01", None),
           (4, 1, "1004890", "Specjalista/ka ds. planowania transportu", 1, 1, "2026-11-10", "2026-12-10", None)],
  pokaz=["JobPostingKey", "EmployerAccountKey", "ExternalPostingId", "PostingTitle", "PostingStatusKey", "VacancyCount",
         "PublishedDate", "ExpiryDate"])
p("PostingSeniority", "Przykład na danych – poziomy jednego ogłoszenia:",
  "Ogłoszenie 4 szuka osoby na poziomie Junior albo Mid, więc ma dwa wiersze – jak lekarz z dwiema specjalizacjami. "
  "Ogłoszenie „Magazynier/ka” nie ma tu żadnego wiersza, bo firma nie podała poziomu. Ta sama para „ogłoszenie – "
  "poziom” może być tylko raz.",
  wiersze=[(1, 4, 2), (2, 4, 3)])
p("WorkMode", "Przykład na danych – lista trybów pracy:",
  "„Magazynier/ka” ma tryb 1 – Stacjonarna, a „Specjalista/ka ds. planowania transportu” – dwa tryby: 2 – Hybrydowa i "
  "3 – Zdalna (`PostingWorkMode`).")
p("PostingWorkMode", "Przykład na danych – tryby pracy czterech ogłoszeń:",
  "Trzy ogłoszenia magazyniera mają po jednym trybie, a ogłoszenie 4 – dwa naraz: hybrydowy albo zdalny. Gdyby tryb "
  "był kolumną w tabeli ogłoszeń, drugi tryb nie miałby gdzie się zmieścić.",
  wiersze=[(1, 1, 1), (2, 2, 1), (3, 3, 1), (4, 4, 2), (5, 4, 3)])
p("PostingLocation", "Przykład na danych – miejsca pracy ogłoszeń:",
  "Ogłoszenie 1 ma dwa miejsca pracy: Kraków (główne, flaga 1) i Wieliczkę. Główne miejsce może być tylko jedno – "
  "drugiego wiersza ogłoszenia 1 z flagą 1 baza nie przyjmie.",
  wiersze=[(1, 1, 1, 1), (2, 1, 2, 0), (3, 2, 1, 1), (4, 3, 1, 1), (5, 4, 1, 1)])
p("Location", "Przykład na danych – trzy miejscowości:",
  "Kraków ma urzędowy kod SIMC z rejestru TERYT – tekst z 7 cyfr, bo może zaczynać się od zera. Wieliczka nie ma "
  "jeszcze wpisanego kodu: kolumna może być pusta, a gdy ją uzupełnimy, baza nie pozwoli, żeby dwie miejscowości "
  "miały ten sam kod. Berlin leży za granicą, więc nie ma kodu SIMC ani polskiego województwa.",
  wiersze=[(1, "Kraków", "0950463", 6, 1),
           (2, "Wieliczka", None, 6, 1),
           (3, "Berlin", None, None, 2)])
p("Region", "Przykład na danych – początek listy województw:",
  "Kod województwa z rejestru TERYT (np. 12 – małopolskie) jest tekstem, a numerem wiersza jest `RegionKey`. Kraków i "
  "Wieliczka (`Location`) mają `RegionKey` = 6, czyli małopolskie. Każde województwo wskazuje kraj – Polskę (1); "
  "regiony innych krajów dopiszemy tak samo.", ile=6)

# ───────────── 9. Warunki zatrudnienia ─────────────
p("Currency", "Przykład na danych – lista walut:",
  "Widełki ogłoszenia „Magazynier/ka” (`PostingSalary`) są w złotych – `CurrencyKey` = 1. Kod waluty to tekst z "
  "trzech wielkich liter.")
p("ContractType", "Przykład na danych – lista rodzajów umowy:",
  "Ogłoszenie „Magazynier/ka” daje do wyboru umowę o pracę (1) albo umowę zlecenie (3) – zobacz `PostingSalary`.")
p("SalaryPeriod", "Przykład na danych – lista okresów:",
  "Umowa o pracę w ogłoszeniu „Magazynier/ka” ma kwoty miesięczne (2), a umowa zlecenie – za godzinę (1).")
p("PostingSalary", "Przykład na danych – widełki dwóch ogłoszeń:",
  "Ogłoszenie 1 daje do wyboru dwie umowy, więc ma dwa aktualne wiersze – po jednym na umowę. 24 listopada firma "
  "obniżyła widełki umowy o pracę: stary wiersz (1) dostał datę końca i flagę 0, a nowy (3) – flagę 1. Agencja na OLX "
  "nie podała kwot, więc wiersz 4 ma puste kwoty – brak widełek też jest informacją. Baza nie przyjmie kwoty „od” "
  "większej niż „do” ani kwot bez waluty i okresu.",
  wiersze=[(1, 1, 1, 5200, 6000, 1, 2, 1, "2026-11-03 06:01", "2026-11-24 06:00", 0),
           (2, 1, 3, 32, 36, 1, 1, 1, "2026-11-03 06:01", None, 1),
           (3, 1, 1, 4800, 5500, 1, 2, 1, "2026-11-24 06:00", None, 1),
           (4, 2, 1, None, None, None, None, None, "2026-11-03 09:20", None, 1)],
  pokaz=["PostingSalaryKey", "JobPostingKey", "ContractTypeKey", "SalaryFrom", "SalaryTo", "SalaryPeriodKey",
         "ValidFrom", "ValidTo", "IsCurrent"])
p("PostingBenefit", "Przykład na danych – benefity ogłoszenia „Magazynier/ka”:",
  "Dwa benefity to dwa wiersze. Ten sam benefit może być przy ogłoszeniu tylko raz.",
  wiersze=[(1, 1, 1), (2, 1, 2)])
p("Benefit", "Przykład na danych – lista benefitów:",
  "Każdy benefit należy do grupy: prywatna opieka medyczna – do grupy 1 (Zdrowie), karta sportowa – do grupy 2 (Sport "
  "i rekreacja). Nazwa benefitu nie może się powtórzyć.")
p("BenefitCategory", "Przykład na danych – lista grup benefitów:",
  "Grupy pozwalają porównać ogłoszenia, nawet gdy firmy nazywają benefity inaczej. Oba benefity ogłoszenia "
  "„Magazynier/ka” są z grup 1 i 2.")

# ───────────── 10. Wymagania i obowiązki ─────────────
p("RequirementLevel", "Przykład na danych – oba poziomy wymagania:",
  "W ogłoszeniu „Magazynier/ka” (`PostingRequirement`) prawo jazdy i uprawnienia UDT są wymagane (1), a angielski i "
  "komunikatywność – mile widziane (2).")
p("PostingResponsibility", "Przykład na danych – obowiązki ogłoszenia „Magazynier/ka”:",
  "Każdy obowiązek to osobny wiersz z jednym zdaniem. Zapisujemy też, jak go znaleźliśmy: oba znalazł model AI (3), "
  "więc w razie wątpliwości wiadomo, że trzeba je sprawdzić.",
  wiersze=[(1, 1, "Kompletowanie zamówień według listy", 3),
           (2, 1, "Rozładunek i przyjmowanie dostaw", 3)])
p("ProficiencyLevel", "Przykład na danych – lista poziomów znajomości:",
  "Poziom należy do grupy umiejętności: A2–C1 to poziomy języka (grupa 3), a „Podstawowy”–„Zaawansowany” – poziomy "
  "narzędzi (grupa 1). Wymaganie angielskiego w ogłoszeniu „Magazynier/ka” ma poziom 2 – B1.")
p("PostingRequirement", "Przykład na danych – wymagania ogłoszenia „Magazynier/ka”:",
  "Cztery wymagania to cztery wiersze. Poziom jest tylko przy języku, a lata doświadczenia – tylko przy uprawnieniach "
  "UDT, dlatego te kolumny mogą być puste. Ta sama umiejętność może być w ogłoszeniu tylko raz, a liczba lat nie może "
  "być ujemna.",
  wiersze=[(1, 1, 5, 1, None, None, 3),
           (2, 1, 6, 1, None, 1, 3),
           (3, 1, 2, 2, 2, None, 3),
           (4, 1, 3, 2, None, None, 3)],
  pokaz=["PostingRequirementKey", "JobPostingKey", "SkillKey", "RequirementLevelKey", "ProficiencyLevelKey",
         "MinYearsExperience"])
p("ExtractionMethod", "Przykład na danych – lista sposobów odczytania:",
  "Wszystkie wymagania i obowiązki z przykładu znalazł model AI (3). Gdyby platforma podała umiejętności w osobnym "
  "polu API, zapisalibyśmy sposób 1.")
p("SkillCategory", "Przykład na danych – lista grup umiejętności:",
  "Prawo jazdy i uprawnienia UDT są w grupie 6 – Uprawnienie, a język angielski – w grupie 3 – Język obcy (`Skill`).")
p("Skill", "Przykład na danych – lista umiejętności:",
  "Lista jest wspólna dla wszystkich ogłoszeń: ogłoszenie zapisuje tylko numer umiejętności. Uprawnienia UDT (6) "
  "dopisaliśmy jednym wierszem, gdy pojawiły się w ogłoszeniu „Magazynier/ka”.",
  dodatkowe=[(6, "Uprawnienia UDT na wózek widłowy", 6)])
p("SkillSynonym", "Przykład na danych – inne zapisy umiejętności:",
  "Firma napisała „angielski komunikatywny” – program znajduje tu słowo „angielski” i wie, że chodzi o umiejętność 2 – "
  "Język angielski. Ten sam zapis może prowadzić tylko do jednej umiejętności.")

# ───────────── 11. Historia i treść ogłoszenia ─────────────
p("EventSource", "Przykład na danych – lista źródeł informacji:",
  "Większość zdarzeń ogłoszenia „Magazynier/ka” (`PostingEvent`) zgłosiła platforma (1); zmianę treści wykrył nasz "
  "program (2).")
p("PostingEventType", "Przykład na danych – lista rodzajów zdarzeń:",
  "Ogłoszenie „Magazynier/ka” ma w historii zdarzenia rodzajów 1, 2, 3, 4 i 6 – zobacz `PostingEvent`.")
p("PostingEvent", "Przykład na danych – historia ogłoszenia „Magazynier/ka”:",
  "Każde zdarzenie to nowy wiersz – wierszy się nie zmienia ani nie usuwa. Z tej listy widać, że ogłoszenie było "
  "odświeżane co tydzień, wygasło 3 grudnia i po dwóch dniach wróciło. Właśnie takie powtórki liczy organizm 12.",
  wiersze=[(1, 1, 1, 1, "2026-11-03 06:01", 1, None),
           (2, 1, 3, 1, "2026-11-10 06:00", None, None),
           (3, 1, 3, 1, "2026-11-17 06:00", None, None),
           (4, 1, 3, 1, "2026-11-24 06:00", None, None),
           (5, 1, 2, 2, "2026-11-24 06:00", None, None),
           (6, 1, 4, 1, "2026-12-03 00:00", None, None),
           (7, 1, 6, 1, "2026-12-05 06:00", None, None)],
  pokaz=["PostingEventKey", "JobPostingKey", "PostingEventTypeKey", "EventSourceKey", "OccurredAt", "DataDeliveryKey"])
p("PostingVersion", "Przykład na danych – dwie wersje treści (treść i skrót skrócone):",
  "Gdy treść się zmienia, nie nadpisujemy jej: wersja 1 dostaje datę końca i flagę 0, a wersja 2 – flagę 1. Po "
  "skrócie treści (`TextHash`) program od razu widzi, że wersje się różnią. W treści oczyszczonej (`CleanText`) nie ma "
  "już klauzul i stopek.",
  wiersze=[(1, 1, 1, "Magazynier/ka – praca od zaraz", "Szukamy osób do pracy w magazynie w Krakowie…",
            "Szukamy osób do pracy w magazynie w Krakowie…", "a41f2c90…09c2", "2026-11-03 06:01", "2026-11-24 06:00", 0),
           (2, 1, 2, "Magazynier/ka – praca od zaraz",
            "Szukamy osób do pracy w magazynie w Krakowie i Wieliczce… Administratorem Twoich danych jest…",
            "Szukamy osób do pracy w magazynie w Krakowie i Wieliczce…", "c7e25d18…5b10", "2026-11-24 06:00", None, 1)],
  pokaz=["PostingVersionKey", "JobPostingKey", "VersionNumber", "CleanText", "TextHash", "ValidFrom", "ValidTo",
         "IsCurrent"])
p("BoilerplatePattern", "Przykład na danych – trzy powtarzalne fragmenty (treść skrócona):",
  "Klauzula RODO i zgoda na przyszłe rekrutacje są ogólne – pasują do ogłoszeń wielu firm, więc `EmployerKey` jest "
  "pusty. Stopka „O nas” należy tylko do Przykład Logistyka.",
  wiersze=[(1, 2, "Administratorem Twoich danych osobowych jest…", None),
           (2, 1, "Przykład Logistyka to firma magazynowa z Krakowa…", 1),
           (3, 3, "Wyrażam zgodę na przetwarzanie moich danych w przyszłych rekrutacjach…", None)])
p("VersionBoilerplate", "Przykład na danych – fragmenty znalezione w wersji 2:",
  "W wersji 2 ogłoszenia program znalazł trzy fragmenty, więc są trzy wiersze. Ten sam fragment w tej samej wersji "
  "może być zapisany tylko raz.",
  wiersze=[(1, 2, 1), (2, 2, 2), (3, 2, 3)])
p("BoilerplateType", "Przykład na danych – lista rodzajów fragmentów:",
  "W przykładzie (`BoilerplatePattern`) są fragmenty rodzajów 1, 2 i 3.")

# ───────────── 12. Podobne ogłoszenia i rodziny ─────────────
p("SimilarityType", "Przykład na danych – lista rodzajów podobieństwa:",
  "Ogłoszenia z pracuj.pl i z OLX są parą rodzaju 4 – To samo ogłoszenie na innej platformie, a ogłoszenia z "
  "października i listopada – parą rodzaju 2 (`SimilarityPair`).")
p("SimilarityMethod", "Przykład na danych – lista metod:",
  "Każda metoda ma swoje wersje (`SimilarityMethodVersion`), bo program porównujący ogłoszenia będzie poprawiany.")
p("SimilarityMethodVersion", "Przykład na danych – wersje metod:",
  "Każda metoda ma teraz jedną wersję 1.0 z flagą „aktualna”. Gdy poprawimy porównanie tekstu, powstanie wiersz „1.1” "
  "z flagą 1, a wiersz 1 dostanie datę końca i flagę 0 – stare wyniki zostaną przy wersji, którą je policzono.")
p("SimilarityPair", "Przykład na danych – dwie pary podobnych ogłoszeń:",
  "Para to dwa klucze do tej samej tabeli ogłoszeń. Mniejszy numer zawsze stoi pierwszy (baza tego pilnuje), dzięki "
  "czemu para 1–2 nie zapisze się drugi raz jako 2–1. Podobieństwo jest liczbą od 0 do 1.",
  wiersze=[(1, 1, 2, 4, 2, 0.94, "2026-11-03 10:00"),
           (2, 1, 3, 2, 1, 0.88, "2026-11-03 10:00")],
  pokaz=["SimilarityPairKey", "FirstJobPostingKey", "SecondJobPostingKey", "SimilarityTypeKey",
         "SimilarityMethodVersionKey", "SimilarityScore"])
p("FamilyMember", "Przykład na danych – ogłoszenia w rodzinie „Magazynier/ka, Kraków”:",
  "Trzy ogłoszenia magazyniera należą do rodziny. Ogłoszenie 4 program dopisał przez pomyłkę, a następnego dnia je "
  "wypisaliśmy: wiersz został, z datą usunięcia i flagą 0. Ogłoszenie może być aktualnie tylko w jednej rodzinie.",
  wiersze=[(1, 1, 1, "2026-11-03 10:05", None, 1),
           (2, 1, 2, "2026-11-03 10:05", None, 1),
           (3, 1, 3, "2026-11-03 10:05", None, 1),
           (4, 1, 4, "2026-11-10 10:00", "2026-11-11 09:00", 0)])
p("PostingFamily", "Przykład na danych – rodzina ogłoszeń:",
  "Rodzina to jedno stanowisko jednej firmy w czasie: od pierwszej publikacji w marcu do ostatniej 5 grudnia. Baza nie "
  "przyjmie ostatniej publikacji wcześniejszej niż pierwsza.",
  wiersze=[(1, 1, "Magazynier/ka, Kraków", "2026-03-02", "2026-12-05")])
p("FamilyLifecycle", "Przykład na danych – historia rodziny policzona dwa razy:",
  "Co miesiąc liczymy rodzinę od nowa i dopisujemy wiersz – stary zostaje, więc widać zmianę: od 1 listopada przybyła "
  "jedna publikacja i druga platforma (OLX). Jedna rodzina ma najwyżej jedno obliczenie na dzień. Te liczby trafiają "
  "potem do sygnałów (organizm 17).",
  wiersze=[(1, 1, "2026-11-01", 6, 132, 5, 27, 1, 1),
           (2, 1, "2026-12-01", 7, 160, 6, 31, 2, 1)])

# ───────────── 13. Kandydat, aplikacje i zgody ─────────────
# Fala zgłoszeń z 8 grudnia (organizmy 14–16): 12 pseudonimów z jednego urządzenia, co 14 minut od 20:00.
FALA = [(datetime(2026, 12, 8, 20, 0) + timedelta(minutes=14 * i)).strftime("%Y-%m-%d %H:%M") for i in range(12)]
p("CandidatePseudonym", "Przykład na danych – pseudonimy kandydatów (skrócone):",
  "Nie znamy imienia, nazwiska ani e-maila kandydata – tylko ciąg znaków od platformy. Pseudonimy od 3 wzwyż to 12 "
  "pseudonimów z fali zgłoszeń 8 grudnia (organizm 16). Ten sam ciąg na innej platformie byłby inną osobą, dlatego "
  "pseudonim jest unikalny razem z platformą.",
  wiersze=[(1, 1, "c3f9a7e1…4b20", "2026-11-04 19:00"),
           (2, 1, "8b02d4c9…71ee", "2026-11-05 19:00")]
  + [(3 + i, 1, f"f0{i + 1:02d}b7e3…9d{i + 1:02d}", czas) for i, czas in enumerate(FALA)], ile=4)
p("Application", "Przykład na danych – dwie aplikacje na ogłoszenie „Magazynier/ka”:",
  "Aplikacja to para „kandydat – ogłoszenie” z własnym kluczem, bo odwołują się do niej stany, przypomnienia i dowód "
  "aplikacji w organizmie 15 – jak wizyta u lekarza w konkretnej klinice. Ta sama osoba może zaaplikować na to samo "
  "ogłoszenie tylko raz.",
  wiersze=[(1, 1, 1, "2026-11-04 18:20", 3),
           (2, 2, 1, "2026-11-05 08:10", 4)])
p("Consent", "Przykład na danych – zgody jednej osoby:",
  "Zapisujemy, którą wersję treści osoba zobaczyła (1.2 zgody na przypomnienia) i co zdecydowała. Gdyby wycofała "
  "zgodę, powstałby nowy wiersz z `IsGranted` = 0, a stary zostałby bez zmian – tak widać, jaka zgoda obowiązywała "
  "w danym dniu.",
  wiersze=[(1, 1, 2, 1, "2026-11-04 18:25"),
           (2, 1, 3, 1, "2026-12-05 09:58")])
p("ApplicationStatusChange", "Przykład na danych – stany dwóch aplikacji:",
  "Aplikacja 1 była najpierw „Wysłana”, a 6 listopada firma ją wyświetliła – stan aktualny ma flagę 1. Aplikacja może "
  "mieć tylko jeden aktualny stan.",
  wiersze=[(1, 1, 1, "2026-11-04 18:20", 0),
           (2, 1, 2, "2026-11-06 09:00", 1),
           (3, 2, 1, "2026-11-05 08:10", 1)])
p("ApplicationStatus", "Przykład na danych – lista stanów aplikacji:",
  "Aplikacja 1 z przykładu (`ApplicationStatusChange`) przeszła ze stanu 1 do 2. „Zatrudnienie” (6) też zbieramy, bo "
  "liczy się odsetek sukcesów, a nie pojedyncza odmowa.")
p("ConsentTextVersion", "Przykład na danych – wersje treści zgód (treść skrócona):",
  "Gdy zmieniamy treść zgody na przypomnienia, nie poprawiamy starej: wersja 1.1 dostała datę końca i flagę 0, a "
  "pokazujemy wersję 1.2. Dzięki temu przy każdej zgodzie wiadomo, jaki dokładnie tekst ktoś zaakceptował. Każdy "
  "rodzaj zgody ma jedną aktualną wersję.",
  wiersze=[(1, 1, "1.1", "Zgadzam się na przypomnienie o wyniku rekrutacji…", "2026-10-01", "2026-10-31", 0),
           (2, 1, "1.2", "Zgadzam się na jedno przypomnienie po 30 dniach od aplikacji…", "2026-11-01", None, 1),
           (3, 2, "1.0", "Zgadzam się na zapisanie skrótu cech mojego urządzenia na 90 dni…", "2026-11-01", None, 1)],
  pokaz=["ConsentTextVersionKey", "ConsentTypeKey", "VersionLabel", "ConsentText", "ValidFrom", "ValidTo", "IsCurrent"])
p("ConsentType", "Przykład na danych – oba rodzaje zgody:",
  "Osoba z przykładu (`Consent`) dała oba rodzaje zgody: na przypomnienia (1) i na zapisanie skrótu cech urządzenia "
  "(2).")

# ───────────── 14. Zgłoszenie wyniku rekrutacji ─────────────
p("ReportOutcome", "Przykład na danych – lista wyników:",
  "Wszystkie zgłoszenia z przykładu (`RecruitmentReport`) mają wynik 1 – Brak odpowiedzi (cisza).")
p("RecruitmentReport", "Przykład na danych – zgłoszenia o ogłoszeniu „Magazynier/ka”:",
  "Zgłoszenie 1 przyszło po przypomnieniu 1, więc ma jego numer. Zgłoszenia od 2 wzwyż przyszły 8 grudnia wieczorem "
  "przez widżet od 12 różnych pseudonimów – to fala, którą wykrywa organizm 16. Zgłoszeń się nie poprawia: każda ocena "
  "jest osobno, w organizmie 15.",
  wiersze=[(1, 1, 1, 1, 1, 2, 1, "2026-12-05 10:00")]
  + [(2 + i, 3 + i, 1, 1, 1, 1, None, czas) for i, czas in enumerate(FALA)], ile=3,
  pokaz=["RecruitmentReportKey", "CandidatePseudonymKey", "JobPostingKey", "ReportOutcomeKey", "ReportChannelKey",
         "ReminderKey", "ReportedAt"])
p("Reminder", "Przykład na danych – przypomnienia o dwóch aplikacjach:",
  "30 dni po aplikacji prosimy platformę o przypomnienie numer 1. Pierwsza osoba odpowiedziała, druga – nie. "
  "Przypomnienie należy do aplikacji (pary „kandydat – ogłoszenie”), a numer przypomnienia nie może się w niej "
  "powtórzyć.",
  wiersze=[(1, 1, 4, 1, "2026-12-04 10:00"),
           (2, 2, 3, 1, "2026-12-05 10:00")])
p("RecruitmentStage", "Przykład na danych – lista etapów:",
  "Zgłoszenie z 5 grudnia skończyło się na etapie 1 – Po wysłaniu CV. Kolejność (`StageRank`) pozwala policzyć, jak "
  "daleko kandydaci dochodzą w rekrutacjach firmy.")
p("ReportChannel", "Przykład na danych – oba kanały zgłoszenia:",
  "Zgłoszenie 1 przyszło jako odpowiedź na przypomnienie (2), a zgłoszenia z fali 8 grudnia – przez formularz w "
  "widżecie (1).")
p("ReminderStatus", "Przykład na danych – lista stanów przypomnienia:",
  "Przypomnienie pierwszej osoby ma stan 4 – Kandydat odpowiedział, a drugiej – 3 – Bez odpowiedzi (`Reminder`).")

# ───────────── 15. Weryfikacja zgłoszenia ─────────────
p("CheckType", "Przykład na danych – lista sprawdzeń:",
  "Zgłoszenie 1 przeszło wszystkie cztery sprawdzenia (`ReportCheck`), a zgłoszenie 2 z fali – dwa.")
p("VerdictDecision", "Przykład na danych – lista decyzji:",
  "Zgłoszenie 1 ma ocenę 1 – Przyjęte. Zgłoszenia z fali 8 grudnia dostały najpierw 2 – Do moderacji, a po decyzji "
  "moderatora 3 – Odrzucone (`ReportVerdict`).")
p("ReportCheck", "Przykład na danych – sprawdzenia dwóch zgłoszeń:",
  "Zgłoszenie 1 ma cztery sprawdzenia, wszystkie pozytywne. Zgłoszenie 2 z fali nie ma dowodu aplikacji, a z jego "
  "urządzenia przyszło też 11 innych zgłoszeń. Nowe sprawdzenie to nowy wiersz – bez zmiany schematu.",
  wiersze=[(1, 1, 1, 1, "2026-12-05 10:00", "Token Turnstile poprawny"),
           (2, 1, 2, 1, "2026-12-05 10:01", "Platforma potwierdziła aplikację z 4 listopada"),
           (3, 1, 3, 1, "2026-12-05 10:01", "Z tego urządzenia nie było innych zgłoszeń"),
           (4, 1, 4, 1, "2026-12-05 10:02", "Brak fali zgłoszeń o tej firmie"),
           (5, 2, 2, 2, "2026-12-08 20:01", "Brak aplikacji tego pseudonimu na to ogłoszenie"),
           (6, 2, 3, 2, "2026-12-08 23:05", "To samo urządzenie co 11 innych zgłoszeń")])
p("ReportVerdict", "Przykład na danych – oceny zgłoszeń:",
  "Zgłoszenie 1 program przyjął z wagą 0,9 – ocenił program, więc `SystemUserKey` jest pusty. Zgłoszenie 2 program "
  "skierował do moderacji, a moderator (użytkownik 1) je odrzucił: pierwsza ocena została z flagą 0, druga ma flagę 1. "
  "Tak samo jest z pozostałymi 11 zgłoszeniami fali. Do Trust Score bierzemy tylko oceny aktualne.",
  wiersze=[(1, 1, 1, 1, 0.9, "2026-12-05 10:02", 1, None)]
  + [w for i in range(12) for w in ((2 + 2 * i, 2 + i, 2, 1, 0.5, "2026-12-08 23:05", 0, None),
                                     (3 + 2 * i, 2 + i, 3, 1, 0.0, "2026-12-09 09:30", 1, 1))], ile=3)
p("VerdictRuleSet", "Przykład na danych – wersja reguł oceny:",
  "Wszystkie oceny z przykładu policzono według wersji 1.0 – jedynej z flagą 1. Gdy zmienimy reguły, powstanie wiersz "
  "1.1 z flagą 1, a 1.0 dostanie datę końca – dwóch aktualnych wersji naraz baza nie przyjmie.")
p("CheckResult", "Przykład na danych – lista wyników sprawdzenia:",
  "Zgłoszenie 1 ma cztery wyniki 1 – Pozytywny, a zgłoszenie 2 – dwa wyniki 2 – Negatywny (`ReportCheck`).")
p("ReportDevice", "Przykład na danych – urządzenia, z których przyszły zgłoszenia:",
  "Zgłoszenie 1 przyszło z urządzenia 1. Wszystkie 12 zgłoszeń z fali przyszło z tego samego urządzenia 2 – tak "
  "organizm 16 rozpoznaje jedno urządzenie z wieloma pseudonimami. Jedno zgłoszenie ma najwyżej jedno urządzenie.",
  wiersze=[(1, 1, 1)] + [(2 + i, 2 + i, 2) for i in range(12)], ile=3)
p("DeviceFingerprint", "Przykład na danych – dwa urządzenia (skrót skrócony):",
  "Zapisujemy tylko skrót cech urządzenia, a nie same cechy, i datę usunięcia – 90 dni po pierwszym zgłoszeniu. Ten "
  "sam skrót może być w bazie tylko raz.",
  wiersze=[(1, "e5a1c3d9…77d0", "2026-12-05 09:59", "2027-03-05"),
           (2, "0c9d4e2b…aa31", "2026-12-08 20:00", "2027-03-08")])

# ───────────── 16. Wykrywanie nadużyć ─────────────
p("AlertType", "Przykład na danych – lista rodzajów alertu:",
  "Alert z 8 grudnia (`AbuseAlert`) ma rodzaj 3 – Jedno urządzenie, wiele pseudonimów.")
p("AlertStatus", "Przykład na danych – lista stanów alertu:",
  "Alert z przykładu przeszedł przez stany 1, 2 i 3 (`AlertStatusChange`). „Fałszywy alarm” (4) zamknąłby alert bez "
  "skutków dla zgłoszeń.")
p("AbuseAlert", "Przykład na danych – alert o fali zgłoszeń:",
  "Alert mówi, kogo dotyczy (Przykład Logistyka), jaki wzorzec wykryto, w jakim okresie i ile było zgłoszeń. Stanu "
  "alertu tu nie ma – stan się zmienia, więc jest w osobnej tabeli z historią.",
  wiersze=[(1, 1, 3, "2026-12-08 20:00", "2026-12-08 23:00", "2026-12-08 23:05", 12)])
p("AlertStatusChange", "Przykład na danych – historia stanów alertu:",
  "Stan „Nowy” nadał program, więc autor jest pusty. Kolejne stany zapisał moderator (użytkownik 1), z komentarzem. "
  "Aktualny stan ma flagę 1 i może być tylko jeden.",
  wiersze=[(1, 1, 1, "2026-12-08 23:05", None, None, 0),
           (2, 1, 2, "2026-12-09 09:00", "Sprawdzam zgłoszenia", 1, 0),
           (3, 1, 3, "2026-12-09 09:30", "Te same cechy urządzenia przy 12 pseudonimach", 1, 1)])
p("AlertReport", "Przykład na danych – zgłoszenia przypisane do alertu:",
  "Alert ma 12 zgłoszeń, więc 12 wierszy – jedno zgłoszenie mogłoby też trafić do kilku alertów. Ta sama para „alert – "
  "zgłoszenie” może być tylko raz.",
  wiersze=[(1 + i, 1, 2 + i) for i in range(12)], ile=3)

# ───────────── 17. Sygnały o firmie ─────────────
p("SignalGroup", "Przykład na danych – lista grup sygnałów:",
  "Każdy sygnał (`SignalType`) należy do jednej z czterech grup, np. powtórki ogłoszeń (1) albo odpowiedzi firmy na "
  "aplikacje (2).")
p("SignalSnapshot", "Przykład na danych – stany sygnałów dwóch firm:",
  "Przykład Logistyka ma dwa stany: na 1 listopada i na 1 grudnia – z ich porównania widać trend. Firma może mieć "
  "tylko jeden stan na dzień. Same wartości sygnałów są w `SignalValue`.",
  wiersze=[(1, 1, "2026-11-01"), (2, 1, "2026-12-01"), (3, 2, "2026-12-01")])
p("SignalValue", "Przykład na danych – wartości sygnałów:",
  "Wiersze 1–6 to stan Przykład Logistyka na 1 grudnia: m.in. 38% powtórek (policzone z 21 ogłoszeń) i 34 zgłoszenia "
  "ciszy na 100 aplikacji (z 410 aplikacji). Wiersz 7 to ten sam sygnał powtórek miesiąc wcześniej – 33%. Każdy sygnał "
  "ma w jednym stanie jedną wartość. Nowy sygnał to nowy wiersz w `SignalType`, a nie nowa kolumna.",
  wiersze=[(1, 2, 1, 38, 21), (2, 2, 2, 4.2, 5), (3, 2, 3, 0.5, 410), (4, 2, 4, 34, 410), (5, 2, 5, 86, 21),
           (6, 2, 6, 2821, None), (7, 1, 1, 33, 18), (8, 3, 1, 10, 4)])
p("SignalType", "Przykład na danych – lista sygnałów:",
  "Przy każdym sygnale jest grupa, jednostka i kierunek: dla powtórek więcej znaczy gorzej (`HigherIsBetter` = 0), a "
  "dla zatrudnień – lepiej (1). Dzięki temu metoda punktowania (organizm 18) nie musi znać znaczenia sygnału.",
  pokaz=["SignalTypeKey", "SignalTypeName", "SignalGroupKey", "MeasureUnitKey", "HigherIsBetter"])
p("MeasureUnit", "Przykład na danych – lista jednostek:",
  "Odsetek powtórek jest w procentach (1), wiek firmy w dniach (2), a zgłoszenia ciszy – na 100 aplikacji (4). "
  "Jednostkę wybieramy z listy, więc nie będzie „%” obok „procent” i „proc.”.")

# ───────────── 18. Trust Score i publikacja ─────────────
p("ScoringMethodType", "Przykład na danych – oba rodzaje metody:",
  "Metoda z przykładu (`ScoringMethod`) to rodzaj 1 – wagi ustalone przez zespół. Gdy wytrenujemy model, dopiszemy "
  "metodę rodzaju 2.")
p("ScoringMethod", "Przykład na danych – metoda liczenia wyniku:",
  "Wersja 1.0 jest jedyną używaną teraz (flaga 1) – drugiej używanej metody naraz baza nie przyjmie. Każdy wynik "
  "(`TrustScore`) zapisuje, którą metodą go policzono, więc po zmianie metody stare wyniki dalej da się wyjaśnić.")
p("ScoringWeight", "Przykład na danych – wagi sygnałów w metodzie 1.0:",
  "Każdy z sześciu sygnałów ma w metodzie swoją wagę; razem dają 1. Nowa wersja metody będzie miała własne wiersze "
  "wag, a ta sama para „metoda – sygnał” może być tylko raz.",
  wiersze=[(1, 1, 1, 0.25), (2, 1, 2, 0.15), (3, 1, 3, 0.2), (4, 1, 4, 0.2), (5, 1, 5, 0.1), (6, 1, 6, 0.1)])
p("TrustScore", "Przykład na danych – wyniki dwóch firm z 1 grudnia:",
  "Przykład Logistyka ma wynik 41 na 100 z pewnością 0,72. Kadry Przykład ma 63, ale pewność tylko 0,35, bo mamy o "
  "niej mało danych – tego wyniku nie pokażemy (zobacz `PublishedScore`). Każde przeliczenie to nowy wiersz; baza "
  "pilnuje, żeby wynik był od 0 do 100, a pewność od 0 do 1.",
  wiersze=[(1, 2, 1, 41, 0.72, "2026-12-01 03:00"), (2, 3, 1, 63, 0.35, "2026-12-01 03:00")])
p("ScoreReason", "Przykład na danych – trzy powody wyniku 41:",
  "Powody mają kolejność ważności (`ReasonRank`), która nie może się powtórzyć w jednym wyniku. Każdy powód wskazuje "
  "sygnał, z którego wynika – dlatego firma wie, co poprawić.",
  wiersze=[(1, 1, 2, 1, "To samo ogłoszenie 7 razy w 9 miesięcy"),
           (2, 1, 1, 2, "38% ogłoszeń to powtórki"),
           (3, 1, 4, 3, "34 na 100 aplikacji kończy się ciszą")])
p("PublishedScore", "Przykład na danych – publikacja wyników:",
  "Wynik Przykład Logistyka jest pokazywany od 1 grudnia (stan 1 – Opublikowany). Wynik Kadry Przykład ma stan 2 – Za "
  "mało danych, więc nie jest pokazywany. Gdyby firma się odwołała i miała rację, wiersz 1 dostałby datę końca i "
  "flagę 0, a nowy wiersz – stan „Wycofany po odwołaniu”. Firma ma jedną aktualną publikację.",
  wiersze=[(1, 1, 1, 1, "2026-12-01 03:05", None, 1), (2, 2, 2, 2, "2026-12-01 03:05", None, 1)])
p("PublicationStatus", "Przykład na danych – lista stanów publikacji:",
  "W przykładzie (`PublishedScore`) są stany 1 i 2. Nowy stan, np. „Wstrzymany na czas aktualizacji”, to jeden nowy "
  "wiersz.")

# ───────────── 19. Użytkownicy systemu i role ─────────────
p("Role", "Przykład na danych – cała lista ról:",
  "Rolę wybieramy z listy, więc literówka nie zrobi z jednej roli dwóch. Moderator z przykładu (`UserRole`) ma role 2 "
  "i 3, a osoba z działu HR firmy Przykład Logistyka – rolę 5. Nowa rola, np. „audytor”, to jeden nowy wiersz.")
p("UserRole", "Przykład na danych – role trzech osób:",
  "Pierwsza osoba ma dwie role naraz, więc rola nie może być jedną kolumną w tabeli kont. Stażysta miał rolę analityka "
  "tylko w październiku: wiersz ma datę końca i flagę 0, a nie został usunięty. Tej samej roli nie da się dać jednej "
  "osobie drugi raz jako aktualnej.",
  wiersze=[(1, 1, 2, "2026-11-01", None, 1),
           (2, 1, 3, "2026-12-01", None, 1),
           (3, 2, 5, "2026-12-10", None, 1),
           (4, 3, 3, "2026-10-01", "2026-10-31", 0)])
p("SystemUser", "Przykład na danych – trzy konta (skrót hasła skrócony):",
  "Zamiast hasła zapisujemy tylko jego skrót. Osoba z HR loguje się przez zewnętrzny system, więc skrótu hasła nie ma. "
  "Konto stażysty jest wyłączone (flaga 0 i data wyłączenia), ale nie usunięte, bo są z nim związane jego wcześniejsze "
  "działania. Ten sam login może być tylko raz.",
  wiersze=[(1, "moderator1@ghostjob.example", "Moderator 1", "$2b$12$Qx…", "2026-10-25 09:00", 1, None),
           (2, "hr@przyklad-logistyka.example", "Dział HR Przykład Logistyka", None, "2026-12-10 11:00", 1, None),
           (3, "stazysta@ghostjob.example", "Stażysta – analiza danych", "$2b$12$Lm…", "2026-10-01 09:00", 0,
            "2026-10-31 17:00")])
p("EmployerRepresentative", "Przykład na danych – przedstawiciel firmy:",
  "Osoba z działu HR reprezentuje Przykład Logistyka od 10 grudnia; potwierdziliśmy to tego samego dnia o 15:00. Gdy "
  "przestanie tam pracować, wiersz dostanie datę końca i flagę 0 – zostanie w historii, bo jej odwołanie od oceny musi "
  "mieć autora.",
  wiersze=[(1, 2, 1, "2026-12-10", None, 1, "2026-12-10 15:00")])
