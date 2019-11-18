/* Copyright (c) 2019 vesoft inc. All rights reserved.
 *
 * This source code is licensed under Apache 2.0 License,
 * attached with Common Clause Condition 1.0, found in the LICENSES directory.
 */

#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <elf.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <inttypes.h>
#include <cassert>
#include <capstone/capstone.h>
#include <algorithm>
#include <unordered_map>
#include <map>
#include <unordered_set>
#include <vector>
#include <tuple>

int main (int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "%s <executable>\n", argv[0]);
        return 1;
    }

    auto fd = ::open(argv[1], O_RDONLY);
    if (fd == -1) {
        ::perror("open");
        return 1;
    }
    auto size = ::lseek(fd, 0, SEEK_END);
    auto *base = (char*)::mmap(NULL, size, PROT_READ, MAP_PRIVATE, fd, 0);
    if (base == MAP_FAILED) {
        ::perror("open");
        return 1;
    }

    auto *ehdr = reinterpret_cast<Elf64_Ehdr*>(base);

    auto *shdr_base = base + ehdr->e_shoff;
    auto shdr_size = ehdr->e_shentsize;
    auto shdr_num = ehdr->e_shnum;
    auto sname_hdr_idx = ehdr->e_shstrndx;
    auto sname_hdr = reinterpret_cast<Elf64_Shdr*>(shdr_base + sname_hdr_idx * shdr_size);
    auto snames_base = base + sname_hdr->sh_offset;

    using CodeSection = std::tuple<const uint8_t*, uint64_t, size_t>;
    std::unordered_set<std::string> code_section_names = {".init", ".plt", ".text", ".fini"};
    std::vector<CodeSection> code_sections;

    for (auto i = 0u; i < shdr_num; i++) {
        auto shdr = reinterpret_cast<Elf64_Shdr*>(shdr_base + shdr_size * i);
        auto shdr_name = snames_base + shdr->sh_name;
        if (code_section_names.count(shdr_name) == 1) {
            auto *start = reinterpret_cast<const uint8_t*>(base + shdr->sh_offset);
            auto vma = reinterpret_cast<uint64_t>(shdr->sh_addr);
            auto size = shdr->sh_size;
            code_sections.emplace_back(start, vma, size);
        }
    }

    constexpr auto kBaseGroupId = 1;
    std::map<uint32_t, std::unordered_set<std::string>> groups;
    std::unordered_map<uint32_t, std::string> group_names {
        {kBaseGroupId, "BASE"},
        {128, "VT-x/AMD-V"},
        {129, "3DNow"},
        {130, "AES"},
        {131, "ADX"},
        {132, "AVX"},
        {133, "AVX2"},
        {134, "AVX512"},
        {135, "BMI"},
        {136, "BMI2"},
        {137, "CMOV"},
        {138, "F16C"},
        {139, "FMA"},
        {140, "FMA4"},
        {141, "FSGSBASE"},
        {142, "HLE"},
        {143, "MMX"},
        {144, "MODE32"},
        {145, "MODE64"},
        {146, "RTM"},
        {147, "SHA"},
        {148, "SSE1"},
        {149, "SSE2"},
        {150, "SSE3"},
        {151, "SSE41"},
        {152, "SSE42"},
        {153, "SSE4A"},
        {154, "SSSE3"},
        {155, "PCLMUL"},
        {156, "XOP"},
        {157, "CDI"},
        {158, "ERI"},
        {159, "TBM"},
        {160, "16BITMODE"},
        {161, "NOT64BITMODE"},
        {162, "SGX"},
        {163, "DQI"},
        {164, "BWI"},
        {165, "PFI"},
        {166, "VLX"},
        {167, "SMAP"},
        {168, "NOVLX"},
        {169, "FPU"},
    };

    auto insn_count = 0UL;
    for (auto &section : code_sections) {
        ::csh handle;
        if (auto err = ::cs_open(CS_ARCH_X86, CS_MODE_64, &handle)) {
            fprintf(stderr, "Failed to disassemble: %s\n", ::cs_strerror(err));
            continue;
        }
        ::cs_option(handle, CS_OPT_DETAIL, CS_OPT_ON);
        //::cs_option(handle, CS_OPT_SYNTAX, CS_OPT_SYNTAX_ATT);
        auto code = std::get<0>(section);
        auto vma = std::get<1>(section);
        auto size = std::get<2>(section);
        auto *insn = ::cs_malloc(handle);
        while (::cs_disasm_iter(handle, &code, &size, &vma, insn)) {
            insn_count++;
            auto *detail = insn->detail;
            if (detail == nullptr) {
                continue;
            }
            if (detail->groups_count == 0) {
                continue;
            }
            for (auto i = 0u; i < detail->groups_count; i++) {
                auto group = detail->groups[i];
                if (group < 128) {
                    group = kBaseGroupId;
                }
                groups[group].emplace(insn->mnemonic);
            }
        }
        if (size != 0) {
            fprintf(stderr, "Warning: Failed to disassemble at 0x%lx, skip this section\n", vma);
        }
        ::cs_free(insn, 1);
        ::cs_close(&handle);
    }

    for (auto &pair : groups) {
        char list[4096];
        auto pos = 0;
        auto len = snprintf(list, sizeof(list), "%s\n      ", group_names[pair.first].c_str());
        pos += len;
        auto current_width = len;
        auto first = true;
        for (auto &insn : pair.second) {
            if (current_width + insn.size() > 80) {
                first = true;
                len = snprintf(list + pos, sizeof(list) - pos, "\n      ");
                pos += len;
                current_width = len;
            }
            if (!first) {
                len = snprintf(list + pos, sizeof(list) - pos, ", ");
                current_width += len;
                pos += len;
            } else {
                first = false;
            }
            len = snprintf(list + pos, sizeof(list) - pos, "%s", insn.c_str());
            pos += len;
            current_width += len;
        }
        list[pos] = '\0';
        fprintf(stdout, "%s\n", list);
    }

    fprintf(stdout, "\n%lu instructions disassembled\n", insn_count);

    return 0;
}
