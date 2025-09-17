#!/bin/bash

# Comprehensive test script for tree-sitter grammars
# Tests that all grammars can be loaded and used

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Color output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Tree-Sitter Grammar Test Suite${NC}"
echo "==============================="

# First, build the test project
echo -e "\n${YELLOW}Building test project...${NC}"
cd "$SCRIPT_DIR"
dotnet build tests/TreeSitter.Tests.csproj --configuration Release

# Run the test suite
echo -e "\n${YELLOW}Running unit tests...${NC}"
dotnet test tests/TreeSitter.Tests.csproj --configuration Release --no-build --verbosity normal

# Create a simple test program to validate each grammar
echo -e "\n${YELLOW}Creating grammar validation program...${NC}"
cat > "$SCRIPT_DIR/test-grammar-loading.csx" << 'EOF'
#r "nuget: TreeSitter.DotNet, 1.0.1"
#r "./src/bin/Release/netstandard2.0/TreeSitter.dll"

using System;
using System.IO;
using TreeSitter;

var grammars = new[] {
    "C", "Cpp", "CSharp", "JavaScript", "TypeScript", "Python",
    "Go", "Rust", "Java", "Ruby", "PHP", "HTML", "CSS", "JSON",
    "Bash", "Swift", "Scala", "Haskell", "OCaml", "Julia",
    "Agda", "EmbeddedTemplate", "JSDoc", "QL", "Razor",
    "Toml", "TSQ", "Verilog"
};

var testCode = new Dictionary<string, string> {
    ["C"] = "int main() { return 0; }",
    ["Cpp"] = "int main() { return 0; }",
    ["CSharp"] = "class Program { static void Main() {} }",
    ["JavaScript"] = "console.log('test');",
    ["TypeScript"] = "const x: string = 'test';",
    ["Python"] = "print('test')",
    ["Go"] = "package main\nfunc main() {}",
    ["Rust"] = "fn main() {}",
    ["Java"] = "public class Test { public static void main(String[] args) {} }",
    ["Ruby"] = "puts 'test'",
    ["PHP"] = "<?php echo 'test'; ?>",
    ["HTML"] = "<html><body>Test</body></html>",
    ["CSS"] = "body { color: red; }",
    ["JSON"] = "{\"test\": true}",
    ["Bash"] = "echo 'test'",
    ["Swift"] = "print(\"test\")",
    ["Scala"] = "object Test { def main(args: Array[String]): Unit = {} }",
    ["Haskell"] = "main = putStrLn \"test\"",
    ["OCaml"] = "let () = print_endline \"test\"",
    ["Julia"] = "println(\"test\")",
    ["Toml"] = "[package]\nname = \"test\"",
    ["TSQ"] = "(identifier) @variable"
};

Console.WriteLine("\nTesting grammar loading and parsing:");
Console.WriteLine("====================================");

int successful = 0;
int failed = 0;
var failedGrammars = new List<string>();

foreach (var grammar in grammars) {
    try {
        Console.Write($"Testing {grammar}... ");

        using var language = new Language(grammar);
        using var parser = new Parser(language);

        // Get appropriate test code or use default
        var code = testCode.ContainsKey(grammar) ? testCode[grammar] : "test";

        using var tree = parser.Parse(code);

        if (tree != null && tree.RootNode != null) {
            Console.WriteLine("✓ Success");
            successful++;
        } else {
            Console.WriteLine("✗ Failed - no parse tree");
            failed++;
            failedGrammars.Add(grammar);
        }
    } catch (Exception ex) {
        Console.WriteLine($"✗ Failed - {ex.Message}");
        failed++;
        failedGrammars.Add(grammar);
    }
}

Console.WriteLine("\n====================================");
Console.WriteLine($"Results: {successful} successful, {failed} failed");

if (failedGrammars.Count > 0) {
    Console.WriteLine("\nFailed grammars:");
    foreach (var grammar in failedGrammars) {
        Console.WriteLine($"  - {grammar}");
    }
}

Environment.Exit(failed == 0 ? 0 : 1);
EOF

# Run the grammar loading test
echo -e "\n${YELLOW}Testing grammar loading...${NC}"
dotnet script "$SCRIPT_DIR/test-grammar-loading.csx" || {
    echo -e "${RED}Grammar loading tests failed${NC}"
    exit 1
}

# Test library architecture (macOS only)
if [ "$(uname -s)" = "Darwin" ]; then
    echo -e "\n${YELLOW}Verifying library architectures...${NC}"

    for lib in build/runtimes/osx/native/*.dylib; do
        if [ -f "$lib" ]; then
            name=$(basename "$lib")
            echo -n "  $name: "
            lipo -info "$lib" 2>/dev/null | grep -o "x86_64\|arm64" | tr '\n' ' '
            echo ""
        fi
    done
fi

# Performance benchmark
echo -e "\n${YELLOW}Running performance benchmark...${NC}"
cat > "$SCRIPT_DIR/benchmark.csx" << 'EOF'
#r "./src/bin/Release/netstandard2.0/TreeSitter.dll"

using System;
using System.Diagnostics;
using TreeSitter;

var code = @"
function fibonacci(n) {
    if (n <= 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

class Example {
    constructor() {
        this.value = 42;
    }

    async fetchData() {
        const response = await fetch('/api/data');
        return response.json();
    }
}

const arr = [1, 2, 3, 4, 5];
const doubled = arr.map(x => x * 2);
console.log(doubled);
";

using var language = new Language("JavaScript");
using var parser = new Parser(language);

// Warm up
for (int i = 0; i < 10; i++) {
    using var warmupTree = parser.Parse(code);
}

// Benchmark
var sw = Stopwatch.StartNew();
const int iterations = 1000;

for (int i = 0; i < iterations; i++) {
    using var tree = parser.Parse(code);
}

sw.Stop();

Console.WriteLine($"Parsed JavaScript {iterations} times in {sw.ElapsedMilliseconds}ms");
Console.WriteLine($"Average: {sw.ElapsedMilliseconds / (double)iterations:F2}ms per parse");
Console.WriteLine($"Throughput: {iterations / (sw.ElapsedMilliseconds / 1000.0):F0} parses/second");
EOF

dotnet script "$SCRIPT_DIR/benchmark.csx"

echo -e "\n${GREEN}All tests completed successfully!${NC}"