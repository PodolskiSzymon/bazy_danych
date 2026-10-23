# Jak czytać mapę Ghost-Job Scanner

1. **Co pokazuje mapa.** To diagram przepływu danych naszego systemu (DFD): kto korzysta z infrastruktury, jakie programy przetwarzają dane i w jakich zbiorach te dane lądują. Zgodnie z poleceniem traktujemy programy jak ludzi: każdy ma jedno zadanie, tak jak pracownik w firmie.

2. **Kolory mówią, czym jest kafelek.**
   - Zielony – osoba, czyli rola człowieka: kandydat, pracodawca, moderator, administrator.
   - Granatowy – system spoza nas: platformy pracuj.pl i OLX, rejestry KRS i VAT, Cloudflare, model AI.
   - Niebieski – nasz program.
   - Pomarańczowy – zbiór danych, czyli przyszła tabela w SQL. „(widok)” to zapytanie liczone na żywo, nie osobna tabela.

3. **Przerywana linia to Brama API.** Wszystko z zewnątrz przechodzi najpierw przez jeden program – Kontrolera kluczy API, który sprawdza klucz partnera i pilnuje limitów zapytań.

4. **Każdy wiersz to jedna warstwa, czytana od lewej do prawej:** źródło danych → dział (grupa naszych programów) → zbiory, które ten dział zapisuje. Strzałka do zbioru oznacza zapis.

5. **Strzałki między warstwami pokazują odczyt.** Warstwa niżej czyta zbiory warstwy wyżej, np. Dział Ogłoszeń czyta powiązania kont z Działu Firm, żeby przypisać ogłoszenie do właściwej firmy.

6. **Główna zasada projektu.** Do każdego zbioru pisze dokładnie jeden program (właściciel), pozostałe tylko czytają. Dzięki temu na pytanie „skąd się wziął ten zbiór?” jest jedna odpowiedź, a w SQL od razu wiadomo, jakie uprawnienia (GRANT) dostaje każdy program.

7. **Kolejność warstw odpowiada drodze danych.**
   1. Ustalamy, kim jest firma – dane z platform sprawdzamy w rejestrach.
   2. Śledzimy jej ogłoszenia i wykrywamy powtórki.
   3. Zbieramy zgłoszenia kandydatów; liczą się dopiero po sprawdzeniu (Cloudflare, log aplikacji, odcisk urządzenia, wykrywanie ataków).
   4. Liczymy Trust Score; ostrzeżenie o firmie przed publikacją zatwierdza człowiek.
   5. Kontakt z ludźmi: odznaka przy ofercie, odwołania firm, wnioski RODO.
   6. Zaplecze dla wszystkich: parametry, harmonogram, audyt, kopie zapasowe.

8. **Szczegóły.** Na stronie `web/index.html` kliknięcie warstwy otwiera ją osobno, a kliknięcie kafelka pokazuje, jak program działa, co analizuje i co oddaje, a przy zbiorze – polską nazwę, zawartość, przeznaczenie oraz kto go zapisuje i kto czyta.

9. **Prywatność.** Nie przechowujemy CV, imion ani e-maili kandydatów – tylko pseudonim od platformy. System walczący z wyłudzaniem CV sam nie może ich zbierać.
