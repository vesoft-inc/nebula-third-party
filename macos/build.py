#!/usr/bin/env python3
# Copyright (c) 2026 vesoft inc. All rights reserved.

"""Build the locked Nebula NG dependency profile with the macOS SDK."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import shlex
import shutil
import subprocess


HERE = Path(__file__).resolve().parent
REPO = HERE.parent
DEPLOYMENT_TARGET = "15.0"
EPOCH = 1735689600
ORDER = """
bzip2 zlib zstd lz4 snappy libevent libev fmt gflags glog double-conversion
openssl lzma sodium jemalloc libdwarf bison flex gperf boost abseil re2
c-ares protobuf grpc folly fizz wangle proxygen rocksdb llvm openblas faiss
utf8proc xsimd arrow date googletest googlebenchmark s2geometry yaml-cpp
libcurl libxml2 datasketches inja nlohmann-json simdjson
annoy cppjieba eigen hnswlib jwt-cpp limonp robin-hood-hashing tomlplusplus valijson
""".split()
HEADERS = {
    "annoy": {"annoy/annoylib.h": "src/annoylib.h", "annoy/kissrandom.h": "src/kissrandom.h"},
    "cppjieba": {"cppjieba": "include/cppjieba"},
    "eigen": {"eigen3/Eigen": "Eigen", "eigen3/unsupported": "unsupported"},
    "hnswlib": {"hnswlib": "hnswlib"},
    "jwt-cpp": {"jwt-cpp": "include/jwt-cpp"},
    "limonp": {"limonp": "include/limonp"},
    "robin-hood-hashing": {"robin_hood.h": "src/include/robin_hood.h"},
    "tomlplusplus": {"toml++": "include/toml++"},
    "valijson": {"valijson": "include/valijson"},
}
CMAKE_OPTIONS = {
    "abseil": ["ABSL_PROPAGATE_CXX_STD=ON", "ABSL_ENABLE_INSTALL=ON"],
    "arrow": [
        "ARROW_BUILD_STATIC=OFF", "ARROW_BUILD_SHARED=ON", "ARROW_BUILD_TESTS=OFF",
        "ARROW_FILESYSTEM=ON", "ARROW_CSV=ON", "ARROW_IPC=ON", "ARROW_COMPUTE=OFF",
        "ARROW_GANDIVA=OFF", "ARROW_PARQUET=OFF", "ARROW_ORC=OFF", "ARROW_HDFS=OFF",
        "ARROW_S3=OFF", "ARROW_GCS=OFF", "ARROW_AZURE=OFF", "ARROW_JEMALLOC=OFF",
        "ARROW_DEPENDENCY_SOURCE=SYSTEM", "ARROW_SIMD_LEVEL=NONE", "xsimd_SOURCE=SYSTEM",
    ],
    "c-ares": ["CARES_SHARED=ON", "CARES_STATIC=OFF"],
    "datasketches": ["WITH_TESTS=OFF", "WITH_PYTHON=OFF"],
    "date": ["BUILD_TZ_LIB=ON", "USE_SYSTEM_TZ_DB=ON"],
    "fizz": ["BUILD_TESTS=OFF", "BUILD_EXAMPLES=OFF", "Boost_NO_BOOST_CMAKE=ON"],
    "fmt": ["FMT_TEST=OFF"],
    "folly": ["BUILD_TESTS=OFF", "Boost_NO_BOOST_CMAKE=ON", "FOLLY_CXX_FLAGS=-Wno-error"],
    "gflags": ["GFLAGS_BUILD_SHARED_LIBS=ON", "GFLAGS_BUILD_STATIC_LIBS=OFF", "REGISTER_INSTALL_PREFIX=OFF"],
    "glog": ["BUILD_TESTING=OFF", "WITH_GFLAGS=ON", "WITH_UNWIND=OFF"],
    "googlebenchmark": ["BENCHMARK_ENABLE_TESTING=OFF", "BENCHMARK_ENABLE_GTEST_TESTS=OFF"],
    "inja": ["BUILD_TESTING=OFF", "BUILD_BENCHMARK=OFF", "INJA_INSTALL=ON"],
    "libcurl": [
        "BUILD_CURL_EXE=OFF", "CURL_USE_OPENSSL=ON", "CURL_USE_LIBPSL=OFF",
        "CURL_USE_LIBSSH2=OFF", "CURL_DISABLE_LDAP=ON", "CURL_DISABLE_LDAPS=ON",
        "USE_NGHTTP2=OFF", "CURL_CA_BUNDLE=/etc/ssl/cert.pem", "CURL_CA_PATH=/etc/ssl/certs",
    ],
    "libdwarf": ["BUILD_SHARED=ON", "BUILD_NON_SHARED=OFF", "BUILD_DWARFDUMP=OFF"],
    "libevent": [
        "EVENT__LIBRARY_TYPE=SHARED", "EVENT__DISABLE_OPENSSL=ON", "EVENT__DISABLE_TESTS=ON",
        "EVENT__DISABLE_BENCHMARK=ON", "EVENT__DISABLE_SAMPLES=ON", "EVENT__DISABLE_REGRESS=ON",
    ],
    "libxml2": [
        "LIBXML2_WITH_PROGRAMS=OFF", "LIBXML2_WITH_TESTS=OFF", "LIBXML2_WITH_PYTHON=OFF",
        "LIBXML2_WITH_LZMA=OFF", "LIBXML2_WITH_ZLIB=OFF", "LIBXML2_WITH_ICU=OFF",
    ],
    "llvm": ["OPENMP_ENABLE_LIBOMPTARGET=OFF", "LIBOMP_ARCH=aarch64", "LIBOMP_INSTALL_ALIASES=OFF"],
    "lz4": ["BUILD_STATIC_LIBS=OFF", "LZ4_BUILD_CLI=OFF"],
    "nlohmann-json": ["JSON_BuildTests=OFF", "JSON_Install=ON"],
    "openblas": ["NOFORTRAN=ON", "TARGET=ARMV8", "NO_AFFINITY=ON", "NO_LAPACKE=ON", "NUM_THREADS=8"],
    "protobuf": [
        "protobuf_BUILD_TESTS=OFF", "protobuf_BUILD_SHARED_LIBS=ON", "protobuf_ABSL_PROVIDER=package",
    ],
    "proxygen": ["BUILD_TESTS=OFF", "BUILD_SAMPLES=OFF", "Boost_NO_BOOST_CMAKE=ON"],
    "re2": ["RE2_BUILD_TESTING=OFF"],
    "rocksdb": [
        "PORTABLE=ON", "WITH_SNAPPY=ON", "WITH_ZSTD=ON", "WITH_ZLIB=ON", "WITH_LZ4=ON",
        "WITH_BZ2=ON", "WITH_JEMALLOC=OFF", "WITH_GFLAGS=OFF", "WITH_TESTS=OFF",
        "WITH_BENCHMARK_TOOLS=OFF", "WITH_TOOLS=OFF", "WITH_CORE_TOOLS=OFF",
        "WITH_TRACE_TOOLS=OFF", "USE_RTTI=ON", "FAIL_ON_WARNINGS=OFF",
        "CMAKE_CXX_FLAGS=-DNPERF_CONTEXT",
    ],
    "s2geometry": ["WITH_GLOG=ON", "WITH_GFLAGS=ON", "BUILD_EXAMPLES=OFF"],
    "simdjson": ["SIMDJSON_DEVELOPER_MODE=OFF"],
    "snappy": ["SNAPPY_BUILD_TESTS=OFF", "SNAPPY_BUILD_BENCHMARKS=OFF"],
    "wangle": ["BUILD_TESTS=OFF", "BUILD_EXAMPLES=OFF", "Boost_NO_BOOST_CMAKE=ON"],
    "yaml-cpp": ["YAML_BUILD_SHARED_LIBS=ON", "YAML_CPP_BUILD_TESTS=OFF", "YAML_CPP_BUILD_TOOLS=OFF"],
    "zstd": ["ZSTD_BUILD_STATIC=OFF", "ZSTD_BUILD_PROGRAMS=OFF", "ZSTD_BUILD_TESTS=OFF"],
}
CMAKE_SUBDIRS = {"arrow": "cpp", "fizz": "fizz", "llvm": "openmp", "lz4": "build/cmake",
                 "wangle": "wangle", "zstd": "build/cmake"}


def digest(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


class Build:
    def __init__(self, work, archives, jobs, offline):
        self.work = work
        self.prefix = work / "prefix"
        self.archives = archives
        self.jobs = jobs
        self.offline = offline
        self.lock_path = HERE / "sources.json"
        self.lock = json.loads(self.lock_path.read_text())
        self.env = {
            key: value for key, value in os.environ.items()
            if not key.startswith(("DYLD_", "PKG_CONFIG_", "CMAKE_"))
            and key not in ("CPATH", "C_INCLUDE_PATH", "CPLUS_INCLUDE_PATH", "LIBRARY_PATH",
                            "SDKROOT", "CPPFLAGS", "CFLAGS", "CXXFLAGS", "LDFLAGS", "GREP_OPTIONS")
        }
        self.sdk = subprocess.check_output(["xcrun", "--sdk", "macosx", "--show-sdk-path"],
                                           text=True).strip()
        self.env.update(
            LC_ALL="C", TZ="UTC", SOURCE_DATE_EPOCH=str(EPOCH),
            MACOSX_DEPLOYMENT_TARGET=DEPLOYMENT_TARGET, SDKROOT=self.sdk,
            CC="/usr/bin/clang", CXX="/usr/bin/clang++",
            PATH=f"{self.prefix / 'bin'}:{self.env.get('PATH', os.defpath)}",
            PKG_CONFIG_LIBDIR=str(self.prefix / "lib/pkgconfig"),
            lt_cv_sys_max_cmd_len="196608",
            LDFLAGS="-Wl,-headerpad_max_install_names",
        )
        for directory in ("logs", "src", "build", "done"):
            (work / directory).mkdir(parents=True, exist_ok=True)
        for directory in ("bin", "include", "lib"):
            (self.prefix / directory).mkdir(parents=True, exist_ok=True)
        archives.mkdir(parents=True, exist_ok=True)
        self.log = None

    def run(self, *args, cwd=None, env=None, stdin=None):
        args = [str(arg) for arg in args]
        print("+", shlex.join(args), file=self.log, flush=True)
        subprocess.run(args, cwd=cwd, env=self.env if env is None else env, stdin=stdin,
                       stdout=self.log, stderr=subprocess.STDOUT, check=True)

    def fetch(self, name):
        entry = self.lock[name]
        archive = self.archives / entry["archive"]
        expected = entry["sha256"]
        if archive.exists():
            if digest(archive) != expected:
                raise RuntimeError(f"Source checksum mismatch: {archive}")
            return archive
        if self.offline:
            raise RuntimeError(f"Locked archive missing from the offline cache: {archive}")

        partial = archive.with_suffix(archive.suffix + ".partial")
        for url in entry["urls"]:
            try:
                self.run("/usr/bin/curl", "-fLsS", "--retry", "2", "--connect-timeout", "15",
                         "--max-time", "300", "-o", partial, url)
                if digest(partial) == expected:
                    partial.replace(archive)
                    return archive
                print(f"Checksum mismatch from {url}", file=self.log, flush=True)
            except subprocess.CalledProcessError:
                continue
        raise RuntimeError(f"Could not obtain verified archive: {name}")

    def unpack(self, name, destination, strip=1):
        archive = self.fetch(name)
        destination.mkdir(parents=True, exist_ok=True)
        self.run("/usr/bin/tar", "-xf", archive, f"--strip-components={strip}", "-C", destination)

    def make(self, *targets, cwd, env=None):
        self.run("/usr/bin/make", f"-j{self.jobs}", *targets, cwd=cwd, env=env)

    def cmake(self, name, source, build, *options, targets=()):
        options = list(CMAKE_OPTIONS.get(name, ())) + list(options)
        self.run(
            "cmake", "-S", source / CMAKE_SUBDIRS.get(name, ""), "-B", build, "-G", "Ninja",
            "-DCMAKE_C_COMPILER=/usr/bin/clang", "-DCMAKE_CXX_COMPILER=/usr/bin/clang++",
            "-DCMAKE_CXX_STANDARD=17", "-DCMAKE_OSX_ARCHITECTURES=arm64",
            f"-DCMAKE_OSX_DEPLOYMENT_TARGET={DEPLOYMENT_TARGET}", f"-DCMAKE_OSX_SYSROOT={self.sdk}",
            "-DCMAKE_BUILD_TYPE=Release", "-DCMAKE_INSTALL_LIBDIR=lib",
            f"-DCMAKE_INSTALL_PREFIX={self.prefix}", f"-DCMAKE_PREFIX_PATH={self.prefix}",
            "-DCMAKE_INSTALL_NAME_DIR=@rpath", "-DCMAKE_INSTALL_RPATH=@loader_path;@loader_path/../lib",
            "-DCMAKE_FIND_USE_PACKAGE_REGISTRY=OFF", "-DCMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY=OFF",
            "-DCMAKE_IGNORE_PREFIX_PATH=/usr/local;/opt/homebrew",
            f"-DBOOST_ROOT={self.prefix}", "-DBoost_NO_SYSTEM_PATHS=ON",
            f"-DOPENSSL_ROOT_DIR={self.prefix}", "-DBUILD_SHARED_LIBS=ON", "-DBUILD_TESTING=OFF",
            *(f"-D{option}" for option in options),
        )
        command = ["cmake", "--build", build, "--parallel", str(self.jobs)]
        if targets:
            command.extend(("--target", *targets))
        self.run(*command)
        if not targets:
            self.run("cmake", "--install", build)

    def shared_library(self, name, real_name, version, sources, *flags):
        library = self.prefix / "lib" / real_name
        self.run(self.env["CC"], "-O2", "-fPIC", "-dynamiclib",
                 "-Wl,-headerpad_max_install_names", "-install_name", f"@rpath/{real_name}",
                 "-compatibility_version", version, "-current_version", version,
                 *flags, "-o", library, *sources)
        alias = self.prefix / "lib" / f"lib{name}.dylib"
        alias.unlink(missing_ok=True)
        alias.symlink_to(real_name)

    def copy_libraries(self, build, patterns):
        destination = self.prefix / "lib"
        for pattern in patterns:
            for item in sorted(build.glob(pattern)):
                target = destination / item.name
                if item.is_symlink():
                    target.unlink(missing_ok=True)
                    target.symlink_to(os.readlink(item))
                else:
                    shutil.copy2(item, target)

    def build_one(self, name, source, build):
        include = self.prefix / "include"
        if name in HEADERS:
            for target, relative in HEADERS[name].items():
                src = source / relative
                if src.is_dir():
                    shutil.copytree(src, include / target, dirs_exist_ok=True)
                else:
                    (include / target).parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(src, include / target)
        elif name == "bzip2":
            files = "blocksort huffman crctable randtable compress decompress bzlib".split()
            self.shared_library("bz2", "libbz2.1.0.dylib", "1.0.8",
                                [source / f"{file}.c" for file in files])
            shutil.copy2(source / "bzlib.h", include)
        elif name == "libev":
            libev = source / "src"
            self.shared_library("ev", "libev.4.dylib", "4.0", [libev / "ev.c"],
                                "-DEV_STANDALONE=1", "-DEV_MULTIPLICITY=1",
                                "-DEV_USE_MONOTONIC=1", "-DEV_USE_KQUEUE=1",
                                "-DEV_USE_POLL=1", "-DEV_USE_SELECT=1")
            for header in ("ev.h", "ev++.h"):
                shutil.copy2(libev / header, include)
        elif name == "openssl":
            self.run("/usr/bin/perl", "./Configure", "darwin64-arm64-cc", "shared", "no-tests",
                     f"--prefix={self.prefix}", "--openssldir=/etc/ssl", cwd=source)
            self.make("build_libs", cwd=source)
            self.make("install_dev", cwd=source)
        elif name in ("sodium", "lzma", "bison", "flex", "gperf", "jemalloc"):
            env = self.env.copy()
            flags = {
                "sodium": ("--disable-static", "--enable-shared", "--disable-pie"),
                "lzma": ("--disable-static", "--enable-shared"),
                "flex": ("--enable-static", "--disable-shared"),
                "jemalloc": ("--enable-autogen", "--enable-stats", "--enable-prof",
                             "--with-version=5.3.0-0-gdeadbeaf"),
            }.get(name, ())
            if name == "jemalloc":
                self.configure_autoconf(build, env)
                self.run("autoconf", cwd=source, env=env)
            self.run(source / "configure", f"--prefix={self.prefix}", *flags, cwd=build, env=env)
            if name == "jemalloc":
                self.make("build_lib_shared", cwd=build, env=env)
                self.make("install_include", "install_lib_shared", cwd=build, env=env)
            else:
                self.make(cwd=build, env=env)
                self.make("install", cwd=build, env=env)
        elif name == "boost":
            libraries = "context,thread,system,filesystem,graph,program_options,regex,iostreams,date_time"
            self.run("./bootstrap.sh", "--with-toolset=clang", f"--with-libraries={libraries}",
                     "--without-icu", f"--prefix={self.prefix}", cwd=source)
            self.run("./b2", "install", "-d0", f"-j{self.jobs}", "--disable-icu",
                     "toolset=clang-darwin", "cxxstd=17",
                     f"cxxflags=-arch arm64 -mmacosx-version-min={DEPLOYMENT_TARGET}",
                     "linkflags=-arch arm64", f"include={include}", f"library-path={self.prefix / 'lib'}",
                     "link=shared", "runtime-link=shared", "variant=release", cwd=source)
        elif name == "faiss":
            self.cmake(name, source, build, "FAISS_ENABLE_GPU=OFF", "FAISS_ENABLE_PYTHON=OFF",
                       "FAISS_ENABLE_C_API=OFF", "BLA_VENDOR=OpenBLAS",
                       f"BLAS_LIBRARIES={self.prefix / 'lib/libopenblas.dylib'}",
                       "OpenMP_CXX_FLAGS=-Xpreprocessor -fopenmp", f"OpenMP_CXX_INCLUDE_DIR={include}",
                       "OpenMP_CXX_LIB_NAMES=omp", f"OpenMP_omp_LIBRARY={self.prefix / 'lib/libomp.dylib'}",
                       targets=("faiss",))
            self.run("cmake", "--install", build)
        elif name == "grpc":
            self.unpack("opencensus-proto", source / "third_party/opencensus-proto")
            providers = ("ZLIB", "CARES", "RE2", "SSL", "PROTOBUF", "ABSL")
            self.cmake(name, source, build, *(f"gRPC_{p}_PROVIDER=package" for p in providers),
                       "gRPC_BUILD_TESTS=OFF",
                       targets=("grpc++", "grpc++_reflection", "grpc_cpp_plugin"))
            self.copy_libraries(build, ("lib*.dylib",))
            for directory in ("grpc", "grpcpp", "grpc++"):
                shutil.copytree(source / "include" / directory, include / directory, dirs_exist_ok=True)
            shutil.copy2(build / "grpc_cpp_plugin", self.prefix / "bin")
        elif name == "rocksdb":
            self.cmake(name, source, build, targets=("rocksdb-shared",))
            self.copy_libraries(build, ("librocksdb*.dylib",))
            shutil.copytree(source / "include/rocksdb", include / "rocksdb", dirs_exist_ok=True)
        else:
            self.cmake(name, source, build)

    def configure_autoconf(self, build, env):
        # Some Homebrew autoconf bottles point autom4te at Perl from an older macOS SDK.
        autom4te = Path(shutil.which("autom4te", path=env["PATH"]) or "/nonexistent")
        text = autom4te.read_text()
        interpreter = text.splitlines()[0].removeprefix("#!")
        if not Path(interpreter).exists():
            corrected = build / "autom4te"
            corrected.write_text("#!/usr/bin/perl\n" + text.split("\n", 1)[1])
            corrected.chmod(0o755)
            env["AUTOM4TE"] = str(corrected)

    def install_notices(self, name, source):
        dest = self.prefix / "share/licenses" / name
        for item in sorted(source.iterdir()):
            if item.is_file() and item.name.upper().startswith(
                ("LICENSE", "COPYING", "NOTICE", "COPYRIGHT", "AUTHORS", "PATENTS")
            ):
                dest.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(item, dest / item.name)
        if name == "libev":
            dest.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source / "src/LICENSE", dest / "LICENSE")
        if name == "llvm":
            dest.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source / "openmp/LICENSE.TXT", dest / "LICENSE-openmp.TXT")
        if name == "grpc":
            self.install_notices("opencensus-proto", source / "third_party/opencensus-proto")

    def build(self, dependencies=ORDER):
        for name in dependencies:
            stamp = self.work / "done" / name
            if stamp.exists():
                continue
            source = self.work / "src" / name
            build = self.work / "build" / name
            log = self.work / "logs" / f"{name}.log"
            print(f"Building {name}", flush=True)
            with log.open("w") as self.log:
                if source.exists():
                    shutil.rmtree(source)
                if build.exists():
                    shutil.rmtree(build)
                build.mkdir()
                self.unpack(name, source, self.lock[name].get("strip", 1))
                for patch in self.lock[name].get("patches", ()):
                    with (REPO / patch).open("rb") as stream:
                        self.run("/usr/bin/patch", "--batch", "--forward", "-p1", cwd=source, stdin=stream)
                try:
                    self.build_one(name, source, build)
                    self.install_notices(name, source)
                except (subprocess.CalledProcessError, OSError) as error:
                    raise RuntimeError(f"{name} failed; see {log}") from error
                stamp.touch()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--work-dir", required=True, type=Path)
    parser.add_argument("--source-cache", type=Path)
    parser.add_argument("--offline", action="store_true", help="Require all archives in the cache")
    parser.add_argument("--jobs", type=int, default=os.cpu_count())
    args = parser.parse_args()
    if platform.system() != "Darwin" or platform.machine() != "arm64":
        parser.error("Run on a native Apple Silicon macOS host.")
    if args.jobs < 1:
        parser.error("--jobs must be at least 1")
    work = args.work_dir.resolve()
    cache = args.source_cache.resolve() if args.source_cache else work / "archives"
    Build(work, cache, args.jobs, args.offline).build()


if __name__ == "__main__":
    main()
