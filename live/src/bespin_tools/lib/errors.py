from __future__ import annotations

from click import ClickException



class BespinctlError(ClickException):

    def __init__(self, msg: str, /, exit_code=1, exc_info: Exception | None=None, logger=None):
        assert exit_code > 0
        super().__init__(msg)
        self.exit_code, self.exc_info = exit_code, exc_info
        if logger is None:
            from bespin_tools.lib.logging import logger  # Reduce risk of import loops
        self._logger = logger

    @classmethod
    def invariant(cls, condition: bool, msg: str):
        if not condition:
            raise cls(msg)

    def show(self, **_) -> None:
        self._logger.error(self.format_message(), exc_info=self.exc_info)
