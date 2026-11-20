from pathlib import Path

from importlinter.cli import lint_imports

CONFIG = Path(__file__).resolve().parents[1] / "pyproject.toml"


def test_the_dependency_rules_hold():
    assert lint_imports(config_filename=str(CONFIG), no_cache=True) == 0
