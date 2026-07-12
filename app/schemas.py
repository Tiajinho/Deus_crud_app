from datetime import datetime

from sqlmodel import Field, SQLModel

from app.models import ItemBase


class ItemCreate(ItemBase):
    pass


class ItemRead(ItemBase):
    id: int
    created_at: datetime
    updated_at: datetime


class ItemUpdate(SQLModel):
    name: str | None = Field(default=None, min_length=1, max_length=100)
    description: str | None = Field(default=None, max_length=1000)
    price: float | None = Field(default=None, ge=0)
    quantity: int | None = Field(default=None, ge=0)
