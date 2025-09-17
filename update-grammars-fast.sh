#!/usr/bin/env bash

# Tree-Sitter Grammar Update Script (Fast version with shallow clones)
# Updates all tree-sitter grammars to their latest versions

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NATIVE_DIR="$SCRIPT_DIR/tree-sitter-native"
TEMP_DIR="/tmp/tree-sitter-update"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Grammar repositories - using parallel arrays for bash 3.x compatibility
GRAMMAR_NAMES=(
    "tree-sitter"
    "tree-sitter-c"
    "tree-sitter-cpp"
    "tree-sitter-c-sharp"
    "tree-sitter-javascript"
    "tree-sitter-typescript"
    "tree-sitter-python"
    "tree-sitter-go"
    "tree-sitter-rust"
    "tree-sitter-java"
    "tree-sitter-ruby"
    "tree-sitter-php"
    "tree-sitter-html"
    "tree-sitter-css"
    "tree-sitter-json"
    "tree-sitter-bash"
    "tree-sitter-swift"
    "tree-sitter-scala"
    "tree-sitter-haskell"
    "tree-sitter-ocaml"
    "tree-sitter-julia"
    "tree-sitter-agda"
    "tree-sitter-embedded-template"
    "tree-sitter-jsdoc"
    "tree-sitter-ql"
    "tree-sitter-razor"
    "tree-sitter-toml"
    "tree-sitter-tsq"
    "tree-sitter-verilog"
)

GRAMMAR_REPOS=(
    "https://github.com/tree-sitter/tree-sitter"
    "https://github.com/tree-sitter/tree-sitter-c"
    "https://github.com/tree-sitter/tree-sitter-cpp"
    "https://github.com/tree-sitter/tree-sitter-c-sharp"
    "https://github.com/tree-sitter/tree-sitter-javascript"
    "https://github.com/tree-sitter/tree-sitter-typescript"
    "https://github.com/tree-sitter/tree-sitter-python"
    "https://github.com/tree-sitter/tree-sitter-go"
    "https://github.com/tree-sitter/tree-sitter-rust"
    "https://github.com/tree-sitter/tree-sitter-java"
    "https://github.com/tree-sitter/tree-sitter-ruby"
    "https://github.com/tree-sitter/tree-sitter-php"
    "https://github.com/tree-sitter/tree-sitter-html"
    "https://github.com/tree-sitter/tree-sitter-css"
    "https://github.com/tree-sitter/tree-sitter-json"
    "https://github.com/tree-sitter/tree-sitter-bash"
    "https://github.com/tree-sitter/tree-sitter-swift"
    "https://github.com/tree-sitter/tree-sitter-scala"
    "https://github.com/tree-sitter/tree-sitter-haskell"
    "https://github.com/tree-sitter/tree-sitter-ocaml"
    "https://github.com/tree-sitter/tree-sitter-julia"
    "https://github.com/tree-sitter/tree-sitter-agda"
    "https://github.com/tree-sitter/tree-sitter-embedded-template"
    "https://github.com/tree-sitter/tree-sitter-jsdoc"
    "https://github.com/tree-sitter/tree-sitter-ql"
    "https://github.com/tree-sitter/tree-sitter-razor"
    "https://github.com/tree-sitter/tree-sitter-toml"
    "https://github.com/tree-sitter/tree-sitter-tsq"
    "https://github.com/tree-sitter/tree-sitter-verilog"
)

echo -e "${GREEN}Tree-Sitter Grammar Update Script (Fast)${NC}"
echo "=========================================="
echo "Using shallow clones for speed..."

# Create temp directory
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# Function to update grammar
update_grammar() {
    local name=$1
    local repo=$2
    local target_dir="$NATIVE_DIR/$name"

    echo -e "\n${YELLOW}Updating $name...${NC}"

    # Remove old clone if exists
    rm -rf "$name"

    # Shallow clone with depth 1 for speed
    git clone --depth 1 "$repo" "$name" 2>/dev/null || {
        echo -e "${RED}Failed to clone $name${NC}"
        return 1
    }

    cd "$name"

    # Create target directory
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
    fi

    # Handle special cases for grammar source locations
    case "$name" in
        "tree-sitter")
            # Copy tree-sitter core library source
            if [ -d "lib/src" ]; then
                cp -r lib/src/* "$target_dir/" 2>/dev/null || true
            fi
            if [ -f "lib/include/tree_sitter/api.h" ]; then
                mkdir -p "$target_dir/../include/tree_sitter"
                cp lib/include/tree_sitter/*.h "$target_dir/../include/tree_sitter/" 2>/dev/null || true
            fi
            ;;
        "tree-sitter-ocaml")
            # OCaml has grammars in subdirectory
            if [ -d "grammars/ocaml/src" ]; then
                cp grammars/ocaml/src/* "$target_dir/" 2>/dev/null || true
            fi
            ;;
        "tree-sitter-php")
            # PHP has grammar in php subdirectory
            if [ -d "php/src" ]; then
                cp php/src/* "$target_dir/" 2>/dev/null || true
            fi
            ;;
        "tree-sitter-typescript")
            # TypeScript has multiple grammars
            if [ -d "typescript/src" ]; then
                cp typescript/src/* "$target_dir/" 2>/dev/null || true
            fi
            # Also copy TSX grammar
            if [ -d "tsx/src" ]; then
                mkdir -p "$NATIVE_DIR/tree-sitter-tsx"
                cp tsx/src/* "$NATIVE_DIR/tree-sitter-tsx/" 2>/dev/null || true
            fi
            ;;
        *)
            # Standard case - copy src directory
            if [ -d "src" ]; then
                cp src/* "$target_dir/" 2>/dev/null || true
            elif [ -d "queries" ]; then
                # Some grammars might have queries but no src
                echo "Note: $name has queries but no src directory"
            fi
            ;;
    esac

    cd "$TEMP_DIR"
    echo -e "${GREEN}✓ $name updated${NC}"
}

# Update all grammars
total=${#GRAMMAR_NAMES[@]}
for i in ${!GRAMMAR_NAMES[@]}; do
    count=$((i + 1))
    echo -e "\n${YELLOW}[$count/$total]${NC} Processing ${GRAMMAR_NAMES[$i]}..."
    update_grammar "${GRAMMAR_NAMES[$i]}" "${GRAMMAR_REPOS[$i]}"
done

echo -e "\n${GREEN}All grammars have been updated!${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Review the changes in tree-sitter-native/"
echo "2. Build the native libraries:"
echo "   - macOS: ./build-macos.sh"
echo "   - Linux: cd tree-sitter-native && make"
echo "   - Windows: Use Visual Studio with tree-sitter-native.sln"
echo "3. Run tests to ensure everything works"

# Cleanup
rm -rf "$TEMP_DIR"