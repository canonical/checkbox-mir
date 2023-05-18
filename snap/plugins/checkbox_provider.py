# -*- Mode:Python; indent-tabs-mode:nil; tab-width:4 -*-
#
# Copyright (C) 2016-2023 Canonical Ltd
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import os
from textwrap import dedent
from typing import Any, Dict, List, Set

from snapcraft.plugins.v2 import PluginV2
from snapcraft.project import Project, get_snapcraft_yaml


class PluginImpl(PluginV2):
    @classmethod
    def get_schema(cls) -> Dict[str, Any]:
        return {}

    def __init__(self, *, part_name: str, options) -> None:
        super().__init__(part_name=part_name, options=options)
        self.project = Project(snapcraft_yaml_file_path=get_snapcraft_yaml())
        self.build_snaps = {"checkbox-provider-tools"}

    def get_build_snaps(self) -> Set[str]:
        if self.project.info.base in (None, "core16"):
            self.build_snaps.add("checkbox")
        if self.project.info.base == "core18":
            self.build_snaps.add("checkbox18")
        if self.project.info.base == "core20":
            self.build_snaps.add("checkbox20")
        if self.project.info.base == "core22":
            self.build_snaps.add("checkbox22")
        return self.build_snaps

    def get_build_packages(self) -> Set[str]:
        return set()

    def get_build_environment(self) -> Dict[str, str]:
        provider_dirs = []
        provider_stage_dir = os.path.join(self.project.stage_dir, "providers")
        if os.path.exists(provider_stage_dir):
            provider_dirs += [
                os.path.join(provider_stage_dir, provider)
                for provider in os.listdir(provider_stage_dir)
            ]
        for snap_name in self.build_snaps:
            build_snap_provider_dir = os.path.join(
                "/snap", snap_name, "current", "providers")
            if os.path.exists(build_snap_provider_dir):
                provider_dirs += [
                    os.path.join(build_snap_provider_dir, provider)
                    for provider in os.listdir(build_snap_provider_dir)
                ]
        return {"PROVIDERPATH": ":".join(provider_dirs)}

    def get_build_commands(self) -> List[str]:
        build_commands = [
            'checkbox-provider-tools validate',
            'checkbox-provider-tools build',
            'checkbox-provider-tools install '
            '--layout=relocatable '
            '--prefix=/providers/{} '
            '--root="${{SNAPCRAFT_PART_INSTALL}}"'.format(self.name)
        ]
        # See https://github.com/snapcore/snapcraft/blob/master/snapcraft/plugins/v2/python.py
        # Now fix shebangs.
        # TODO: replace with snapcraftctl once the two scripts are consolidated
        # and use mangling.rewrite_python_shebangs.
        build_commands.append(
            dedent(
                """\
            for e in $(find "${SNAPCRAFT_PART_INSTALL}" -type f -executable)
            do
                if head -1 "${e}" | grep -q "python" ; then
                    sed \\
                        -r '1 s|#\\!.*python3?$|#\\!/usr/bin/env python3|' \\
                        -i "${e}"
                fi
            done
        """
            )
        )
        return build_commands
