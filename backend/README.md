# Backend Rooter API

## Setup

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Run

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Docs: http://127.0.0.1:8000/docs

## Endpoints

- `GET /health`
- `GET /areas`
- `GET /areas/{area_id}/clubs`
- `GET /clubs/{club_id}`
