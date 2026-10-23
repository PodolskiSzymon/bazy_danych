"""Generator rysunku jednej warstwy (widget + embed) dla dokumentu Claude Docs.

Użycie: python3 gen_layer.py <nr_warstwy>  -> wypisuje JSON z członkami batcha.
"""
import json
import os
import sys
import textwrap

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from data import LAYERS  # noqa: E402

TAB_FILE = "60d89b62-19f3"
BODY = "66bcc4fe-038e"
PENDING = {1: "m37qd1jmxnv.47", 2: "m37qd1jmxnv.48", 3: "m37qd1jmxnv.49",
           4: "m37qd1jmxnv.50", 5: "m37qd1jmxnv.51", 6: "m37qd1jmxnv.52"}

WRAP = 52          # znaków w linii pola (zmierzone ~5.6 j./znak przy 11.5 px)
X = [24, 388]      # dwie kolumny kafelków
CW = 348           # szerokość kafelka


def esc(s):
    assert not any(c in s for c in "{}<>'"), s
    return s


def wrap(label, text):
    return textwrap.wrap(f"{label} {text}", width=WRAP,
                         break_long_words=False, break_on_hyphens=False)


def card_lines(item):
    out = []
    for label, text in item["fields"]:
        ls = wrap(label, text)
        assert ls[0].startswith(label), (label, ls)
        out.append((label, ls))
    return out


def card_h(item):
    return 60 + 16 * sum(len(ls) for _, ls in card_lines(item))


SHAPES = {
    "person": "{{box({x}, {y}, {w}, {h}, cPerson, 0, false)}}",
    "sys": "{{box({x}, {y}, {w}, {h}, cSys, 0, false)}}",
    "prog": "{{box({x}, {y}, {w}, {h}, cProg, 8, false)}}",
    "widget": "{{box({x}, {y}, {w}, {h}, cProg, 8, true)}}",
    "store": "{{storeBox({x}, {y}, {w}, {h})}}",
}


def emit_card(prefix, item, x, y, h):
    assert len(item["name"]) <= 40, item["name"]
    assert len(item["sub"]) <= 50, item["sub"]
    shape = SHAPES[item["kind"]].format(x=x, y=y, w=CW, h=h)
    t = [
        f"<text data-claude-text-id='{prefix}-name' x='{x + 16}' y='{y + 24}' fontWeight='600' fill={{ink}}>{esc(item['name'])}</text>",
        f"<text data-claude-text-id='{prefix}-sub' x='{x + 16}' y='{y + 42}' fontSize='11.5' fill={{quiet}}>{esc(item['sub'])}</text>",
    ]
    ly = y + 62
    for fi, (label, ls) in enumerate(card_lines(item)):
        for li, line in enumerate(ls):
            assert len(line) <= WRAP + 2, line
            if li == 0:
                rest = line[len(label):]
                spans = f"<tspan data-claude-text-id='{prefix}-f{fi}-lab' fontWeight='600'>{esc(label)}</tspan>"
                if rest.strip():
                    spans += f"<tspan data-claude-text-id='{prefix}-f{fi}-l0'>{esc(rest)}</tspan>"
                t.append(f"<text x='{x + 16}' y='{ly}' fontSize='11.5' fill={{ink}}>{spans}</text>")
            else:
                t.append(f"<text data-claude-text-id='{prefix}-f{fi}-l{li}' x='{x + 16}' y='{ly}' fontSize='11.5' fill={{ink}}>{esc(line)}</text>")
            ly += 16
    return f"<g data-claude-anchor='{prefix}'>{shape}{''.join(t)}</g>"


LEGEND = [
    ("person", "key-osoba", "osoba"),
    ("sys", "key-system", "system spoza nas"),
    ("prog", "key-program", "nasz program"),
    ("store", "key-zbior", "zbiór danych"),
]
WIDGET_LEGEND = ("widget", "key-widzet", "nasz kod w przeglądarce")


def legend(layer):
    items = list(LEGEND) + ([WIDGET_LEGEND] if any(s["kind"] == "widget" for s in layer["sources"]) else [])
    out, x = [], 24
    for kind, tid, label in items:
        if kind == "store":
            sw = (f"<rect x='{x}' y='48' width='12' height='12' fill={{cStore}} fillOpacity='0.1'/>"
                  f"<path d='M{x + 12} 48H{x}V60H{x + 12}' fill='none' stroke={{cStore}} strokeWidth='1.25'/>")
        else:
            c = {"person": "cPerson", "sys": "cSys", "prog": "cProg", "widget": "cProg"}[kind]
            r = "3" if kind in ("prog", "widget") else "0"
            dash = " strokeDasharray='3 2'" if kind == "widget" else ""
            sw = (f"<rect x='{x}' y='48' width='12' height='12' rx='{r}' fill={{{c}}} fillOpacity='0.1' "
                  f"stroke={{{c}}} strokeWidth='1.25'{dash}/>")
        out.append(sw + f"<text data-claude-text-id='{tid}' x='{x + 18}' y='58' fontSize='11.5' fill={{ink}}>{label}</text>")
        x += 18 + round(len(label) * 6.4) + 22
    assert x < 760, x
    return f"<g data-claude-anchor='legenda'>{''.join(out)}</g>"


HEADER = ("export default () => { const ink = 'var(--cds-text-primary)', quiet = 'var(--cds-text-secondary)', "
          "edge = 'var(--cds-chart-axis)'; const cPerson = 'var(--cds-chart-categorical-3)', "
          "cSys = 'var(--cds-chart-categorical-4)', cProg = 'var(--cds-chart-categorical-1)', "
          "cStore = 'var(--cds-chart-categorical-2)'; const box = (x, y, w, h, c, r, dash) => <rect x={x} y={y} "
          "width={w} height={h} rx={r} fill={c} fillOpacity='0.1' stroke={c} strokeWidth='1.25' "
          "strokeDasharray={dash ? '5 4' : 'none'}/>; const storeBox = (x, y, w, h) => <g><rect x={x} y={y} "
          "width={w} height={h} fill={cStore} fillOpacity='0.1'/><path d={`M${x + w} ${y}H${x}V${y + h}H${x + w}`} "
          "fill='none' stroke={cStore} strokeWidth='1.25'/></g>; ")


def build(layer):
    assert len(layer["title"]) <= 82, layer["title"]
    bands = [
        ("src", layer["sources"], layer.get("band1", "SKĄD BIERZEMY DANE")),
        ("prog", layer["programs"], "PROGRAMY WARSTWY – NASI „PRACOWNICY”"),
        ("zb", layer["stores"], "ZBIORY, KTÓRE WARSTWA ZAPISUJE (PRZYSZŁE TABELE)"),
    ]
    arrows_txt = [layer.get("arrow1", "dane trafiają do programów"), "programy zapisują wyniki w zbiorach"]
    cards, arrows, labels = [], [], []
    band_y = 94
    note_y = None
    for bi, (pfx, items, blabel) in enumerate(bands):
        labels.append(f"<text data-claude-text-id='band{bi + 1}' x='24' y='{band_y}' fontSize='11.5' "
                      f"fontWeight='600' fill={{quiet}}>{esc(blabel)}</text>")
        y = band_y + 10
        for r in range(0, len(items), 2):
            row = items[r:r + 2]
            h = max(card_h(it) for it in row)
            for ci, it in enumerate(row):
                cards.append(emit_card(f"{pfx}-{it['key']}", it, X[ci], y, h))
            y += h + 16
        end = y - 16
        if bi < 2:
            arrows.append(f"<path d='M380 {end + 8}V{end + 40}' markerEnd='url(#lay-arrow)'/>")
            labels.append(f"<text data-claude-text-id='arrow{bi + 1}' x='392' y='{end + 29}' fontSize='11.5' "
                          f"fill={{quiet}}>{esc(arrows_txt[bi])}</text>")
            band_y = end + 66
        else:
            note_y = end + 32
    assert len(layer["note"]) <= 112, len(layer["note"])
    labels.append(f"<text data-claude-text-id='note' x='24' y='{note_y}' fontSize='11.5' fill={{quiet}}>{esc(layer['note'])}</text>")
    H = note_y + 24
    body = (f"return <svg viewBox='0 0 760 {H}' role='img' aria-label='{esc(layer['title'])}' fontSize='13'>"
            "<defs><marker id='lay-arrow' viewBox='0 0 10 10' refX='9' refY='5' markerWidth='6' markerHeight='6' "
            "orient='auto-start-reverse'><path d='M0 0L10 5L0 10z' fill={edge}/></marker></defs>"
            f"<text data-claude-text-id='title' x='24' y='30' fontSize='15' fontWeight='600' fill={{ink}}>{esc(layer['title'])}</text>"
            + legend(layer)
            + f"<g data-claude-anchor='connectors' fill='none' stroke={{edge}} strokeWidth='1.25'>{''.join(arrows)}</g>"
            + "".join(labels) + "".join(cards) + "</svg>; };")
    return HEADER + body, H


def plural(n, one, few, many):
    if n == 1:
        return f"{n} {one}"
    if 2 <= n % 10 <= 4 and not 12 <= n % 100 <= 14:
        return f"{n} {few}"
    return f"{n} {many}"


def members(n):
    layer = next(l for l in LAYERS if l["id"] == n)
    code, H = build(layer)
    lid = f"w{n}"
    caption = (f"warstwa {n} · " + plural(len(layer["sources"]), "źródło", "źródła", "źródeł") + ", "
               + plural(len(layer["programs"]), "program", "programy", "programów") + ", "
               + plural(len(layer["stores"]), "zbiór", "zbiory", "zbiorów"))
    content = f"## Warstwa {n} – {layer['name']}\n\n<?claude block w?>\n\n{layer['link']}"
    return [
        {"$lid": lid, "verb": "create", "object": "node", "engine": "widget",
         "payload": {"parent": {"object": "file", "id": TAB_FILE}, "code": code}},
        {"verb": "update", "ref": {"object": "node", "id": BODY}, "engine": "prose",
         "payload": {"ops": [{"op": "replace", "target": {"kind": "blocks", "ids": [PENDING[n]]},
                              "with": {"as": "markdown",
                                       "blocks": {"w": {"type": "embed", "ref": f"node/$lid:{lid}", "caption": caption}},
                                       "from": {"kind": "inline", "content": content}}}]}},
    ], H


if __name__ == "__main__":
    n = int(sys.argv[1])
    m, H = members(n)
    sys.stderr.write(f"warstwa {n}: H={H}, code={len(m[0]['payload']['code'])} znaków\n")
    print(json.dumps(m, ensure_ascii=False))
