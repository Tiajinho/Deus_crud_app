from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlmodel import Session

from app import crud
from app.database import get_session
from app.schemas import ItemCreate, ItemRead, ItemUpdate

router = APIRouter(prefix="/items", tags=["items"])


@router.post("", response_model=ItemRead, status_code=status.HTTP_201_CREATED)
def create_item(item_in: ItemCreate, session: Session = Depends(get_session)) -> ItemRead:
    return crud.create_item(session, item_in)


@router.get("", response_model=list[ItemRead])
def list_items(
    offset: int = Query(default=0, ge=0),
    limit: int = Query(default=100, ge=1, le=100),
    session: Session = Depends(get_session),
) -> list[ItemRead]:
    return crud.get_items(session, offset=offset, limit=limit)


@router.get("/{item_id}", response_model=ItemRead)
def get_item(item_id: int, session: Session = Depends(get_session)) -> ItemRead:
    item = crud.get_item(session, item_id)
    if item is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Item not found")
    return item


@router.patch("/{item_id}", response_model=ItemRead)
def update_item(
    item_id: int, item_in: ItemUpdate, session: Session = Depends(get_session)
) -> ItemRead:
    item = crud.get_item(session, item_id)
    if item is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Item not found")
    return crud.update_item(session, item, item_in)


@router.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_item(item_id: int, session: Session = Depends(get_session)) -> None:
    item = crud.get_item(session, item_id)
    if item is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Item not found")
    crud.delete_item(session, item)
