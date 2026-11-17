"""Converte as logos oficiais dos clubes (PDF) em PNG para o app.

Uso (requer poppler-utils e ImageMagick):

    python backend/scripts/importar_logos.py [pasta_dos_pdfs]

Cada PDF traz o texto "Rotary Club de <Nome>, 4440", usado para associar a
logo ao clube de ``data/clubs.json``. Os PNGs vão para
``mobile/assets/images/clubs/`` e o campo ``logo`` dos clubes é preenchido.
"""

import json
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

from importar_planilha import (
    BACKEND_JSON,
    CLUB_LOGOS_DIR as LOGOS_DIR,
    MOBILE_JSON,
    ROOT,
    key,
    slug,
)

DEFAULT_PDF_DIR = ROOT / "docs" / "logos" / "Rotary Logos_PDF"
LOGO_HEIGHT = 210

# Nome no PDF (normalizado) -> nome do clube no app (normalizado).
ALIASES = {
    "gloria do oeste": "gloria d oeste",
    "vila bela de santissima trindade centro": "vila bela ss trindade centro",
    "rondonopolis distrito de vila operaria": "rondonopolis dist vila operaria",
    "brasnorte centro": "brasnorte",
}


def pdf_number(path: Path) -> int:
    match = re.search(r"-(\d+)\.pdf$", path.name)
    return int(match.group(1)) if match else 0


def club_name_in_pdf(path: Path) -> str | None:
    text = subprocess.run(
        ["pdftotext", "-l", "1", str(path), "-"],
        capture_output=True,
        text=True,
        check=True,
    ).stdout
    # Lotes novos às vezes omitem ", 4440" no texto embutido.
    match = re.search(
        r"rotary club de (.+?)(?:\s*,\s*4440)?\s*$",
        text.strip(),
        flags=re.I | re.S,
    )
    if not match:
        return None
    return re.sub(r"\s+", " ", match.group(1)).strip(" ,")


def render_png(pdf: Path, target: Path) -> None:
    with tempfile.TemporaryDirectory() as tmp:
        base = Path(tmp) / "logo"
        subprocess.run(
            ["pdftocairo", "-png", "-transp", "-singlefile", "-r", "400", str(pdf), str(base)],
            check=True,
        )
        subprocess.run(
            [
                "convert",
                f"{base}.png",
                "-trim",
                "+repage",
                "-filter",
                "Lanczos",
                "-resize",
                f"x{LOGO_HEIGHT}",
                "-colors",
                "128",
                "-define",
                "png:compression-level=9",
                "-strip",
                str(target),
            ],
            check=True,
        )


def main() -> None:
    pdf_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_PDF_DIR
    data = json.loads(BACKEND_JSON.read_text(encoding="utf-8"))
    clubs_by_key = {key(c["name"]): c for c in data["clubs"]}

    if LOGOS_DIR.exists():
        shutil.rmtree(LOGOS_DIR)
    LOGOS_DIR.mkdir(parents=True)

    matched: dict[str, Path] = {}
    unmatched = []
    for pdf in sorted(pdf_dir.glob("*.pdf"), key=pdf_number):
        name = club_name_in_pdf(pdf)
        if name is None:
            unmatched.append(pdf.name)
            continue
        k = key(name)
        club = clubs_by_key.get(ALIASES.get(k, k))
        if club is None:
            unmatched.append(name)
        elif club["id"] not in matched:
            matched[club["id"]] = pdf

    for club in data["clubs"]:
        pdf = matched.get(club["id"])
        if pdf is None:
            club["logo"] = None
            continue
        filename = f"{slug(club['name'])}.png"
        render_png(pdf, LOGOS_DIR / filename)
        club["logo"] = filename

    BACKEND_JSON.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    shutil.copyfile(BACKEND_JSON, MOBILE_JSON)

    without_logo = [c["name"] for c in data["clubs"] if not c["logo"]]
    print(f"{len(matched)} logos geradas em {LOGOS_DIR.relative_to(ROOT)}.")
    print("Logos sem clube no app:", ", ".join(unmatched) or "nenhuma")
    print(f"Clubes sem logo ({len(without_logo)}):", ", ".join(without_logo))


if __name__ == "__main__":
    main()
