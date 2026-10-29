"""Buduje stronę web/organizmy.html i skrypty sql/organizmy/*.sql z danych w narzedzia/organizmy.py.

Użycie: python narzedzia/gen_organizmy.py
"""
import html
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
from organizmy import DO_ROZPISANIA, ETAPY, ORGANIZMY, SCHEMAT_PROWADZACEGO  # noqa: E402

SQL_DIR = os.path.join(ROOT, "sql", "organizmy")
OUT_HTML = os.path.join(ROOT, "web", "organizmy.html")

KIND_LABEL = {
    "słownik": "słownik wariantów",
    "łącząca": "tabela łącząca (wiele do wielu)",
    "historia": "historia zmian",
    "zdarzenia": "dziennik zdarzeń",
    "migawka": "stan na dany dzień",
}
SQL_WORDS = {"IS", "NULL", "NOT", "OR", "AND", "BETWEEN", "IN"}


def esc(s):
    return html.escape(str(s), quote=True)


def slug(s):
    s = s.lower()
    for a, b in zip("ąćęłńóśźż", "acelnoszz"):
        s = s.replace(a, b)
    return re.sub(r"[^a-z0-9]+", "_", s).strip("_")


# ───────────── model: kolumny, klucze, ograniczenia ─────────────
def build_model():
    tables = {}
    for o in ORGANIZMY:
        o["own"] = []
        for t in o["tables"]:
            if t["name"] in tables:
                raise SystemExit(f"Tabela {t['name']} występuje w dwóch organizmach")
            t["org"] = o["id"]
            tables[t["name"]] = t
            o["own"].append(t["name"])
    for t in tables.values():
        cols = [{"name": t["name"] + "Key", "type": f"NUMBER({t['digits']})", "desc": "Klucz główny – numer wiersza",
                 "null": False, "pk": True}]
        for c in t["cols"]:
            c = dict(c)
            if "ref" in c:
                parent = tables.get(c["ref"])
                if parent is None:
                    raise SystemExit(f"{t['name']}.{c['name']}: nie ma tabeli {c['ref']}")
                c["type"] = f"NUMBER({parent['digits']})"
                c["ext"] = parent["org"] != t["org"]
            cols.append(c)
        names = [c["name"] for c in cols]
        dup = sorted({n for n in names if names.count(n) > 1})
        if dup:
            raise SystemExit(f"{t['name']}: powtórzone kolumny {dup}")
        t["columns"], t["colnames"] = cols, names
        # ograniczenia – te same nazwy na diagramie i w SQL
        t["pk_name"] = f"{t['name']}_PK"
        singles = [[c["name"]] for c in cols if c.get("unique")]
        multi = t["unique"]
        for u in singles + multi:
            for n in u:
                if n not in names:
                    raise SystemExit(f"{t['name']}: klucz unikalny na nieistniejącej kolumnie {n}")
        uqs = [(f"{t['name']}_{u[0]}_UN", u) for u in singles]
        uqs += [(f"{t['name']}_UN" if len(multi) == 1 else f"{t['name']}_UN{i}", u) for i, u in enumerate(multi, 1)]
        t["uqs"] = uqs
        cks = [(f"{t['name']}_{c['name']}_CK", f"{c['name']} IN ('T', 'N')") for c in cols if c.get("flag")]
        for i, ch in enumerate(t["checks"], 1):
            for word in re.findall(r"[A-Za-z_][A-Za-z0-9_]*", ch):
                if word not in SQL_WORDS and word not in names:
                    raise SystemExit(f"{t['name']}: warunek „{ch}” – nie ma kolumny {word}")
            cks.append((f"{t['name']}_CK{i}", ch))
        t["cks"] = cks
        fk_cols = [c for c in cols if "ref" in c]
        fks = []
        for c in fk_cols:
            same = [d for d in fk_cols if d["ref"] == c["ref"]]
            name = f"{t['name']}_{c['ref']}_FK" if len(same) == 1 else f"{t['name']}_{c['name']}_FK"
            fks.append((name, c))
        t["fks"] = fks
    # przykładowe wiersze
    for t in tables.values():
        if not t["rows"]:
            continue
        data_cols = t["columns"][1:]
        for r in t["rows"]:
            if len(r) != len(data_cols):
                raise SystemExit(f"{t['name']}: wiersz {r} ma {len(r)} wartości, a kolumn jest {len(data_cols)}")
            for c, v in zip(data_cols, r):
                if v is None:
                    if not c["null"]:
                        raise SystemExit(f"{t['name']}: pusta wartość w wymaganej kolumnie {c['name']}")
                    continue
                if "ref" in c:
                    parent = tables[c["ref"]]
                    if parent["org"] != t["org"] or not parent["rows"] or not 1 <= v <= len(parent["rows"]):
                        raise SystemExit(f"{t['name']}.{c['name']}: wartość {v} nie wskazuje wiersza w {c['ref']}")
    # tabele z innych organizmów
    for o in ORGANIZMY:
        ext = []
        for name in o["own"]:
            for c in tables[name]["columns"]:
                if c.get("ext") and c["ref"] not in ext:
                    ext.append(c["ref"])
        missing = [e for e in ext if e not in o["stubs"]]
        extra = [s for s in o["stubs"] if s not in ext]
        if missing or extra:
            raise SystemExit(f"Organizm {o['id']}: brak miejsca na diagramie dla {missing}, zbędne {extra}")
        o["ext"] = ext
    return tables


# ───────────── diagram ER (SVG) ─────────────
CH, CH_H, CH_F = 7.2, 7.9, 6.3          # szerokość znaku: wiersz 12 px, nagłówek 13 px, stopka 10.5 px (font mono)
PAD, HDR, TOP, ROW, FOOT = 10, 26, 8, 18, 15
GX, GY, MARGIN = 74, 58, 14


def disp_type(t):
    return t.replace("(", " (")


def make_box(t, stub):
    if stub:
        pk = t["columns"][0]
        rows = [("P", "*", pk["name"], disp_type(pk["type"]))]
        foot = []
        sub = f"z organizmu {t['org']}"
    else:
        uq_cols = {n for _, u in t["uqs"] for n in u}
        rows = []
        for c in t["columns"]:
            mk = "P" if c.get("pk") else ("F" if "ref" in c else "")
            if c["name"] in uq_cols:
                mk += "U"
            rows.append((mk, "" if c["null"] else "*", c["name"], disp_type(c["type"])))
        foot = [f"{t['pk_name']} ({t['columns'][0]['name']})"] + [f"{n} ({', '.join(u)})" for n, u in t["uqs"]]
        sub = None
    namew = max(len(r[2]) for r in rows)
    typew = max(len(r[3]) for r in rows)
    w = max((3 + 2 + namew + 2 + typew) * CH, len(t["name"]) * CH_H + 12,
            max((len(f) for f in foot), default=0) * CH_F) + 2 * PAD
    hdr = HDR + (12 if stub else 0)
    h = hdr + TOP + len(rows) * ROW + ((8 + len(foot) * FOOT) if foot else 0) + 6
    return {"name": t["name"], "stub": stub, "rows": rows, "foot": foot, "sub": sub, "w": round(w), "h": h,
            "hdr": hdr, "namex": PAD + 5 * CH, "typex": PAD + (5 + namew + 2) * CH, "org": t["org"]}


def clip(cx, cy, w, h, dx, dy):
    tx = (w / 2) / abs(dx) if dx else float("inf")
    ty = (h / 2) / abs(dy) if dy else float("inf")
    t = min(tx, ty)
    return cx + dx * t, cy + dy * t


def seg_hits_box(p, q, b, pad=3):
    """Czy odcinek p–q przechodzi przez prostokąt b (algorytm Lianga–Barsky’ego)."""
    x0, y0, x1, y1 = b["x"] - pad, b["y"] - pad, b["x"] + b["w"] + pad, b["y"] + b["h"] + pad
    dx, dy = q[0] - p[0], q[1] - p[1]
    t0, t1 = 0.0, 1.0
    for pp, qq in ((-dx, p[0] - x0), (dx, x1 - p[0]), (-dy, p[1] - y0), (dy, y1 - p[1])):
        if pp == 0:
            if qq < 0:
                return False
        else:
            r = qq / pp
            if pp < 0:
                t0 = max(t0, r)
            else:
                t1 = min(t1, r)
            if t0 > t1:
                return False
    return True


def layout(o, tables):
    boxes = {}
    for name in o["own"]:
        b = make_box(tables[name], False)
        b["pos"] = tables[name]["pos"]
        boxes[name] = b
    for name, pos in o["stubs"].items():
        b = make_box(tables[name], True)
        b["pos"] = pos
        boxes[name] = b
    seen = {}
    for b in boxes.values():
        if b["pos"] in seen:
            raise SystemExit(f"Organizm {o['id']}: {b['name']} i {seen[b['pos']]} mają to samo miejsce {b['pos']}")
        seen[b["pos"]] = b["name"]
    ncol = max(b["pos"][0] for b in boxes.values()) + 1
    nrow = max(b["pos"][1] for b in boxes.values()) + 1
    colw = [max([b["w"] for b in boxes.values() if b["pos"][0] == c] or [0]) for c in range(ncol)]
    rowh = [max([b["h"] for b in boxes.values() if b["pos"][1] == r] or [0]) for r in range(nrow)]
    xs = [MARGIN + sum(colw[:c]) + GX * c for c in range(ncol)]
    ys = [MARGIN + sum(rowh[:r]) + GY * r for r in range(nrow)]
    for b in boxes.values():
        c, r = b["pos"]
        b["x"] = round(xs[c] + (colw[c] - b["w"]) / 2)
        b["y"] = round(ys[r] + (rowh[r] - b["h"]) / 2)
    width = round(xs[-1] + colw[-1] + MARGIN + 40)
    height = round(ys[-1] + rowh[-1] + MARGIN)
    # krawędzie: od tabeli z kluczem obcym do tabeli, na którą wskazuje
    edges = []
    for name in o["own"]:
        for fk_name, c in tables[name]["fks"]:
            edges.append({"from": name, "to": c["ref"], "opt": c["null"], "col": c["name"], "fk": fk_name})
    groups = {}
    for e in edges:
        groups.setdefault(tuple(sorted((e["from"], e["to"]))), []).append(e)
    for g in groups.values():
        for i, e in enumerate(g):
            e["off"] = (i - (len(g) - 1) / 2) * 12
    return boxes, edges, width, height


def foot_path(px, py, ux, uy):
    """Kurza łapka przy tabeli podrzędnej (wiele), zwrócona w stronę tabeli nadrzędnej."""
    nx, ny = -uy, ux
    ax, ay = px + ux * 13, py + uy * 13
    toes = [(px + nx * 7, py + ny * 7), (px, py), (px - nx * 7, py - ny * 7)]
    d = "".join(f"M{ax:.1f} {ay:.1f}L{tx:.1f} {ty:.1f}" for tx, ty in toes)
    bx, by = px + ux * 17, py + uy * 17
    d += f"M{bx + nx * 6:.1f} {by + ny * 6:.1f}L{bx - nx * 6:.1f} {by - ny * 6:.1f}"
    return d


def head_path(px, py, ux, uy):
    """Grot przy tabeli nadrzędnej."""
    nx, ny = -uy, ux
    bx, by = px - ux * 10, py - uy * 10
    return (f"M{px:.1f} {py:.1f}L{bx + nx * 5:.1f} {by + ny * 5:.1f}"
            f"L{bx - nx * 5:.1f} {by - ny * 5:.1f}Z")


def render_svg(o, tables, warnings):
    boxes, edges, W, H = layout(o, tables)
    parts = []
    for e in edges:
        a, b = boxes[e["from"]], boxes[e["to"]]
        cls = "edge" + (" opt" if e["opt"] else "")
        title = f"{e['from']}.{e['col']} → {e['to']}"
        if a is b:  # relacja do samej siebie
            sx, sy = a["x"] + a["w"], a["y"] + a["h"] * 0.34
            ex, ey = a["x"] + a["w"], a["y"] + a["h"] * 0.62
            d = f"M{sx} {sy:.1f}H{sx + 34}V{ey:.1f}H{ex}"
            parts.append(f'<g class="{cls}" data-from="{a["name"]}" data-to="{a["name"]}"><title>{esc(title)}</title>'
                         f'<path class="e-line" d="{d}"/><path class="e-foot" d="{foot_path(sx, sy, 1, 0)}"/>'
                         f'<path class="e-head" d="{head_path(ex, ey, -1, 0)}"/></g>')
            continue
        acx, acy = a["x"] + a["w"] / 2, a["y"] + a["h"] / 2
        bcx, bcy = b["x"] + b["w"] / 2, b["y"] + b["h"] / 2
        dx, dy = bcx - acx, bcy - acy
        ln = (dx * dx + dy * dy) ** 0.5
        ux, uy = dx / ln, dy / ln
        nx, ny = -uy, ux
        off = e["off"]
        acx, acy, bcx, bcy = acx + nx * off, acy + ny * off, bcx + nx * off, bcy + ny * off
        p = clip(acx, acy, a["w"], a["h"], ux, uy)
        q = clip(bcx, bcy, b["w"], b["h"], -ux, -uy)
        for other in boxes.values():
            if other is not a and other is not b and seg_hits_box(p, q, other):
                warnings.append(f"organizm {o['id']}: linia {e['from']} → {e['to']} przecina tabelę {other['name']}")
        parts.append(f'<g class="{cls}" data-from="{a["name"]}" data-to="{b["name"]}"><title>{esc(title)}</title>'
                     f'<path class="e-line" d="M{p[0]:.1f} {p[1]:.1f}L{q[0]:.1f} {q[1]:.1f}"/>'
                     f'<path class="e-foot" d="{foot_path(p[0], p[1], ux, uy)}"/>'
                     f'<path class="e-head" d="{head_path(q[0], q[1], ux, uy)}"/></g>')
    edges_svg = "".join(parts)
    parts = []
    for b in sorted(boxes.values(), key=lambda b: (b["pos"][1], b["pos"][0])):
        x, y, w, h = b["x"], b["y"], b["w"], b["h"]
        cls = "tbl stub" if b["stub"] else "tbl"
        label = (f"Tabela {b['name']} z organizmu {b['org']} – przejdź" if b["stub"]
                 else f"Tabela {b['name']} – pokaż opis")
        g = [f'<g class="{cls}" data-t="{b["name"]}" data-org="{b["org"]}" tabindex="0" role="button" '
             f'aria-label="{esc(label)}">',
             f'<rect class="t-box" x="{x}" y="{y}" width="{w}" height="{h}"/>',
             f'<rect class="t-hdr" x="{x}" y="{y}" width="{w}" height="{b["hdr"]}"/>',
             f'<text class="t-title" x="{x + w / 2:.1f}" y="{y + 17}" text-anchor="middle">{esc(b["name"])}</text>']
        if b["sub"]:
            g.append(f'<text class="t-sub" x="{x + w / 2:.1f}" y="{y + 31}" text-anchor="middle">{esc(b["sub"])}</text>')
        ry = y + b["hdr"] + TOP + 12
        for mk, rq, name, typ in b["rows"]:
            g.append(f'<text class="t-row" y="{ry}"><tspan class="t-mk" x="{x + PAD}">{mk}</tspan>'
                     f'<tspan class="t-rq" x="{x + PAD + 3 * CH:.1f}">{rq}</tspan>'
                     f'<tspan x="{x + b["namex"]:.1f}">{esc(name)}</tspan>'
                     f'<tspan class="t-ty" x="{x + b["typex"]:.1f}">{esc(typ)}</tspan></text>')
            ry += ROW
        if b["foot"]:
            sy = ry - 12 + 6
            g.append(f'<line class="t-sep" x1="{x}" x2="{x + w}" y1="{sy}" y2="{sy}"/>')
            fy = sy + 14
            for f in b["foot"]:
                g.append(f'<text class="t-foot" x="{x + PAD}" y="{fy}">{esc(f)}</text>')
                fy += FOOT
        g.append("</g>")
        parts.append("".join(g))
    boxes_svg = "".join(parts)
    return (f'<svg class="er" viewBox="0 0 {W} {H}" width="{W}" height="{H}" role="group" '
            f'aria-label="Diagram tabel organizmu {o["id"]}: {esc(o["title"])}">'
            f'<g class="edges">{edges_svg}</g><g class="boxes">{boxes_svg}</g></svg>')


# ───────────── SQL ─────────────
def sql_value(c, v):
    if v is None:
        return "NULL"
    if isinstance(v, (int, float)):
        return str(v)
    s = str(v).replace("'", "''")
    if c["type"] == "DATE":
        return f"DATE '{s}'"
    if c["type"].startswith("TIMESTAMP"):
        return f"TIMESTAMP '{s}'"
    return f"'{s}'"


def seed_order(names, tables):
    """Kolejność wstawiania przykładowych wierszy: najpierw tabele, na które inne wskazują."""
    order, done = [], set()

    def visit(n):
        if n in done:
            return
        done.add(n)
        for c in tables[n]["columns"]:
            if "ref" in c and c["ref"] in names and c["ref"] != n:
                visit(c["ref"])
        order.append(n)

    for n in names:
        visit(n)
    return [n for n in order if tables[n]["rows"]]


def sql_organism(o, tables):
    out = [f"-- Organizm {o['id']}: {o['title']}",
           f"-- {o['short']}",
           "-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.",
           "-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.",
           ""]
    for n in o["own"]:
        t = tables[n]
        w = max(len(c["name"]) for c in t["columns"])
        tw = max(len(c["type"]) for c in t["columns"])
        lines = [f"    {c['name'].ljust(w)}  {c['type'].ljust(tw)}{'' if c['null'] else '  NOT NULL'}".rstrip()
                 for c in t["columns"]]
        out.append(f"CREATE TABLE {n} (\n" + ",\n".join(lines) + "\n);")
        out.append("")
    for n in o["own"]:
        t = tables[n]
        out.append(f"COMMENT ON TABLE {n} IS '{t['desc'].replace(chr(39), chr(39) * 2)}';")
        for c in t["columns"]:
            out.append(f"COMMENT ON COLUMN {n}.{c['name']} IS '{c['desc'].replace(chr(39), chr(39) * 2)}';")
        out.append("")
    for n in o["own"]:
        t = tables[n]
        out.append(f"ALTER TABLE {n} ADD CONSTRAINT {t['pk_name']} PRIMARY KEY ({t['columns'][0]['name']});")
        for name, cols in t["uqs"]:
            out.append(f"ALTER TABLE {n} ADD CONSTRAINT {name} UNIQUE ({', '.join(cols)});")
        for name, expr in t["cks"]:
            out.append(f"ALTER TABLE {n} ADD CONSTRAINT {name} CHECK ({expr});")
    out.append("")
    for n in o["own"]:
        t = tables[n]
        for name, c in t["fks"]:
            if not c["ext"]:
                out.append(f"ALTER TABLE {n} ADD CONSTRAINT {name} FOREIGN KEY ({c['name']})"
                           f" REFERENCES {c['ref']} ({c['ref']}Key);")
    seeds = seed_order(o["own"], tables)
    if seeds:
        out.append("")
        out.append("-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).")
        for n in seeds:
            t = tables[n]
            cols = t["columns"]
            for i, r in enumerate(t["rows"], 1):
                vals = [str(i)] + [sql_value(c, v) for c, v in zip(cols[1:], r)]
                out.append(f"INSERT INTO {n} ({', '.join(c['name'] for c in cols)}) VALUES ({', '.join(vals)});")
        out.append("COMMIT;")
    return "\n".join(out) + "\n"


def sql_links(tables):
    out = ["-- Połączenia między organizmami: klucze obce do tabel z innych organizmów.",
           "-- Uruchom po plikach 01–18. Wygenerowane z narzedzia/organizmy.py.", ""]
    for o in ORGANIZMY:
        lines = []
        for n in o["own"]:
            for name, c in tables[n]["fks"]:
                if c["ext"]:
                    lines.append(f"ALTER TABLE {n} ADD CONSTRAINT {name} FOREIGN KEY ({c['name']})"
                                 f" REFERENCES {c['ref']} ({c['ref']}Key);")
        if lines:
            out.append(f"-- organizm {o['id']}: {o['title']}")
            out += lines
            out.append("")
    return "\n".join(out)


def sql_drop(tables):
    out = ["-- Usuwa wszystkie tabele organizmów (np. przed ponownym utworzeniem po poprawkach).",
           "-- Uwaga: kasuje też dane w tych tabelach.", ""]
    for o in reversed(ORGANIZMY):
        for n in reversed(o["own"]):
            out.append(f"DROP TABLE {n} CASCADE CONSTRAINTS PURGE;")
    return "\n".join(out) + "\n"


# ───────────── strona HTML ─────────────
def tchip(name, tables, org_id):
    t = tables[name]
    if t["org"] == org_id:
        return f'<button type="button" class="tchip" data-t="{name}">{name}</button>'
    return f'<a class="tchip ext" href="#o{t["org"]}/{name}" title="Organizm {t["org"]}">{name}</a>'


def key_cell(c, t, tables):
    out = []
    if c.get("pk"):
        out.append('<span class="kb kb-p">PK</span>')
    if "ref" in c:
        parent = tables[c["ref"]]
        target = (f'<a href="#o{parent["org"]}/{parent["name"]}">{parent["name"]}</a> '
                  f'<span class="dim">(organizm {parent["org"]})</span>' if c["ext"]
                  else f'<button type="button" class="linkish" data-t="{parent["name"]}">{parent["name"]}</button>')
        out.append(f'<span class="kb kb-f">FK</span> → {target}')
    if any(c["name"] in u for _, u in t["uqs"]):
        out.append('<span class="kb kb-u">UQ</span>')
    return " ".join(out) or '<span class="dim">–</span>'


def value_label(tables, ref, key):
    t = tables[ref]
    first = t["rows"][key - 1][0]
    return f"{key} · {first}"


def rows_block(t, tables):
    if not t["rows"]:
        return ""
    data_cols = t["columns"][1:]
    if len(data_cols) == 1:
        chips = "".join(f'<li><span class="vk">{i}</span>{esc(r[0])}</li>' for i, r in enumerate(t["rows"], 1))
        return f'<div class="vals"><p class="vals-h">Warianty (wiersze w tabeli)</p><ul class="vchips">{chips}</ul></div>'
    head = "".join(f'<th class="mono">{esc(c["name"])}</th>' for c in t["columns"])
    body = []
    for i, r in enumerate(t["rows"], 1):
        cells = [f'<td class="mono">{i}</td>']
        for c, v in zip(data_cols, r):
            if v is None:
                cells.append('<td class="dim">pusta</td>')
            elif "ref" in c:
                cells.append(f"<td>{esc(value_label(tables, c['ref'], v))}</td>")
            else:
                cells.append(f"<td>{esc(v)}</td>")
        body.append("<tr>" + "".join(cells) + "</tr>")
    return (f'<div class="vals"><p class="vals-h">Przykładowe wiersze</p><div class="tscroll"><table class="vt">'
            f'<thead><tr>{head}</tr></thead><tbody>{"".join(body)}</tbody></table></div></div>')


def table_card(t, tables):
    kind = f'<span class="badge">{esc(KIND_LABEL[t["kind"]])}</span>' if t["kind"] else ""
    rows = []
    for c in t["columns"]:
        req = '<span class="req" title="wymagana">*</span>' if not c["null"] else '<span class="req"></span>'
        rows.append(f'<tr><td class="mono cname">{req}{esc(c["name"])}</td><td class="mono ctype">{esc(c["type"])}</td>'
                    f'<td class="ckey">{key_cell(c, t, tables)}</td><td>{esc(c["desc"])}</td></tr>')
    extra = []
    if t["cks"]:
        conds = "; ".join(f'<code>{esc(expr)}</code>' for _, expr in t["cks"])
        extra.append(f'<p class="cnote">Warunki poprawności: {conds}</p>')
    return (f'<article class="tcard" id="t-{t["name"]}" data-t="{t["name"]}">'
            f'<header class="tcard-h"><h3 class="mono">{esc(t["name"])}</h3>{kind}</header>'
            f'<p class="tdesc">{esc(t["desc"])}</p>'
            f'<div class="tscroll"><table class="ct"><thead><tr><th>Kolumna</th><th>Typ</th><th>Klucz</th><th>Opis</th>'
            f'</tr></thead><tbody>{"".join(rows)}</tbody></table></div>'
            f'{"".join(extra)}{rows_block(t, tables)}</article>')


def org_section(o, tables, warnings):
    n = len(ORGANIZMY)
    prev_o = next((p for p in ORGANIZMY if p["id"] == o["id"] - 1), None)
    next_o = next((p for p in ORGANIZMY if p["id"] == o["id"] + 1), None)
    pn = (f'<a class="pn" href="#o{prev_o["id"]}">← {prev_o["id"]}. {esc(prev_o["title"])}</a>' if prev_o
          else '<span></span>')
    nn = (f'<a class="pn nx" href="#o{next_o["id"]}">{next_o["id"]}. {esc(next_o["title"])} →</a>' if next_o
          else '<a class="pn nx" href="#start">Przegląd wszystkich →</a>')
    variants = "".join(
        f'<li><p>{esc(v["text"])}</p><p class="vt-to"><span class="arrow" aria-hidden="true">→</span> '
        f'{" ".join(tchip(tn, tables, o["id"]) for tn in v["tables"])}</p></li>' for v in o["variants"])
    ext = ""
    if o["ext"]:
        items = "".join(
            f'<li><a href="#o{tables[e]["org"]}/{e}" class="mono">{e}</a> – organizm {tables[e]["org"]}: '
            f'{esc(next(p["title"] for p in ORGANIZMY if p["id"] == tables[e]["org"]))}</li>' for e in o["ext"])
        ext = (f'<section class="block"><h3 class="eyebrow">Połączenia z innymi organizmami</h3>'
               f'<p class="hint">Szare ramki na diagramie. Klucze obce do nich są w pliku 99_polaczenia_miedzy_organizmami.sql, '
               f'bo organizmy są na razie osobne.</p><ul class="plain">{items}</ul></section>')
    maps = "".join(f'<li><a href="index.html#warstwa-{m["layer"]}">Warstwa {m["layer"]}</a> – {esc(m["what"])}</li>'
                   for m in o["map"])
    cards = "".join(table_card(tables[tn], tables) for tn in o["own"])
    sql = esc(sql_organism(o, tables))
    stage = ETAPY[o["stage"]]
    return f'''
<section class="view org" id="o{o["id"]}" data-org="{o["id"]}" aria-labelledby="h-o{o["id"]}">
  <nav class="crumbs" aria-label="Nawigacja organizmów"><a class="back" href="#start">← Wszystkie organizmy</a>
    <span class="crumb-pn">{pn}{nn}</span></nav>
  <p class="eyebrow">Organizm {o["id"]} z {n} · {o["stage"]}. {esc(stage)}</p>
  <h2 class="h1" id="h-o{o["id"]}" tabindex="-1">{esc(o["title"])}</h2>
  <p class="lede">{esc(o["short"])}</p>
  <div class="qa">
    <section class="qa-box"><h3 class="eyebrow">Co to jest w szerszym kontekście?</h3><p>{esc(o["context"])}</p></section>
    <section class="qa-box"><h3 class="eyebrow">Jakie mogą być warianty? → tabele</h3><ul class="variants">{variants}</ul></section>
  </div>
  <section class="block">
    <div class="dg-bar"><h3 class="eyebrow">Diagram tabel</h3>
      <button type="button" class="tbtn zoom" aria-pressed="false">Pełny rozmiar</button></div>
    <div class="dg">{render_svg(o, tables, warnings)}</div>
    <p class="sel" aria-live="polite"><span class="dim">Kliknij tabelę na diagramie, żeby zobaczyć jej opis i połączenia.</span></p>
  </section>
  <aside class="ask"><h3 class="eyebrow">Pytanie do prowadzącego</h3><p>{esc(o["question"])}</p></aside>
  <section class="block"><h3 class="eyebrow">Tabele organizmu ({len(o["own"])})</h3><div class="cards">{cards}</div></section>
  {ext}
  <section class="block"><h3 class="eyebrow">Na mapie warstw</h3><ul class="plain">{maps}</ul></section>
  <details class="sqlbox"><summary>SQL tego organizmu – do Oracle i do importu w Data Modeler</summary>
    <div class="sql-bar"><span class="hint mono">sql/organizmy/{o["id"]:02d}_{slug(o["title"])}.sql</span>
    <button type="button" class="tbtn copy">Kopiuj SQL</button></div><pre class="sql"><code>{sql}</code></pre></details>
  <nav class="pn-bottom" aria-label="Poprzedni i następny organizm">{pn}{nn}</nav>
</section>'''


def overview(tables):
    groups = []
    for key, name in ETAPY.items():
        cards = []
        for o in [p for p in ORGANIZMY if p["stage"] == key]:
            names = ", ".join(o["own"])
            cards.append(f'<a class="ocard" href="#o{o["id"]}"><span class="onum">{o["id"]}</span>'
                         f'<span class="otitle">{esc(o["title"])}</span><span class="oshort">{esc(o["short"])}</span>'
                         f'<span class="otabs mono">{len(o["own"])} tabel: {esc(names)}</span></a>')
        groups.append(f'<section class="stage"><h3 class="stage-h"><span class="stage-k">{key}</span>{esc(name)}</h3>'
                      f'<div class="ocards">{"".join(cards)}</div></section>')
    lecturer = "".join(f'<li><span class="mono">{esc(a)}</span> – {esc(b)}</li>' for a, b in SCHEMAT_PROWADZACEGO)
    todo = "".join(f'<li><b>{esc(a)}</b> <span class="dim">(warstwa {w}: {esc(z)})</span></li>' for a, w, z in DO_ROZPISANIA)
    total = sum(len(o["own"]) for o in ORGANIZMY)
    links = esc(sql_links(tables))
    return f'''
<section class="view" id="start" aria-labelledby="h-start">
  <p class="eyebrow">Projekt bazy danych · model tabel</p>
  <h1 class="h1" id="h-start" tabindex="-1">Organizmy tabel – od źródła danych</h1>
  <p class="lede">Zaczynamy od platformy, która dostarcza dane, i idziemy ich drogą aż do Trust Score. Każdy etap to osobny
  „organizm” – kilka tabel relacyjnych, które działają razem. Razem {len(ORGANIZMY)} organizmów i {total} tabel.</p>
  <div class="qa">
    <section class="qa-box"><h3 class="eyebrow">Jak powstał każdy organizm</h3>
      <p>Przy każdej tabeli zadawaliśmy dwa pytania:</p>
      <ol class="steps"><li><b>Co to jest w szerszym kontekście?</b> – np. platforma to każde źródło ofert pracy, nie tylko portal.</li>
      <li><b>Jakie mogą być warianty?</b> – np. portal, agregator, urząd pracy, strona kariery firmy.</li></ol>
      <p>Wariant, który może się powtarzać albo zmieniać, dostaje własną tabelę: słownik (lista wariantów), tabelę łączącą
      (wiele do wielu) albo historię (każda zmiana to nowy wiersz).</p></section>
    <section class="qa-box"><h3 class="eyebrow">Punkt wyjścia: schemat z zajęć</h3>
      <ul class="plain">{lecturer}</ul>
      <p class="hint">Nazwy i typy jak na schemacie: tabele po angielsku w PascalCase, klucz główny <span class="mono">&lt;Tabela&gt;Key</span>
      typu NUMBER, klucz obcy nazywa się tak samo jak klucz, do którego prowadzi.</p></section>
  </div>
  <section class="block legend-box" aria-label="Legenda diagramu"><h3 class="eyebrow">Jak czytać diagramy</h3>
    <ul class="legend">
      <li><span class="lg-mk">P</span> klucz główny</li><li><span class="lg-mk">F</span> klucz obcy</li>
      <li><span class="lg-mk">U</span> wartość unikalna</li><li><span class="lg-mk">*</span> kolumna wymagana (NOT NULL)</li>
      <li><svg width="70" height="18" aria-hidden="true"><path class="lg-line" d="M4 9H62"/><path class="lg-line" d="M17 9L4 2M17 9L4 9M17 9L4 16M21 3V15"/><path class="lg-head" d="M66 9L56 4L56 14Z"/></svg> wiele wierszy → jeden wiersz (grot przy tabeli, na którą wskazuje klucz obcy)</li>
      <li><svg width="70" height="18" aria-hidden="true"><path class="lg-line lg-opt" d="M4 9H62"/><path class="lg-head" d="M66 9L56 4L56 14Z"/></svg> linia przerywana: klucz obcy może być pusty</li>
      <li><span class="lg-stub">Tabela</span> szara ramka: tabela z innego organizmu</li>
    </ul></section>
  {"".join(groups)}
  <section class="block"><h3 class="eyebrow">Jeszcze nierozpisane – po uwagach prowadzącego, tym samym sposobem</h3>
    <ul class="plain">{todo}</ul></section>
  <details class="sqlbox"><summary>SQL połączeń między organizmami (99_polaczenia_miedzy_organizmami.sql)</summary>
    <div class="sql-bar"><span class="hint">Uruchom po plikach 01–18, gdy organizmy mają już działać razem.</span>
    <button type="button" class="tbtn copy">Kopiuj SQL</button></div><pre class="sql"><code>{links}</code></pre></details>
</section>'''


def nav_html():
    items = [f'<a class="pill" href="#start" data-nav="start">Przegląd</a>']
    for o in ORGANIZMY:
        items.append(f'<a class="pill" href="#o{o["id"]}" data-nav="o{o["id"]}" title="{esc(o["title"])}">{o["id"]}</a>')
    return "".join(items)


def main():
    tables = build_model()
    warnings = []
    sections = [overview(tables)] + [org_section(o, tables, warnings) for o in ORGANIZMY]
    os.makedirs(SQL_DIR, exist_ok=True)
    for old in os.listdir(SQL_DIR):
        if old.endswith(".sql"):
            os.remove(os.path.join(SQL_DIR, old))
    for o in ORGANIZMY:
        with open(os.path.join(SQL_DIR, f"{o['id']:02d}_{slug(o['title'])}.sql"), "w", encoding="utf-8") as f:
            f.write(sql_organism(o, tables))
    with open(os.path.join(SQL_DIR, "99_polaczenia_miedzy_organizmami.sql"), "w", encoding="utf-8") as f:
        f.write(sql_links(tables))
    with open(os.path.join(SQL_DIR, "usun_wszystkie_tabele.sql"), "w", encoding="utf-8") as f:
        f.write(sql_drop(tables))
    titles = {f"o{o['id']}": f"{o['id']}. {o['title']}" for o in ORGANIZMY}
    tpl = open(os.path.join(HERE, "template_organizmy.html"), encoding="utf-8").read()
    for key in ("__NAV__", "__SECTIONS__", "__TITLES__"):
        assert tpl.count(key) == 1, key
    page = (tpl.replace("__NAV__", nav_html())
               .replace("__TITLES__", json.dumps(titles, ensure_ascii=False).replace("</", "<\\/"))
               .replace("__SECTIONS__", "".join(sections)))
    with open(OUT_HTML, "w", encoding="utf-8") as f:
        f.write(page)
    total = sum(len(o["own"]) for o in ORGANIZMY)
    print(f"zapisano {os.path.relpath(OUT_HTML, ROOT)} ({len(page) // 1024} KB), {len(ORGANIZMY)} organizmów, {total} tabel,"
          f" SQL w {os.path.relpath(SQL_DIR, ROOT)}/")
    for w in warnings:
        print("UWAGA:", w)


if __name__ == "__main__":
    main()
