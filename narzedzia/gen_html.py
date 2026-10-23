"""Buduje klikalną stronę mapa-warstw.html z tych samych danych co rysunki w dokumencie."""
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from data import LAYERS  # noqa: E402
from roles import ROLES  # noqa: E402

# Krótkie opisy źródeł na mapie (te same co na rysunku całej struktury).
MAP_SOURCES = {
    1: [("sys", "Platformy", "konta firm (API)"), ("sys", "Rejestry publiczne", "KRS, VAT, CEIDG, REGON")],
    2: [("sys", "Platformy", "ogłoszenia i zdarzenia"), ("sys", "Model AI", "cechy i wektory tekstu")],
    3: [("person", "Kandydat", "zgłoszenie w widżecie"), ("sys", "Platformy", "log aplikacji"),
        ("sys", "Cloudflare", "człowiek czy bot?")],
    4: [("sys", "Model AI", "teczki spraw (LLM)"), ("person", "Personel", "wagi i etykiety")],
    5: [("person", "Kandydat", "widzi odznakę oferty"), ("person", "Pracodawca", "wynik i odwołanie"),
        ("person", "Moderator, IOD", "decyzje, wnioski RODO")],
    6: [("person", "Administrator", "parametry i słowniki")],
}

# Co dalej czyta następna warstwa (strzałki między pasami na mapie).
FLOW_NEXT = {
    1: "warstwa 2 czyta powiązania kont (employer_account_links)",
    2: "warstwa 3 czyta ogłoszenia (job_postings)",
    3: "warstwa 4 czyta zbiory warstw 1–3",
    4: "warstwa 5 czyta opublikowany wynik (published_trust_scores)",
    5: "zbiory zaplecza poniżej czytają wszystkie warstwy",
}

# Uprawnienia programów – te same kolumny „Czyta” / „Zapisuje” co w pierwszym dokumencie.
READS = {
    "rejestrator-kont": ["partners"],
    "urzednik": ["employer_accounts", "system_parameters"],
    "porzadkowy": ["employer_accounts", "registry_snapshots", "legal_form_dictionary"],
    "przyjmujacy": ["partners"],
    "redaktor": ["job_postings", "boilerplate_patterns", "employer_boilerplate"],
    "analityk-wymagan": ["posting_texts_clean", "seniority_dictionary", "skills_dictionary"],
    "wektoryzator": ["posting_texts_clean"],
    "detektyw": ["posting_vectors", "posting_features", "job_postings", "employer_account_links", "system_parameters"],
    "kronikarz": ["similar_posting_pairs", "posting_events", "job_postings"],
    "rejestrator-aplikacji": ["partners"],
    "notariusz": [],
    "sekretarka": ["application_log", "consents", "system_parameters"],
    "kancelaria": ["job_postings"],
    "bramkarz": [],
    "daktyloskop": ["consents"],
    "sprawdzacz": ["application_log", "system_parameters"],
    "analityk-naduzyc": ["reports", "device_fingerprints", "bot_checks", "application_log", "api_access_log"],
    "kierownik": ["reports", "bot_checks", "device_fingerprints", "abuse_alerts", "moderator_decisions", "system_parameters"],
    "statystyk": ["posting_lifecycles", "posting_families", "posting_features", "validated_reports", "application_log",
                  "registry_snapshots", "employers", "moderator_decisions"],
    "sedzia": ["employer_signals", "system_parameters", "model_registry"],
    "asystent": ["posting_families", "similar_posting_pairs", "employer_signals", "report_verdicts", "appeals"],
    "rzecznik": ["trust_score_history", "moderator_decisions", "system_parameters"],
    "bibliotekarz": ["employer_signals", "posting_lifecycles", "moderator_decisions"],
    "trener": ["training_datasets"],
    "informator": ["job_postings", "employer_account_links", "published_trust_scores", "posting_lifecycles"],
    "okienko": ["published_trust_scores", "employer_signals", "posting_families", "employers", "moderator_decisions"],
    "biurko": ["moderation_queue", "case_files", "reports", "similar_posting_pairs", "appeals"],
    "urzednik-rodo": ["consents"],
    "rzecznik-prasowy": ["employer_signals", "posting_lifecycles", "published_trust_scores", "badge_view_stats"],
    "portier": ["partners", "api_keys"],
    "biuro-admina": ["job_runs", "system_alerts", "llm_usage_log", "audit_log"],
    "zegar": ["system_parameters"],
    "straznik": ["job_runs", "task_queue", "api_access_log"],
    "lacznik": ["llm_cache", "system_parameters"],
    "protokolant": [],
    "sprzatacz": ["system_parameters"],
    "archiwista": [],
}
WRITES = {
    "rejestrator-kont": ["employer_accounts"],
    "urzednik": ["registry_snapshots"],
    "porzadkowy": ["employers", "employer_account_links", "employer_merge_log"],
    "przyjmujacy": ["raw_postings", "job_postings", "posting_events"],
    "redaktor": ["posting_texts_clean", "employer_boilerplate"],
    "analityk-wymagan": ["posting_features"],
    "wektoryzator": ["posting_vectors"],
    "detektyw": ["similar_posting_pairs"],
    "kronikarz": ["posting_families", "posting_lifecycles"],
    "rejestrator-aplikacji": ["application_log"],
    "notariusz": ["consents"],
    "sekretarka": ["reminders_sent"],
    "kancelaria": ["reports"],
    "bramkarz": ["bot_checks"],
    "daktyloskop": ["device_fingerprints"],
    "sprawdzacz": [],
    "analityk-naduzyc": ["abuse_alerts"],
    "kierownik": ["report_verdicts"],
    "statystyk": ["employer_signals"],
    "sedzia": ["trust_score_history"],
    "asystent": ["case_files"],
    "rzecznik": ["published_trust_scores"],
    "bibliotekarz": ["training_datasets"],
    "trener": ["model_registry"],
    "informator": ["badge_view_stats"],
    "okienko": ["appeals"],
    "biurko": ["moderator_decisions"],
    "urzednik-rodo": ["privacy_requests"],
    "rzecznik-prasowy": ["public_reports"],
    "portier": ["api_access_log"],
    "biuro-admina": ["system_parameters", "partners", "api_keys", "staff_accounts", "boilerplate_patterns",
                     "legal_form_dictionary", "seniority_dictionary", "skills_dictionary"],
    "zegar": ["job_runs"],
    "straznik": ["system_alerts"],
    "lacznik": ["llm_cache", "llm_usage_log"],
    "protokolant": ["audit_log"],
    "sprzatacz": [],
    "archiwista": ["backups"],
}
# Z którymi programami rozmawia dane źródło (osoba albo system).
TALKS = {
    "platformy": ["rejestrator-kont"],
    "rejestry": ["urzednik"],
    "platformy-ogloszenia": ["przyjmujacy"],
    "model-ai": ["lacznik", "analityk-wymagan", "wektoryzator"],
    "kandydat": ["kancelaria", "notariusz"],
    "widzet": ["kancelaria", "notariusz", "daktyloskop"],
    "platformy-log": ["rejestrator-aplikacji", "sekretarka"],
    "cloudflare": ["bramkarz"],
    "model-ai-teczki": ["lacznik", "asystent"],
    "personel": ["biuro-admina", "biurko"],
    "kandydat-odznaka": ["informator", "urzednik-rodo"],
    "pracodawca": ["okienko"],
    "moderator": ["biurko"],
    "iod": ["urzednik-rodo"],
    "administrator": ["biuro-admina"],
}
# Widoki – liczone na żywo z innych zbiorów.
VIEW_OF = {
    "validated_reports": ["reports", "report_verdicts"],
    "moderation_queue": ["report_verdicts", "abuse_alerts", "appeals", "published_trust_scores"],
}
# Zbiory pomocnicze bez własnego kafelka (opis do dymka).
AUX = {
    "employer_merge_log": "historia scaleń firm (warstwa 1)",
    "raw_postings": "surowa kopia ogłoszeń od platform (warstwa 2)",
    "posting_texts_clean": "oczyszczony tekst ogłoszeń (warstwa 2)",
    "posting_vectors": "wektory znaczenia ogłoszeń (warstwa 2)",
    "employer_boilerplate": "akapity powtarzane przez firmę (warstwa 2)",
    "consents": "zgody kandydatów (warstwa 3)",
    "reminders_sent": "wysłane przypomnienia (warstwa 3)",
    "bot_checks": "wyniki sprawdzenia w Cloudflare (warstwa 3)",
    "badge_view_stats": "liczniki wyświetleń odznak (warstwa 5)",
    "api_access_log": "log zapytań do API (warstwa 6)",
    "system_alerts": "alerty techniczne (warstwa 6)",
    "llm_usage_log": "koszty wywołań AI (warstwa 6)",
}
# Jedyny wyjątek od zasady jednego właściciela.
SHARED_WRITE = {"task_queue": "każdy program – tylko własne zlecenia (jedyny wyjątek od zasady jednego właściciela)"}
# Cztery tabele słowników mają jeden wspólny kafelek.
ALIAS = {name: "slowniki" for name in
         ("legal_form_dictionary", "seniority_dictionary", "skills_dictionary", "boilerplate_patterns")}


def build_data():
    layers = []
    prog_keys, store_keys = set(), set()
    for L in LAYERS:
        n = L["id"]
        lay = {
            "id": n,
            "name": L["name"],
            "mapTitle": L["map_title"],
            "storeGroup": L["store_group"],
            "finding": re.sub(r"^Warstwa \d+: ", "", L["title"]),
            "link": L["link"],
            "band1": L.get("band1", "SKĄD BIERZEMY DANE"),
            "arrow1": L.get("arrow1", "dane trafiają do programów"),
            "note": L["note"],
            "mapSources": [{"kind": k, "name": a, "detail": b} for k, a, b in MAP_SOURCES[n]],
            "flowNext": FLOW_NEXT.get(n),
            "sources": [], "programs": [], "stores": [],
        }
        for s in L["sources"]:
            lay["sources"].append({"key": s["key"], "kind": s["kind"], "name": s["name"], "sub": s["sub"],
                                   "fields": [list(f) for f in s["fields"]], "talks": TALKS[s["key"]],
                                   "role": ROLES[s["key"]]})
        for p in L["programs"]:
            prog_keys.add(p["key"])
            lay["programs"].append({"key": p["key"], "kind": "prog", "name": p["name"], "sub": p["sub"],
                                    "fields": [list(f) for f in p["fields"]],
                                    "reads": READS[p["key"]], "writes": WRITES[p["key"]],
                                    "role": ROLES[p["key"]]})
        for z in L["stores"]:
            store_keys.add(z["key"])
            item = {"key": z["key"], "kind": "store", "name": z["name"], "sub": z["sub"],
                    "fields": [list(f) for f in z["fields"]]}
            if z["key"] in VIEW_OF:
                item["viewOf"] = VIEW_OF[z["key"]]
            if z["key"] in SHARED_WRITE:
                item["sharedWrite"] = SHARED_WRITE[z["key"]]
            if z["key"] == "slowniki":
                item["tables"] = sorted(ALIAS)
            lay["stores"].append(item)
        layers.append(lay)
    # Spójność: każdy program ma wpis w READS/WRITES, każdy zbiór z kafelkiem ma właściciela albo jest widokiem.
    assert prog_keys == set(READS) == set(WRITES), prog_keys ^ set(READS)
    written = {ALIAS.get(d, d) for ds in WRITES.values() for d in ds}
    for k in store_keys:
        assert k in written or k in VIEW_OF or k in SHARED_WRITE, k
    # Każde źródło i każdy program ma opisaną rolę (roles.py).
    role_keys = prog_keys | {s["key"] for L in layers for s in L["sources"]}
    assert role_keys == set(ROLES), role_keys ^ set(ROLES)
    known = store_keys | set(AUX) | set(ALIAS)
    for ds in list(READS.values()) + list(WRITES.values()):
        for d in ds:
            assert d in known, d
    return {"layers": layers, "aux": AUX, "alias": ALIAS}


def main():
    data = json.dumps(build_data(), ensure_ascii=False).replace("</", "<\\/")
    tpl = open(os.path.join(HERE, "template.html"), encoding="utf-8").read()
    assert tpl.count("__DATA__") == 1
    out = os.path.join(HERE, "mapa-warstw.html")
    open(out, "w", encoding="utf-8").write(tpl.replace("__DATA__", data))
    print(out, os.path.getsize(out), "bajtów")


if __name__ == "__main__":
    main()
