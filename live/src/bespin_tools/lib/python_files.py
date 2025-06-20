from __future__ import annotations


from pathlib import Path
from typing import Iterable
from types import ModuleType

from bespin_tools.lib.util import iterdir


def python_cache_paths(below: Path) -> Iterable[Path]:
    for path in iterdir(below) if below.exists() else ():
        if path.name == '__pycache__' and path.is_dir():
            yield path
        elif path.suffix in ('.pyc', '.pyo', '.pyd') and '__pycache__' not in path.parts and path.is_file():
            yield path

def python_files(below: Path) -> Iterable[Path]:
    for path in iterdir(below):
        if path.suffix == ".py" and path.is_file():
            yield path

def python_modules(below: ModuleType) -> Iterable[str]:
    module_root = Path(below.__file__).parent
    for path in python_files(module_root):
        parts: list[str] = [below.__name__, *path.relative_to(module_root).parts]
        if parts[-1] == "__init__.py":
            parts.pop()
        parts[-1] = parts[-1].removesuffix(".py")
        yield ".".join(parts)
