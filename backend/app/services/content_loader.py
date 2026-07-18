from __future__ import annotations

import json
from functools import lru_cache
from pathlib import Path

DATA_DIR = Path(__file__).resolve().parents[1] / "data"


def _load_json(filename: str) -> list[dict]:
    path = DATA_DIR / filename
    if not path.exists():
        return []
    return json.loads(path.read_text(encoding="utf-8"))


@lru_cache
def get_questions() -> list[dict]:
    return _load_json("questions.json")


@lru_cache
def get_road_signs() -> list[dict]:
    return _load_json("road_signs.json")


@lru_cache
def get_highway_code() -> list[dict]:
    return _load_json("highway_code.json")


@lru_cache
def get_hazard_videos() -> list[dict]:
    return _load_json("hazard_videos.json")
