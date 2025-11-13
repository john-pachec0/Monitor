#!/usr/bin/env python3
"""
Generate iOS App Icons from SVG
Converts appIcon.svg to all required iOS app icon sizes
"""

import os
import subprocess
import sys
from pathlib import Path

# iOS App Icon sizes (filename: size in pixels)
ICON_SIZES = {
    'icon-40x40@2x.png': 40,
    'icon-60x60@2x.png': 60,
    'icon-58x58@2x.png': 58,
    'icon-87x87@3x.png': 87,
    'icon-80x80@2x.png': 80,
    'icon-120x120@3x.png': 120,
    'icon-120x120@2x.png': 120,
    'icon-180x180@3x.png': 180,
    'icon-1024x1024.png': 1024,
}

def svg_to_png_rsvg(svg_path, png_path, size):
    """Convert SVG to PNG using rsvg-convert (best quality)"""
    try:
        subprocess.run([
            'rsvg-convert',
            '-w', str(size),
            '-h', str(size),
            '-o', png_path,
            svg_path
        ], check=True, capture_output=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False

def svg_to_png_imagemagick(svg_path, png_path, size):
    """Convert SVG to PNG using ImageMagick"""
    try:
        subprocess.run([
            'convert',
            '-background', 'none',
            '-resize', f'{size}x{size}',
            svg_path,
            png_path
        ], check=True, capture_output=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False

def svg_to_png_qlmanage(svg_path, png_path, size):
    """Convert SVG to PNG using macOS qlmanage (fallback)"""
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
        svg_filename = os.path.basename(svg_path)
        temp_png = f'/tmp/{svg_filename}.png'

        # Move to desired location
        subprocess.run(['mv', temp_png, png_path], check=True)
        return True
    except Exception:
        return False

def convert_svg_to_png(svg_path, png_path, size):
    """Try multiple conversion methods in order of quality"""
    methods = [
        ('rsvg-convert', svg_to_png_rsvg),
        ('ImageMagick', svg_to_png_imagemagick),
        ('qlmanage', svg_to_png_qlmanage),
    ]

    for method_name, method_func in methods:
        if method_func(svg_path, png_path, size):
            return True, method_name

    return False, None

def main():
    # Paths
    project_root = Path(__file__).parent.parent
    svg_path = project_root / 'appIcon.svg'
    output_dir = project_root / 'Monitor' / 'Assets.xcassets' / 'AppIcon.appiconset'

    # Validate SVG exists
    if not svg_path.exists():
        print(f"❌ Error: SVG file not found at {svg_path}")
        print(f"   Please ensure appIcon.svg exists in {project_root}")
        return 1

    # Create output directory if needed
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"📱 Generating iOS App Icons from {svg_path.name}")
    print(f"📂 Output directory: {output_dir}")
    print()

    # Generate all icon sizes
    method_used = None
    success_count = 0

    for filename, size in ICON_SIZES.items():
        output_path = output_dir / filename
        success, method = convert_svg_to_png(str(svg_path), str(output_path), size)

        if success:
            if method_used is None:
                method_used = method
                print(f"🔧 Using {method} for conversion")
                print()

            print(f"✅ {filename:<25} ({size}x{size}px)")
            success_count += 1
        else:
            print(f"❌ {filename:<25} (FAILED)")

    print()
    print("=" * 60)
    print(f"✨ Generated {success_count}/{len(ICON_SIZES)} icons successfully")

    if success_count < len(ICON_SIZES):
        print()
        print("⚠️  Some icons failed to generate")
        print("   Install rsvg-convert for best results:")
        print("   brew install librsvg")
        return 1

    print()
    print("📌 Next steps:")
    print("   1. Open Monitor.xcodeproj in Xcode")
    print("   2. Select the Monitor target")
    print("   3. Go to 'General' tab")
    print("   4. Under 'App Icons and Launch Screen', select 'AppIcon'")
    print("   5. Build and run to see your new icon!")

    return 0

if __name__ == '__main__':
    sys.exit(main())
