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

    constexpr auto kGenericGroupId = 1;
    std::unordered_map<uint32_t, std::unordered_set<std::string>> groups;
    std::unordered_map<uint32_t, std::string> group_names;

    auto nr_insn = 0UL;
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
            nr_insn++;
            auto *detail = insn->detail;
            if (detail == nullptr) {
                continue;
            }
            if (detail->groups_count == 0) {
                continue;
            }
            for (auto i = 0u; i < detail->groups_count; i++) {
                auto group = detail->groups[i];
                auto *group_name = ::cs_group_name(handle, detail->groups[i]);
                if (group < 128) {
                    group = kGenericGroupId;
                    group_name = "generic";
                }
                groups[group].emplace(insn->mnemonic);
                group_names[group] = group_name;
            }
        }
        ::cs_free(insn, 1);
        ::cs_close(&handle);
    }

    for (auto &pair : groups) {
        char line[512];
        auto width = snprintf(line, sizeof(line), "%s(", group_names[pair.first].c_str());
        for (auto &insn : pair.second) {
            if (width + insn.size() > 80) {
                width += snprintf(line + width, sizeof(line) - width, "...");
                break;
            } else {
                width += snprintf(line + width, sizeof(line) - width, "%s, ", insn.c_str());
            }
        }
        if (line[width - 1] != '.') {
            width -= 2;
        }
        snprintf(line + width, sizeof(line) - width, ")");
        fprintf(stdout, "%s\n", line);
    }

    fprintf(stdout, "\n%lu instructions processed\n", nr_insn);

    return 0;
}
