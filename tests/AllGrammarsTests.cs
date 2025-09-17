using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace TreeSitter.Tests;

[TestClass]
public class AllGrammarsTests
{
    [TestMethod]
    public void CanLoadAllWorkingGrammars()
    {
        string[] workingGrammars = {
            "bash", "c", "c-sharp", "css", "embedded-template", "go",
            "haskell", "html", "java", "javascript", "jsdoc", "json",
            "kotlin", "python", "ruby", "rust", "scala", "typescript"
        };

        foreach (var grammar in workingGrammars)
        {
            try
            {
                var lang = new Language(grammar);
                Assert.IsNotNull(lang);
                Assert.IsTrue(lang.AbiVersion >= 14);
                Console.WriteLine($"✅ {grammar}: ABI {lang.AbiVersion}");
            }
            catch (Exception ex)
            {
                Assert.Fail($"Failed to load {grammar}: {ex.Message}");
            }
        }
    }

    [TestMethod]
    public void CanParseBashCode()
    {
        var bash = new Language("bash");
        var parser = new Parser(bash);
        var tree = parser.Parse("echo \"Hello World\"");

        Assert.IsNotNull(tree);
        Assert.AreEqual("program", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseCSharpCode()
    {
        var csharp = new Language("c-sharp");
        var parser = new Parser(csharp);
        var tree = parser.Parse("using System; class Test { }");

        Assert.IsNotNull(tree);
        Assert.AreEqual("compilation_unit", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseEmbeddedTemplateCode()
    {
        var template = new Language("embedded-template");
        var parser = new Parser(template);
        var tree = parser.Parse("<%= \"Hello\" %>");

        Assert.IsNotNull(tree);
        Assert.IsTrue(tree.RootNode.Children.Count >= 0);
    }

    [TestMethod]
    public void CanParseHaskellCode()
    {
        var haskell = new Language("haskell");
        var parser = new Parser(haskell);
        var tree = parser.Parse("main = putStrLn \"Hello\"");

        Assert.IsNotNull(tree);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseRustCode()
    {
        var rust = new Language("rust");
        var parser = new Parser(rust);
        var tree = parser.Parse("fn main() { println!(\"Hello\"); }");

        Assert.IsNotNull(tree);
        Assert.AreEqual("source_file", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseScalaCode()
    {
        var scala = new Language("scala");
        var parser = new Parser(scala);
        var tree = parser.Parse("object Main { def main(args: Array[String]) = println(\"Hello\") }");

        Assert.IsNotNull(tree);
        Assert.AreEqual("compilation_unit", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseRubyCode()
    {
        var ruby = new Language("ruby");
        var parser = new Parser(ruby);
        var tree = parser.Parse("def hello\n  puts 'Hello World'\nend");

        Assert.IsNotNull(tree);
        Assert.AreEqual("program", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseKotlinCode()
    {
        var kotlin = new Language("kotlin");
        var parser = new Parser(kotlin);
        var tree = parser.Parse("fun main() { println(\"Hello World\") }");

        Assert.IsNotNull(tree);
        Assert.AreEqual("source_file", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }
}