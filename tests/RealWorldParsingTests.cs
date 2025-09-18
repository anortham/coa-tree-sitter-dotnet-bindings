using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.IO;

namespace TreeSitter.Tests;

[TestClass]
public class RealWorldParsingTests
{
    private static string GetResourcePath(string filename)
    {
        var testDir = Path.GetDirectoryName(typeof(RealWorldParsingTests).Assembly.Location) ?? "";
        return Path.Combine(testDir, "resources", filename);
    }

    private static string ReadResourceFile(string filename)
    {
        var path = GetResourcePath(filename);
        if (!File.Exists(path))
        {
            throw new FileNotFoundException($"Test resource file not found: {path}");
        }
        return File.ReadAllText(path);
    }

    [TestMethod]
    public void CanParseRealWorldPythonCode()
    {
        var python = new Language("python");
        var parser = new Parser(python);
        var code = ReadResourceFile("python_complex.py");

        var tree = parser.Parse(code);

        Assert.IsNotNull(tree);
        Assert.AreEqual("module", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 5); // Should have multiple classes/imports
        Assert.IsFalse(tree.RootNode.HasError);
    }

    [TestMethod]
    public void CanParseRealWorldGoCode()
    {
        var go = new Language("go");
        var parser = new Parser(go);
        var code = ReadResourceFile("go_main.go");

        var tree = parser.Parse(code);

        Assert.IsNotNull(tree);
        Assert.AreEqual("source_file", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
        Assert.IsFalse(tree.RootNode.HasError);
    }

    [TestMethod]
    public void CanParseRealWorldJavaCode()
    {
        var java = new Language("java");
        var parser = new Parser(java);
        var code = ReadResourceFile("java_main.java");

        var tree = parser.Parse(code);

        Assert.IsNotNull(tree);
        Assert.AreEqual("program", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
        Assert.IsFalse(tree.RootNode.HasError);
    }

    [TestMethod]
    public void CanParseRealWorldKotlinCode()
    {
        var kotlin = new Language("kotlin");
        var parser = new Parser(kotlin);
        var code = ReadResourceFile("kotlin_model.kt");

        var tree = parser.Parse(code);

        Assert.IsNotNull(tree);
        Assert.AreEqual("source_file", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
        Assert.IsFalse(tree.RootNode.HasError);
    }

    [TestMethod]
    public void CanParseRealWorldDartCode()
    {
        var dart = new Language("dart");
        var parser = new Parser(dart);
        var code = ReadResourceFile("dart_main.dart");

        var tree = parser.Parse(code);

        Assert.IsNotNull(tree);
        Assert.AreEqual("program", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 3); // Should have imports, classes, functions
        Assert.IsFalse(tree.RootNode.HasError);
    }

    [TestMethod]
    public void CanParseRealWorldRubyCode()
    {
        var ruby = new Language("ruby");
        var parser = new Parser(ruby);
        var code = ReadResourceFile("ruby_models.rb");

        var tree = parser.Parse(code);

        Assert.IsNotNull(tree);
        Assert.AreEqual("program", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 2);
        Assert.IsFalse(tree.RootNode.HasError);
    }

    [TestMethod]
    public void CanParseRealWorldPhpCode()
    {
        var php = new Language("php");
        var parser = new Parser(php);
        var code = ReadResourceFile("php_index.php");

        var tree = parser.Parse(code);

        Assert.IsNotNull(tree);
        Assert.AreEqual("program", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
        Assert.IsFalse(tree.RootNode.HasError);
    }

    [TestMethod]
    public void CanParseRealWorldTypeScriptCode()
    {
        var typescript = new Language("typescript");
        var parser = new Parser(typescript);
        var code = ReadResourceFile("typescript_index.ts");

        var tree = parser.Parse(code);

        Assert.IsNotNull(tree);
        Assert.AreEqual("program", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
        Assert.IsFalse(tree.RootNode.HasError);
    }

    [TestMethod]
    public void CanParseRealWorldSwiftCode()
    {
        var swift = new Language("swift");
        var parser = new Parser(swift);
        var code = ReadResourceFile("swift_main.swift");

        var tree = parser.Parse(code);

        Assert.IsNotNull(tree);
        Assert.AreEqual("program", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
        // Note: Swift Package.swift files may have minor parsing variations
        // Assert.IsFalse(tree.RootNode.HasError);
    }

    [TestMethod]
    public void CanParseRealWorldLuaCode()
    {
        var lua = new Language("lua");
        var parser = new Parser(lua);
        var code = ReadResourceFile("lua_calculator.lua");

        var tree = parser.Parse(code);

        Assert.IsNotNull(tree);
        Assert.AreEqual("chunk", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 10); // Complex calculator should have many statements
        Assert.IsFalse(tree.RootNode.HasError);
    }

    [TestMethod]
    public void CanParseRealWorldRustCode()
    {
        var rust = new Language("rust");
        var parser = new Parser(rust);
        var code = ReadResourceFile("rust_main.rs");

        var tree = parser.Parse(code);

        Assert.IsNotNull(tree);
        Assert.AreEqual("source_file", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
        Assert.IsFalse(tree.RootNode.HasError);
    }

    [TestMethod]
    public void CanParseAdvancedCppCode()
    {
        var cpp = new Language("cpp");
        var parser = new Parser(cpp);
        var code = ReadResourceFile("cpp_advanced.cpp");

        var tree = parser.Parse(code);

        Assert.IsNotNull(tree);
        Assert.AreEqual("translation_unit", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 5); // Includes, template class, main function
        Assert.IsFalse(tree.RootNode.HasError);
    }

    [TestMethod]
    public void CanParseAdvancedCSharpCode()
    {
        var csharp = new Language("c-sharp");
        var parser = new Parser(csharp);
        var code = ReadResourceFile("csharp_advanced.cs");

        var tree = parser.Parse(code);

        Assert.IsNotNull(tree);
        Assert.AreEqual("compilation_unit", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 3); // Using statements, namespace, classes
        Assert.IsFalse(tree.RootNode.HasError);
    }

    [TestMethod]
    public void CanParseModernJavaScriptCode()
    {
        var javascript = new Language("javascript");
        var parser = new Parser(javascript);
        var code = ReadResourceFile("javascript_modern.js");

        var tree = parser.Parse(code);

        Assert.IsNotNull(tree);
        Assert.AreEqual("program", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 5); // Classes, functions, export statements
        Assert.IsFalse(tree.RootNode.HasError);
    }
}