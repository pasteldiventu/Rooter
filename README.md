# Rooter — Rotary Club (Mato Grosso)

App facilitador para localizar clubes Rotary **somente no estado de Mato Grosso**: escolher a **Área**, ver contatos do presidente, horário de reunião (quando disponível) e abrir o endereço no Google Maps.

Stack: **Flutter** (mobile) + **FastAPI** (API) + **Shorebird** (updates OTA).

## Estrutura

```
Rooter/
  backend/   # FastAPI + dados mock (JSON)
  mobile/    # App Flutter
```

## Backend

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

- Health: http://127.0.0.1:8000/health
- Docs: http://127.0.0.1:8000/docs

Dados em `backend/data/clubs.json` (planilha de presidentes + clube fictício **Teste Funcionamento** com endereço do Instituto de Computação da UFMT).

## Mobile

```bash
cd mobile
flutter pub get
```

URL da API (padrão = emulador Android):

| Ambiente | Base URL |
|----------|----------|
| Emulador Android | `http://10.0.2.2:8000` (default) |
| iOS Simulator / desktop | `http://127.0.0.1:8000` |
| Device físico | `http://<IP-da-máquina>:8000` |

Exemplos:

```bash
# Emulador Android (default)
flutter run

# iOS / desktop
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000

# Device físico
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
```

Fluxo: **Áreas → Clubes → Detalhe** (contato, reunião se houver, endereço → Google Maps).

Se a API não responder (timeout ~3s ou erro de rede), o app usa automaticamente o JSON embutido (`assets/data/clubs.json`) e mostra um banner **Modo demonstração**. Assim o APK funciona sozinho para apresentação.

## Shorebird (OTA)

O app já foi inicializado (`mobile/shorebird.yaml`). Com o Shorebird CLI e conta autenticada (`shorebird login`):

```bash
cd mobile

# Release inicial (loja / distribuição)
shorebird release android
# shorebird release ios

# Patch OTA (código Dart, sem republicar na loja)
shorebird patch android
# shorebird patch ios
```

## MVP — o que está fora

Login, admin CRUD, mapa embutido, GPS do usuário, multi-distrito, banco real.
