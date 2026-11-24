#!/usr/bin/env python3
# Copyright (c) 2026 vesoft inc. All rights reserved.

"""Create and audit a relocatable Nebula NG SDK and its locked source archive."""

import argparse
import gzip
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import tarfile
import tempfile

from build import DEPLOYMENT_TARGET, EPOCH, HERE, REPO, TEST_DEPENDENCIES, copy_notices, digest


TOOLS = ("bison", "flex", "gperf", "protoc", "grpc_cpp_plugin")
SYSTEM_PREFIXES = ("/usr/lib/", "/System/Library/")
BASE_RECIPE = "ae0ced6da151d41245cdcfc150e2a87527ad49a7"


def capture(*args):
    return subprocess.check_output(args, text=True)


def run(*args):
    subprocess.run(args, check=True)


def package_version():
    env = (REPO / ".env").read_text()
    return re.search(r"^VERSION=(\d+\.\d+)$", env, re.M)[1]


def load_commands(path):
    commands = capture("/usr/bin/otool", "-l", path)
    dylibs = []
    rpaths = []
    identity = None
    for line in commands.splitlines():
        line = line.strip()
        if line.startswith("cmd "):
            command = line.split()[1]
        if line.startswith(("name ", "path ")) and " (offset " in line:
            value = line.split(" ", 1)[1].rsplit(" (offset ", 1)[0]
            if command == "LC_ID_DYLIB":
                identity = value
            elif command == "LC_RPATH":
                rpaths.append(value)
            elif command.endswith("_DYLIB"):
                dylibs.append(value)
    return identity, dylibs, rpaths


def native_arm64(path):
    arches = capture("/usr/bin/lipo", "-archs", path).split()
    if arches != ["arm64"]:
        raise RuntimeError(f"Expected arm64 Mach-O: {path} ({' '.join(arches)})")


def make_relative(root, image):
    native_arm64(image)
    identity, dependencies, rpaths = load_commands(image)
    args = []
    if identity is not None:
        name = Path(identity).name
        if not (root / "lib" / name).is_file():
            raise RuntimeError(f"{image.name}: missing dylib install name {name}")
        if identity != f"@rpath/{name}":
            args.extend(("-id", f"@rpath/{name}"))
    for dependency in dict.fromkeys(dependencies):
        if dependency.startswith(SYSTEM_PREFIXES):
            continue
        name = Path(dependency).name
        if not (root / "lib" / name).is_file():
            raise RuntimeError(f"{image.name}: unpackaged dependency {dependency}")
        relative = f"@rpath/{name}"
        if dependency != relative:
            args.extend(("-change", dependency, relative))

    desired = "@loader_path" if identity is not None else "@loader_path/../lib"
    for rpath in dict.fromkeys(rpaths):
        if rpath != desired:
            args.extend(("-delete_rpath", rpath))
    if desired not in rpaths:
        args.extend(("-add_rpath", desired))
    if args:
        run("/usr/bin/install_name_tool", *args, image)
    run("/usr/bin/codesign", "--force", "--sign", "-", "--timestamp=none",
        "--identifier", image.name, image)
    run("/usr/bin/codesign", "--verify", image)
    identity, dependencies, rpaths = load_commands(image)
    if rpaths != [desired] or any(not dep.startswith(("@rpath/", *SYSTEM_PREFIXES))
                                  for dep in dependencies):
        raise RuntimeError(f"Unexpected loader paths after rewriting {image}")


def verify_links(root):
    for path in sorted(root.rglob("*")):
        if path.is_symlink() and not path.resolve(strict=True).is_relative_to(root):
            raise RuntimeError(f"Package symlink escapes the prefix: {path}")


def stage_pkg_config(prefix, root):
    destination = root / "lib/pkgconfig"
    destination.mkdir()
    for file in sorted((prefix / "lib/pkgconfig").glob("*.pc")):
        text = file.read_text()
        encoded = re.search(r"^prefix=(/[^\n]+)$", text, flags=re.M)
        text = re.sub(r"^prefix=.*\n", "", text, flags=re.M)
        for original in (str(prefix), encoded[1] if encoded else str(prefix)):
            text = text.replace(original, "${prefix}")
        if "${exec_prefix}" in text and not re.search(r"^exec_prefix=", text, flags=re.M):
            text = "exec_prefix=${prefix}\n" + text
        (destination / file.name).write_text("prefix=${pcfiledir}/../..\n" + text)


def verify_pkg_config(root):
    directory = root / "lib/pkgconfig"
    modules = [path.stem for path in sorted(directory.glob("*.pc"))]
    env = {**os.environ, "PKG_CONFIG_LIBDIR": str(directory), "PKG_CONFIG_PATH": ""}
    flags = subprocess.check_output(
        ["pkg-config", "--cflags", "--libs", *modules], env=env, text=True
    )
    sdk = Path(capture("xcrun", "--sdk", "macosx", "--show-sdk-path").strip())
    for flag in shlex.split(flags):
        if flag.startswith(("-L", "-I")) and not Path(flag[2:]).resolve().is_relative_to(root):
            raise RuntimeError(f"pkg-config exposes an external search path: {flag}")
        if flag.startswith("-l"):
            name = f"lib{flag[2:]}"
            if not any(path.is_file() for path in (
                root / "lib" / f"{name}.dylib", root / "lib" / f"{name}.a",
                sdk / "usr/lib" / f"{name}.tbd",
            )):
                raise RuntimeError(f"pkg-config references an unpackaged library: {flag}")


def stage(prefix, root, with_tests=False):
    shutil.copytree(prefix / "include", root / "include", symlinks=True)
    for name in ("bison", "licenses"):
        shutil.copytree(prefix / "share" / name, root / "share" / name, symlinks=True)
    (root / "lib").mkdir()
    (root / "bin").mkdir()
    for directory in ("lib", "lib64"):
        libraries = (prefix / directory).glob("*")
        for library in sorted(path for path in libraries if path.suffix in (".dylib", ".a")):
            installed = root / "lib" / library.name
            if installed.exists() or installed.is_symlink():
                if digest(library.resolve()) != digest(installed.resolve()):
                    raise RuntimeError(f"Conflicting dylib {library}")
                continue
            if library.is_symlink():
                installed.symlink_to(Path(library.readlink()).name)
            else:
                shutil.copyfile(library, installed)
                if library.suffix == ".dylib":
                    installed.chmod(0o755)
    stage_pkg_config(prefix, root)

    for name in TOOLS:
        tool = root / "bin" / (f"{name}.real" if name == "bison" else name)
        source = tool.name if with_tests else name
        shutil.copyfile(prefix / "bin" / source, tool)
        tool.chmod(0o755)
    bison = root / "bin/bison"
    bison.write_text(
        '#!/bin/sh\n'
        'set -eu\n'
        'bin_dir="$(cd -P "$(dirname "$0")" && pwd)"\n'
        'export BISON_PKGDATADIR="${BISON_PKGDATADIR:-$bin_dir/../share/bison}"\n'
        'exec "$bin_dir/bison.real" "$@"\n'
    )
    bison.chmod(0o755)

    # Audit every included Mach-O, even libraries outside the four daemons' link graph.
    verify_links(root)
    verify_pkg_config(root)
    for image in sorted((root / "lib").glob("*.dylib")):
        if not image.is_symlink():
            make_relative(root, image)
    for library in sorted((root / "lib").glob("*.a")):
        if not library.is_symlink():
            native_arm64(library)
    for name in TOOLS:
        make_relative(root, root / "bin" / (f"{name}.real" if name == "bison" else name))

    lock = HERE / "sources.json"
    shutil.copyfile(lock, root / "sources.json")
    profile = "Profile: Nebula NG daemon SDK (Arrow filesystem, IPC and CSV)\n"
    if with_tests:
        test_lock = HERE / "test-sources.json"
        shutil.copyfile(test_lock, root / test_lock.name)
        profile = (
            "Profile: Nebula NG SDK\n"
            f"Test source lock SHA-256: {digest(test_lock)}\n"
        )
    (root / "version-info").write_text(
        f"Package: Nebula Third Party\nVersion: {package_version()}\n"
        f"Platform: macOS arm64\nDeployment target: {DEPLOYMENT_TARGET}\n"
        f"Recipe baseline: {BASE_RECIPE}\n"
        f"Source lock SHA-256: {digest(lock)}\n"
        f"Compiler: {capture('/usr/bin/clang', '--version').splitlines()[0]}\n"
        f"SDK: {capture('xcrun', '--sdk', 'macosx', '--show-sdk-version').strip()}\n"
        f"{profile}"
    )


def archive(path, root_name, entries):
    partial = path.with_suffix(path.suffix + ".partial")
    with partial.open("wb") as file, gzip.GzipFile(
        filename="", mode="wb", fileobj=file, compresslevel=6, mtime=EPOCH
    ) as compressed, tarfile.open(fileobj=compressed, mode="w", format=tarfile.PAX_FORMAT) as tar:
        root = tarfile.TarInfo(root_name)
        root.type = tarfile.DIRTYPE
        root.mode = 0o755
        root.mtime = EPOCH
        tar.addfile(root)
        for name, source in sorted(entries):
            info = tar.gettarinfo(str(source), f"{root_name}/{name}")
            info.uid = info.gid = 0
            info.uname = info.gname = ""
            info.mtime = EPOCH
            info.mode = 0o755 if info.isdir() or source.stat().st_mode & 0o111 else 0o644
            info.pax_headers.clear()
            if info.isreg():
                with source.open("rb") as stream:
                    tar.addfile(info, stream)
            else:
                tar.addfile(info)
    partial.replace(path)
    path.with_suffix(path.suffix + ".sha256").write_text(f"{digest(path)}  {path.name}\n")
    print(path, flush=True)


def source_entries(cache):
    lock = json.loads((HERE / "sources.json").read_text())
    lock.update(json.loads((HERE / "test-sources.json").read_text()))
    recipes = {".env", "README.md", "macos/build.py", "macos/build-test-sdk.py",
               "macos/package.py", "macos/sources.json", "macos/test-sources.json"}
    for entry in lock.values():
        recipes.update(entry.get("patches", ()))
        source = (cache / entry["archive"]).resolve(strict=True)
        if digest(source) != entry["sha256"]:
            raise RuntimeError(f"Source checksum mismatch: {source}")
        yield f"archives/{entry['archive']}", source
    for recipe in recipes:
        yield recipe, REPO / recipe


def arrow_bundled_sources(work):
    # ExternalProject keeps the source tarball and extracted tree beside its build stamps.
    for stamp in sorted((work / "build/arrow").rglob("*_ep-stamp")):
        project = stamp.name.removesuffix("-stamp")
        source = stamp.with_name(project)
        downloads = sorted(stamp.parent.glob("*.tar.gz"))
        if not (stamp / f"{project}-done").is_file() or len(downloads) != 1:
            raise RuntimeError(f"Incomplete Arrow dependency build: {project}")
        yield project.removesuffix("_ep"), source, downloads[0]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--work-dir", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    parser.add_argument("--source-cache", type=Path)
    args = parser.parse_args()
    work = args.work_dir.resolve()
    cache = args.source_cache.resolve() if args.source_cache else work / "archives"
    output = args.output_dir.resolve()
    output.mkdir(parents=True, exist_ok=True)
    root_name = f"vesoft-third-party-{package_version()}-macos-arm64"
    if not (work / "base-sdk").is_file() or not all(
        (work / "done" / name).is_file() for name in TEST_DEPENDENCIES
    ):
        parser.error("--work-dir must contain a completed build-test-sdk.py build.")
    bundled = list(arrow_bundled_sources(work))
    if not bundled:
        parser.error("Expected Arrow's bundled dependencies in the SDK build.")
    sources = list(source_entries(cache))
    with tempfile.TemporaryDirectory(prefix="package-", dir=work) as staging:
        stage_root = Path(staging)
        stage(work / "prefix", stage_root, with_tests=True)
        notices = stage_root / "share/licenses"
        for name, source, download in bundled:
            copy_notices(source, notices / "arrow/bundled" / name)
            sources.append((f"arrow-bundled/{name}/{download.name}", download))
        for source in sorted((work / "src/duckdb/third_party").iterdir()):
            if source.is_dir():
                copy_notices(source, notices / "duckdb/bundled" / source.name)
        archive(output / f"{root_name}.tar.gz", root_name,
                ((str(item.relative_to(stage_root)), item) for item in stage_root.rglob("*")))
    archive(output / f"{root_name}-sources.tar.gz", f"{root_name}-sources", sources)


if __name__ == "__main__":
    main()
