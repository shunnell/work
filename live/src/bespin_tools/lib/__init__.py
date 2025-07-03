from __future__ import annotations

def replaceall(item: str, replacements: str, replacewith: str):
    for r in replacements:
        item = item.replace(r, replacewith)
    return item