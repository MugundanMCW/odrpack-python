#!/bin/bash
set -xe

# ARM64: compilers (CC/CXX/FC) and OpenBLAS are already set up by
# cibw-scripts/setup_windows_arm64.ps1, so there is nothing to install here.
if [[ -n "${ODRPACK_WIN_ARM64:-}" ]]; then
    clang-cl --version
    flang-new --version
    pkg-config --modversion openblas
    exit 0
fi

# x86-64: install OpenBLAS via MSYS2/MinGW.

# Verify active compiler locations
which gcc
which gfortran

# Update pacman database and upgrade system packages
PATH="/c/msys64/usr/bin:$PATH"
pacman -Sy --noconfirm
pacman -Suu --noconfirm

# Install OpenBLAS
pacman -S --noconfirm mingw-w64-x86_64-openblas

ls -l /c/msys64/mingw64/lib/pkgconfig/
ls -l /c/msys64/mingw64/lib/libopenblas.*
ls -l /c/msys64/mingw64/bin

# Copy OpenBLAS files to mingw64 (where the active compiler toolchain is)
# Without this, some dlls come from c/msys64/mingw64 and others from c/msys64/ resulting in
# a runtime failure
mkdir -p /c/mingw64/lib/pkgconfig
cp /c/msys64/mingw64/lib/pkgconfig/openblas.pc /c/mingw64/lib/pkgconfig/
cp /c/msys64/mingw64/bin/libopenblas.dll /c/mingw64/bin/
cp /c/msys64/mingw64/lib/libopenblas.*   /c/mingw64/lib/
cp -r /c/msys64/mingw64/include/openblas    /c/mingw64/include

# Verify OpenBLAS detection
pkg-config --modversion openblas
