#pragma once

#ifdef __APPLE__

#include <cmath>
#include <cstdint>
#include <libkern/_OSByteOrder.h>
#include "MemoryPatch.hpp" 

// ---------- [ Write 8-bit ] ----------
static inline bool writeData8(const char *fileName, uintptr_t offset, uint8_t data) {
    return MemoryPatch::createWithBytes(fileName, offset, &data, 1).Modify();
}

static inline bool writeData8(uintptr_t address, uint8_t data) {
    return MemoryPatch::createWithBytes(address, &data, 1).Modify();
}

// ---------- [ Write 16-bit ] ----------
static inline bool writeData16(const char *fileName, uintptr_t offset, uint16_t data) {
    uint16_t tmp = _OSSwapInt16(data);
    return MemoryPatch::createWithBytes(fileName, offset, &tmp, 2).Modify();
}

static inline bool writeData16(uintptr_t address, uint16_t data) {
    uint16_t tmp = _OSSwapInt16(data);
    return MemoryPatch::createWithBytes(address, &tmp, 2).Modify();
}

// ---------- [ Write 32-bit ] ----------
static inline bool writeData32(const char *fileName, uintptr_t offset, uint32_t data) {
    uint32_t tmp = _OSSwapInt32(data);
    return MemoryPatch::createWithBytes(fileName, offset, &tmp, 4).Modify();
}

static inline bool writeData32(uintptr_t address, uint32_t data) {
    uint32_t tmp = _OSSwapInt32(data);
    return MemoryPatch::createWithBytes(address, &tmp, 4).Modify();
}

// ---------- [ Write 64-bit ] ----------
static inline bool writeData64(const char *fileName, uintptr_t offset, uint64_t data) {
    uint64_t tmp = _OSSwapInt64(data);
    return MemoryPatch::createWithBytes(fileName, offset, &tmp, 8).Modify();
}

static inline bool writeData64(uintptr_t address, uint64_t data) {
    uint64_t tmp = _OSSwapInt64(data);
    return MemoryPatch::createWithBytes(address, &tmp, 8).Modify();
}

#endif // __APPLE__
