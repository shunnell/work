from __future__ import annotations

from typing import Sequence

from rich.console import Console
from rich.table import Table

from bespin_tools.lib.aws.util import UNNAMED
from bespin_tools.lib.errors import BespinctlError


class BespinctlTable(Table):
    def __init__(self, columns: Sequence[str], rows: Sequence[Sequence] = (), **kwargs):
        super().__init__(show_header=True, header_style="bold magenta", expand=True, **kwargs)
        BespinctlError.invariant(len(columns) > 0, "No columns supplied")
        for col in columns:
            self.add_column(col, no_wrap=True)
            BespinctlError.invariant(str(self.columns[-1].header) == col, f"Invalid column header: {type(col)} '{col}'")
        for row in rows:
            self.add_row(*row)

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        console = Console(record=True)
        console.print(self)

    def add_row(self, *args, **kwargs):
        colnames = tuple(c.header for c in self.columns)
        if len(args) == 1 and isinstance(args[0], dict):
            args = tuple(args[0][c] for c in colnames)
        BespinctlError.invariant(len(args) == len(colnames), f"Expected {len(colnames)} fields but got {len(args)}")
        super().add_row(*[str(a).replace(UNNAMED, f"[yellow]{UNNAMED}[/yellow]") for a in args], **kwargs)
