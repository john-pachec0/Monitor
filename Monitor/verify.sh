#!/bin/bash
# Monitor Package Verification Script
# Run this after extracting to verify all files are present

echo "🔍 Verifying Monitor Package..."
echo ""

# Check if we're in the right directory
if [ ! -f "MonitorApp.swift" ]; then
    echo "❌ Error: MonitorApp.swift not found"
    echo "   Please run this script from the Monitor/ directory"
    exit 1
fi

# Define expected files
declare -a REQUIRED_FILES=(
    "MonitorApp.swift"
    "Models/AnxiousThought.swift"
    "Core/Theme.swift"
    "Features/Home/HomeView.swift"
    "Features/Capture/CaptureThoughtView.swift"
    "Features/Review/ReviewThoughtView.swift"
    "START-HERE.md"
    "README.md"
    "SETUP.md"
    "ARCHITECTURE.md"
    "DESIGN.md"
    "BRANDING.md"
    "REBRAND.md"
    "PACKAGE-CONTENTS.md"
)

MISSING_COUNT=0
FOUND_COUNT=0

# Check each file
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
        ((FOUND_COUNT++))
    else
        echo "❌ MISSING: $file"
        ((MISSING_COUNT++))
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Results: $FOUND_COUNT found, $MISSING_COUNT missing"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $MISSING_COUNT -eq 0 ]; then
    echo "🎉 SUCCESS! All files present and accounted for!"
    echo ""
    echo "Next steps:"
    echo "1. Read START-HERE.md"
    echo "2. Follow SETUP.md to create Xcode project"
    echo "3. Build and run the app!"
    echo ""
    echo "Quick start:"
    echo "  open START-HERE.md"
    echo ""
else
    echo "⚠️  WARNING: $MISSING_COUNT file(s) missing!"
    echo "   Try re-extracting the archive."
    echo ""
fi

# Count Swift files
SWIFT_COUNT=$(find . -name "*.swift" -type f | wc -l | tr -d ' ')
echo "📊 Found $SWIFT_COUNT Swift source files"

# Count documentation files
MD_COUNT=$(find . -name "*.md" -type f | wc -l | tr -d ' ')
echo "📚 Found $MD_COUNT Markdown documentation files"

echo ""
echo "Total package size:"
du -sh . 2>/dev/null || echo "Unable to calculate size"

echo ""
echo "Ready to build? Run:"
echo "  open SETUP.md"
