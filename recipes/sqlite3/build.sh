#!/bin/bash

# Prevent running ldconfig when cross-compiling.
if [[ "${BUILD}" != "${HOST}" ]]; then
  echo "#!/usr/bin/env bash" > ldconfig
  chmod +x ldconfig
  export PATH=${PWD}:$PATH
fi

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/libtool/build-aux/config.* .

export CPPFLAGS="${CPPFLAGS} -DSQLITE_ENABLE_COLUMN_METADATA=1 \
                             -DSQLITE_ENABLE_STAT4 \
                             -DSQLITE_USE_URI=1 \
                             -DSQLITE_ENABLE_UNLOCK_NOTIFY \
                             -DSQLITE_ENABLE_DBSTAT_VTAB=1 \
                             -DSQLITE_SECURE_DELETE \
                             -DSQLITE_MAX_VARIABLE_NUMBER=250000 \
                             -DSQLITE_MAX_EXPR_DEPTH=10000 \
                             -DSQLITE_ENABLE_JSON1 \
                             -DSQLITE_ENABLE_RTREE=1"

if [[ "$target_platform" == "linux-ppc64le" ]]; then
    export PPC64LE="--build=ppc64le-linux"
fi

./configure --prefix=$PREFIX \
            --build=${BUILD} \
            --host=${HOST} \
            --enable-threadsafe \
            --enable-tempstore \
            --enable-shared=yes \
            --disable-static \
            --disable-tcl \
            --enable-readline=no \
            CFLAGS="${CFLAGS} -I${PREFIX}/include" \
            LDFLAGS="${LDFLAGS} -L${PREFIX}/lib" \
            ${PPC64LE}

make -j${CPU_COUNT} ${VERBOSE_AT}
make check
make install

rm -rf $PREFIX/share
