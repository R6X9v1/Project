#pragma once

#include <dlfcn.h>
#include <mach-o/dyld.h>
#include <mach/mach.h>
#import "fishhook/fishhook.h"

#import "../KittyMemory/writeData.hpp"

#define timer(sec) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), dispatch_get_main_queue(), ^{


#define HOOKSYM(sym, ptr, org) rebind_symbols((struct rebinding[1]){{sym, (void *)ptr, (void **)&org}}, 1)
#define HOOKSYM_NO_ORIG(sym, ptr) rebind_symbols((struct rebinding[1]){{sym, (void *)ptr, NULL}}, 1)


#define getSym(symName) dlsym((void *)RTLD_DEFAULT, symName)


#define UIColorFromHex(hexColor) [UIColor colorWithRed:((float)((hexColor & 0xFF0000) >> 16))/255.0 \
                                                 green:((float)((hexColor & 0xFF00) >> 8))/255.0 \
                                                  blue:((float)(hexColor & 0xFF))/255.0 alpha:1.0]


inline uint64_t var_00338e3(uint64_t offset) {
    return KittyMemory::getAbsoluteAddress(NULL, offset);
}

// 🛠️ Memory patching helper
inline void patchOffset(uint64_t offset, std::string hexBytes) {
    MemoryPatch patch = MemoryPatch::createWithHex(NULL, offset, hexBytes);
    if (!patch.isValid()) return;
    if (!patch.Modify()) return;
}
 
