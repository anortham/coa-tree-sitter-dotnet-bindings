#!/bin/bash

# Regenerate all tree-sitter grammar parsers
# This script uses the tree-sitter CLI to regenerate parser.c files
# with the correct version compatibility

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NATIVE_DIR="$SCRIPT_DIR/tree-sitter-native"

echo "Regenerating all tree-sitter grammar parsers..."

# Find all grammar directories
GRAMMARS=()
for dir in "$NATIVE_DIR"/tree-sitter-*; do
    if [ -d "$dir" ] && [ -f "$dir/grammar.js" ]; then
        grammar_name=$(basename "$dir" | sed 's/tree-sitter-//')
        GRAMMARS+=("$grammar_name")
    fi
done

echo "Found ${#GRAMMARS[@]} grammars to regenerate"

# Regenerate each grammar
for grammar in "${GRAMMARS[@]}"; do
    echo ""
    echo "=== Regenerating $grammar ==="

    grammar_dir="$NATIVE_DIR/tree-sitter-$grammar"
    cd "$grammar_dir"

    # Check if grammar.js exists
    if [ ! -f "grammar.js" ]; then
        echo "⚠️  No grammar.js found in $grammar, skipping"
        continue
    fi

    # Backup existing files
    if [ -f "src/parser.c" ]; then
        mv src/parser.c src/parser.c.bak 2>/dev/null
    elif [ -f "parser.c" ]; then
        mv parser.c parser.c.bak 2>/dev/null
    fi

    # Regenerate the parser
    if tree-sitter generate; then
        echo "✓ Generated parser for $grammar"

        # Clean up backup if generation succeeded
        rm -f src/parser.c.bak parser.c.bak 2>/dev/null
    else
        echo "❌ Failed to generate parser for $grammar"

        # Restore backup if generation failed
        if [ -f "src/parser.c.bak" ]; then
            mv src/parser.c.bak src/parser.c
        elif [ -f "parser.c.bak" ]; then
            mv parser.c.bak parser.c
        fi
    fi
done

echo ""
echo "Grammar regeneration complete!"
echo "Generated parsers should now be compatible with tree-sitter 0.25.9"