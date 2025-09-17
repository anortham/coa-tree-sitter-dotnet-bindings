//
// .NET bindings for tree-sitter
// Copyright (c) 2025 Marius Greuel
// SPDX-License-Identifier: MIT
// https://github.com/mariusgreuel/tree-sitter-dotnet-bindings
//

using System.Reflection;
using System.Runtime.InteropServices;

namespace TreeSitter;

internal static class NativeLibrary
{
    public static IntPtr Load(string libraryName, Assembly assembly, DllImportSearchPath? searchPath)
    {
        return LoadLibraryByName(libraryName, assembly, searchPath, throwOnError: true);
    }

    public static bool TryLoad(string libraryName, Assembly assembly, DllImportSearchPath? searchPath, out IntPtr handle)
    {
        handle = LoadLibraryByName(libraryName, assembly, searchPath, throwOnError: false);
        return handle != IntPtr.Zero;
    }

    public static void Free(IntPtr handle)
    {
        if (handle != IntPtr.Zero)
        {
            System.Runtime.InteropServices.NativeLibrary.Free(handle);
        }
    }

    public static IntPtr GetExport(IntPtr handle, string name)
    {
        if (System.Runtime.InteropServices.NativeLibrary.TryGetExport(handle, name, out var address))
        {
            return address;
        }

        throw new EntryPointNotFoundException($"Could not find entry point '{name}' in library");
    }

    public static bool TryGetExport(IntPtr handle, string name, out IntPtr address)
    {
        return System.Runtime.InteropServices.NativeLibrary.TryGetExport(handle, name, out address);
    }

    static IntPtr LoadLibraryByName(string libraryName, Assembly assembly, DllImportSearchPath? searchPath, bool throwOnError)
    {
        var searchPaths = new List<string>();

        // Add assembly directory
        if (searchPath == null || (searchPath.Value & DllImportSearchPath.AssemblyDirectory) != 0)
        {
            searchPaths.Add(AppContext.BaseDirectory);

            // Add runtime-specific paths
            var rid = GetRuntimeIdentifier();
            searchPaths.Add(Path.Combine(AppContext.BaseDirectory, "runtimes", rid, "native"));
            searchPaths.Add(Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "build", "runtimes", rid, "native"));
        }

        // Try each search path with various naming conventions
        foreach (var searchDir in searchPaths)
        {
            foreach (var variation in GetLibraryNameVariations(libraryName))
            {
                var fullPath = Path.Combine(searchDir, variation);
                if (File.Exists(fullPath))
                {
                    if (System.Runtime.InteropServices.NativeLibrary.TryLoad(fullPath, out var handle))
                    {
                        return handle;
                    }
                }
            }
        }

        // Try system search
        foreach (var variation in GetLibraryNameVariations(libraryName))
        {
            if (System.Runtime.InteropServices.NativeLibrary.TryLoad(variation, assembly, searchPath, out var handle))
            {
                return handle;
            }
        }

        if (throwOnError)
        {
            throw new DllNotFoundException($"Unable to load dynamic library '{libraryName}' or one of its dependencies.");
        }

        return IntPtr.Zero;
    }

    static IEnumerable<string> GetLibraryNameVariations(string name)
    {
        // Return the name as-is first
        yield return name;

        // Platform-specific variations
        if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
        {
            if (!name.EndsWith(".dll", StringComparison.OrdinalIgnoreCase))
            {
                yield return name + ".dll";
            }
        }
        else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
        {
            yield return "lib" + name;
            yield return name + ".so";
            yield return "lib" + name + ".so";
        }
        else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
        {
            yield return "lib" + name;
            yield return name + ".dylib";
            yield return "lib" + name + ".dylib";
        }
    }

    static string GetRuntimeIdentifier()
    {
        string architecture = RuntimeInformation.ProcessArchitecture.ToString().ToLowerInvariant();

        if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
        {
            return $"win-{architecture}";
        }
        else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
        {
            return $"linux-{architecture}";
        }
        else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
        {
            return $"osx-{architecture}";
        }
        else
        {
            throw new PlatformNotSupportedException();
        }
    }
}