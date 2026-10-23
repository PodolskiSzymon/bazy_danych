# Ghost-Job Scanner – kontekst do kontynuacji rozmowy z Claude

Wklej ten plik na początku nowej rozmowy i napisz, co chcesz dalej zrobić.

## Kim jestem i o co chodzi
- Student, przedmiot **„Podstawy baz danych”**. Rozmawiamy po polsku, odpowiedzi mają być konkretne i proste.
- Grupa wybrała mój pomysł: **Ghost-Job Scanner** – system wykrywający widmowe ogłoszenia o pracę („ghost jobs”) i zjawisko CV Harvesting (firmy publikują oferty bez zamiaru zatrudnienia, żeby zbierać CV).
- System to **nakładka**: platformy z ogłoszeniami (pracuj.pl, OLX) wpinają nasz kod (widżet) i przesyłają nam dane przez API. Kandydaci zgłaszają przez widżet wynik rekrutacji (cisza, odmowa, rozmowa, zatrudnienie).
- Cel: śledzić cykl życia ogłoszeń (powtórki, parafrazy, ten sam etat jako Senior/Mid), krzyżować to ze zgłoszeniami kandydatów i liczyć **Trust Score** pracodawcy.
- Fundament bazy z prezentacji: Pracodawcy, Ogłoszenia, Cykle życia, Aplikacje Logi.

## Zadanie od prowadzącego
Wypisać **wszystkie osoby** korzystające z infrastruktury i **wszystkie zbiory danych**, z których korzystają – zanim powstanie SQL. Prowadzący każe traktować **programy jak ludzi** (każdy program = pracownik z jednym zadaniem). Na kolejnych zajęciach będzie mówił, co poprawić lub dodać.

## Ustalenia projektowe (już przyjęte)
1. **Program = osoba = konto w bazie** z uprawnieniami (GRANT). „Czyta/Zapisuje” = uprawnienia.
2. **Jeden zbiór – jeden właściciel**: do zbioru pisze dokładnie jeden program, reszta czyta. Zmiany w cudzym zbiorze (np. usunięcie danych z RODO) idą jako zlecenie do właściciela. Jedyny wyjątek: `task_queue` (każdy wrzuca własne zlecenia).
3. **Wynik to nie kopia**: zbiory wyliczane to widoki (np. `validated_reports`, `moderation_queue`) albo zapisy z wersją algorytmu.
4. **Każdy łańcuch „skąd mam ten zbiór” kończy się w korzeniu**: system zewnętrzny, człowiek, personel (konfiguracja) albo zegar.
5. **Nie zbieramy tego, co zwalczamy**: żadnych CV, imion, e-maili kandydatów – tylko pseudonim od platformy.
6. **Zbieramy też sukcesy** (zatrudnienia), bo liczy się odsetek, nie pojedyncza odmowa.
7. Między programami dane czekają w kolejce (`task_queue`), nie w RAM.
8. Zamiast podziału „od nas do nas / od klientów” jest **6 źródeł danych**: platformy, kandydaci (przez widżet – nie ufamy, sprawdzamy), pracodawcy (odwołania), rejestry i usługi (KRS, VAT, CEIDG, REGON, Cloudflare, AI), nasz personel, nasze programy (dane pochodne).
9. Zgłoszenie kandydata liczy się dopiero po 4 sprawdzeniach: Cloudflare Turnstile (token 300 s, jednorazowy, Cloudflare NIE dostaje danych o urządzeniu), dowód aplikacji z logu platformy, odcisk urządzenia (skrót, za zgodą), wykrywanie zmasowanych ataków. Decyzja: przyjęte / do moderacji / odrzucone.
10. Trust Score: na start reguły z wagami od zespołu, publikacja dopiero przy wystarczającej pewności, spadek do ostrzeżenia zatwierdza moderator. Model uczony (i „autonomiczny LLM” z prezentacji) dopiero, gdy będą etykiety z decyzji moderatorów.

## Kolory i notacja (DFD)
zielony = osoba · granatowy = system zewnętrzny · niebieski = nasz program · pomarańczowy (otwarty prostokąt) = zbiór danych / tabela · przerywana linia = Brama API (Kontroler kluczy API).

## Co już istnieje
- Dokument pełny (zasady, tabele programów i zbiorów, scenariusze, „a co jeśli”): https://claude.ai/artifact/MWacLCmou941PPf5J2bnFs
- Dokument z rysunkami warstw: https://claude.ai/artifact/VfRSCXDk94Q6kNwiW1mbUH
- Klikalna strona (mapa → warstwa → szczegóły, mini-mapa, linki `#warstwa-1`…`#warstwa-6`): https://claude.ai/artifact/UMrirDyWtNnRGee2rqNTjh
- Pliki u mnie: `ghost-job-scanner-mapa.html` (strona offline), `ghost-job-scanner-mapa.txt` (wersja tekstowa z identyfikatorami).
- Identyfikatory: `W3-P7` = warstwa 3, program 7; Ź = źródło, P = program, Z = zbiór. Poprawki od prowadzącego zapisujemy z identyfikatorem.

## Otwarte decyzje grupy
- [ ] Czy „Aplikacje Logi” z prezentacji to log aplikacji od platformy (założenie), czy wpisy samych kandydatów?
- [ ] Pole na komentarz w zgłoszeniu? (ryzyko danych osobowych rekruterów) 
- [ ] Załączniki-dowody (zrzut maila)? 
- [ ] Forma wyniku: 0–100, kolory czy same fakty?
- [ ] Czy „stanowisko obsadzone” od firmy wymaga dowodu?
- [ ] Zgłoszenia od przeglądarek agentowych – dopuszczać?
- [ ] Wartości startowe w `system_parameters` (dni do „ciszy”, próg pewności, limity).

## Pełna mapa (wszystkie osoby, programy i zbiory)

```text
GHOST-JOB SCANNER – MAPA WARSTW (wersja tekstowa)

Jak czytać:
- Każdy element ma identyfikator, np. W1-P2 = warstwa 1, program 2.
  Przy poprawkach piszcie identyfikator, np. „W3-Z4: dodać pole X”.
- Ź = źródło (osoba albo system spoza nas), P = nasz program, Z = zbiór danych (przyszła tabela SQL).
- Zasada: do każdego zbioru pisze dokładnie jeden program (właściciel), reszta tylko czyta.
- Wszystko z zewnątrz przechodzi przez Bramę API (W6-P1 Kontroler kluczy API).

POPRAWKI OD PROWADZĄCEGO (dopisujcie tutaj):
- [ ] ...

======================================================================
WARSTWA 1 – DZIAŁ FIRM
Sedno: z kont na platformach powstaje jedna sprawdzona lista firm.
Powiązania: Zbiory tej warstwy czyta warstwa 2, żeby przypisać każde ogłoszenie do właściwej firmy.
======================================================================

--- ŹRÓDŁA ---

[W1-Ź1] Platformy  (SYSTEM ZEWNĘTRZNY)
    pracuj.pl, OLX – serwisy, które wpięły nasz kod
    Bierzemy: konto firmy – nazwę, id konta, NIP, stronę www
    Jak: ich serwer wysyła dane do naszego API (przez Bramę)
    Rozmawia z: Importer kont firm

[W1-Ź2] Rejestry publiczne  (SYSTEM ZEWNĘTRZNY)
    państwowe bazy firm: KRS, VAT, CEIDG, REGON
    Bierzemy: nazwę urzędową, status firmy, datę rejestracji i rodzaj działalności (PKD)
    Jak: pytamy po numerze NIP, KRS albo REGON; wynik zapisujemy z datą
    Rozmawia z: Weryfikator firm w rejestrach

--- PROGRAMY ---

[W1-P1] Importer kont firm  (PROGRAM)
    import_employer_account.py
    Działa: odbiera konto firmy przysłane przez platformę
    Analizuje: czy dane są kompletne i w dobrym formacie
    Oddaje: wpis w employer_accounts i zlecenie dla Weryfikatora firm w rejestrach
    Czyta: partners
    Zapisuje: employer_accounts

[W1-P2] Weryfikator firm w rejestrach  (PROGRAM)
    verify_company_registry.py
    Działa: sprawdza sumę kontrolną NIP i pyta rejestry o firmę; co jakiś czas sprawdza ponownie
    Analizuje: czy firma istnieje, czy działa, od kiedy i czym się zajmuje
    Oddaje: odpis w registry_snapshots
    Czyta: employer_accounts, system_parameters
    Zapisuje: registry_snapshots

[W1-P3] Łączyciel kont z platform  (PROGRAM)
    resolve_employer_identity.py
    Działa: łączy konta z różnych platform w jednego pracodawcę
    Analizuje: NIP, a bez NIP nazwę i stronę www; rozpoznaje agencje rekrutacyjne
    Oddaje: employers i employer_account_links; błędne scalenie da się cofnąć
    Czyta: employer_accounts, registry_snapshots, legal_form_dictionary
    Zapisuje: employers, employer_account_links, employer_merge_log

--- ZBIORY ---

[W1-Z1] employer_accounts  (ZBIÓR)
    konta firm na platformach
    Przechowuje: platformę, id konta, nazwę, NIP (jeśli podany), stronę www
    Po co: z tego Łączyciel kont z platform ustala, kto naprawdę stoi za kontem – jedna firma może mieć wiele kont

[W1-Z2] registry_snapshots  (ZBIÓR)
    odpisy z rejestrów publicznych
    Przechowuje: dane z rejestru razem z datą i źródłem sprawdzenia
    Po co: wykrywa firmy wykreślone i świeże wydmuszki; dzięki niemu nie pytamy rejestru przy każdym ogłoszeniu

[W1-Z3] employers  (ZBIÓR)
    pracodawcy – jeden wiersz = jedna firma
    Przechowuje: podmiot, typ (firma, agencja, osoba prywatna) i stan weryfikacji
    Po co: główna tabela: dla każdego wiersza liczymy Trust Score i do niej odwołują się inne zbiory

[W1-Z4] employer_account_links  (ZBIÓR)
    powiązania kont z firmami
    Przechowuje: które konto na której platformie należy do której firmy i z jaką pewnością
    Po co: ogłoszenie z dowolnej platformy trafia do właściwej firmy

Uwaga: Pomocnicze zbiory tej warstwy: employer_merge_log (historia scaleń) i legal_form_dictionary (formy prawne).

======================================================================
WARSTWA 2 – DZIAŁ OGŁOSZEŃ
Sedno: każde ogłoszenie porównujemy z poprzednimi ogłoszeniami tej firmy.
Powiązania: Rodziny i cykle życia ogłoszeń czyta warstwa 4, a samą ofertę – Przyjmowacz zgłoszeń kandydatów z warstwy 3.
======================================================================

--- ŹRÓDŁA ---

[W2-Ź1] Platformy  (SYSTEM ZEWNĘTRZNY)
    pracuj.pl, OLX
    Bierzemy: treść ogłoszenia i jego zdarzenia: publikację, edycję, odświeżenie, wygaśnięcie, zamknięcie
    Jak: ich serwer wysyła je do naszego API; każda platforma ma swój format
    Rozmawia z: Importer ogłoszeń

[W2-Ź2] Model AI  (SYSTEM ZEWNĘTRZNY)
    zewnętrzny model językowy i model wektorów
    Bierzemy: wymagania wyciągnięte z tekstu i wektory znaczenia (liczby opisujące sens)
    Jak: zawsze przez Pośrednika zapytań do AI z warstwy 6, który pamięta odpowiedzi
    Rozmawia z: Pośrednik zapytań do AI, Ekstraktor wymagań z ogłoszeń, Zamieniacz ogłoszeń na wektory

--- PROGRAMY ---

[W2-P1] Importer ogłoszeń  (PROGRAM)
    import_job_posting.py + adaptery platform
    Działa: odbiera ogłoszenie; adapter danej platformy przepisuje jej format na nasz wspólny
    Analizuje: czy to nowe ogłoszenie, czy zmiana już znanego
    Oddaje: job_postings, posting_events i surową kopię raw_postings
    Czyta: partners
    Zapisuje: raw_postings, job_postings, posting_events

[W2-P2] Czyściciel treści ogłoszeń  (PROGRAM)
    clean_posting_text.py
    Działa: usuwa HTML, stopki „O nas” i klauzule RODO
    Analizuje: akapity, które firma powtarza w każdym ogłoszeniu; czy prosi o zgodę na przyszłe rekrutacje
    Oddaje: czysty tekst gotowy do porównań
    Czyta: job_postings, boilerplate_patterns, employer_boilerplate
    Zapisuje: posting_texts_clean, employer_boilerplate

[W2-P3] Ekstraktor wymagań z ogłoszeń  (PROGRAM)
    extract_posting_features.py
    Działa: najpierw reguły (np. widełki „8000–10000 zł”), potem AI dla reszty
    Analizuje: poziom, wymagania, obowiązki, widełki, rodzaj umowy, pracę zdalną
    Oddaje: posting_features
    Czyta: posting_texts_clean, seniority_dictionary, skills_dictionary
    Zapisuje: posting_features

[W2-P4] Zamieniacz ogłoszeń na wektory  (PROGRAM)
    embed_posting.py
    Działa: zamienia tekst na wektor – listę liczb opisującą sens, a nie dokładne słowa
    Analizuje: znaczenie całego ogłoszenia
    Oddaje: wektor do szukania podobnych ogłoszeń (posting_vectors)
    Czyta: posting_texts_clean
    Zapisuje: posting_vectors

[W2-P5] Wyszukiwacz podobnych ogłoszeń  (PROGRAM)
    find_similar_postings.py
    Działa: porównuje ogłoszenie z poprzednimi ogłoszeniami tej samej firmy
    Analizuje: kopię, parafrazę, ten sam etat jako Senior i Mid, duplikat na innej platformie
    Oddaje: similar_posting_pairs
    Czyta: posting_vectors, posting_features, job_postings, employer_account_links, system_parameters
    Zapisuje: similar_posting_pairs

[W2-P6] Grupowacz ogłoszeń w rodziny  (PROGRAM)
    build_posting_families.py
    Działa: łączy podobne ogłoszenia w rodziny – to samo stanowisko w czasie
    Analizuje: ile razy ogłoszenie wracało, ile dni było widoczne, przerwy, odświeżenia, warianty poziomu
    Oddaje: posting_families i posting_lifecycles
    Czyta: similar_posting_pairs, posting_events, job_postings
    Zapisuje: posting_families, posting_lifecycles

--- ZBIORY ---

[W2-Z1] job_postings  (ZBIÓR)
    ogłoszenia w naszym formacie
    Przechowuje: tytuł, opis, firmę, miejsce, umowę, daty publikacji i wygaśnięcia, stan
    Po co: dowód, co i kiedy firma opublikowała; z tego korzystają wszystkie kolejne warstwy

[W2-Z2] posting_events  (ZBIÓR)
    dziennik zdarzeń ogłoszeń
    Przechowuje: opublikowano, edytowano, odświeżono, wygasło, zamknięto, wznowiono – każde z datą
    Po co: oś czasu ogłoszenia; tylko dopisujemy, nic nie nadpisujemy, więc to dobry dowód

[W2-Z3] posting_features  (ZBIÓR)
    cechy ogłoszeń
    Przechowuje: poziom, wymagania, obowiązki, widełki z walutą, umowę, pracę zdalną
    Po co: wykrywa „ten sam etat jako Senior i Mid” i firmy, które nigdy nie podają widełek

[W2-Z4] similar_posting_pairs  (ZBIÓR)
    pary podobnych ogłoszeń
    Przechowuje: dwa ogłoszenia, stopień podobieństwa, rodzaj relacji i wersję algorytmu
    Po co: twardy dowód powtórek; po poprawce algorytmu wszystko można przeliczyć

[W2-Z5] posting_families  (ZBIÓR)
    rodziny ogłoszeń
    Przechowuje: wszystkie wersje jednego stanowiska jednej firmy
    Po co: zamiast wielu osobnych ogłoszeń widać jedno stanowisko publikowane wiele razy

[W2-Z6] posting_lifecycles  (ZBIÓR)
    cykle życia rodzin ogłoszeń
    Przechowuje: liczbę publikacji, dni widoczności, przerwy, odświeżenia, warianty, platformy
    Po co: główny sygnał „ghost joba” dla Trust Score i fakt na odznace: „publikowane 6. raz”

Uwaga: Pomocnicze zbiory: raw_postings (kopia surowa), posting_texts_clean, posting_vectors, słowniki i wzorce stopek.

======================================================================
WARSTWA 3 – DZIAŁ ZGŁOSZEŃ
Sedno: zgłoszenie kandydata liczy się dopiero po czterech sprawdzeniach.
Powiązania: Do Trust Score w warstwie 4 trafiają tylko zgłoszenia z widoku validated_reports.
======================================================================

--- ŹRÓDŁA ---

[W3-Ź1] Kandydat  (OSOBA)
    osoba szukająca pracy na pracuj.pl lub OLX
    Daje: zgłoszenie wyniku rekrutacji (cisza, odmowa, rozmowa, zatrudnienie) i zgody
    Znamy: tylko pseudonim od platformy – nie imię, e-mail ani CV
    Rozmawia z: Przyjmowacz zgłoszeń kandydatów, Rejestrator zgód kandydatów

[W3-Ź2] Widżet – nasz kod u partnera  (NASZ KOD W PRZEGLĄDARCE)
    działa w przeglądarce kandydata, nie u nas
    Co to: nasz kod JavaScript na stronie pracuj.pl/OLX, np. przycisk „Zgłoś wynik rekrutacji” i formularz
    Pliki: report_form.js (formularz), device_signals.js (cechy urządzenia), consent_prompt.js (zgody)
    Uwaga: każdy może go podrobić, dlatego wszystko, co przyśle, sprawdzamy
    Rozmawia z: Przyjmowacz zgłoszeń kandydatów, Rejestrator zgód kandydatów, Porównywacz odcisków urządzeń

[W3-Ź3] Platformy  (SYSTEM ZEWNĘTRZNY)
    pracuj.pl, OLX
    Bierzemy: log aplikacji – kto (pseudonim) aplikował na którą ofertę i kiedy
    Po co: najmocniejszy dowód, że zgłaszający naprawdę aplikował
    Rozmawia z: Importer logu aplikacji, Wysyłacz przypomnień

[W3-Ź4] Cloudflare Turnstile  (SYSTEM ZEWNĘTRZNY)
    usługa odróżniająca ludzi od botów
    Bierzemy: odpowiedź tak/nie dla tokenu z przeglądarki; token żyje 300 s i działa raz
    Nie dostaje: żadnych danych o karcie graficznej ani urządzeniu
    Rozmawia z: Odsiewacz botów

--- PROGRAMY ---

[W3-P1] Przyjmowacz zgłoszeń kandydatów  (PROGRAM)
    receive_report.py
    Działa: przyjmuje zgłoszenie z widżetu i od razu je zapisuje – nic nie ginie
    Analizuje: format i to, czy oferta istnieje
    Oddaje: reports oraz zlecenie oceny dla Oceniacza wiarygodności zgłoszeń
    Czyta: job_postings
    Zapisuje: reports

[W3-P2] Odsiewacz botów  (PROGRAM)
    verify_turnstile.py
    Działa: pyta Cloudflare, czy token z formularza jest ważny
    Analizuje: tylko odpowiedź tak/nie i kody błędów
    Oddaje: bot_checks – wynik sprawdzenia
    Czyta: —
    Zapisuje: bot_checks

[W3-P3] Importer logu aplikacji  (PROGRAM)
    import_application_events.py
    Działa: odbiera od platformy informację, że pseudonim X aplikował na ofertę Y
    Analizuje: format; statusy z systemu rekrutacji platformy, jeśli je udostępnia
    Oddaje: application_log
    Czyta: partners
    Zapisuje: application_log

[W3-P4] Weryfikator złożenia aplikacji  (PROGRAM)
    check_application_proof.py
    Działa: na prośbę Oceniacza wiarygodności zgłoszeń szuka aplikacji zgłaszającego
    Analizuje: czy naprawdę aplikował i czy minęło dość dni, żeby mówić o ciszy
    Oddaje: opinię dla Oceniacza wiarygodności zgłoszeń; sam nic nie zapisuje
    Czyta: application_log, system_parameters
    Zapisuje: —

[W3-P5] Porównywacz odcisków urządzeń  (PROGRAM)
    check_this_fingerprint.py
    Działa: z cech urządzenia liczy skrót (hasz); surowych cech nie zapisuje
    Analizuje: ile kont i zgłoszeń ma to samo urządzenie
    Oddaje: device_fingerprints
    Czyta: consents
    Zapisuje: device_fingerprints

[W3-P6] Wykrywacz kampanii zgłoszeń  (PROGRAM)
    detect_report_campaigns.py
    Działa: regularnie przegląda wszystkie świeże zgłoszenia
    Analizuje: fale zgłoszeń na jedną firmę z nowych kont i tych samych urządzeń, np. atak konkurencji
    Oddaje: abuse_alerts
    Czyta: reports, device_fingerprints, bot_checks, application_log, api_access_log
    Zapisuje: abuse_alerts

[W3-P7] Oceniacz wiarygodności zgłoszeń  (PROGRAM)
    check_is_user_complaint_reliable.py
    Działa: zbiera wynik Odsiewacza botów i opinie Weryfikatora złożenia aplikacji, Porównywacza odcisków urządzeń i Wykrywacza kampanii zgłoszeń
    Analizuje: łączy wszystkie opinie w jedną wagę 0–1
    Oddaje: decyzję: przyjęte, do moderacji albo odrzucone – z powodami (report_verdicts)
    Czyta: reports, bot_checks, device_fingerprints, abuse_alerts, moderator_decisions, system_parameters
    Zapisuje: report_verdicts

[W3-P8] Wysyłacz przypomnień  (PROGRAM)
    remind_candidates.py
    Działa: po ustalonej liczbie dni od aplikacji prosi platformę, żeby zapytała kandydata o wynik
    Analizuje: komu wolno przypomnieć (zgoda) i komu już przypomniano
    Oddaje: reminders_sent; skutek: dużo więcej zgłoszeń
    Czyta: application_log, consents, system_parameters
    Zapisuje: reminders_sent

[W3-P9] Rejestrator zgód kandydatów  (PROGRAM)
    record_consent.py
    Działa: zapisuje zgodę albo jej wycofanie
    Analizuje: na co jest zgoda (przypomnienia, cechy urządzenia) i w jakiej wersji treści
    Oddaje: consents – dowód zgody wymagany przez RODO
    Czyta: —
    Zapisuje: consents

--- ZBIORY ---

[W3-Z1] application_log  (ZBIÓR)
    dziennik aplikacji
    Przechowuje: pseudonim, ofertę i datę aplikacji, a jeśli platforma je ma – statusy rekrutacji
    Po co: dowód, że zgłaszający aplikował; pozwala liczyć zgłoszenia na 100 aplikacji

[W3-Z2] reports  (ZBIÓR)
    zgłoszenia kandydatów
    Przechowuje: wynik (cisza, odmowa, zatrudnienie…), daty, skrót urządzenia; tylko dopisujemy
    Po co: surowy głos kandydatów – liczy się dopiero po ocenie Oceniacza wiarygodności zgłoszeń

[W3-Z3] device_fingerprints  (ZBIÓR)
    odciski urządzeń
    Przechowuje: skrót urządzenia i liczniki: ile kont, zgłoszeń i różnych firm
    Po co: wykrywa jedną osobę z wieloma kontami; trzymany krótko, bo to dane osobowe

[W3-Z4] abuse_alerts  (ZBIÓR)
    alerty nadużyć
    Przechowuje: podejrzaną falę zgłoszeń: firmę, okno czasu, zgłoszenia w grupie, powód
    Po co: wstrzymuje atak, zanim zaszkodzi firmie; sprawa trafia do moderatora

[W3-Z5] report_verdicts  (ZBIÓR)
    oceny zgłoszeń
    Przechowuje: wagę 0–1, decyzję, powody, wersję reguł; nowa ocena = nowy wiersz
    Po co: wiadomo, dlaczego zgłoszenie się liczy albo nie; można je ocenić ponownie

[W3-Z6] validated_reports (widok)  (ZBIÓR)
    zgłoszenia zwalidowane
    Przechowuje: nic osobno – to zapytanie łączące reports z najnowszą oceną „przyjęte”
    Po co: to Twój dawny plik .csv; widok nie rozjedzie się z ocenami, kopia mogłaby
    Widok liczony z: reports, report_verdicts

Uwaga: Pomocnicze zbiory: consents (zgody), reminders_sent (wysłane przypomnienia), bot_checks (wyniki z Cloudflare).

======================================================================
WARSTWA 4 – DZIAŁ ANALIZ (TRUST SCORE)
Sedno: z sygnałów powstaje Trust Score, a ostrzeżenia zatwierdza człowiek.
Powiązania: Kandydat i firma widzą wyłącznie published_trust_scores – przez warstwę 5.
======================================================================

--- ŹRÓDŁA ---

[W4-Ź1] Model AI  (SYSTEM ZEWNĘTRZNY)
    zewnętrzny model językowy
    Bierzemy: teczki spraw – streszczenie dowodów dla moderatora: oś czasu, liczby
    Nie robi: sam nie wystawia wyniku i niczego nie publikuje
    Rozmawia z: Pośrednik zapytań do AI, Kompletowacz teczek spraw

[W4-Ź2] Personel  (OSOBA)
    nasi ludzie: administrator i moderatorzy
    Dają: wagi i progi Trust Score oraz etykiety – decyzje, z których uczy się model
    Rozmawia z: Edytor ustawień systemu, Zapisywacz decyzji moderatora

--- PROGRAMY ---

[W4-P1] Wyliczacz sygnałów o firmach  (PROGRAM)
    compute_employer_signals.py
    Działa: regularnie liczy liczby opisujące każdą firmę
    Analizuje: odsetek powtórek, ciszę i zatrudnienia na 100 aplikacji, widełki, flagi z rejestru, wyniki odwołań
    Oddaje: employer_signals – migawkę na dany dzień
    Czyta: posting_lifecycles, posting_families, posting_features, validated_reports, application_log, registry_snapshots, employers, moderator_decisions
    Zapisuje: employer_signals

[W4-P2] Wystawiacz Trust Score  (PROGRAM)
    compute_trust_score.py
    Działa: z sygnałów liczy wynik 0–100: na start wagi od zespołu, później model
    Analizuje: ile danych stoi za wynikiem – to jego pewność
    Oddaje: trust_score_history z głównymi powodami
    Czyta: employer_signals, system_parameters, model_registry
    Zapisuje: trust_score_history

[W4-P3] Kompletowacz teczek spraw  (PROGRAM)
    llm_case_analyst.py
    Działa: dla spraw granicznych i odwołań prosi AI o streszczenie
    Analizuje: oś czasu ogłoszeń, podobieństwa, liczby zgłoszeń
    Oddaje: case_files – teczkę dla moderatora
    Czyta: posting_families, similar_posting_pairs, employer_signals, report_verdicts, appeals
    Zapisuje: case_files

[W4-P4] Publikator Trust Score  (PROGRAM)
    publish_trust_score.py
    Działa: decyduje, co zobaczy kandydat
    Analizuje: mała pewność → „za mało danych”; spadek do ostrzeżenia → najpierw moderator
    Oddaje: published_trust_scores
    Czyta: trust_score_history, moderator_decisions, system_parameters
    Zapisuje: published_trust_scores

[W4-P5] Zbieracz danych treningowych  (PROGRAM)
    build_training_dataset.py
    Działa: składa materiał do nauki modelu
    Analizuje: sygnały firm i decyzje moderatorów jako poprawne odpowiedzi (etykiety)
    Oddaje: training_datasets – bez danych osób
    Czyta: employer_signals, posting_lifecycles, moderator_decisions
    Zapisuje: training_datasets

[W4-P6] Trener sztucznej inteligencji  (PROGRAM)
    train_and_evaluate_model.py
    Działa: uczy model i sprawdza go na danych, których wcześniej nie widział
    Analizuje: czy nowy model jest lepszy od reguł
    Oddaje: model_registry; model działa dopiero po zatwierdzeniu
    Czyta: training_datasets
    Zapisuje: model_registry

--- ZBIORY ---

[W4-Z1] employer_signals  (ZBIÓR)
    sygnały pracodawców
    Przechowuje: dla każdej firmy na każdy dzień wszystkie składowe oceny
    Po co: wejście dla Wystawiacza Trust Score, historia zmian i materiał do nauki modelu

[W4-Z2] trust_score_history  (ZBIÓR)
    historia Trust Score
    Przechowuje: każdy wyliczony wynik: firmę, datę, wynik, pewność, powody, wersję modelu
    Po co: widać, jak i dlaczego wynik się zmieniał – potrzebne przy odwołaniu i w sporze

[W4-Z3] published_trust_scores  (ZBIÓR)
    opublikowane wyniki
    Przechowuje: to, co widzi kandydat: wynik albo „za mało danych”, od kiedy, czy wstrzymany
    Po co: odznaka i panel firmy czytają tylko ten zbiór, nigdy wyniku roboczego

[W4-Z4] case_files  (ZBIÓR)
    teczki spraw
    Przechowuje: streszczenie dowodów od modelu AI
    Po co: moderator decyduje szybciej i na podstawie dowodów, a nie samego wyniku

[W4-Z5] training_datasets  (ZBIÓR)
    zbiory treningowe
    Przechowuje: kolejne wersje: sygnały + etykiety, bez danych osób
    Po co: na nich uczy się przyszły model; wersje pozwalają powtórzyć naukę

[W4-Z6] model_registry  (ZBIÓR)
    rejestr modeli
    Przechowuje: wersję modelu, zbiór treningowy, wynik testu, stan i to, kto zatwierdził
    Po co: wiadomo, który model wystawił wynik; można wrócić do poprzedniego

Uwaga: Wynik roboczy (trust_score_history) i wynik publiczny (published_trust_scores) to celowo dwa osobne zbiory.

======================================================================
WARSTWA 5 – BIURO OBSŁUGI
Sedno: tu system rozmawia z ludźmi – kandydatem, firmą, moderatorem i IOD.
Powiązania: Decyzje moderatorów wracają do warstw 3 i 4, które oceniają sprawę ponownie.
======================================================================

--- Z KIM ROZMAWIA ---

[W5-Ź1] Kandydat  (OSOBA)
    osoba szukająca pracy
    Dostaje: odznakę przy ofercie: wynik, pewność, 2–3 powody albo „za mało danych”
    Jak: przez widżet trust_badge.js na stronie platformy
    Rozmawia z: Wyświetlacz odznak zaufania, Realizator wniosków RODO

[W5-Ź2] Pracodawca  (OSOBA)
    firma oceniana przez system (też agencja)
    Dostaje: swój wynik i powody
    Daje: odwołania, np. „stanowisko obsadzone”
    Jak: loguje się przez platformę i potwierdza NIP
    Rozmawia z: Przyjmowacz odwołań firm

[W5-Ź3] Moderator  (OSOBA)
    nasz pracownik
    Robi: rozstrzyga sprawy sporne i zatwierdza ostrzeżenia
    Rozmawia z: Zapisywacz decyzji moderatora

[W5-Ź4] IOD – Inspektor Ochrony Danych  (OSOBA)
    osoba odpowiedzialna za RODO
    Robi: pilnuje wniosków kandydatów, terminów przechowywania i audytu
    Rozmawia z: Realizator wniosków RODO

--- PROGRAMY ---

[W5-P1] Wyświetlacz odznak zaufania  (PROGRAM)
    serve_trust_badge.py
    Działa: gdy kandydat otwiera ofertę, widżet pyta Wyświetlacza odznak zaufania o odznakę
    Analizuje: oferta → firma → opublikowany wynik oraz fakty, np. „publikowane 6. raz”
    Oddaje: odznakę i dzienne liczniki wyświetleń (bez danych osób)
    Czyta: job_postings, employer_account_links, published_trust_scores, posting_lifecycles
    Zapisuje: badge_view_stats

[W5-P2] Przyjmowacz odwołań firm  (PROGRAM)
    employer_panel
    Działa: strona dla firm: wynik, powody i rodziny ogłoszeń
    Analizuje: przyjmuje odwołania, np. „stanowisko obsadzone” albo „to nie nasze ogłoszenie”
    Oddaje: appeals
    Czyta: published_trust_scores, employer_signals, posting_families, employers, moderator_decisions
    Zapisuje: appeals

[W5-P3] Zapisywacz decyzji moderatora  (PROGRAM)
    moderation_panel
    Działa: pokazuje moderatorowi kolejkę spraw razem z teczkami
    Analizuje: człowiek ogląda dowody i decyduje
    Oddaje: moderator_decisions z uzasadnieniem
    Czyta: moderation_queue, case_files, reports, similar_posting_pairs, appeals
    Zapisuje: moderator_decisions

[W5-P4] Realizator wniosków RODO  (PROGRAM)
    handle_privacy_request.py
    Działa: przyjmuje wnioski kandydatów (wgląd, usunięcie, sprzeciw) przekazane przez platformę
    Analizuje: które zbiory mają dane tego pseudonimu
    Oddaje: zlecenia usunięcia dla właścicieli zbiorów i wpis w privacy_requests
    Czyta: consents
    Zapisuje: privacy_requests

[W5-P5] Generator raportów publicznych  (PROGRAM)
    public_reports.py
    Działa: regularnie robi zestawienia rynku pracy
    Analizuje: tylko liczby zbiorcze, nigdy pojedyncze osoby
    Oddaje: public_reports – raporty dla mediów, PIP i badaczy
    Czyta: employer_signals, posting_lifecycles, published_trust_scores, badge_view_stats
    Zapisuje: public_reports

--- ZBIORY ---

[W5-Z1] appeals  (ZBIÓR)
    odwołania firm
    Przechowuje: czego dotyczy, rodzaj odwołania, treść, załączniki
    Po co: firma ma prawo się bronić; to też chroni nas w razie sporu

[W5-Z2] moderator_decisions  (ZBIÓR)
    decyzje moderatorów
    Przechowuje: czego dotyczy, decyzję, uzasadnienie, kto i kiedy
    Po co: zmienia oceny i wyniki; w przyszłości to etykiety, z których uczy się model

[W5-Z3] moderation_queue (widok)  (ZBIÓR)
    kolejka moderacji
    Przechowuje: nic osobno – to zapytanie o wszystko, co czeka na decyzję człowieka
    Po co: jedno miejsce pracy moderatora
    Widok liczony z: report_verdicts, abuse_alerts, appeals, published_trust_scores

[W5-Z4] privacy_requests  (ZBIÓR)
    wnioski RODO
    Przechowuje: rodzaj wniosku, daty, zakres i wykonanie – bez treści danych
    Po co: dowód, że wniosek wykonaliśmy w terminie

[W5-Z5] public_reports  (ZBIÓR)
    raporty publiczne
    Przechowuje: opublikowane zestawienia i pakiety dowodowe
    Po co: nacisk na nieuczciwe firmy – to cel całego projektu

Uwaga: Pomocniczy zbiór: badge_view_stats (ile razy dziennie pokazano odznakę danej oferty).

======================================================================
WARSTWA 6 – ZAPLECZE
Sedno: zaplecze pilnuje porządku – zasad, czasu, kosztów i śladów.
Powiązania: Zbiory zaplecza czytają wszystkie warstwy, a Kontroler kluczy API pilnuje wejścia do każdej z nich.
======================================================================

--- ŹRÓDŁA ---

[W6-Ź1] Administrator  (OSOBA)
    nasz pracownik techniczny
    Daje: parametry (progi, wagi, terminy), słowniki, klucze partnerów, konta personelu
    Rozmawia z: Edytor ustawień systemu

--- PROGRAMY ---

[W6-P1] Kontroler kluczy API (Brama API)  (PROGRAM)
    api_gateway – przerywana linia na mapie
    Działa: każde zapytanie z zewnątrz przechodzi najpierw przez niego
    Analizuje: klucz API partnera, domenę widżetu i liczbę zapytań (limity)
    Oddaje: wpuszcza albo odrzuca; zapisuje api_access_log
    Czyta: partners, api_keys
    Zapisuje: api_access_log

[W6-P2] Edytor ustawień systemu  (PROGRAM)
    admin_panel
    Działa: strona, w której administrator zmienia ustawienia systemu
    Analizuje: kto zmienia – każda zmiana trafia do audytu
    Oddaje: system_parameters, słowniki, partners, api_keys, staff_accounts
    Czyta: job_runs, system_alerts, llm_usage_log, audit_log
    Zapisuje: system_parameters, partners, api_keys, staff_accounts, boilerplate_patterns, legal_form_dictionary, seniority_dictionary, skills_dictionary

[W6-P3] Uruchamiacz zadań cyklicznych  (PROGRAM)
    scheduler
    Działa: uruchamia programy o ustalonych porach, np. przeliczenie Trust Score co noc
    Analizuje: harmonogram zapisany w system_parameters
    Oddaje: job_runs – co, kiedy i z jakim skutkiem się uruchomiło
    Czyta: system_parameters
    Zapisuje: job_runs

[W6-P4] Obserwator stanu systemu  (PROGRAM)
    monitoring
    Działa: pilnuje, czy wszystkie programy działają
    Analizuje: błędy w job_runs, długość kolejki zleceń, nietypowy ruch w API
    Oddaje: alerty techniczne dla administratora
    Czyta: job_runs, task_queue, api_access_log
    Zapisuje: system_alerts

[W6-P5] Pośrednik zapytań do AI  (PROGRAM)
    llm_gateway.py
    Działa: jedyny program, który łączy się z modelem AI; inne programy pytają przez niego
    Analizuje: czy ta sama treść była już pytana – wtedy odpowiedź z pamięci, bez opłaty
    Oddaje: llm_cache i licznik kosztów AI
    Czyta: llm_cache, system_parameters
    Zapisuje: llm_cache, llm_usage_log

[W6-P6] Zapisywacz dziennika audytu  (PROGRAM)
    audit_logger
    Działa: zapisuje każdą ważną czynność ludzi i programów
    Analizuje: kto czytał dane osobowe, kto zmienił wynik, parametr albo decyzję
    Oddaje: audit_log – nikt nie może go edytować
    Czyta: —
    Zapisuje: audit_log

[W6-P7] Usuwacz przeterminowanych danych  (PROGRAM)
    retention_cleaner.py
    Działa: po terminie przechowywania każe właścicielom zbiorów usunąć stare dane
    Analizuje: daty w zbiorach i terminy z parametrów
    Oddaje: zlecenia usunięcia; sam niczego nie kasuje
    Czyta: system_parameters
    Zapisuje: —

[W6-P8] Twórca kopii zapasowych  (PROGRAM)
    backup_job
    Działa: robi szyfrowane kopie zapasowe bazy
    Analizuje: datę wygaśnięcia każdej kopii
    Oddaje: backups – stare kopie same wygasają
    Czyta: —
    Zapisuje: backups

--- ZBIORY ---

[W6-Z1] system_parameters  (ZBIÓR)
    parametry systemu
    Przechowuje: progi i wagi: po ilu dniach cisza = ghosting, próg pewności, terminy, limity
    Po co: zmiana zasad bez zmiany kodu

[W6-Z2] słowniki i wzorce  (ZBIÓR)
    4 tabele: *_dictionary i boilerplate_patterns
    Przechowuje: synonimy i wzorce, np. „JS” = „JavaScript”, „sp. z o.o.” = „spółka z o.o.”
    Po co: programy rozumieją to samo, choć firmy piszą różnie

[W6-Z3] partners  (ZBIÓR)
    partnerzy – podłączone platformy
    Przechowuje: platformę, domeny widżetu, wersję formatu, umowę powierzenia danych
    Po co: Kontroler kluczy API wie, kogo wpuścić, a Importer ogłoszeń – którego adaptera użyć

[W6-Z4] api_keys  (ZBIÓR)
    klucze API
    Przechowuje: skrót klucza, platformę, uprawnienia, ważność
    Po co: tylko znani partnerzy mogą wysyłać nam dane

[W6-Z5] staff_accounts  (ZBIÓR)
    konta personelu
    Przechowuje: konta i role: moderator, analityk, administrator, IOD
    Po co: każdy widzi tylko to, do czego ma prawo

[W6-Z6] audit_log  (ZBIÓR)
    dziennik audytu
    Przechowuje: kto (człowiek lub program), kiedy, na czym i co zmienił
    Po co: rozliczalność wobec RODO i dowód w sporze

[W6-Z7] task_queue  (ZBIÓR)
    kolejka zleceń
    Przechowuje: zlecenia między programami: rodzaj, odnośnik do danych, czy zrobione
    Po co: gdy program nie działa, praca czeka, a nie ginie w pamięci RAM

[W6-Z8] job_runs  (ZBIÓR)
    dziennik uruchomień
    Przechowuje: start, koniec, liczbę rekordów i błędy każdego uruchomienia
    Po co: Obserwator stanu systemu widzi, co się zepsuło i kiedy

[W6-Z9] llm_cache  (ZBIÓR)
    pamięć odpowiedzi AI
    Przechowuje: odpowiedź AI zapisaną pod skrótem treści
    Po co: ta sama treść = brak drugiej opłaty

[W6-Z10] backups  (ZBIÓR)
    kopie zapasowe
    Przechowuje: szyfrowane kopie bazy z datą wygaśnięcia
    Po co: odtworzenie po awarii; wygasają, żeby usunięte dane znikały też z kopii

Uwaga: Pomocnicze zbiory: api_access_log (log zapytań), system_alerts (alerty techniczne), llm_usage_log (koszty AI).

```
