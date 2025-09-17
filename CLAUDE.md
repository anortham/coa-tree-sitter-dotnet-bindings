# Tree-Sitter .NET Bindings - AI Agent Guide

## Project Overview
This is a forked .NET binding library for the tree-sitter parsing framework, providing C# developers with access to high-performance incremental parsing capabilities. Tree-sitter is a parser generator tool that produces fast, robust parsers with incremental re-parsing and concrete syntax tree generation.

**Fork Repository**: https://github.com/anortham/coa-tree-sitter-dotnet-bindings
**Original Repository**: https://github.com/mariusgreuel/tree-sitter-dotnet-bindings

## Key Project Facts
- **Primary Language**: C# (.NET Standard 2.0)
- **Target Framework**: .NET Standard 2.0 with C# 12.0
- **Package Name**: TreeSitter.DotNet
- **Native Dependencies**: Includes pre-built native libraries for Windows and Linux (x64/arm64)
- **Supported Languages**: 28+ programming language grammars included

## Project Structure

### Core Components
```
/src/                    # Main .NET bindings source code
  ├── Parser.cs         # Core parser implementation
  ├── Language.cs       # Language grammar handling
  ├── Tree.cs          # Syntax tree representation
  ├── Node.cs          # AST node operations
  ├── Query.cs         # Pattern matching queries
  └── Native.cs        # P/Invoke declarations

/tree-sitter-native/    # Native C libraries project
  └── tree-sitter-native.sln

/tests/                 # Unit test suite
  └── TreeSitter.Tests.csproj

/examples/              # Usage examples
  └── demo/            # Basic demo application

/build/                # Pre-built native libraries
  └── runtimes/        # Platform-specific binaries
```

## Development Guidelines

### Building the Project

#### Windows Build
```cmd
cd tree-sitter-native
msbuild tree-sitter-native.sln /p:Configuration=Release /p:Platform=x64
cd ..\src
dotnet build TreeSitter.csproj
```

#### Linux Build
```bash
cd tree-sitter-native
make
cd ../src
dotnet build TreeSitter.csproj
```

#### macOS Build
```bash
# Update grammar sources (first time or when updating)
./update-grammars.sh

# Build native libraries
./build-macos.sh

# Build .NET bindings
cd src
dotnet build TreeSitter.csproj
```

### Testing
```bash
dotnet test tests/TreeSitter.Tests.csproj
```

## API Design Patterns

### Resource Management
- All native resources implement `IDisposable`
- Use `using` statements for proper cleanup
- Check for `ObjectDisposedException` in property/method access

### Error Handling
- Native failures throw `InvalidOperationException`
- Null arguments throw `ArgumentNullException`
- Invalid states throw `ObjectDisposedException`

### Interop Patterns
- P/Invoke declarations in `Native.cs`
- IntPtr handles for native objects
- Manual marshalling for complex types
- SafeHandle patterns for resource management

## Key Classes and Their Responsibilities

1. **Parser**: Main entry point for parsing source code
   - Manages language configuration
   - Handles timeout and cancellation
   - Produces syntax trees

2. **Language**: Represents a programming language grammar
   - Loads native language libraries
   - Provides symbol metadata
   - Supports lookahead iteration

3. **Tree**: Immutable syntax tree representation
   - Contains root node
   - Supports incremental editing
   - Thread-safe operations

4. **Node**: Individual syntax tree node
   - Tree traversal operations
   - Text extraction
   - Type and field information

5. **Query**: Pattern matching for syntax trees
   - S-expression query syntax
   - Capture groups
   - Predicate support

## Native Library Management
- Platform detection via runtime identifiers (RIDs)
- Automatic library copying during build
- Support for win-x86, win-x64, win-arm64, linux-x64, linux-arm64, osx-x64, osx-arm64

## Common Tasks

### Adding New Language Support
1. Add native grammar library to tree-sitter-native project
2. Update build scripts for Windows, Linux, and macOS
3. Place compiled libraries in `/build/runtimes/[RID]/native/`
4. Update README.md with new language listing
5. Add the grammar repository to `update-grammars.sh`

### Implementing New Bindings
1. Add P/Invoke declarations to `Native.cs`
2. Create managed wrapper in appropriate class
3. Handle resource lifecycle properly
4. Add unit tests to verify functionality

### Performance Considerations
- Minimize string marshalling overhead
- Cache frequently accessed properties
- Use spans/memory for large text operations
- Leverage incremental parsing for edits

## Testing Strategy
- Unit tests for all public API surface
- Integration tests with real language grammars
- Memory leak detection via finalizers
- Cross-platform compatibility verification

## NuGet Package Structure
```
TreeSitter.DotNet/
  ├── lib/netstandard2.0/
  │   └── TreeSitter.dll
  ├── runtimes/
  │   ├── win-x64/native/
  │   ├── linux-x64/native/
  │   └── [other platforms]/
  └── PACKAGE.md
```

## Important Conventions
- Follow existing P/Invoke patterns exactly
- Maintain backwards compatibility
- Document all public APIs with XML comments
- Use nullable reference types consistently
- Test on Windows, Linux, and macOS platforms
- Use .dylib extension for macOS, .so for Linux, .dll for Windows

## Common Pitfalls to Avoid
1. Forgetting to dispose native resources
2. String encoding mismatches (UTF-8 vs UTF-16)
3. Platform-specific path separators
4. Assuming library load order
5. Race conditions in multi-threaded scenarios

## Debugging Tips
- Enable native debugging for P/Invoke issues
- Use `Logger` class for parser diagnostics
- Check native library dependencies with platform tools
- Verify RID-specific library placement
- Monitor memory usage for leaks

## Release Process
1. Update version in TreeSitter.csproj
2. Run `update-grammars.sh` to ensure latest grammar versions
3. Build native libraries for all platforms:
   - Windows: Use Visual Studio with tree-sitter-native.sln
   - Linux: Run `make` in tree-sitter-native/
   - macOS: Run `build-macos.sh`
4. Run full test suite on each platform
5. Update package documentation
6. Create NuGet package with all RID variants

## Updating Tree-Sitter Grammars
The project includes scripts to automate grammar updates:
- `update-grammars.sh`: Downloads latest grammar sources from GitHub
- `build-macos.sh`: Builds all grammars for macOS
- Source files are fetched but not committed - they're built locally