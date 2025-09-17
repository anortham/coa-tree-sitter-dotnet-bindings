#!/bin/bash

# Build script for macOS universal binaries (x64 + arm64)
# This creates fat binaries that work on both Intel and Apple Silicon Macs

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NATIVE_DIR="$SCRIPT_DIR/tree-sitter-native"

# Output directories
BUILD_X64="$SCRIPT_DIR/build/runtimes/osx-x64/native"
BUILD_ARM64="$SCRIPT_DIR/build/runtimes/osx-arm64/native"
BUILD_UNIVERSAL="$SCRIPT_DIR/build/runtimes/osx/native"

# Color output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Building tree-sitter universal binaries for macOS${NC}"
echo "=================================================="

# Create build directories
mkdir -p "$BUILD_X64"
mkdir -p "$BUILD_ARM64"
mkdir -p "$BUILD_UNIVERSAL"

# List of all grammars to build
GRAMMARS=(
    "tree-sitter"
    "tree-sitter-agda"
    "tree-sitter-bash"
    "tree-sitter-c"
    "tree-sitter-cpp"
    "tree-sitter-c-sharp"
    "tree-sitter-css"
    "tree-sitter-dart"
    "tree-sitter-embedded-template"
    "tree-sitter-go"
    "tree-sitter-haskell"
    "tree-sitter-html"
    "tree-sitter-java"
    "tree-sitter-javascript"
    "tree-sitter-jsdoc"
    "tree-sitter-json"
    "tree-sitter-julia"
    "tree-sitter-kotlin"
    "tree-sitter-lua"
    "tree-sitter-markdown"
    "tree-sitter-ocaml"
    "tree-sitter-php"
    "tree-sitter-python"
    "tree-sitter-ql"
    "tree-sitter-ruby"
    "tree-sitter-rust"
    "tree-sitter-razor"
    "tree-sitter-scala"
    "tree-sitter-sql"
    "tree-sitter-swift"
    "tree-sitter-toml"
    "tree-sitter-tsq"
    "tree-sitter-typescript"
    "tree-sitter-tsx"
    "tree-sitter-verilog"
    "tree-sitter-yaml"
)

# Function to build for a specific architecture
build_arch() {
    local arch=$1
    local output_dir=$2
    local grammar=$3

    echo -e "  Building for ${arch}..."

    cd "$NATIVE_DIR/$grammar"

    # Clean previous build
    make clean 2>/dev/null || true

    # Set architecture-specific flags
    export CFLAGS="-arch $arch -fPIC -std=c99 -O3 -I../include"
    export LDFLAGS="-arch $arch -dynamiclib"

    # Build
    make 2>/dev/null || {
        echo -e "${RED}  Failed to build $grammar for $arch${NC}"
        return 1
    }

    # Copy to architecture-specific directory
    cp lib$grammar.dylib "$output_dir/" 2>/dev/null || cp libtree-sitter.dylib "$output_dir/" 2>/dev/null

    return 0
}

# Function to create universal binary
create_universal() {
    local grammar=$1
    local lib_name="lib$grammar.dylib"

    # Special case for tree-sitter core
    if [ "$grammar" = "tree-sitter" ]; then
        lib_name="libtree-sitter.dylib"
    fi

    if [ -f "$BUILD_X64/$lib_name" ] && [ -f "$BUILD_ARM64/$lib_name" ]; then
        echo -e "  Creating universal binary..."
        lipo -create \
            "$BUILD_X64/$lib_name" \
            "$BUILD_ARM64/$lib_name" \
            -output "$BUILD_UNIVERSAL/$lib_name"

        # Verify the universal binary
        lipo -info "$BUILD_UNIVERSAL/$lib_name" | grep -q "x86_64 arm64" && {
            echo -e "  ${GREEN}✓ Universal binary created${NC}"
        } || {
            echo -e "  ${RED}✗ Failed to create universal binary${NC}"
            return 1
        }
    else
        echo -e "  ${YELLOW}⚠ Skipping universal binary (missing architecture builds)${NC}"
    fi
}

# Build all grammars
total=${#GRAMMARS[@]}
success=0
failed=0

for i in ${!GRAMMARS[@]}; do
    grammar="${GRAMMARS[$i]}"
    count=$((i + 1))

    echo -e "\n${YELLOW}[$count/$total]${NC} Building $grammar..."

    if [ ! -d "$NATIVE_DIR/$grammar" ]; then
        echo -e "  ${YELLOW}⚠ Source directory not found, skipping${NC}"
        continue
    fi

    # Check if source files exist
    if ! ls "$NATIVE_DIR/$grammar"/*.c >/dev/null 2>&1; then
        echo -e "  ${YELLOW}⚠ No source files found, skipping${NC}"
        continue
    fi

    # Ensure Makefile exists
    if [ ! -f "$NATIVE_DIR/$grammar/Makefile" ]; then
        cp "$NATIVE_DIR/Makefile.grammar" "$NATIVE_DIR/$grammar/Makefile"
    fi

    # Build for both architectures
    x64_success=false
    arm64_success=false

    if build_arch "x86_64" "$BUILD_X64" "$grammar"; then
        x64_success=true
    fi

    if build_arch "arm64" "$BUILD_ARM64" "$grammar"; then
        arm64_success=true
    fi

    # Create universal binary if both architectures built successfully
    if $x64_success && $arm64_success; then
        create_universal "$grammar"
        ((success++))
        echo -e "${GREEN}✓ $grammar built successfully${NC}"
    else
        ((failed++))
        echo -e "${RED}✗ $grammar build failed${NC}"
    fi
done

echo -e "\n=================================================="
echo -e "${GREEN}Build Summary:${NC}"
echo -e "  Successful: $success"
echo -e "  Failed: $failed"
echo -e "  Total: $total"
echo ""
echo -e "${GREEN}Build artifacts:${NC}"
echo "  x64 libraries: $BUILD_X64"
echo "  arm64 libraries: $BUILD_ARM64"
echo "  Universal libraries: $BUILD_UNIVERSAL"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Verify builds with: lipo -info $BUILD_UNIVERSAL/*.dylib"
echo "2. Build .NET project: cd src && dotnet build"
echo "3. Run tests: dotnet test tests/TreeSitter.Tests.csproj"