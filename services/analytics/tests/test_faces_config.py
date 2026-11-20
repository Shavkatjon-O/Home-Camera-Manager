from app.config import parse_config


def camera(*views):
    return {"id": "cam", "name": "PTZ 2", "stream": "cam_main", "lenses": 2, "views": list(views)}


def view(lens, **fields):
    return {"id": f"v{lens}", "name": f"Lens {lens}", "lens": lens, **fields}


def test_faces_follow_the_profile_unless_the_view_overrides_them():
    config = parse_config(
        {
            "cameras": [
                camera(
                    view(1, profile="perimeter"),
                    view(2, profile="identity"),
                )
            ]
        }
    )
    perimeter, identity = config.views
    assert not perimeter.faces and not perimeter.recognises
    assert identity.faces and identity.recognises
    overridden = parse_config({"cameras": [camera(view(1, profile="perimeter", faces=True), view(2, faces=False))]})
    assert [item.recognises for item in overridden.views] == [True, False]


def test_disabled_or_undetected_views_never_recognise_and_toggling_restarts_the_pipeline():
    off = parse_config({"cameras": [camera(view(1, faces=True, enabled=False), view(2, profile="tamper", faces=True))]})
    assert [item.recognises for item in off.views] == [False, False]
    before = parse_config({"cameras": [camera(view(1), view(2))]})
    after = parse_config({"cameras": [camera(view(1), view(2, faces=True))]})
    assert before.pipeline_key() != after.pipeline_key()
