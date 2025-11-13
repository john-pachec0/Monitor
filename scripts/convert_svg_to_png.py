#!/usr/bin/env python3
"""Convert SVG to PNG for app icon generation"""

from PIL import Image
import io
import subprocess
import sys

def svg_to_png(svg_path, png_path, size=1024):
    """Convert SVG to PNG using qlmanage (macOS built-in)"""
    try:
        # Use macOS qlmanage to convert SVG to PNG
        subprocess.run([
            'qlmanage',
            '-t',
            '-s', str(size),
            '-o', '/tmp',
            svg_path
        ], check=True, capture_output=True)

        # qlmanage creates file.svg.png in /tmp
        import os
        svg_filename = os.path.basename(svg_path)
        temp_png = f'/tmp/{svg_filename}.png'

        # Move to desired location
        subprocess.run(['mv', temp_png, png_path], check=True)
        print(f"✓ Converted {svg_path} to {png_path}")
        return True
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == '__main__':
    svgs = [
        'tangled-professional-v1.svg',
        'tangled-transformation-v2.svg',
        'spiral-professional-v1.svg',
        'tangled-dark-mode-v1.svg'
    ]

    base_dir = '/Users/japacheco/ios-development/Untwist/AppIconDesigns'

    for svg in svgs:
        svg_path = f'{base_dir}/{svg}'
        png_path = f'{base_dir}/{svg.replace(".svg", ".png")}'
        svg_to_png(svg_path, png_path, 1024)
