#!/bin/bash

# Build comprehensive set of tree-sitter grammars for codesearch
# Downloads and builds grammars using tree-sitter CLI for maximum compatibility

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="$SCRIPT_DIR/build/runtimes/osx-arm64/native"
NATIVE_DIR="$SCRIPT_DIR/tree-sitter-native"

# Comprehensive list of important languages for codesearch
GRAMMARS=(
    # Core web technologies
    "typescript"
    "css"
    "scss"
    "yaml"
    "xml"
    "toml"

    # Enterprise languages
    "java"
    "c-sharp"
    "scala"
    "kotlin"

    # Functional languages
    "haskell"
    "ocaml"
    "elixir"

    # Other important languages
    "bash"
    "php"
    "ruby"
    "perl"
    "lua"
    "r"
    "julia"
    "dart"
    "swift"

    # Data/config formats
    "sql"
    "graphql"
    "dockerfile"
    "terraform"

    # Documentation
    "markdown"
    "latex"

    # Special purpose
    "regex"
    "jsdoc"
)

echo "Building comprehensive tree-sitter grammar set..."
echo "Target: ${#GRAMMARS[@]} additional grammars"
mkdir -p "$BUILD_DIR"

successful=0
failed=0

for grammar in "${GRAMMARS[@]}"; do
    echo ""
    echo "=== Processing $grammar ==="

    # Skip if already built
    if [ -f "$BUILD_DIR/libtree-sitter-$grammar.dylib" ]; then
        echo "✓ $grammar already exists, skipping"
        ((successful++))
        continue
    fi

    temp_dir="$NATIVE_DIR/build-$grammar"
    rm -rf "$temp_dir"

    echo "Downloading $grammar grammar..."
    if git clone "https://github.com/tree-sitter/tree-sitter-$grammar.git" "$temp_dir" 2>/dev/null; then
        cd "$temp_dir"

        echo "Generating parser..."
        if tree-sitter generate 2>/dev/null; then
            echo "Building library..."

            # Detect source structure
            if [ -f "src/parser.c" ]; then
                SOURCES="src/parser.c"
                SCANNER=""

                # Handle different scanner types
                if [ -f "src/scanner.c" ]; then
                    SCANNER="c"
                    SOURCES="$SOURCES src/scanner.c"
                elif [ -f "src/scanner.cc" ] || [ -f "src/scanner.cpp" ]; then
                    SCANNER="cpp"
                fi

                # Build based on scanner type
                if [ "$SCANNER" = "cpp" ]; then
                    # C++ scanner build
                    echo "Building with C++ scanner..."
                    clang++ -fPIC -std=c++14 -O3 \
                        -I"$NATIVE_DIR/tree-sitter/src" \
                        -I"$NATIVE_DIR/include" \
                        -c src/scanner.* -o scanner.o 2>/dev/null

                    clang -fPIC -std=c99 -O3 \
                        -I"$NATIVE_DIR/tree-sitter/src" \
                        -I"$NATIVE_DIR/include" \
                        -c src/parser.c -o parser.o 2>/dev/null

                    if clang++ -dynamiclib -O3 \
                        -install_name "@rpath/libtree-sitter-$grammar.dylib" \
                        -o "$BUILD_DIR/libtree-sitter-$grammar.dylib" \
                        parser.o scanner.o 2>/dev/null; then
                        echo "✓ Built $grammar (C++ scanner)"
                        ((successful++))
                    else
                        echo "❌ Failed to link $grammar"
                        ((failed++))
                    fi
                    rm -f parser.o scanner.o
                else
                    # Pure C build
                    if clang -fPIC -std=c99 -O3 \
                        -I"$NATIVE_DIR/tree-sitter/src" \
                        -I"$NATIVE_DIR/include" \
                        -dynamiclib \
                        -install_name "@rpath/libtree-sitter-$grammar.dylib" \
                        -o "$BUILD_DIR/libtree-sitter-$grammar.dylib" \
                        $SOURCES 2>/dev/null; then
                        echo "✓ Built $grammar"
                        ((successful++))
                    else
                        echo "❌ Failed to build $grammar"
                        ((failed++))
                    fi
                fi
            else
                echo "❌ No src/parser.c found for $grammar"
                ((failed++))
            fi
        else
            echo "❌ Failed to generate parser for $grammar"
            ((failed++))
        fi

        cd "$SCRIPT_DIR"
        rm -rf "$temp_dir"
    else
        echo "❌ Failed to clone $grammar"
        ((failed++))
    fi
done

echo ""
echo "=========================================="
echo "Build Summary:"
echo "✓ Successfully built: $successful grammars"
echo "❌ Failed: $failed grammars"
echo ""
echo "All available grammars:"
ls -la "$BUILD_DIR"/*.dylib | awk '{print "  " $9}' | sed 's/.*libtree-sitter-//' | sed 's/\.dylib$//' | sort

total_count=$(ls -1 "$BUILD_DIR"/*.dylib 2>/dev/null | wc -l | tr -d ' ')
echo ""
echo "Total working grammars: $total_count"