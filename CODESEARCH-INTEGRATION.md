# Tree-Sitter Integration for CodeSearch MCP Server

This forked repository provides robust tree-sitter bindings optimized for the CodeSearch MCP server, enabling high-performance syntax-aware code search and analysis across 28+ programming languages.

## Key Features for CodeSearch

### 🚀 Performance Optimizations
- **Universal binaries** for macOS (x64 + ARM64)
- **Incremental parsing** for real-time code analysis
- **Memory-efficient** tree representations
- **Thread-safe** operations for concurrent searches

### 📊 Supported Languages
All major languages used in modern codebases:
- **Systems**: C, C++, Rust, Go
- **Web**: JavaScript, TypeScript, HTML, CSS, PHP
- **Enterprise**: Java, C#, Scala
- **Scripting**: Python, Ruby, Bash, Julia
- **Functional**: Haskell, OCaml, Agda
- **Data**: JSON, TOML, SQL (via QL)
- **Mobile**: Swift, Java, TypeScript (React Native)
- **Specialized**: Verilog, Razor, TSQ (tree-sitter queries)

## Integration with CodeSearch

### Basic Usage

```csharp
using TreeSitter;

// Initialize parser for a language
using var language = new Language("JavaScript");
using var parser = new Parser(language);

// Parse source code
var sourceCode = File.ReadAllText("app.js");
using var tree = parser.Parse(sourceCode);

// Access syntax tree
var rootNode = tree.RootNode;
```

### Advanced Search Patterns

```csharp
// Find all function declarations
using var query = new Query(language, @"
    (function_declaration
        name: (identifier) @function.name
        parameters: (formal_parameters) @function.params
    )
");

var matches = query.Execute(rootNode);
foreach (var match in matches.Matches)
{
    var funcName = match.Captures
        .First(c => c.Name == "function.name")
        .Node.Text;
    Console.WriteLine($"Found function: {funcName}");
}
```

### Incremental Parsing for Live Search

```csharp
// Initial parse
var tree = parser.Parse(sourceCode);

// User makes an edit
var edit = new Edit
{
    StartByte = 100,
    OldEndByte = 105,
    NewEndByte = 110,
    StartPoint = new Point(5, 10),
    OldEndPoint = new Point(5, 15),
    NewEndPoint = new Point(5, 20)
};

// Apply edit and reparse incrementally
tree.Edit(edit);
var newTree = parser.Parse(modifiedSource, tree);
```

## Building for Production

### Quick Start
```bash
# 1. Update all grammars to latest versions
./update-grammars.sh

# 2. Build native libraries
./build-macos-universal.sh  # Creates universal binaries for macOS

# 3. Build .NET bindings
cd src
dotnet build --configuration Release

# 4. Run comprehensive tests
./test-grammars.sh
```

### Platform-Specific Builds

#### macOS (Universal Binary)
```bash
./build-macos-universal.sh
# Produces fat binaries in: build/runtimes/osx/native/
```

#### Linux
```bash
cd tree-sitter-native
make
# Produces .so files in: build/runtimes/linux-x64/native/
```

#### Windows
```cmd
cd tree-sitter-native
msbuild tree-sitter-native.sln /p:Configuration=Release /p:Platform=x64
# Produces .dll files in: build/runtimes/win-x64/native/
```

## Performance Benchmarks

On Apple M1 Max:
- JavaScript parsing: ~0.15ms per file (average)
- TypeScript parsing: ~0.18ms per file (average)
- Large file (10,000 lines): ~12ms
- Query execution: ~0.05ms for simple patterns

## Query Language Reference

Tree-sitter uses S-expression queries for pattern matching:

### Basic Patterns
```scheme
; Match any identifier
(identifier)

; Match specific node types
(function_declaration)
(class_declaration)
(variable_declarator)
```

### Capturing Nodes
```scheme
; Capture with names
(function_declaration
  name: (identifier) @function.name)

; Multiple captures
(variable_declarator
  name: (identifier) @variable.name
  value: (_) @variable.value)
```

### Predicates
```scheme
; Match specific text
((identifier) @constant
 (#match? @constant "^[A-Z_]+$"))

; Equality checks
((identifier) @keyword
 (#eq? @keyword "async"))
```

## Integration Best Practices

### 1. Language Detection
```csharp
public static string DetectLanguage(string filePath)
{
    return Path.GetExtension(filePath).ToLower() switch
    {
        ".js" or ".mjs" => "JavaScript",
        ".ts" or ".tsx" => "TypeScript",
        ".py" => "Python",
        ".cs" => "CSharp",
        ".go" => "Go",
        ".rs" => "Rust",
        ".java" => "Java",
        ".cpp" or ".cc" or ".cxx" => "Cpp",
        ".c" or ".h" => "C",
        ".rb" => "Ruby",
        ".php" => "PHP",
        _ => null
    };
}
```

### 2. Error Recovery
```csharp
try
{
    using var tree = parser.Parse(sourceCode);
    if (tree.RootNode.HasError)
    {
        // Handle parse errors
        var errorNodes = FindErrorNodes(tree.RootNode);
        LogParseErrors(errorNodes);
    }
}
catch (Exception ex)
{
    // Fallback to basic text search
    return BasicTextSearch(sourceCode, searchPattern);
}
```

### 3. Memory Management
```csharp
// Always dispose tree-sitter objects
using (var language = new Language("JavaScript"))
using (var parser = new Parser(language))
using (var tree = parser.Parse(code))
{
    // Process syntax tree
}

// For batch processing
public void ProcessFiles(string[] files)
{
    using var language = new Language("JavaScript");
    using var parser = new Parser(language);

    foreach (var file in files)
    {
        var code = File.ReadAllText(file);
        using var tree = parser.Parse(code);
        ProcessTree(tree);
    }
}
```

### 4. Caching Strategies
```csharp
// Cache parsed trees for frequently accessed files
private readonly Dictionary<string, (Tree tree, DateTime lastModified)> _treeCache = new();

public Tree GetOrParseTree(string filePath)
{
    var lastModified = File.GetLastWriteTime(filePath);

    if (_treeCache.TryGetValue(filePath, out var cached))
    {
        if (cached.lastModified == lastModified)
            return cached.tree;

        // File changed, dispose old tree
        cached.tree.Dispose();
    }

    var code = File.ReadAllText(filePath);
    var tree = _parser.Parse(code);
    _treeCache[filePath] = (tree, lastModified);

    return tree;
}
```

## Troubleshooting

### Common Issues

1. **Library not found**
   - Ensure native libraries are in the correct runtime folder
   - Check library architecture matches your system
   - On macOS: `otool -L library.dylib` to check dependencies

2. **Parse errors on valid code**
   - Update to latest grammar version
   - Check if language version is supported
   - Some grammars have known limitations

3. **Memory leaks**
   - Always dispose Tree, Parser, and Language objects
   - Use `using` statements or implement proper disposal

4. **Performance issues**
   - Use incremental parsing for edits
   - Cache parsed trees when possible
   - Consider parallelizing for batch operations

## CI/CD Integration

GitHub Actions workflow is included for:
- Automated grammar updates (weekly)
- Multi-platform builds (Windows, Linux, macOS)
- Comprehensive test suite execution
- NuGet package generation

## Contributing

To add support for a new language:

1. Add grammar repository to `update-grammars.sh`
2. Update build scripts for all platforms
3. Add test cases in `test-grammars.sh`
4. Update language list in documentation
5. Submit PR with test results

## License

MIT License - See LICENSE file for details

## Support

For CodeSearch-specific integration issues:
- GitHub Issues: https://github.com/anortham/coa-tree-sitter-dotnet-bindings/issues
- Original Project: https://github.com/mariusgreuel/tree-sitter-dotnet-bindings