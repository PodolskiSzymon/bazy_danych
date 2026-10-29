"""Buduje web/index.html (mapa warstw) z data.py i template.html oraz web/organizmy.html i sql/organizmy/
(organizmy tabel) z organizmy.py.

Użycie: python narzedzia/build_web.py
"""
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
subprocess.run([sys.executable, os.path.join(HERE, "gen_html.py")], check=True)
src = open(os.path.join(HERE, "mapa-warstw.html"), encoding="utf-8").read()
i = src.index("</style>") + len("</style>")
page = ('<!doctype html>\n<html lang="pl">\n<head>\n<meta charset="utf-8">\n'
        '<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">\n'
        + src[:i] + '\n</head>\n<body>\n' + src[i:] + '\n</body>\n</html>\n')
out = os.path.join(HERE, "..", "web", "index.html")
open(out, "w", encoding="utf-8").write(page)
print("zapisano", os.path.normpath(out))
subprocess.run([sys.executable, os.path.join(HERE, "gen_organizmy.py")], check=True)
