from fastapi.testclient import TestClient


def _payload(**overrides: object) -> dict[str, object]:
    data: dict[str, object] = {
        "name": "Widget",
        "description": "A test widget",
        "price": 9.99,
        "quantity": 5,
    }
    data.update(overrides)
    return data


def test_create_item(client: TestClient) -> None:
    resp = client.post("/items", json=_payload())
    assert resp.status_code == 201
    body = resp.json()
    assert body["name"] == "Widget"
    assert body["id"] >= 1
    assert "created_at" in body and "updated_at" in body


def test_create_item_validation_error(client: TestClient) -> None:
    resp = client.post("/items", json=_payload(price=-1))
    assert resp.status_code == 422


def test_list_items(client: TestClient) -> None:
    client.post("/items", json=_payload(name="A"))
    client.post("/items", json=_payload(name="B"))
    resp = client.get("/items")
    assert resp.status_code == 200
    assert len(resp.json()) == 2


def test_list_items_pagination(client: TestClient) -> None:
    for i in range(3):
        client.post("/items", json=_payload(name=f"Item {i}"))
    resp = client.get("/items", params={"offset": 1, "limit": 1})
    assert resp.status_code == 200
    assert len(resp.json()) == 1


def test_get_item(client: TestClient) -> None:
    created = client.post("/items", json=_payload()).json()
    resp = client.get(f"/items/{created['id']}")
    assert resp.status_code == 200
    assert resp.json()["id"] == created["id"]


def test_get_item_not_found(client: TestClient) -> None:
    resp = client.get("/items/999")
    assert resp.status_code == 404
    assert resp.json()["detail"] == "Item not found"


def test_update_item(client: TestClient) -> None:
    created = client.post("/items", json=_payload()).json()
    resp = client.patch(f"/items/{created['id']}", json={"price": 19.99})
    assert resp.status_code == 200
    body = resp.json()
    assert body["price"] == 19.99
    assert body["name"] == "Widget"  # unchanged fields preserved


def test_update_item_not_found(client: TestClient) -> None:
    resp = client.patch("/items/999", json={"price": 1.0})
    assert resp.status_code == 404


def test_delete_item(client: TestClient) -> None:
    created = client.post("/items", json=_payload()).json()
    resp = client.delete(f"/items/{created['id']}")
    assert resp.status_code == 204
    assert client.get(f"/items/{created['id']}").status_code == 404


def test_delete_item_not_found(client: TestClient) -> None:
    resp = client.delete("/items/999")
    assert resp.status_code == 404
