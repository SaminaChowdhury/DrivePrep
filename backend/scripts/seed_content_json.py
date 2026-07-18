"""One-off helper: export bundled Flutter content into backend JSON data files."""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DATA_DIR = Path(__file__).resolve().parents[1] / "app" / "data"


def _dart_maps_to_json(text: str) -> list[dict]:
    start = text.index("[")
    end = text.rindex("]") + 1
    block = text[start:end]
    items: list[dict] = []
    depth = 0
    current: list[str] = []
    for char in block:
        if char == "{":
            if depth == 0:
                current = ["{"]
            else:
                current.append(char)
            depth += 1
        elif char == "}":
            current.append(char)
            depth -= 1
            if depth == 0:
                raw = "".join(current)
                raw = re.sub(r"'([^'\\]*(?:\\.[^'\\]*)*)'", r'"\1"', raw)
                raw = re.sub(r"(\w+)\s*:", r'"\1":', raw)
                raw = raw.replace("\\'", "'")
                items.append(json.loads(raw))
                current = []
    return items


def export_questions() -> None:
    dart = (ROOT / "lib/features/theory/data/default_questions.dart").read_text(
        encoding="utf-8"
    )
    items = _dart_maps_to_json(dart)
    (DATA_DIR / "questions.json").write_text(
        json.dumps(items, indent=2, ensure_ascii=False), encoding="utf-8"
    )
    print(f"Wrote {len(items)} questions")


def export_signs() -> None:
    dart = (ROOT / "lib/features/signs/data/default_signs.dart").read_text(encoding="utf-8")
    signs: list[dict] = []
    for block in re.findall(
        r"RoadSign\(\s*([\s\S]*?)\s*\),", dart
    ):
        def field(name: str) -> str:
            match = re.search(rf"{name}:\s*'([^']*)'", block)
            return match.group(1) if match else ""

        signs.append(
            {
                "id": field("id"),
                "title": field("title"),
                "meaning": field("meaning"),
                "category": field("category"),
                "imageAssetPath": field("imageAssetPath"),
            }
        )
    (DATA_DIR / "road_signs.json").write_text(
        json.dumps(signs, indent=2, ensure_ascii=False), encoding="utf-8"
    )
    print(f"Wrote {len(signs)} road signs")


def export_highway() -> None:
    dart = (ROOT / "lib/core/data/default_highway_code.dart").read_text(encoding="utf-8")
    items = _dart_maps_to_json(dart)
    (DATA_DIR / "highway_code.json").write_text(
        json.dumps(items, indent=2, ensure_ascii=False), encoding="utf-8"
    )
    print(f"Wrote {len(items)} highway code entries")


def export_hazard_videos() -> None:
    videos = [
        {
            "id": "hazard_01",
            "title": "Suburban Street",
            "description": "Watch for pedestrians stepping out between parked cars.",
            "videoUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
            "thumbnailUrl": None,
            "durationSeconds": 15,
            "category": "Urban",
            "hazardTimestampSeconds": 8,
            "order": 1,
        },
        {
            "id": "hazard_02",
            "title": "Roundabout Approach",
            "description": "Identify when a cyclist enters your path at a mini-roundabout.",
            "videoUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
            "thumbnailUrl": None,
            "durationSeconds": 15,
            "category": "Junctions",
            "hazardTimestampSeconds": 10,
            "order": 2,
        },
        {
            "id": "hazard_03",
            "title": "Dual Carriageway",
            "description": "Spot the vehicle merging from a slip road onto the main carriageway.",
            "videoUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
            "thumbnailUrl": None,
            "durationSeconds": 15,
            "category": "Motorway",
            "hazardTimestampSeconds": 11,
            "order": 3,
        },
    ]
    (DATA_DIR / "hazard_videos.json").write_text(
        json.dumps(videos, indent=2, ensure_ascii=False), encoding="utf-8"
    )
    print(f"Wrote {len(videos)} hazard videos")


if __name__ == "__main__":
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    export_questions()
    export_signs()
    export_highway()
    export_hazard_videos()
