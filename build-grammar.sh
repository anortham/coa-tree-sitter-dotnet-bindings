#!/bin/bash

# Build a single tree-sitter grammar
# Usage: ./build-grammar.sh <grammar-name>

GRAMMAR=$1
if [ -z "$GRAMMAR" ]; then
    echo "Usage: $0 <grammar-name>"
    echo "Example: $0 json"
    exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="$SCRIPT_DIR/build/runtimes/osx-arm64/native"
NATIVE_DIR="$SCRIPT_DIR/tree-sitter-native"
GRAMMAR_DIR="$NATIVE_DIR/tree-sitter-$GRAMMAR"

if [ ! -d "$GRAMMAR_DIR" ]; then
    echo "Grammar directory not found: $GRAMMAR_DIR"
    exit 1
fi

echo "Building tree-sitter-$GRAMMAR..."
cd "$GRAMMAR_DIR"

# Find all source files
SOURCES=""
if [ -f "src/parser.c" ]; then
    SOURCES="src/parser.c"
elif [ -f "parser.c" ]; then
    SOURCES="parser.c"
else
    echo "No parser.c found!"
    exit 1
fi

# Add scanner if exists
if [ -f "src/scanner.c" ]; then
    SOURCES="$SOURCES src/scanner.c"
elif [ -f "scanner.c" ]; then
    SOURCES="$SOURCES scanner.c"
elif [ -f "src/scanner.cc" ]; then
    # C++ scanner - use clang++
    echo "Found C++ scanner - using clang++"
    clang++ -fPIC -std=c++14 -O3 \
        -I"$NATIVE_DIR/tree-sitter/src" \
        -I"$NATIVE_DIR/include" \
        -c src/scanner.cc -o scanner.o

    # Compile parser.c
    clang -fPIC -std=c99 -O3 \
        -I"$NATIVE_DIR/tree-sitter/src" \
        -I"$NATIVE_DIR/include" \
        -c $SOURCES -o parser.o

    # Link
    clang++ -dynamiclib -O3 \
        -install_name @rpath/libtree-sitter-$GRAMMAR.dylib \
        -o "$BUILD_DIR/libtree-sitter-$GRAMMAR.dylib" \
        parser.o scanner.o

    rm -f parser.o scanner.o
    echo "✓ Built tree-sitter-$GRAMMAR with C++ scanner"
    exit 0
elif [ -f "scanner.cc" ]; then
    # C++ scanner - use clang++
    echo "Found C++ scanner - using clang++"
    clang++ -fPIC -std=c++14 -O3 \
        -I"$NATIVE_DIR/tree-sitter/src" \
        -I"$NATIVE_DIR/include" \
        -c scanner.cc -o scanner.o

    # Compile parser.c
    clang -fPIC -std=c99 -O3 \
        -I"$NATIVE_DIR/tree-sitter/src" \
        -I"$NATIVE_DIR/include" \
        -c $SOURCES -o parser.o

    # Link
    clang++ -dynamiclib -O3 \
        -install_name @rpath/libtree-sitter-$GRAMMAR.dylib \
        -o "$BUILD_DIR/libtree-sitter-$GRAMMAR.dylib" \
        parser.o scanner.o

    rm -f parser.o scanner.o
    echo "✓ Built tree-sitter-$GRAMMAR with C++ scanner"
    exit 0
fi

# Build with C only
clang -fPIC -std=c99 -O3 \
    -I"$NATIVE_DIR/tree-sitter/src" \
    -I"$NATIVE_DIR/include" \
    -dynamiclib \
    -install_name @rpath/libtree-sitter-$GRAMMAR.dylib \
    -o "$BUILD_DIR/libtree-sitter-$GRAMMAR.dylib" \
    $SOURCES

echo "✓ Built tree-sitter-$GRAMMAR"