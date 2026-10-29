from pydantic import BaseModel


class Area(BaseModel):
    id: str
    name: str
    number: int
    assistant_governor: str | None = None


class ClubSummary(BaseModel):
    id: str
    area_id: str
    name: str
    logo: str | None = None


class ClubDetail(BaseModel):
    id: str
    area_id: str
    name: str
    president_name: str | None = None
    president_phone: str | None = None
    president_email: str | None = None
    address: str | None = None
    latitude: float | None = None
    longitude: float | None = None
    meeting_schedule: str | None = None
    logo: str | None = None
