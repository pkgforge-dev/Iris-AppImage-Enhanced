#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm cmake sdl3

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano libdecor-mini

echo "Building stable version of Iris..."
echo "---------------------------------------------------------------"
REPO="https://github.com/allkern/iris"
VERSION="$(curl -s https://api.github.com/repos/allkern/iris/tags | grep '"name"' | grep -v 'pre' | head -1 | cut -d '"' -f 4)"
git clone --branch "$VERSION" --recursive --depth 1 "$REPO" ./iris
echo "$VERSION" > ~/version

echo "Patching SDL version-script CMake check (upstream commit 9228b91)..."
echo "---------------------------------------------------------------"
sed -i 's|-Wl,--version-script=${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/dummy.sym|LINKER:SHELL:--version-script \\"${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/dummy.sym\\"|' iris/deps/SDL/cmake/macros.cmake
sed -i 's|-Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/src/dynapi/SDL_dynapi.sym|LINKER:SHELL:--version-script \\"${CMAKE_CURRENT_SOURCE_DIR}/src/dynapi/SDL_dynapi.sym\\"|' iris/deps/SDL/CMakeLists.txt

echo "Disabling IPO/LTO (the .incbin resources cannot be found during LTO fat-linking)..."
echo "---------------------------------------------------------------"
sed -i 's|check_ipo_supported(RESULT LTO_SUPPORTED OUTPUT LTO_ERROR)|set(LTO_SUPPORTED FALSE)|' iris/CMakeLists.txt

mkdir -p ./AppDir/bin
cmake -S ./iris -B ./iris/build -DCMAKE_BUILD_TYPE=Release
cmake --build ./iris/build -j$(nproc)
mv -v ./iris/build/iris ./AppDir/bin
