#!/bin/bash

# Build script for macOS native libraries
# This script sets up Makefiles and builds all tree-sitter grammars

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NATIVE_DIR="$SCRIPT_DIR/tree-sitter-native"

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    RID="osx-arm64"
else
    RID="osx-x64"
fi

BUILD_DIR="$SCRIPT_DIR/build/runtimes/$RID/native"

echo "Building tree-sitter native libraries for $RID"
echo "============================================"

# Create build directory
mkdir -p "$BUILD_DIR"

# List of all grammars to build
GRAMMARS=(
    "tree-sitter"
    "tree-sitter-agda"
    "tree-sitter-bash"
    "tree-sitter-c"
    "tree-sitter-cpp"
    "tree-sitter-c-sharp"
    "tree-sitter-css"
    "tree-sitter-embedded-template"
    "tree-sitter-go"
    "tree-sitter-haskell"
    "tree-sitter-html"
    "tree-sitter-java"
    "tree-sitter-javascript"
    "tree-sitter-jsdoc"
    "tree-sitter-json"
    "tree-sitter-julia"
    "tree-sitter-ocaml"
    "tree-sitter-php"
    "tree-sitter-python"
    "tree-sitter-ql"
    "tree-sitter-ruby"
    "tree-sitter-rust"
    "tree-sitter-razor"
    "tree-sitter-scala"
    "tree-sitter-swift"
    "tree-sitter-toml"
    "tree-sitter-tsq"
    "tree-sitter-typescript"
    "tree-sitter-tsx"
    "tree-sitter-verilog"
)

# Special build for tree-sitter core library
build_tree_sitter_core() {
    echo "Building tree-sitter core..."
    cd "$NATIVE_DIR/tree-sitter"

    # Check if source files exist
    if [ ! -f "*.c" ] && [ ! -f "lib.c" ]; then
        echo "Warning: No source files found for tree-sitter core. Run update-grammars.sh first."
        return 1
    fi

    # Copy Makefile if it doesn't exist
    if [ ! -f "Makefile" ]; then
        cp ../Makefile.grammar Makefile
    fi

    make clean 2>/dev/null || true
    make
    cp libtree-sitter.dylib "$BUILD_DIR/"
    echo "✓ tree-sitter core built"
}

# Build function for standard grammars
build_grammar() {
    local grammar=$1
    echo "Building $grammar..."

    cd "$NATIVE_DIR/$grammar"

    # Check if source files exist
    if ! ls *.c >/dev/null 2>&1; then
        echo "Warning: No source files found for $grammar. Skipping..."
        return 0
    fi

    # Copy Makefile if it doesn't exist
    if [ ! -f "Makefile" ]; then
        cp ../Makefile.grammar Makefile
    fi

    # Build
    make clean 2>/dev/null || true
    make

    # Copy to build directory
    cp lib$grammar.dylib "$BUILD_DIR/"
    echo "✓ $grammar built"
}

# Build all grammars
cd "$NATIVE_DIR"

# Build core first
if [ -d "tree-sitter" ]; then
    build_tree_sitter_core || echo "Failed to build tree-sitter core"
fi

# Build all language grammars
for grammar in "${GRAMMARS[@]}"; do
    if [ "$grammar" != "tree-sitter" ] && [ -d "$grammar" ]; then
        build_grammar "$grammar" || echo "Failed to build $grammar"
    fi
done

echo ""
echo "Build complete! Libraries are in: $BUILD_DIR"
echo ""
echo "To test the build, run:"
echo "  cd $SCRIPT_DIR"
echo "  dotnet test tests/TreeSitter.Tests.csproj"