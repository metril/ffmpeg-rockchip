# Native compilation on ARM/ARM64 host

# Build MPP
mkdir -p ~/dev && cd ~/dev
git clone -b jellyfin-mpp --depth=1 https://github.com/nyanmisaka/mpp.git rkmpp
pushd rkmpp
mkdir rkmpp_build
pushd rkmpp_build
cmake \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TEST=OFF \
    ..
make -j $(nproc)
make install


# Build RGA
mkdir -p ~/dev && cd ~/dev
git clone -b jellyfin-rga --depth=1 https://github.com/nyanmisaka/rk-mirrors.git rkrga
meson setup rkrga rkrga_build \
    --prefix=/usr \
    --libdir=lib \
    --buildtype=release \
    --default-library=shared \
    -Dcpp_args=-fpermissive \
    -Dlibdrm=false \
    -Dlibrga_demo=false
meson configure rkrga_build
ninja -C rkrga_build install


# Build the minimal FFmpeg (You can customize the configure and install prefix)
mkdir -p ~/dev && cd ~/dev
git clone --depth=1 https://github.com/nyanmisaka/ffmpeg-rockchip.git ffmpeg
cd ffmpeg
./configure --prefix=/usr --enable-gpl --enable-version3 --enable-libdrm --enable-rkmpp --enable-rkrga --enable-libfreetype --enable-libharfbuzz
make -j $(nproc)

# Try the compiled FFmpeg without installation
./ffmpeg -decoders | grep rkmpp
./ffmpeg -encoders | grep rkmpp
./ffmpeg -filters | grep rkrga

# Install FFmpeg to the prefix path
make install

cd ~/

rm -rf ~/dev
