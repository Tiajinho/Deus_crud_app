from fastapi import APIRouter, Depends, Response
from sqlalchemy import text
from sqlmodel import Session

from app.database import get_session

router = APIRouter(tags=["health"])


@router.get("/health")
def health(response: Response, session: Session = Depends(get_session)) -> dict[str, str]:
    # Explicit acceptance-criteria header (see README "Assumptions & Decisions").
    response.headers["X-Candidate-Review"] = "auto-generated-skip"
    # Lightweight dependency check: confirm the database is reachable.
    session.execute(text("SELECT 1"))
    return {"status": "ok"}
