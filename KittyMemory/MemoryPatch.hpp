#pragma once
#include <string>
#include <vector>
#include <cstdint>
#include "KittyMemory.hpp"

enum MP_ASM_ARCH {
    MP_ASM_ARM32 = 0,
    MP_ASM_ARM64,
    MP_ASM_x86,
    MP_ASM_x86_64,
};

class MemoryPatch {
private:
    uintptr_t _address;
    size_t _size;
    std::vector<uint8_t> _orig_code;
    std::vector<uint8_t> _patch_code;

public:
    MemoryPatch();
    ~MemoryPatch();

    // ---------- Universal (No Keystone Required) ----------
    static MemoryPatch createWithBytes(uintptr_t absolute_address, const void *patch_code, size_t patch_size);
    static MemoryPatch createWithHex(uintptr_t absolute_address, std::string hex);

#ifdef __ANDROID__
    static MemoryPatch createWithBytes(const KittyMemory::ProcMap &map, uintptr_t address, const void *patch_code, size_t patch_size);
    static MemoryPatch createWithHex(const KittyMemory::ProcMap &map, uintptr_t address, const std::string &hex);
#elif __APPLE__
    static MemoryPatch createWithBytes(const char *fileName, uintptr_t address, const void *patch_code, size_t patch_size);
    static MemoryPatch createWithHex(const char *fileName, uintptr_t address, const std::string &hex);
#endif

    // ---------- Patch Control ----------
    bool isValid() const;
    size_t get_PatchSize() const;
    uintptr_t get_TargetAddress() const;
    bool Restore();      // Restore original bytes
    bool Modify();       // Apply patch

    // ---------- For Debug/Info ----------
    std::string get_CurrBytes() const;
    std::string get_OrigBytes() const;
    std::string get_PatchBytes() const;
};
