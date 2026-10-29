# Ghost-Job Scanner – projekt bazy danych

Projekt na przedmiot **Podstawy baz danych**: system wykrywający widmowe ogłoszenia o pracę („ghost jobs”) i zjawisko CV Harvesting. Platformy z ogłoszeniami (pracuj.pl, OLX) wpinają nasz kod i przesyłają dane przez API, a kandydaci zgłaszają wynik rekrutacji. Na tej podstawie liczymy **Trust Score** pracodawcy.

Etap obecny: **model tabel** – po uwagach prowadzącego zaczynamy od źródła danych (platformy) i każdy etap rozpisujemy na osobny „organizm”: grupę powiązanych tabel relacyjnych. Wcześniejsza mapa programów i zbiorów zostaje jako opis działania systemu.

![Cała struktura – sześć warstw](docs/img/mapa-calosc.png)

## Co jest w repozytorium

| Ścieżka | Zawartość |
|---|---|
| `docs/01-aktorzy-i-zbiory.md` | Pełny opis: zasady, ludzie i systemy zewnętrzne, 41 programów, 50 zbiorów + 2 widoki, kolejność startu, scenariusze, „a co jeśli”, decyzje do podjęcia |
| `docs/02-jak-czytac-mape.md` | Krótkie objaśnienie mapy (np. dla prowadzącego) |
| `docs/03-kontekst-dla-claude.md` | Kontekst do wklejenia w nową rozmowę z Claude + pełna mapa |
| `docs/mapa-warstw.txt` | Mapa jako czysty tekst z identyfikatorami (np. `W3-P7`) – do wspólnego pliku z poprawkami |
| `docs/img/` | Obrazy: cała struktura, każda warstwa, DFD poziomu 1, droga zgłoszenia |
| `web/index.html` | Klikalna mapa: cała struktura → warstwa → szczegóły kafelka (otwórz w przeglądarce) |
| `web/organizmy.html` | **Model tabel**: 18 organizmów od platformy źródłowej do Trust Score – diagramy jak w Data Modeler, opisy kolumn, warianty, pytania do prowadzącego, SQL. Widok **Opisy** (`organizmy.html#opisy`): każdy organizm opisany prostym językiem i krótko dla technicznych – do czytania i druku |
| `sql/organizmy/` | Skrypty Oracle: jeden plik na organizm (`01_…` – `18_…`), połączenia między organizmami (`99_…`) i `usun_wszystkie_tabele.sql`; w `data_modeler/` te same tabele bez przykładowych wierszy – do importu w Data Modeler |
| `narzedzia/` | Źródło treści (`data.py`, `organizmy.py`, `opisy_organizmow.py`) i generatory stron, rysunków oraz SQL |

## Model tabel – organizmy

Strona `web/organizmy.html` (link jest też na górze mapy warstw). Każdy organizm odpowiada na dwa pytania:

1. **Co to jest w szerszym kontekście?** – np. platforma to każde źródło ofert pracy, nie tylko portal.
2. **Jakie mogą być warianty?** – każdy wariant, który się powtarza albo zmienia, dostaje własną tabelę: słownik (np. `PlatformType`), tabelę łączącą wiele do wielu (np. `PlatformMarket`) albo historię (np. `PartnerAgreement`).

Konwencja jak na schemacie z zajęć: tabele po angielsku w PascalCase (`SourcePlatform`), klucz główny `<Tabela>Key` typu `NUMBER`, klucz obcy nazywa się tak samo jak klucz, do którego prowadzi. W bazie nazwa tabeli zaczyna się od `ORG` i numeru organizmu, np. `ORG01_SourcePlatform`, `ORG03_EndpointData` – dzięki temu tabele jednego organizmu stoją na liście obok siebie, a wpisanie `ORG03_` w wyszukiwarkę tabel (Database Actions → Navigator) pokazuje tylko organizm 3. Kolumny i klucze zostają bez przedrostka (`SourcePlatformKey`); przedrostki wyłącza `PRZEDROSTEK_TABEL = False` w `narzedzia/organizmy.py`. Organizmy są na razie osobne – tabela z innego organizmu jest na diagramie szarą ramką, a klucze obce między organizmami są w osobnym pliku `sql/organizmy/99_polaczenia_miedzy_organizmami.sql`.

| Etap | Organizmy |
|---|---|
| A. Źródło danych | 1 Platforma źródłowa · 2 API platformy · 3 Endpointy i zwracane dane · 4 Odbiór danych z platformy |
| B. Firma | 5 Konto firmy na platformie · 6 Firma w rejestrach publicznych · 7 Powiązanie kont z firmą |
| C. Ogłoszenie | 8 Ogłoszenie i miejsce pracy · 9 Warunki zatrudnienia · 10 Wymagania i obowiązki · 11 Historia i treść ogłoszenia · 12 Podobne ogłoszenia i rodziny |
| D. Kandydat i zgłoszenia | 13 Kandydat, aplikacje i zgody · 14 Zgłoszenie wyniku rekrutacji · 15 Weryfikacja zgłoszenia · 16 Wykrywanie nadużyć |
| E. Ocena firmy | 17 Sygnały o firmie · 18 Trust Score i publikacja |

Jeszcze nierozpisane (po uwagach prowadzącego, tym samym sposobem): moderacja i odwołania, wnioski RODO, odznaka i raporty publiczne, personel i audyt, parametry i harmonogram, pamięć zapytań do AI.

**Opisy organizmów** – widok „Opisy” na stronie (`web/organizmy.html#opisy`) i blok „Opis organizmu” w każdym organizmie. Każdy organizm jest opisany dwa razy: *dla każdego* (o czym jest, przykład, każda tabela prostym językiem; przez wszystkie organizmy idzie jeden zmyślony przykład firmy „Przykład Logistyka”) i *dla technicznych* (relacje, decyzje projektowe i ich skutki, czego baza jeszcze nie pilnuje, zależności między organizmami). Teksty są w `narzedzia/opisy_organizmow.py`; relacje i liczby generator wylicza sam.

Wszystkie skrypty z `sql/organizmy/` zostały uruchomione w testowej bazie Oracle AI Database 26ai (118 tabel, bez błędów) i są założone we wspólnej bazie Oracle Cloud (bez pliku 99). Można je uruchomić w SQL Developer (VS Code albo przeglądarka).

### Diagram w Oracle Data Modeler (jak na zajęciach)

- **W przeglądarce, bez instalowania:** Database Actions → Launchpad → zakładka *Development* → *Data Modeler* → w zakładce *Diagrams* kliknij *New Diagram* → w zakładce *Navigator* wybierz tabele i wpisz `ORG03_` → przeciągnij tabele na diagram albo prawy klik → *Add Object with dependencies to Diagram*. Linie między tabelami pojawią się same, bo klucze obce są w bazie. Diagramy zapisują się w bazie (przy pierwszym użyciu Data Modeler zakłada tabelę `OSDDMW_DIAGRAMS`), więc cały zespół widzi te same.
- **W programie Oracle SQL Developer Data Modeler:** *File → Import → DDL File* → `+` → plik z `sql/organizmy/data_modeler/` (np. `03_endpointy_i_zwracane_dane.sql`) → OK. Jeśli tabele nachodzą na siebie: prawy klik na tle diagramu → *Auto Layout*. `wszystkie_organizmy.sql` daje cały model naraz, razem z kluczami między organizmami.

Kroki według dokumentacji Oracle – w samym programie ich jeszcze nie sprawdziliśmy.

## Warstwy

| Warstwa | Dział | Obraz |
|---|---|---|
| 1 | Dział Firm – z kont na platformach powstaje sprawdzona lista firm | [warstwa-1.png](docs/img/warstwa-1.png) |
| 2 | Dział Ogłoszeń – porównywanie ogłoszeń z poprzednimi | [warstwa-2.png](docs/img/warstwa-2.png) |
| 3 | Dział Zgłoszeń – zgłoszenie liczy się po czterech sprawdzeniach | [warstwa-3.png](docs/img/warstwa-3.png) |
| 4 | Dział Analiz – Trust Score | [warstwa-4.png](docs/img/warstwa-4.png) |
| 5 | Biuro Obsługi – kontakt z kandydatem, firmą, moderatorem, IOD | [warstwa-5.png](docs/img/warstwa-5.png) |
| 6 | Zaplecze – parametry, czas, koszty AI, audyt | [warstwa-6.png](docs/img/warstwa-6.png) |

## Nazwy programów

Każdy program ma nazwę, która mówi, co robi (wzór: *kto + co*). Taki sam jest jego klucz w kodzie i w adresie strony, np. `laczyciel-kont`, `trener-ai`, `uruchamiacz-zadan`. Dawne nazwy (metafory zawodów) i ich odpowiedniki:

| Dawna nazwa | Obecna nazwa |
|---|---|
| Rejestrator kont firm | Importer kont firm |
| Urzędnik rejestrowy | Weryfikator firm w rejestrach |
| Porządkowy | Łączyciel kont z platform |
| Przyjmujący ogłoszenia | Importer ogłoszeń |
| Redaktor | Czyściciel treści ogłoszeń |
| Analityk wymagań | Ekstraktor wymagań z ogłoszeń |
| Wektoryzator | Zamieniacz ogłoszeń na wektory |
| Detektyw podobieństw | Wyszukiwacz podobnych ogłoszeń |
| Kronikarz | Grupowacz ogłoszeń w rodziny |
| Kancelaria | Przyjmowacz zgłoszeń kandydatów |
| Bramkarz | Odsiewacz botów |
| Rejestrator aplikacji | Importer logu aplikacji |
| Sprawdzacz aplikacji | Weryfikator złożenia aplikacji |
| Daktyloskop | Porównywacz odcisków urządzeń |
| Analityk nadużyć | Wykrywacz kampanii zgłoszeń |
| Kierownik zgłoszeń | Oceniacz wiarygodności zgłoszeń |
| Sekretarka | Wysyłacz przypomnień |
| Notariusz zgód | Rejestrator zgód kandydatów |
| Statystyk | Wyliczacz sygnałów o firmach |
| Sędzia | Wystawiacz Trust Score |
| Asystent śledczy | Kompletowacz teczek spraw |
| Rzecznik | Publikator Trust Score |
| Bibliotekarz | Zbieracz danych treningowych |
| Trener | Trener sztucznej inteligencji |
| Informator | Wyświetlacz odznak zaufania |
| Okienko dla firm | Przyjmowacz odwołań firm |
| Biurko moderatora | Zapisywacz decyzji moderatora |
| Urzędnik RODO | Realizator wniosków RODO |
| Rzecznik prasowy | Generator raportów publicznych |
| Portier (Brama API) | Kontroler kluczy API (Brama API) |
| Biuro administratora | Edytor ustawień systemu |
| Zegar | Uruchamiacz zadań cyklicznych |
| Strażnik | Obserwator stanu systemu |
| Łącznik z AI | Pośrednik zapytań do AI |
| Protokolant | Zapisywacz dziennika audytu |
| Sprzątacz | Usuwacz przeterminowanych danych |
| Archiwista | Twórca kopii zapasowych |

## Najważniejsze zasady

1. Program = osoba = konto w bazie z uprawnieniami.
2. Jeden zbiór – jeden właściciel (jedyny wyjątek: `task_queue`).
3. Zbiory wyliczane to widoki albo zapisy z wersją algorytmu, nie kopie.
4. Każdy zbiór da się prześledzić do korzenia: system zewnętrzny, człowiek, personel albo zegar.
5. Nie przechowujemy CV ani danych osobowych kandydatów – tylko pseudonim od platformy.

## Jak zmieniać treść

Treść kafelków jest w `narzedzia/data.py`, długie opisy „Rola” źródeł i programów w `narzedzia/roles.py` (powiązania czyta/zapisuje w `narzedzia/gen_html.py`). Organizmy tabel są w `narzedzia/organizmy.py` – tam nanosimy poprawki prowadzącego (tabela, kolumna, typ, klucz obcy, miejsce na diagramie). Generator sam pilnuje spójności: klucz obcy musi wskazywać istniejącą tabelę, a jego typ jest brany z klucza głównego tej tabeli. Po zmianie:

```bash
python narzedzia/build_web.py      # odświeża web/index.html, web/organizmy.html i sql/organizmy/
python narzedzia/gen_diagramy.py   # DFD poziomu 1 i droga zgłoszenia (narzedzia/diagramy.html)
node narzedzia/render_img.js       # zapisuje obrazy w docs/img/ (wymaga playwright)
```

`narzedzia/gen_layer.py` generował rysunki warstw do dokumentu w Claude Docs (ma w sobie identyfikatory tamtego dokumentu).

## Poprawki od prowadzącego

Zapisujcie je z identyfikatorem elementu z `docs/mapa-warstw.txt`, np. `W3-Z2: dodać pole X`.

- [ ] …
