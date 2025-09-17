using System;
using System.IO;
using TreeSitter;

class Program
{
    static void Main()
    {
        // Test Go parser with Go code
        Console.WriteLine("=== Testing Go Parser ===");
        try
        {
            var goLang = new Language("Go");
            var parser = new Parser(goLang);
            var goCode = @"package main
import ""fmt""
func main() {
    fmt.Println(""Hello"")
}";
            var tree = parser.Parse(goCode);
            Console.WriteLine($"Root node type: {tree.RootNode.Type}");
            Console.WriteLine($"Children: {tree.RootNode.ChildCount}");
            if (tree.RootNode.ChildCount > 0)
            {
                Console.WriteLine($"First child: {tree.RootNode.Child(0)?.Type}");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Go parser error: {ex.Message}");
        }

        Console.WriteLine();

        // Test C parser with C code
        Console.WriteLine("=== Testing C Parser ===");
        try
        {
            var cLang = new Language("C");
            var parser = new Parser(cLang);
            var cCode = @"#include <stdio.h>
int main() {
    printf(""Hello"");
    return 0;
}";
            var tree = parser.Parse(cCode);
            Console.WriteLine($"Root node type: {tree.RootNode.Type}");
            Console.WriteLine($"Children: {tree.RootNode.ChildCount}");
            if (tree.RootNode.ChildCount > 0)
            {
                Console.WriteLine($"First child: {tree.RootNode.Child(0)?.Type}");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"C parser error: {ex.Message}");
        }
    }
}