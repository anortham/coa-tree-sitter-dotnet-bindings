using System;
using System.Runtime.InteropServices;

class TestProgram
{
    [DllImport("libtree-sitter.dylib")]
    static extern uint ts_language_version(IntPtr language);

    [DllImport("libtree-sitter-javascript.dylib")]
    static extern IntPtr tree_sitter_javascript();

    static void Main()
    {
        try
        {
            Console.WriteLine("Testing native library loading...");
            var jsLang = tree_sitter_javascript();
            Console.WriteLine($"JavaScript language pointer: {jsLang}");

            if (jsLang != IntPtr.Zero)
            {
                var version = ts_language_version(jsLang);
                Console.WriteLine($"Language version: {version}");
            }

            Console.WriteLine("Success!");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error: {ex.Message}");
            Console.WriteLine(ex.StackTrace);
        }
    }
}