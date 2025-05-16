from __future__ import annotations

from typing import Sequence

from rich.console import Console
from rich.table import Table

from bespin_tools.lib.aws.util import UNNAMED


class BespinctlTable(Table):
    def __init__(self, columns: Sequence[str], rows: Sequence[Sequence] = (), **kwargs):
        super().__init__(show_header=True, header_style="bold magenta", expand=True, **kwargs)
        for column in columns:
            self.add_column(column)
        for row in rows:
            self.add_row(*row)

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        console = Console(record=True)
        console.print(self)

    def add_row(self, *args, **kwargs):
        super().add_row(*[str(a).replace(UNNAMED, f"[yellow]{UNNAMED}[/yellow]") for a in args], **kwargs)
