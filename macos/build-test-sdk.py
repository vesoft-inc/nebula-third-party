#!/usr/bin/env python3
# Copyright (c) 2026 vesoft inc. All rights reserved.

"""Add the local Nebula NG test dependencies to a copy of the macOS daemon SDK."""

import argparse
import json
from pathlib import Path
import platform
import shutil
import sys

from build import Build, HERE, digest


class TestSdk(Build):
    def __init__(self, work, archives, jobs):
        super().__init__(work, archives, jobs, offline=False)
        self.lock.update(json.loads((HERE / "test-sources.json").read_text()))
        self.env["CMAKE_BUILD_PARALLEL_LEVEL"] = str(jobs)

    def build_one(self, name, source, build):
        if name == "duckdb":
            self.cmake(
                name, source, build, "BUILD_PARQUET_EXTENSION=ON", "BUILD_SHELL=OFF",
                "BUILD_UNITTESTS=OFF", "BUILD_JEMALLOC_EXTENSION=OFF", "BUILD_SHARED_LIBS=OFF",
                "CMAKE_CXX_FLAGS_RELEASE=-O1 -DNDEBUG", targets=("duckdb_static", "parquet_extension"),
            )
            self.run(sys.executable, "scripts/amalgamation.py", "--extended", cwd=source)
            include = self.prefix / "include/duckdb"
            include.mkdir(exist_ok=True)
            shutil.copy2(source / "src/amalgamation/duckdb.hpp", include)
            self.copy_libraries(build, (
                "src/libduckdb_static.a", "third_party/*/libduckdb_*.a",
                "extension/parquet/libparquet_extension.a",
            ))
        elif name == "arrow":
            self.cmake(
                name, source, build, "ARROW_DEPENDENCY_SOURCE=AUTO", "ARROW_COMPUTE=ON",
                "ARROW_DATASET=ON", "ARROW_JSON=ON", "ARROW_PARQUET=ON", "ARROW_ORC=ON",
                "ARROW_HDFS=ON", "ARROW_S3=ON", "ARROW_GCS=ON",
            )
        else:
            super().build_one(name, source, build)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sdk-root", required=True, type=Path)
    parser.add_argument("--work-dir", required=True, type=Path)
    parser.add_argument("--source-cache", type=Path)
    parser.add_argument("--jobs", type=int, default=3)
    args = parser.parse_args()
    if platform.system() != "Darwin" or platform.machine() != "arm64":
        parser.error("Run on a native Apple Silicon macOS host.")
    if args.jobs < 1:
        parser.error("--jobs must be at least 1")
    sdk_root = args.sdk_root.resolve()
    work = args.work_dir.resolve()
    base_lock = sdk_root / "sources.json"
    if not base_lock.is_file() or digest(base_lock) != digest(HERE / "sources.json"):
        parser.error("--sdk-root must point to the macOS daemon SDK for this source lock.")
    if work.is_relative_to(sdk_root) or sdk_root.is_relative_to(work):
        parser.error("--work-dir and --sdk-root must be separate directories.")

    cache = args.source_cache.resolve() if args.source_cache else work / "archives"
    build = TestSdk(work, cache, args.jobs)
    base_marker = work / "base-sdk"
    if base_marker.is_file():
        if base_marker.read_text().strip() != str(sdk_root):
            parser.error("Use a new --work-dir for a different base SDK.")
    else:
        shutil.copytree(sdk_root, build.prefix, symlinks=True, dirs_exist_ok=True)
        base_marker.write_text(f"{sdk_root}\n")
    build.build(("xsimd", "duckdb", "arrow"))
    print(f"NEBULA_THIRDPARTY_ROOT={build.prefix}")


if __name__ == "__main__":
    main()
