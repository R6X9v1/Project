#include "KittyMemory.hpp"

#ifdef __ANDROID__
#include <map>
#include <dlfcn.h>
#elif __APPLE__
extern "C" kern_return_t mach_vm_remap(vm_map_t, mach_vm_address_t *, mach_vm_size_t, mach_vm_offset_t, int, vm_map_t, mach_vm_address_t, boolean_t, vm_prot_t *, vm_prot_t *, vm_inherit_t);
#endif

namespace KittyMemory {

    int setAddressProtection(const void *address, size_t length, int protection) {
        uintptr_t pageStart = KT_PAGE_START(address);
        uintptr_t pageLen = KT_PAGE_LEN2(address, length);
        return mprotect(reinterpret_cast<void *>(pageStart), pageLen, protection);
    }

#ifdef __ANDROID__

    // Android memRead / memWrite
    bool memRead(const void* address, void* buffer, size_t len) {
        if (!address || !buffer || !len)
            return false;
        ProcMap addressMap = getAddressMap(address);
        if (!addressMap.isValid()) return false;
        if (addressMap.protection & PROT_READ) {
            memcpy(buffer, address, len);
            return true;
        }
        if (setAddressProtection(address, len, addressMap.protection | PROT_READ) != 0)
            return false;
        memcpy(buffer, address, len);
        setAddressProtection(address, len, addressMap.protection);
        return true;
    }

    bool memWrite(void *address, const void *buffer, size_t len) {
        if (!address || !buffer || !len)
            return false;
        ProcMap addressMap = getAddressMap(address);
        if (!addressMap.isValid()) return false;
        if (addressMap.protection & PROT_WRITE) {
            memcpy(address, buffer, len);
            return true;
        }
        if (setAddressProtection(address, len, addressMap.protection | PROT_WRITE) != 0)
            return false;
        memcpy(address, buffer, len);
        setAddressProtection(address, len, addressMap.protection);
        return true;
    }

    std::string getProcessName() {
        const char *file = "/proc/self/cmdline";
        char cmdline[128] = {0};
        FILE *fp = fopen(file, "r");
        if (!fp) return "";
        fgets(cmdline, sizeof(cmdline), fp);
        fclose(fp);
        return cmdline;
    }

    std::vector<ProcMap> getAllMaps() {
        std::vector<ProcMap> retMaps;
        FILE *fp = fopen("/proc/self/maps", "r");
        if (!fp) return retMaps;
        char line[512] = {0};
        while (fgets(line, sizeof(line), fp)) {
            ProcMap map;
            char perms[5] = {0}, dev[11] = {0}, pathname[256] = {0};
            sscanf(line, "%llx-%llx %s %llx %s %lu %s",
                   &map.startAddress, &map.endAddress,
                   perms, &map.offset, dev, &map.inode, pathname);
            map.length = map.endAddress - map.startAddress;
            map.dev = dev;
            map.pathname = pathname;
            if (perms[0] == 'r') map.protection |= PROT_READ;
            if (perms[1] == 'w') map.protection |= PROT_WRITE;
            if (perms[2] == 'x') map.protection |= PROT_EXEC;
            map.is_private = (perms[3] == 'p');
            map.is_shared = (perms[3] == 's');
            map.is_rx = (strncmp(perms, "r-x", 3) == 0);
            map.is_rw = (strncmp(perms, "rw-", 3) == 0);
            map.is_ro = (strncmp(perms, "r--", 3) == 0);
            retMaps.push_back(map);
        }
        fclose(fp);
        return retMaps;
    }

    std::vector<ProcMap> getMapsEndWith(const std::string &name) {
        std::vector<ProcMap> all = getAllMaps(), out;
        for (auto &m : all) {
            if (KittyUtils::String::EndsWith(m.pathname, name))
                out.push_back(m);
        }
        return out;
    }

    ProcMap getAddressMap(const std::vector<ProcMap> &maps, const void *address) {
        if (!address) return {};
        for (auto &it : maps) {
            if (it.contains((uintptr_t)address))
                return it;
        }
        return {};
    }

    ProcMap getAddressMap(const void *address) {
        return getAddressMap(getAllMaps(), address);
    }

#elif __APPLE__

    kern_return_t getPageInfo(void *page_start, vm_region_submap_short_info_64 *info_out) {
        vm_address_t region = reinterpret_cast<vm_address_t>(page_start);
        vm_size_t region_len = 0;
        mach_msg_type_number_t info_count = VM_REGION_SUBMAP_SHORT_INFO_COUNT_64;
        unsigned int depth = 0;
        return vm_region_recurse_64(mach_task_self(), &region, &region_len,
                                    &depth, (vm_region_recurse_info_t)info_out, &info_count);
    }

    bool memRead(const void *address, void *buffer, size_t len) {
        if (!address || !buffer || !len)
            return false;
        memcpy(buffer, address, len);
        return true;
    }

    Memory_Status memWrite(void *address, const void *buffer, size_t len) {
        if (!address || !buffer || !len)
            return KMS_INV_ADDR;
        void *page_start = reinterpret_cast<void *>(KT_PAGE_START(address));
        void *page_offset = reinterpret_cast<void *>(KT_PAGE_OFFSET(address));
        size_t page_len = KT_PAGE_LEN2(address, len);
        vm_region_submap_short_info_64 page_info;
        if (getPageInfo(page_start, &page_info) != KERN_SUCCESS)
            return KMS_ERR_GET_PAGEINFO;

        void *new_map = mmap(nullptr, page_len, _PROT_RW_, MAP_ANON | MAP_PRIVATE, -1, 0);
        if (!new_map) return KMS_ERR_MMAP;

        task_t self_task = mach_task_self();
        if (vm_copy(self_task, reinterpret_cast<vm_address_t>(page_start), page_len,
                    reinterpret_cast<vm_address_t>(new_map)) != KERN_SUCCESS)
        {
            munmap(new_map, page_len);
            return KMS_ERR_PROT;
        }

        void *dst = reinterpret_cast<void *>(reinterpret_cast<uintptr_t>(new_map) + reinterpret_cast<uintptr_t>(page_offset));
        memcpy(dst, buffer, len);

        if (mprotect(new_map, page_len, page_info.protection) == -1)
        {
            munmap(new_map, page_len);
            return KMS_ERR_PROT;
        }

        mach_vm_address_t mach_vm_page_start = reinterpret_cast<mach_vm_address_t>(page_start);
        vm_prot_t cur_protection, max_protection;

        if (mach_vm_remap(self_task, &mach_vm_page_start, page_len, 0, VM_FLAGS_OVERWRITE,
                          self_task, reinterpret_cast<mach_vm_address_t>(new_map), TRUE,
                          &cur_protection, &max_protection, page_info.inheritance) != KERN_SUCCESS)
        {
            munmap(new_map, page_len);
            return KMS_ERR_REMAP;
        }

        munmap(new_map, page_len);
        return KMS_SUCCESS;
    }

    MemoryFileInfo getBaseInfo() {
        MemoryFileInfo info;
        uint32_t count = _dyld_image_count();
        for (uint32_t i = 0; i < count; ++i) {
            const mach_header *hdr = _dyld_get_image_header(i);
            if (!hdr || hdr->filetype != MH_EXECUTE) continue;
            info.index = i;
#ifdef __LP64__
            info.header = (const mach_header_64 *)hdr;
#else
            info.header = hdr;
#endif
            info.name = _dyld_get_image_name(i);
            info.address = _dyld_get_image_vmaddr_slide(i);
            break;
        }
        return info;
    }

    uintptr_t getAbsoluteAddress(const char *fileName, uintptr_t address) {
        MemoryFileInfo info = fileName ? getMemoryFileInfo(fileName) : getBaseInfo();
        return info.address + address;
    }

    MemoryFileInfo getMemoryFileInfo(const std::string& fileName) {
        MemoryFileInfo info;
        uint32_t count = _dyld_image_count();
        for (uint32_t i = 0; i < count; ++i) {
            std::string fullpath(_dyld_get_image_name(i));
            if (KittyUtils::String::EndsWith(fullpath, fileName)) {
                info.index = i;
#ifdef __LP64__
                info.header = (const mach_header_64*)_dyld_get_image_header(i);
#else
                info.header = _dyld_get_image_header(i);
#endif
                info.name = _dyld_get_image_name(i);
                info.address = _dyld_get_image_vmaddr_slide(i);
                break;
            }
        }
        return info;
    }

    // ✅ نسخة خالية من substrate
    bool findMSHookMemory(void *, const void *, size_t) {
        return false;
    }

#endif // __APPLE__

}
