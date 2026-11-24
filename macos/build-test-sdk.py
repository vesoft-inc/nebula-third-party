#!/usr/bin/env python3
# Copyright (c) 2026 vesoft inc. All rights reserved.

"""Build the full macOS SDK from the local base dependency build."""

import argparse
import json
from pathlib import Path
import platform
import shutil
import sys
import tempfile

from build import Build, HERE, ORDER, TEST_DEPENDENCIES, digest
from package import stage


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
    base = parser.add_mutually_exclusive_group(required=True)
    base.add_argument("--base-work-dir", type=Path, help="Work directory from macos/build.py")
    base.add_argument("--sdk-root", type=Path, help="An existing staged base SDK")
    parser.add_argument("--work-dir", required=True, type=Path)
    parser.add_argument("--source-cache", type=Path)
    parser.add_argument("--jobs", type=int, default=3)
    args = parser.parse_args()
    if platform.system() != "Darwin" or platform.machine() != "arm64":
        parser.error("Run on a native Apple Silicon macOS host.")
    if args.jobs < 1:
        parser.error("--jobs must be at least 1")
    work = args.work_dir.resolve()
    base_work = args.base_work_dir.resolve() if args.base_work_dir else None
    if base_work:
        if not all((base_work / "done" / name).is_file() for name in ORDER):
            parser.error("--base-work-dir must contain a completed macos/build.py build.")
        sdk_root = base_work / "prefix"
    else:
        sdk_root = args.sdk_root.resolve()
        base_lock = sdk_root / "sources.json"
        if not base_lock.is_file() or digest(base_lock) != digest(HERE / "sources.json"):
            parser.error("--sdk-root must point to a staged base SDK for this source lock.")
    base_dir = base_work or sdk_root
    if work.is_relative_to(base_dir) or base_dir.is_relative_to(work):
        parser.error("The base and full SDK work directories must be separate.")

    cache = args.source_cache.resolve() if args.source_cache else work / "archives"
    build = TestSdk(work, cache, args.jobs)
    base_marker = work / "base-sdk"
    if base_marker.is_file():
        if base_marker.read_text().strip() != str(sdk_root):
            parser.error("Use a new --work-dir for a different base SDK.")
    else:
        if base_work:
            with tempfile.TemporaryDirectory(prefix="base-sdk-", dir=work) as staging:
                stage(sdk_root, Path(staging))
                shutil.copytree(staging, build.prefix, symlinks=True, dirs_exist_ok=True)
        else:
            shutil.copytree(sdk_root, build.prefix, symlinks=True, dirs_exist_ok=True)
        base_marker.write_text(f"{sdk_root}\n")
    build.build(TEST_DEPENDENCIES)
    print(f"NEBULA_THIRDPARTY_ROOT={build.prefix}")


if __name__ == "__main__":
    main()
