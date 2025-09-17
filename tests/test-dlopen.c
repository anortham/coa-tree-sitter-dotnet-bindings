#include <dlfcn.h>
#include <stdio.h>

int main() {
    void* handle = dlopen("libc.dylib", RTLD_NOW);
    if (handle) {
        printf("dlopen succeeded\n");
        dlclose(handle);
    } else {
        printf("dlopen failed: %s\n", dlerror());
    }
    return 0;
}
