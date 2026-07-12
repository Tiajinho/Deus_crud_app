from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.config import get_settings
from app.database import create_db_and_tables
from app.routers import health, items

settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    create_db_and_tables()
    yield


app = FastAPI(title=settings.app_name, version="0.1.0", lifespan=lifespan)
app.include_router(health.router)
app.include_router(items.router)


@app.get("/", tags=["root"])
def root() -> dict[str, str]:
    return {"service": settings.app_name, "docs": "/docs", "health": "/health"}
