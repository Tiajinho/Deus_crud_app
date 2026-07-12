from datetime import UTC, datetime

from sqlmodel import Field, SQLModel


def utcnow() -> datetime:
    return datetime.now(UTC)


class ItemBase(SQLModel):
    name: str = Field(index=True, min_length=1, max_length=100)
    description: str | None = Field(default=None, max_length=1000)
    price: float = Field(default=0.0, ge=0)
    quantity: int = Field(default=0, ge=0)


class Item(ItemBase, table=True):
    id: int | None = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=utcnow)
    updated_at: datetime = Field(default_factory=utcnow)
