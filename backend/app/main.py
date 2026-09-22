from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from .data_loader import load_data
from .models import Area, ClubDetail, ClubSummary

app = FastAPI(
    title="Rooter Rotary API — Mato Grosso",
    description="API de clubes Rotary do estado de Mato Grosso (MT).",
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


@app.get("/areas", response_model=list[Area])
def list_areas() -> list[Area]:
    data = load_data()
    return [Area(**area) for area in data["areas"]]


@app.get("/areas/{area_id}/clubs", response_model=list[ClubSummary])
def list_clubs_by_area(area_id: str) -> list[ClubSummary]:
    data = load_data()
    area_ids = {a["id"] for a in data["areas"]}
    if area_id not in area_ids:
        raise HTTPException(status_code=404, detail="Área não encontrada")

    return [
        ClubSummary(id=c["id"], area_id=c["area_id"], name=c["name"])
        for c in data["clubs"]
        if c["area_id"] == area_id
    ]


@app.get("/clubs/{club_id}", response_model=ClubDetail)
def get_club(club_id: str) -> ClubDetail:
    data = load_data()
    for club in data["clubs"]:
        if club["id"] == club_id:
            return ClubDetail(**club)
    raise HTTPException(status_code=404, detail="Clube não encontrado")
