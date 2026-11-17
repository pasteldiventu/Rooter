"""Importa a Equipe Distrital da planilha oficial para ``clubs.json``.

Uso:

    python backend/scripts/importar_equipe_distrital.py "Equipe_Distrital.xlsx"

Cria a área ``equipe-distrital`` e um "clube" por título/seção da planilha
(Governadoria, Conselho Consultivo, …), com os integrantes em ``members``.
"""

from __future__ import annotations

import json
import re
import shutil
import sys
from pathlib import Path

import openpyxl

from importar_planilha import BACKEND_JSON, MOBILE_JSON, clean, email, key, phone, slug

SHEET = "EQUIPE 2026-27"
AREA_ID = "equipe-distrital"

# Linhas B == "Nome"/"ÁREA" (ou título em caixa alta) iniciam seção.
SKIP_TITLES = {"cargo / funcao", "cargo / função"}


def title_case_section(name: str) -> str:
    raw = re.sub(r"\s+", " ", name).strip(" -–")
    if raw.isupper() or raw.upper() == raw:
        words = raw.lower().split(" ")
        keep_upper = {
            "dei",
            "dqa",
            "fr",
            "ip",
            "ryla",
            "yep",
            "abrol",
            "mt",
            "rdr",
            "rdi",
        }
        out = []
        for i, w in enumerate(words):
            bare = w.strip("()-–")
            if bare.lower() in keep_upper:
                out.append(w.upper() if bare.isalpha() else w)
            elif i > 0 and bare.lower() in {"de", "da", "do", "das", "dos", "e", "a", "à", "às"}:
                out.append(w.lower())
            else:
                out.append(w[:1].upper() + w[1:].lower() if w else w)
        return " ".join(out)
    return raw


def is_section_row(a: str | None, b: str | None) -> bool:
    if not a:
        return False
    if key(a) in SKIP_TITLES:
        return False
    if b in ("Nome", "ÁREA"):
        return True
    if b is None and len(a) >= 4 and a == a.upper() and not a[0].isdigit():
        # Ex.: GOVERNADORIA
        return True
    return False


def person_role_for_section(section: str, cargo: str | None, extra: str | None) -> str:
    sec = key(section)
    if "conselho consultivo" in sec:
        # Coluna B costuma ter o ano de governo (ex.: 2018-19).
        year = clean(extra)
        return f"Ex-Governador ({year})" if year else "Ex-Governador"
    if "governadores assistentes" in sec:
        area = clean(extra)
        return f"Governador Assistente — Área {area}" if area else "Governador Assistente"
    return clean(cargo) or "Membro"


def parse_sheet(path: Path) -> list[dict]:
    wb = openpyxl.load_workbook(path, data_only=True)
    ws = wb[SHEET]
    sections: list[dict] = []
    current: dict | None = None

    for row in ws.iter_rows(values_only=True):
        a = clean(row[0])
        b = clean(row[1])
        c = clean(row[2])
        d = clean(row[3])
        e = clean(row[4])

        if is_section_row(a, b):
            current = {
                "title": title_case_section(a),
                "members": [],
            }
            sections.append(current)
            continue

        if current is None or not a:
            continue
        # Cabeçalho repetido no meio da seção.
        if b in ("Nome", "ÁREA"):
            continue

        sec_key = key(current["title"])
        if "conselho consultivo" in sec_key:
            # A=nome, B=anos, C=clube, D=fone, E=email
            name, role_extra, club_name = a, b, c
            role = person_role_for_section(current["title"], None, role_extra)
            tel, mail = d, e
        elif "governadores assistentes" in sec_key:
            # A=nome (- N clubs), B=área, C=lista clubes, D=fone, E=email
            name = re.sub(r"\s*-\s*\d+\s*(Rotary\s*)?Clubs?\s*$", "", a, flags=re.I).strip()
            role = person_role_for_section(current["title"], None, b)
            club_name = None
            tel, mail = d, e
        else:
            # A=cargo, B=nome, C=clube, D=fone, E=email
            # Se B está vazio, pula (título sem titular).
            if not b:
                continue
            role = person_role_for_section(current["title"], a, None)
            name, club_name, tel, mail = b, c, d, e

        # Telefone placeholder.
        if tel in ("------", "-", "—"):
            tel = None
        if mail in ("------", "-", "—"):
            mail = None

        current["members"].append(
            {
                "role": role,
                "name": name,
                "phone": phone(tel),
                "email": email(mail),
                "club": club_name,
            }
        )

    # Remove seções vazias.
    return [s for s in sections if s["members"]]


def main() -> None:
    if len(sys.argv) != 2:
        sys.exit(__doc__)

    sections = parse_sheet(Path(sys.argv[1]))
    data = json.loads(BACKEND_JSON.read_text(encoding="utf-8"))

    # Remove área/clubes antigos da equipe.
    data["areas"] = [a for a in data["areas"] if a["id"] != AREA_ID]
    data["clubs"] = [c for c in data["clubs"] if c.get("area_id") != AREA_ID]

    area = {
        "id": AREA_ID,
        "name": "Equipe Distrital",
        "number": 0,
        "assistant_governor": "Distrito 4440 — 2026-27",
        "kind": "district_team",
    }
    # Equipe aparece no topo da lista.
    data["areas"].insert(0, area)

    for section in sections:
        title = section["title"]
        members = section["members"]
        first = members[0]
        data["clubs"].append(
            {
                "id": f"{AREA_ID}-{slug(title)}",
                "area_id": AREA_ID,
                "name": title,
                "kind": "district_team",
                "president_name": first["name"],
                "president_phone": first["phone"],
                "president_email": first["email"],
                "address": None,
                "latitude": None,
                "longitude": None,
                "meeting_schedule": None,
                "logo": None,
                "members": members,
            }
        )

    BACKEND_JSON.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    shutil.copyfile(BACKEND_JSON, MOBILE_JSON)

    print(f"Área Equipe Distrital com {len(sections)} seções:")
    for s in sections:
        print(f"  - {s['title']}: {len(s['members'])} integrantes")


if __name__ == "__main__":
    main()
