from datetime import UTC

from app.rules.engine import RulesEngine
from app.rules.model import ArmMode, Box, Detection, Frame, ViewRules

START = 1_700_000_000.0


def box_at(x, y, width=0.04, height=0.12):
    return Box(x - width / 2, y - height, x + width / 2, y)


def detection(track, label, x, y, confidence=0.9):
    return Detection(track, label, confidence, box_at(x, y))


def engine(config, arm=ArmMode.SCHEDULE, started=START - 60):
    config = {**config, "tuning": {"warmup": 0, **config.get("tuning", {})}}
    return RulesEngine("view", ViewRules.from_dict(config), started, UTC, lambda: arm)


def run(rules, frames):
    updates = []
    for at, objects in frames:
        updates += rules.process(Frame(START + at, tuple(objects)))
    return updates


def walk(track, label, start, end, seconds, fps=5, offset=0.0):
    frames = []
    steps = int(seconds * fps)
    for step in range(steps + 1):
        fraction = step / steps
        x = start[0] + (end[0] - start[0]) * fraction
        y = start[1] + (end[1] - start[1]) * fraction
        frames.append((offset + step / fps, [detection(track, label, x, y)]))
    return frames


def actions(updates, kind=None):
    return [(update.action, update.event.kind.value) for update in updates if kind is None or update.event.kind == kind]
