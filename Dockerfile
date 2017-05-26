FROM base/archlinux:latest
RUN pacman -Sy --noconfirm python python2 base-devel mingw-w64 wget 
RUN mkdir /build
WORKDIR /build
RUN wget http://download.qt.io/official_releases/qt/5.8/5.8.0/single/qt-everywhere-opensource-src-5.8.0.tar.gz && \
    bsdtar -xf qt-everywhere-opensource-src-5.8.0.tar.gz
WORKDIR /build/qt-everywhere-opensource-src-5.8.0
# mingw includes are case sensitive.
RUN sed -i 's,#  include <UIViewSettingsInterop.h>,#  include <uiviewsettingsinterop.h>,' qtbase/src/plugins/platforms/windows/qwin10helpers.cpp
# This build will fail somewhere where it tries to build windows code using the 
# host compiler. Just ignore that error and trudge on. Enough of QT is built
# that we can build our updater.
RUN ./configure -release -static -prefix /build/qt-static -qt-zlib -qt-libjpeg -qt-libpng -qt-freetype -qt-pcre -qt-harfbuzz -opengl desktop -opensource -confirm-license -no-qml-debug -no-compile-examples   -skip qtwebkit -skip qtwebkit-examples -no-icu -xplatform win32-g++ -device-option CROSS_COMPILE=i686-w64-mingw32- && \
    make -j$(nproc) -k install || true
WORKDIR /
RUN rm -rf /build/qt-everywhere-opensource-src-5.8.0* 

