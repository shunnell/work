from __future__ import annotations

import re

from click import ParamType


class Regex(ParamType):
    name = "A regular expression pattern"

    Pattern = re.Pattern

    def convert(self, value, param, ctx) -> re.Pattern:
        if isinstance(value, str):
            if len(value) != len(value.strip()):
                self.fail(
                    f"Regex '{value}' has preceeding or trailing whitespace; did you mean to use a character class (e.g. 'foo[ ]')?",
                    param,
                    ctx,
                )
            if len(value) == 0:
                self.fail("Expected regex, got empty string", param, ctx)

            return re.compile(value)
        elif not isinstance(value, re.Pattern):
            self.fail(f"Expected a string, got {type(value)} {value}", param, ctx)
        return value
