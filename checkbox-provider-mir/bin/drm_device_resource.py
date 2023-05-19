#!/usr/bin/env python3

from pathlib import Path
import subprocess

from checkbox_support.parsers.udevadm import UdevadmParser

attributes = ('product_slug')

index = 0

for card in Path('/dev/dri').glob('card*'):
    output = subprocess.check_output(('udevadm', 'info', str(card)), encoding='utf-8')
    parser = UdevadmParser(output)
    try:
        udevinfo = parser.run()[0]
    except IndexError:
        continue

    index += 1
    print(f'path: {card}')
    print(f'product_slug: {udevinfo.product_slug}')
    print(f'index: {index}')

    print()
