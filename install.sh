#!/bin/bash
# stdn installation script

set -e

INSTALL_DIR="${1:-/usr/local/lib/lua/5.1}"

echo "=== stdn Installation ==="
echo "Installing to: $INSTALL_DIR"

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Copy main module
echo "Copying stdn.lua..."
cp stdn.lua "$INSTALL_DIR/"

# Copy submodules
echo "Copying stdn modules..."
cp -r stdn "$INSTALL_DIR/"

echo ""
echo "✓ Installation complete!"
echo ""
echo "Usage:"
echo "  local stdn = require('stdn')"
echo ""
echo "Documentation:"
echo "  README.md      - Full documentation"
echo "  QUICKREF.md    - Quick reference guide"
echo "  ARCHITECTURE.md - Architecture details"
echo ""
echo "Examples:"
echo "  See examples/basic_usage.lua"
echo ""
echo "Tests:"
echo "  cd tests && lua test_all.lua"
