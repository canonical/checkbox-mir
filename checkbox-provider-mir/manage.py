#!/usr/bin/env python3
# Copyright Canonical Ltd.
# All rights reserved.

"""Management script for the Mir provider."""

from plainbox.provider_manager import setup
from plainbox.provider_manager import N_

setup(
    name='checkbox-provider-mir',
    namespace='io.mir-server',
    version="0.1",
    description=N_("Checkbox Provider for testing graphics support and Mir"),
    gettext_domain='checkbox-provider-mir',
)
