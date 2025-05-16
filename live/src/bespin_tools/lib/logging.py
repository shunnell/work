from __future__ import annotations

import logging
from contextlib import contextmanager

import click
from click_log import ClickHandler, simple_verbosity_option

from bespin_tools.lib.errors import BespinctlError


class BespinctlLogger(logging.LoggerAdapter):
    _DEFAULT_COLORS = {
        logging.WARNING: 'yellow',
        logging.ERROR: 'red',
        logging.CRITICAL: 'red',
        logging.FATAL: 'red',
        logging.DEBUG: 'yellow',
    }
    _ROOT_LOGGER = logging.getLogger('bespinctl')
    _ROOT_LOGGER.handlers = [ClickHandler()]
    verbosity_option = simple_verbosity_option(_ROOT_LOGGER)

    def __init__(self, prefixes: list[str]):
        super().__init__(self._ROOT_LOGGER, {'prefixes': tuple(prefixes)}, merge_extra=False)

    def log(self, level, msg: str, *args, color: str | None=None, **kwargs):
        level_name = logging.getLevelName(level).lower()
        if kwargs.get('exc_info') is not None:
            level_name = f"{level_name} (exception)"
        prefix = "".join(f"[{p}]" for p in self.extra['prefixes'] if len(p))
        msg = f"bespinctl{prefix}: {level_name}: {msg.strip()}"
        if color := color or self._DEFAULT_COLORS.get(level):
            msg = click.style(msg, fg=color)
        super().log(level, msg, *args, **kwargs)

    @contextmanager
    def temporary_level(self, level: str | int):
        if isinstance(level, int):
            logging.getLevelName(level)
        else:
            level = logging.getLevelNamesMapping()[level.upper()]
        oldlevel = self.getEffectiveLevel()
        self.setLevel(level)
        try:
            yield
        finally:
            self.setLevel(oldlevel)

    def new_logger_with_prefix(self, prefix: str, append=True) -> BespinctlLogger:
        assert isinstance(prefix, str)
        assert len(prefix)
        rv = type(self)(self.extra["prefixes"] if append else ())
        return rv.change_prefix(prefix)

    def change_prefix(self, prefix: str, append=True) -> BespinctlLogger:
        prefixes = [*self.extra["prefixes"]] if append else []
        prefixes.append(prefix)
        self.extra["prefixes"] = prefixes
        return self

    def attention(self, *args, **kwargs):
        self.info(*args, **kwargs, color='yellow')

    def success(self, *args, **kwargs):
        self.info(*args, **kwargs, color='green')


logger = BespinctlLogger([])

info = logger.info
warn = logger.warn
error = logger.error
debug = logger.debug
attention = logger.attention
success = logger.success


class LoggingMixin:
    def __init__(self, logger_or_prefix: str | BespinctlLogger, *args, **kwargs):
        if isinstance(logger_or_prefix, str):
            self._logger = logger.new_logger_with_prefix(logger_or_prefix)
        else:
            self._logger = logger_or_prefix
        super().__init__(*args, **kwargs)

    def _exc(self, msg, cls=BespinctlError, **kwargs):
        return cls(msg, logger=self._logger, **kwargs)
