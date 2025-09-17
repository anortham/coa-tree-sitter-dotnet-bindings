#!/bin/bash

# Build key grammars needed for tests and codesearch
# This downloads full grammar repos and builds them with tree-sitter CLI

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="$SCRIPT_DIR/build/runtimes/osx-arm64/native"
NATIVE_DIR="$SCRIPT_DIR/tree-sitter-native"

# Key grammars needed for tests and codesearch
GRAMMARS=(
    "json"
    "html"
    "python"
    "rust"
    "typescript"
    "cpp"
    "bash"
)

echo "Building key tree-sitter grammars..."
mkdir -p "$BUILD_DIR"

for grammar in "${GRAMMARS[@]}"; do
    echo ""
    echo "=== Processing $grammar ==="

    temp_dir="$NATIVE_DIR/build-$grammar"

    # Remove existing temp directory
    rm -rf "$temp_dir"

    # Clone the grammar repo
    echo "Downloading $grammar grammar..."
    if git clone "https://github.com/tree-sitter/tree-sitter-$grammar.git" "$temp_dir"; then
        cd "$temp_dir"

        # Generate the parser using tree-sitter CLI
        echo "Generating parser..."
        if tree-sitter generate; then
            echo "Building library..."

            # Find source files
            if [ -f "src/parser.c" ]; then
                SOURCES="src/parser.c"

                # Add scanner if exists
                if [ -f "src/scanner.c" ]; then
                    SOURCES="$SOURCES src/scanner.c"
                elif [ -f "src/scanner.cc" ]; then
                    # C++ scanner
                    clang++ -fPIC -std=c++14 -O3 \
                        -I"$NATIVE_DIR/tree-sitter/src" \
                        -I"$NATIVE_DIR/include" \
                        -c src/scanner.cc -o scanner.o

                    clang -fPIC -std=c99 -O3 \
                        -I"$NATIVE_DIR/tree-sitter/src" \
                        -I"$NATIVE_DIR/include" \
                        -c src/parser.c -o parser.o

                    clang++ -dynamiclib -O3 \
                        -install_name "@rpath/libtree-sitter-$grammar.dylib" \
                        -o "$BUILD_DIR/libtree-sitter-$grammar.dylib" \
                        parser.o scanner.o

                    rm -f parser.o scanner.o
                    echo "✓ Built $grammar with C++ scanner"
                    continue
                fi

                # Build with C
                clang -fPIC -std=c99 -O3 \
                    -I"$NATIVE_DIR/tree-sitter/src" \
                    -I"$NATIVE_DIR/include" \
                    -dynamiclib \
                    -install_name "@rpath/libtree-sitter-$grammar.dylib" \
                    -o "$BUILD_DIR/libtree-sitter-$grammar.dylib" \
                    $SOURCES

                echo "✓ Built $grammar"
            else
                echo "❌ No src/parser.c found for $grammar"
            fi
        else
            echo "❌ Failed to generate parser for $grammar"
        fi

        # Clean up
        cd "$SCRIPT_DIR"
        rm -rf "$temp_dir"
    else
        echo "❌ Failed to clone $grammar"
    fi
done

echo ""
echo "Built grammars:"
ls -la "$BUILD_DIR"/*.dylib | awk '{print "  " $9}' | sed 's/.*\///'

echo ""
echo "Grammar build complete!"