#!/usr/bin/env python3
# Copyright 2023 Canonical Ltd.
# All rights reserved.

"""Management script for the mir provider."""

from plainbox.provider_manager import setup
from plainbox.provider_manager import N_

setup(
    name='checkbox-provider-mir',
    namespace='com.canonical.qa.mir',
    version="0.1",
    description=N_("Checkbox Provider for mir devices"),
    gettext_domain='checkbox-provider-mir',
)
