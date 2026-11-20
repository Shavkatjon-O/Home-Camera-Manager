import json
from collections import Counter
from pathlib import Path

from app.main import app, public_description

EXPORT = Path(__file__).resolve().parents[1] / "openapi.json"


def operations():
    for path, methods in app.openapi()["paths"].items():
        for method, operation in methods.items():
            yield path, method, operation


def test_every_operation_has_a_unique_stable_id():
    ids = Counter(operation["operationId"] for _, _, operation in operations())
    assert [name for name, count in ids.items() if count > 1] == []
    assert all(name.isidentifier() and name == name.lower() for name in ids)


def test_every_operation_has_a_tag_and_a_documented_answer():
    for path, method, operation in operations():
        assert operation.get("tags"), (method, path)
        success = {code: answer for code, answer in operation["responses"].items() if code.startswith("2")}
        assert success, (method, path)
        for code, answer in success.items():
            if code == "204":
                continue
            content = answer.get("content") or {}
            assert content, (method, path)
            for media in content.values():
                assert media.get("schema"), (method, path)


def test_site_routes_name_the_site_header():
    operation = app.openapi()["paths"]["/api/v1/cameras"]["get"]
    assert "X-Site" in [parameter["name"] for parameter in operation["parameters"]]


def test_descriptions_leave_out_code_sections():
    text = "Do a thing.\n\nMore about it.\n\nArgs:\n    service: x.\n\nReturns:\n    y."
    assert public_description(text) == "Do a thing.\n\nMore about it."
    for _, _, operation in operations():
        assert "Args:" not in operation.get("description", "")


def test_the_committed_export_is_current():
    assert EXPORT.is_file(), "run scripts/export-openapi.sh"
    assert json.loads(EXPORT.read_text()) == json.loads(json.dumps(app.openapi())), "run scripts/export-openapi.sh"
