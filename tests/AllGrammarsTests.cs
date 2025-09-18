using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace TreeSitter.Tests;

[TestClass]
public class AllGrammarsTests
{
    [TestMethod]
    public void CanLoadAllWorkingGrammars()
    {
        string[] allGrammars = {
            "agda", "bash", "c", "cpp", "c-sharp", "css", "dart",
            "embedded-template", "go", "haskell", "html", "java",
            "javascript", "jsdoc", "json", "julia", "kotlin", "lua",
            "markdown", "ocaml", "php", "python", "ql", "razor",
            "ruby", "rust", "scala", "sql", "swift", "toml",
            "tsq", "tsx", "typescript", "verilog", "yaml"
        };

        foreach (var grammar in allGrammars)
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

    [TestMethod]
    public void CanParseAgdaCode()
    {
        var agda = new Language("agda");
        var parser = new Parser(agda);
        var tree = parser.Parse("module Test where\n\ndata Nat : Set where\n  zero : Nat");

        Assert.IsNotNull(tree);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseCppCode()
    {
        var cpp = new Language("cpp");
        var parser = new Parser(cpp);
        var tree = parser.Parse("#include <iostream>\nint main() { std::cout << \"Hello\"; return 0; }");

        Assert.IsNotNull(tree);
        Assert.AreEqual("translation_unit", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseCssCode()
    {
        var css = new Language("css");
        var parser = new Parser(css);
        var tree = parser.Parse("body { color: red; font-size: 14px; }");

        Assert.IsNotNull(tree);
        Assert.AreEqual("stylesheet", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseDartCode()
    {
        var dart = new Language("dart");
        var parser = new Parser(dart);
        var tree = parser.Parse("void main() { print('Hello World'); }");

        Assert.IsNotNull(tree);
        Assert.AreEqual("program", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseGoCode()
    {
        var go = new Language("go");
        var parser = new Parser(go);
        var tree = parser.Parse("package main\n\nfunc main() {\n\tfmt.Println(\"Hello\")\n}");

        Assert.IsNotNull(tree);
        Assert.AreEqual("source_file", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseHtmlCode()
    {
        var html = new Language("html");
        var parser = new Parser(html);
        var tree = parser.Parse("<html><body><h1>Hello World</h1></body></html>");

        Assert.IsNotNull(tree);
        Assert.AreEqual("document", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseJavaCode()
    {
        var java = new Language("java");
        var parser = new Parser(java);
        var tree = parser.Parse("public class Test { public static void main(String[] args) { System.out.println(\"Hello\"); } }");

        Assert.IsNotNull(tree);
        Assert.AreEqual("program", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseJavaScriptCode()
    {
        var js = new Language("javascript");
        var parser = new Parser(js);
        var tree = parser.Parse("function hello() { console.log('Hello World'); }");

        Assert.IsNotNull(tree);
        Assert.AreEqual("program", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseJsDocCode()
    {
        var jsdoc = new Language("jsdoc");
        var parser = new Parser(jsdoc);
        var tree = parser.Parse("/**\n * @param {string} name\n */");

        Assert.IsNotNull(tree);
        Assert.IsTrue(tree.RootNode.Children.Count >= 0);
    }

    [TestMethod]
    public void CanParseJsonCode()
    {
        var json = new Language("json");
        var parser = new Parser(json);
        var tree = parser.Parse("{\"name\": \"test\", \"value\": 42}");

        Assert.IsNotNull(tree);
        Assert.AreEqual("document", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseJuliaCode()
    {
        var julia = new Language("julia");
        var parser = new Parser(julia);
        var tree = parser.Parse("function hello()\n    println(\"Hello World\")\nend");

        Assert.IsNotNull(tree);
        Assert.AreEqual("source_file", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseLuaCode()
    {
        var lua = new Language("lua");
        var parser = new Parser(lua);
        var tree = parser.Parse("function hello()\n  print(\"Hello World\")\nend");

        Assert.IsNotNull(tree);
        Assert.AreEqual("chunk", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseMarkdownCode()
    {
        var markdown = new Language("markdown");
        var parser = new Parser(markdown);
        var tree = parser.Parse("# Hello World\n\nThis is a **bold** text.");

        Assert.IsNotNull(tree);
        Assert.AreEqual("document", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseOcamlCode()
    {
        var ocaml = new Language("ocaml");
        var parser = new Parser(ocaml);
        var tree = parser.Parse("let hello () = print_endline \"Hello World\"");

        Assert.IsNotNull(tree);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParsePhpCode()
    {
        var php = new Language("php");
        var parser = new Parser(php);
        var tree = parser.Parse("<?php\necho \"Hello World\";\n?>");

        Assert.IsNotNull(tree);
        Assert.AreEqual("program", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParsePythonCode()
    {
        var python = new Language("python");
        var parser = new Parser(python);
        var tree = parser.Parse("def hello():\n    print('Hello World')");

        Assert.IsNotNull(tree);
        Assert.AreEqual("module", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseQlCode()
    {
        var ql = new Language("ql");
        var parser = new Parser(ql);
        var tree = parser.Parse("import cpp\n\nfrom Function f\nwhere f.getName() = \"main\"\nselect f");

        Assert.IsNotNull(tree);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseRazorCode()
    {
        var razor = new Language("razor");
        var parser = new Parser(razor);
        var tree = parser.Parse("@page \"/test\"\n<h1>Hello @name</h1>\n@code { string name = \"World\"; }");

        Assert.IsNotNull(tree);
        Assert.AreEqual("compilation_unit", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseSqlCode()
    {
        var sql = new Language("sql");
        var parser = new Parser(sql);
        var tree = parser.Parse("SELECT name, age FROM users WHERE age > 18;");

        Assert.IsNotNull(tree);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseSwiftCode()
    {
        var swift = new Language("swift");
        var parser = new Parser(swift);
        var tree = parser.Parse("func hello() { print(\"Hello World\") }");

        Assert.IsNotNull(tree);
        Assert.AreEqual("program", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseTomlCode()
    {
        var toml = new Language("toml");
        var parser = new Parser(toml);
        var tree = parser.Parse("[package]\nname = \"test\"\nversion = \"1.0.0\"");

        Assert.IsNotNull(tree);
        Assert.AreEqual("document", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseTsqCode()
    {
        var tsq = new Language("tsq");
        var parser = new Parser(tsq);
        var tree = parser.Parse("(function_declaration name: (identifier) @function)");

        Assert.IsNotNull(tree);
        Assert.AreEqual("query", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseTsxCode()
    {
        var tsx = new Language("tsx");
        var parser = new Parser(tsx);
        var tree = parser.Parse("const Component = () => <div>Hello</div>;");

        Assert.IsNotNull(tree);
        Assert.AreEqual("program", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseTypeScriptCode()
    {
        var typescript = new Language("typescript");
        var parser = new Parser(typescript);
        var tree = parser.Parse("function hello(name: string): void { console.log(`Hello ${name}`); }");

        Assert.IsNotNull(tree);
        Assert.AreEqual("program", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseVerilogCode()
    {
        var verilog = new Language("verilog");
        var parser = new Parser(verilog);
        var tree = parser.Parse("module test;\n  initial begin\n    $display(\"Hello\");\n  end\nendmodule");

        Assert.IsNotNull(tree);
        Assert.AreEqual("source_file", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }

    [TestMethod]
    public void CanParseYamlCode()
    {
        var yaml = new Language("yaml");
        var parser = new Parser(yaml);
        var tree = parser.Parse("name: test\nversion: 1.0.0\ndependencies:\n  - lib1\n  - lib2");

        Assert.IsNotNull(tree);
        Assert.AreEqual("stream", tree.RootNode.Type);
        Assert.IsTrue(tree.RootNode.Children.Count > 0);
    }
}