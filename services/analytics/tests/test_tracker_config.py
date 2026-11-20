import hashlib
import subprocess
from pathlib import Path

import pytest

from app.settings import Settings

SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "tracker-config.sh"
BASE = Path("/opt/nvidia/deepstream/deepstream/samples/configs/deepstream-app/config_tracker_NvDCF_perf.yml")
OURS = {"maxTargetsPerStream": "60", "probationAge": "3", "maxShadowTrackingAge": "30"}
SYNTHETIC = """%YAML:1.0
TargetManagement:
  maxTargetsPerStream: 150    # note
  probationAge: 2    # note
  maxShadowTrackingAge: 51    # note
  earlyTerminationAge: 1
"""


def run(base, out, pinned=None):
    arguments = ["sh", str(SCRIPT), str(base), str(out)]
    if pinned is not None:
        arguments.append(pinned)
    return subprocess.run(arguments, capture_output=True, text=True)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def values(path):
    found = {}
    for line in path.read_text().splitlines():
        name, _, rest = line.strip().partition(":")
        if name in OURS:
            found[name] = rest.split("#")[0].strip()
    return found


def test_only_the_three_values_change(tmp_path):
    base = tmp_path / "base.yml"
    base.write_text(SYNTHETIC)
    out = tmp_path / "out" / "tracker.yml"
    assert run(base, out, digest(base)).returncode == 0
    assert values(out) == OURS
    changed = [pair for pair in zip(SYNTHETIC.splitlines(), out.read_text().splitlines()) if pair[0] != pair[1]]
    assert len(changed) == 3 and all("# note" in line for _, line in changed)


def test_a_missing_or_different_base_fails(tmp_path):
    base = tmp_path / "base.yml"
    assert run(base, tmp_path / "out.yml").returncode == 1
    base.write_text(SYNTHETIC)
    assert "pinned release" in run(base, tmp_path / "out.yml").stderr
    base.write_text(SYNTHETIC.replace("probationAge: 2", "probationAge: 4"))
    result = run(base, tmp_path / "out.yml", digest(base))
    assert result.returncode == 1 and "probationAge" in result.stderr


@pytest.mark.skipif(not BASE.exists(), reason="runs inside the DeepStream image")
def test_the_image_carries_the_generated_configuration(tmp_path):
    path = Settings().tracker_config
    assert path.exists() and values(path) == OURS
    assert run(BASE, tmp_path / "tracker.yml").returncode == 0
