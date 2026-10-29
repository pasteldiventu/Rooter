"""Atualiza ``data/clubs.json`` a partir da planilha de presidentes do distrito.

Uso (requer ``pip install openpyxl``):

    python backend/scripts/importar_planilha.py "listagem de presidentes.xlsx"

Áreas, governadores assistentes e dados dos presidentes vêm da planilha.
Endereço, coordenadas e horário de reunião não existem na planilha e são
preservados do JSON atual, cruzando os clubes pelo nome.
"""

import json
import re
import shutil
import sys
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BACKEND_JSON = ROOT / "backend" / "data" / "clubs.json"
MOBILE_JSON = ROOT / "mobile" / "assets" / "data" / "clubs.json"
CLUB_LOGOS_DIR = ROOT / "mobile" / "assets" / "images" / "clubs"

SHEET_NAME = "Gov. Assistentes e Pres. 26-27"
MEETINGS_SHEET = "INFORMAÇÕES GERAIS"

# Nome na planilha -> nome exibido no app (acentos e grafia oficial).
DISPLAY_NAMES = {
    "Cuiabá-Taiama": "Cuiabá-Taiamã",
    "Rotary-Dist. Vila Operária": "Rondonópolis-Dist. Vila Operária",
    "Poxoreu - Morro da Mesa": "Poxoréu-Morro da Mesa",
    "Jaciara Águas Cristalinas": "Jaciara-Águas Cristalinas",
    "Santo Antonio do Leste": "Santo Antônio do Leste",
    "Gaucha do Norte": "Gaúcha do Norte",
    "Cáceres Caramujo": "Cáceres-Caramujo",
    "Cáceres Flor do Pantanal": "Cáceres-Flor do Pantanal",
    "Figueiropolis D'Oeste-Centro": "Figueirópolis D'Oeste-Centro",
    "Lambari D´Oeste": "Lambari D'Oeste",
    "Mirassol D' Oeste": "Mirassol D'Oeste",
    "Paranaita": "Paranaíta",
    "Colider": "Colíder",
    "Guaranta do Norte": "Guarantã do Norte",
    "Matupa": "Matupá",
    "Nova Ubirata": "Nova Ubiratã",
    "Claudia": "Cláudia",
    "Sinop Teles Pires": "Sinop-Teles Pires",
    "Marcelandia": "Marcelândia",
    "Itanhanga": "Itanhangá",
    "Nova Maringa-Ponte da Pedra": "Nova Maringá-Ponte da Pedra",
    "Arenapolis": "Arenápolis",
    "Campo Novo dos Parecis": "Campo Novo do Parecis",
    "Campos de Julio": "Campos de Júlio",
    "Juruena-Integraçao": "Juruena-Integração",
    "Juina": "Juína",
}

# Chave normalizada do nome novo -> chave do nome usado no JSON anterior.
LEGACY_ALIASES = {
    "rondonopolis comunidade": "rondonpolis comunidade",
    "rondonopolis dist vila operaria": "rondonpolis dist vila operaria",
    "rondonopolis leste": "rondonpolis leste",
    "rondonopolis rosa bororo": "rondonpolis rosa bororo",
    "itiquira": "itiqurira",
    "pontes e lacerda": "pontes e lacerda centro",
    "brasnorte": "brasnorte centro",
    "juruena integracao": "juruen integracao",
    "campo novo do parecis": "campo novo dos parecis",
    "tangara da serra cidade alta": "tangara da serra cidade lta",
}

EMAIL_FIXES = {
    "yahoo.bom.br": "yahoo.com.br",
    "hotimail.com": "hotmail.com",
}

LOWERCASE_WORDS = {"da", "de", "do", "das", "dos", "e"}

TEST_CLUB_ID = "area-01-teste-funcionamento"


def clean(value) -> str | None:
    if value is None:
        return None
    text = str(value).replace("\xa0", " ")
    text = re.sub(r"\s+", " ", text).strip()
    return text or None


def key(name: str) -> str:
    ascii_name = (
        unicodedata.normalize("NFKD", name).encode("ascii", "ignore").decode()
    )
    return re.sub(r"[^a-z0-9]+", " ", ascii_name.lower()).strip()


def slug(name: str) -> str:
    return key(name).replace(" ", "-")


def person_name(value) -> str | None:
    name = clean(value)
    if name is None or not name.isupper():
        return name
    words = name.lower().split(" ")
    return " ".join(
        w if i > 0 and w in LOWERCASE_WORDS else w.capitalize()
        for i, w in enumerate(words)
    )


def phone(value) -> str | None:
    text = clean(value)
    if text is None:
        return None
    digits = re.sub(r"\D", "", text)
    if len(digits) == 13 and digits.startswith("55"):
        digits = digits[2:]
    if len(digits) == 11:
        return f"{digits[:2]} {digits[2]} {digits[3:7]}-{digits[7:]}"
    if len(digits) == 10:
        return f"{digits[:2]} {digits[2:6]}-{digits[6:]}"
    return text


def email(value) -> str | None:
    text = clean(value)
    if text is None:
        return None
    text = text.lower()
    for wrong, right in EMAIL_FIXES.items():
        text = text.replace(wrong, right)
    return text


def governor_name(value) -> str | None:
    text = clean(value)
    if text is None:
        return None
    return re.sub(r"\s*-\s*\d+\s*Rotary Clubs?\s*$", "", text, flags=re.I)


def read_meetings(workbook) -> dict[str, str]:
    if MEETINGS_SHEET not in workbook.sheetnames:
        return {}
    sheet = workbook[MEETINGS_SHEET]
    col = None
    meetings = {}
    for row in sheet.iter_rows(values_only=True):
        if col is None:
            header = [key(clean(c) or "") for c in row]
            if "reunioes" in header:
                col = header.index("reunioes")
            continue
        club, schedule = clean(row[2]), clean(row[col])
        if club and schedule and club != "ROTARY CLUB":
            meetings[key(DISPLAY_NAMES.get(club, club))] = schedule.capitalize()
    return meetings


def read_sheet(path: Path) -> tuple[list[dict], list[dict]]:
    import openpyxl

    workbook = openpyxl.load_workbook(path, data_only=True)
    sheet = workbook[SHEET_NAME]
    meetings = read_meetings(workbook)

    areas: list[dict] = []
    rows: list[dict] = []
    current = None
    for row in sheet.iter_rows(min_row=1, values_only=True):
        area_cell, governor_cell, club_cell = (clean(c) for c in row[:3])
        if governor_cell and governor_cell.upper().startswith("TOTAL"):
            break
        if area_cell and area_cell.upper().startswith("ÁREA"):
            number = int(re.search(r"\d+", area_cell).group())
            current = {
                "id": f"area-{number:02d}",
                "name": f"Área {number:02d}",
                "number": number,
                "assistant_governor": None,
            }
            areas.append(current)
        if current is None or club_cell in (None, "ROTARY CLUB"):
            continue
        if governor_cell and governor_cell != "ASSISTENTE DO GOVERNADOR":
            current["assistant_governor"] = governor_name(governor_cell)

        name = DISPLAY_NAMES.get(club_cell, club_cell)
        rows.append(
            {
                "area_id": current["id"],
                "name": name,
                "president_name": person_name(row[3]),
                "president_phone": phone(row[4]),
                "president_email": email(row[5]),
                "meeting_schedule": meetings.get(key(name)),
            }
        )
    return areas, rows


def main() -> None:
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    areas, rows = read_sheet(Path(sys.argv[1]))

    previous = json.loads(BACKEND_JSON.read_text(encoding="utf-8"))
    legacy = {key(c["name"]): c for c in previous["clubs"]}
    test_club = next((c for c in previous["clubs"] if c["id"] == TEST_CLUB_ID), None)

    clubs = [test_club] if test_club else []
    used, missing = set(), []
    for row in rows:
        k = key(row["name"])
        old = legacy.get(k) or legacy.get(LEGACY_ALIASES.get(k, ""))
        if old:
            used.add(old["id"])
        else:
            missing.append(row["name"])
        logo = f"{slug(row['name'])}.png"
        clubs.append(
            {
                "id": f"{row['area_id']}-{slug(row['name'])}",
                "area_id": row["area_id"],
                "name": row["name"],
                "president_name": row["president_name"],
                "president_phone": row["president_phone"],
                "president_email": row["president_email"],
                "address": old.get("address") if old else None,
                "latitude": old.get("latitude") if old else None,
                "longitude": old.get("longitude") if old else None,
                "meeting_schedule": row["meeting_schedule"]
                or (old.get("meeting_schedule") if old else None),
                "logo": logo if (CLUB_LOGOS_DIR / logo).exists() else None,
            }
        )

    data = {
        "district": "Distrito 4440 — Mato Grosso",
        "state": previous.get("state", "MT"),
        "scope": previous.get("scope", "Somente clubes do estado de Mato Grosso"),
        "areas": areas,
        "clubs": clubs,
    }
    BACKEND_JSON.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    shutil.copyfile(BACKEND_JSON, MOBILE_JSON)

    removed = [
        c["name"]
        for c in previous["clubs"]
        if c["id"] not in used and c["id"] != TEST_CLUB_ID
    ]
    print(f"{len(areas)} áreas, {len(rows)} clubes da planilha gravados.")
    print("Clubes novos (sem endereço anterior):", ", ".join(missing) or "nenhum")
    print("Clubes removidos (fora da planilha):", ", ".join(removed) or "nenhum")


if __name__ == "__main__":
    main()
