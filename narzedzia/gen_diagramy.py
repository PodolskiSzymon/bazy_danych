"""Buduje diagramy.html z dwoma rysunkami: DFD poziomu 1 i drogę zgłoszenia.

Obrazy PNG z tego pliku robi narzedzia/render_img.js.
"""
import os
import sys
from html import escape

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from data import LAYERS  # noqa: E402
from gen_html import MAP_SOURCES  # noqa: E402

# Krótkie linie programów w kafelku działu (pełne nazwy + najważniejsza uwaga).
DFD_PROGRAMS = {
    1: ["Importer kont firm", "Weryfikator firm w rejestrach (NIP, KRS)", "Łączyciel kont z platform: scala duplikaty"],
    2: ["Importer ogłoszeń (adaptery)", "Czyściciel treści ogłoszeń: tekst i stopki", "Ekstraktor wymagań z ogłoszeń",
        "Zamieniacz ogłoszeń na wektory", "Wyszukiwacz podobnych ogłoszeń", "Grupowacz ogłoszeń w rodziny i cykle życia"],
    3: ["Przyjmowacz zgłoszeń kandydatów", "Odsiewacz botów (Turnstile)", "Importer logu aplikacji",
        "Weryfikator złożenia aplikacji", "Porównywacz odcisków urządzeń", "Wykrywacz kampanii zgłoszeń",
        "Oceniacz wiarygodności zgłoszeń: waga i decyzja", "Wysyłacz przypomnień", "Rejestrator zgód kandydatów"],
    4: ["Wyliczacz sygnałów o firmach", "Wystawiacz Trust Score: wynik i pewność", "Kompletowacz teczek spraw (LLM)",
        "Publikator Trust Score: publikacja wyniku", "Zbieracz danych treningowych", "Trener sztucznej inteligencji"],
    5: ["Wyświetlacz odznak zaufania (widżet)", "Przyjmowacz odwołań firm", "Zapisywacz decyzji moderatora",
        "Realizator wniosków RODO", "Generator raportów publicznych"],
    6: ["Kontroler kluczy API (Brama API)", "Edytor ustawień systemu", "Uruchamiacz zadań cyklicznych (harmonogram)",
        "Obserwator stanu systemu", "Pośrednik zapytań do AI (cache, koszty)", "Zapisywacz dziennika audytu",
        "Usuwacz przeterminowanych danych", "Twórca kopii zapasowych"],
}
DFD_READS = {1: "czyta powiązania kont", 2: "czyta ogłoszenia", 3: "czyta zbiory działów 1–3", 4: "czyta opublikowany wynik"}
# Kierunek strzałek źródło ↔ dział, jak na mapie w template.html.
DIRS = {1: ["in", "both"], 2: ["in", "both"], 3: ["both", "in", "both"], 4: ["both", "in"], 5: ["out", "both", "both"],
        6: ["in"]}

CSS = """
body { margin: 0; background: #fff; font-family: 'IBM Plex Sans', sans-serif; }
svg { display: block; }
text { fill: #1d1d1b; font-size: 19px; }
.title { font-size: 25px; font-weight: 600; }
.dim { fill: #5f5d58; }
.b { font-weight: 600; font-size: 21px; }
.k-person { fill: #eaf5ee; stroke: #2f9e6e; stroke-width: 2.5; }
.k-sys { fill: #e8ebf0; stroke: #1f2f4f; stroke-width: 2.5; }
.k-prog { fill: #e6eff9; stroke: #3b82d6; stroke-width: 2; }
.k-store { fill: #fcefe8; stroke: none; }
.edge { fill: none; stroke: #e07b4f; stroke-width: 2; }
.plain { fill: #fff; stroke: #c9c5bb; stroke-width: 2; }
.hl { fill: #e6eff9; stroke: #3b82d6; stroke-width: 3; }
.dash { fill: #fff; stroke: #c9c5bb; stroke-width: 2; stroke-dasharray: 8 6; }
.ext { fill: #fff; stroke: #c9c5bb; stroke-width: 2; }
.conn { fill: none; stroke: #c9c5bb; stroke-width: 2; }
.gate { stroke: #9a978f; stroke-width: 1.5; stroke-dasharray: 5 5; }
.m-head { fill: #c9c5bb; }
"""
MARKER = ('<defs><marker id="a" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" '
          'orient="auto-start-reverse"><path d="M0 1L10 5L0 9z" class="m-head"/></marker></defs>')


def t(x, y, s, cls="", anchor=None):
    a = f' text-anchor="{anchor}"' if anchor else ""
    c = f' class="{cls}"' if cls else ""
    return f'<text x="{x}" y="{y}"{c}{a}>{escape(s)}</text>'


def arrow(d, both=False):
    s = ' marker-start="url(#a)"' if both else ""
    return f'<path class="conn" d="{d}" marker-end="url(#a)"{s}/>'


def store(x, y, w, h):
    return (f'<rect class="k-store" x="{x}" y="{y}" width="{w}" height="{h}"/>'
            f'<path class="edge" d="M{x + w} {y}H{x}V{y + h}H{x + w}"/>')


def dfd():
    W = 1344
    SX, SW, GX, PX, PW, ZX, ZW = 40, 290, 366, 405, 500, 945, 360
    LH = 27
    out = [t(40, 52, "Każdy dział zapisuje tylko własne zbiory, cudze tylko czyta", "title")]
    legend = [("k-person", "Osoba – człowiek w roli, np. Kandydat"), ("k-sys", "System zewnętrzny – program spoza nas"),
              ("k-prog", "Dział – każda linia to jeden nasz program"), ("k-store", "Zbiór – każda linia to przyszła tabela SQL")]
    for i, (k, s) in enumerate(legend):
        x, y = 40 + (i % 2) * 556, 86 + (i // 2) * 32
        cls = k if k != "k-store" else "k-store\" style=\"stroke:#e07b4f;stroke-width:2"
        out.append(f'<rect class="{cls}" x="{x}" y="{y}" width="19" height="19" rx="3"/>' + t(x + 30, y + 16, s))
    out.append(t(40, 176, "Programy mają nazwy mówiące, co robią, np. Przyjmowacz zgłoszeń kandydatów = receive_report.py; "
                 "„(widok)” = zapytanie, nie tabela", "dim"))
    out.append(t(40, 204, "strzałka do zbioru = zapis, strzałka ze zbioru do działu = odczyt", "dim"))
    out.append(t(GX, 240, "Brama API", "b", "middle").replace('class="b"', 'class="b" style="font-size:18px"'))
    y = 262
    lanes = []
    for L in LAYERS:
        n = L["id"]
        progs, srcs = DFD_PROGRAMS[n], MAP_SOURCES[n]
        stores = [z["name"] for z in L["stores"]]
        h = max(len(srcs) * 92 - 12, 60 + LH * len(progs) + 14, 60 + LH * len(stores) + 14)
        lanes.append((L, y, h, progs, srcs, stores))
        y += h + (82 if n < 5 else 92)
    H = y - 60
    gate_end = lanes[4][1] + lanes[4][2] + 6
    out.append(f'<line class="gate" x1="{GX}" y1="250" x2="{GX}" y2="{gate_end}"/>')
    for i, (L, top, h, progs, srcs, stores) in enumerate(lanes):
        n = L["id"]
        for j, (kind, name, detail) in enumerate(srcs):
            ey = top + j * 92
            out.append(f'<rect class="k-{kind}" x="{SX}" y="{ey}" width="{SW}" height="78"/>')
            out.append(t(SX + 20, ey + 32, name, "b") + t(SX + 20, ey + 60, detail, "dim"))
            cy, d = ey + 39, DIRS[n][j]
            out.append(arrow(f"M{PX} {cy}H{SX + SW}") if d == "out" else arrow(f"M{SX + SW} {cy}H{PX}", d == "both"))
        out.append(f'<rect class="k-prog" x="{PX}" y="{top}" width="{PW}" height="{h}" rx="12"/>')
        out.append(t(PX + 26, top + 40, L["map_title"], "b"))
        out += [t(PX + 26, top + 74 + LH * k, p) for k, p in enumerate(progs)]
        out.append(store(ZX, top, ZW, h))
        out.append(t(ZX + 26, top + 40, L["store_group"], "b"))
        out += [t(ZX + 26, top + 74 + LH * k, z) for k, z in enumerate(stores)]
        out.append(arrow(f"M{PX + PW} {top + h / 2}H{ZX}"))
        if n in DFD_READS:
            b, nt, cx = top + h, lanes[i + 1][1], ZX + ZW * 0.45
            out.append(arrow(f"M{cx} {b}V{b + 36}H{PX + PW / 2}V{nt}"))
            out.append(t((cx + PX + PW / 2) / 2 + 40, b + 26, DFD_READS[n], "dim", "middle"))
    return f'<svg id="dfd" viewBox="0 0 {W} {H}" width="{W}" height="{H}">{MARKER}{"".join(out)}</svg>'


def box(x, y, w, h, cls, title, lines, rx=12):
    r = f' rx="{rx}"' if cls not in ("ext",) else ""
    s = [f'<rect class="{cls}" x="{x}" y="{y}" width="{w}" height="{h}"{r}/>', t(x + 28, y + 42, title, "b")]
    for k, (cls2, line) in enumerate(lines):
        s.append(t(x + 28, y + 72 + 28 * k, line, cls2))
    return "".join(s)


def droga():
    W, H = 1384, 1400
    L, C, R = 42, 410, 950       # lewa (zbiory), środkowa, prawa kolumna
    CW, RW, LW = 495, 392, 311
    o = [t(42, 52, "Zgłoszenie jest zapisywane od razu, a liczy się dopiero po ocenie Oceniacza wiarygodności", "title"),
         t(42, 92, "ostry prostokąt = byt zewnętrzny · zaokrąglony = program · otwarty = zbiór danych", "dim")]
    o.append(box(C, 127, CW, 99, "ext", "Kandydat w widżecie partnera", [("dim", "formularz, cechy urządzenia, token")]))
    o.append(box(R, 127, RW, 99, "ext", "Cloudflare Turnstile", [("dim", "wydaje i sprawdza token")]))
    o.append(box(C, 297, CW, 155, "plain", "Przyjmowacz zgłoszeń kandydatów",
                 [("dim", "receive_report.py"), ("", "sprawdza format i czy oferta istnieje"),
                  ("", "zapisuje od razu – nic nie ginie")]))
    o.append(box(R, 297, RW, 155, "plain", "Odsiewacz botów",
                 [("dim", "verify_turnstile.py"), ("", "pisze bot_checks"), ("", "token: 300 s, jednorazowy")]))
    o.append(box(C, 523, CW, 340, "hl", "Oceniacz wiarygodności zgłoszeń",
                 [("dim", "check_is_user_complaint_reliable.py"), ("", "bierze wynik Odsiewacza botów"),
                  ("", "i trzy opinie (prawa kolumna),"), ("", "liczy wagę 0–1 i decyzję,"),
                  ("", "zapisuje ją z powodami")]))
    for k, (name, line) in enumerate([("Weryfikator złożenia aplikacji", "czyta application_log"),
                                       ("Porównywacz odcisków urządzeń", "pisze device_fingerprints"),
                                       ("Wykrywacz kampanii zgłoszeń", "pisze abuse_alerts")]):
        yy = 523 + 120 * k
        o.append(box(R, yy, RW, 99, "plain", name, [("", line)]))
        o.append(arrow(f"M{R} {yy + 50}H{C + CW}"))
    for yy, name in [(346, "reports"), (771, "report_verdicts"), (1117, "validated_reports (widok)")]:
        o.append(store(L, yy, LW, 57).replace("k-store", "k-store\" style=\"fill:#fff").replace("class=\"edge\"", "class=\"conn\""))
        o.append(t(L + 22, yy + 36, name))
    # strzałki górnej części
    o.append(arrow(f"M{C + CW} 177H{R}", True))
    o.append(arrow(f"M{R + RW / 2} 226V297", True) + t(R + RW / 2 + 16, 270, "tak / nie", "dim"))
    o.append(arrow(f"M{C + CW / 2} 226V297") + t(C + CW / 2 + 16, 270, "zgłoszenie", "dim"))
    o.append(arrow(f"M{C + CW} 375H{R}", True))
    o.append(arrow(f"M{C} 375H{L + LW}"))
    o.append(arrow(f"M{L + 156} 403V573H{C}"))
    o.append(arrow(f"M{C + CW / 2} 452V523") + t(C + CW / 2 + 16, 496, "zlecenie oceny", "dim"))
    o.append(arrow(f"M{C} 799H{L + LW}"))
    # decyzja
    cx, cy = C + CW / 2, 976
    o.append(arrow(f"M{cx} 863V920"))
    o.append(f'<path class="plain" d="M{cx} 920L{cx + 155} {cy}L{cx} 1032L{cx - 155} {cy}z"/>')
    o.append(t(cx, cy + 7, "jaka decyzja?", "b", "middle"))
    o.append(arrow(f"M{cx - 155} {cy}H{L + 156}V1117") + t(354, cy - 14, "przyjęte", "dim", "middle"))
    o.append(arrow(f"M{cx} 1032V1117") + t(cx + 16, 1082, "do moderacji", "dim"))
    o.append(arrow(f"M{cx + 155} {cy}H{R + RW / 2}V1117") + t(1000, cy - 14, "odrzucone", "dim", "middle"))
    o.append(box(C, 1117, CW, 155, "plain", "Zapisywacz decyzji moderatora",
                 [("", "człowiek ogląda teczkę sprawy"), ("", "pisze moderator_decisions"),
                  ("", "Oceniacz ocenia zgłoszenie ponownie")]))
    o.append(box(R, 1117, RW, 99, "dash", "Odrzucone", [("", "zostaje w reports z wagą 0")]))
    o.append(arrow(f"M{L + 156} 1174V1245"))
    o.append(box(L, 1245, LW, 99, "plain", "Dział Analiz", [("", "sygnały → Trust Score")]))
    return f'<svg id="droga" viewBox="0 0 {W} {H}" width="{W}" height="{H}">{MARKER}{"".join(o)}</svg>'


def main():
    page = ('<!doctype html><html lang="pl"><head><meta charset="utf-8">'
            '<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;600&display=swap">'
            f'<style>{CSS}</style></head><body>{dfd()}{droga()}</body></html>')
    out = os.path.join(HERE, "diagramy.html")
    open(out, "w", encoding="utf-8").write(page)
    print(out)


if __name__ == "__main__":
    main()
