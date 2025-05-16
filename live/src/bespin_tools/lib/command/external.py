from __future__ import annotations

import os
import shutil

import attr

from bespin_tools.lib.command.base import BaseCommand


@attr.define()
class ExternalCommand(BaseCommand):
    """
    Class to represent a CLI executable which is pre-installed (by the user, not by bespinctl) locally in the execution
    environment.
    """

    def _resolve(self):
        path = self.name
        if os.path.sep not in self.name:
            path = shutil.which(self.name)
        rv = self._validate_local_executable(path)
        return rv
