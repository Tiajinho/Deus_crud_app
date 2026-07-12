from sqlmodel import Session, select

from app.models import Item, utcnow
from app.schemas import ItemCreate, ItemUpdate


def create_item(session: Session, item_in: ItemCreate) -> Item:
    item = Item(**item_in.model_dump())
    session.add(item)
    session.commit()
    session.refresh(item)
    return item


def get_item(session: Session, item_id: int) -> Item | None:
    return session.get(Item, item_id)


def get_items(session: Session, offset: int = 0, limit: int = 100) -> list[Item]:
    return list(session.exec(select(Item).offset(offset).limit(limit)).all())


def update_item(session: Session, item: Item, item_in: ItemUpdate) -> Item:
    for key, value in item_in.model_dump(exclude_unset=True).items():
        setattr(item, key, value)
    item.updated_at = utcnow()
    session.add(item)
    session.commit()
    session.refresh(item)
    return item


def delete_item(session: Session, item: Item) -> None:
    session.delete(item)
    session.commit()
