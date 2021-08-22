#!/bin/sh

mkdir build
cd build

if [[ $CONDA_BUILD_CROSS_COMPILATION == 1 ]]; then
  export BUILD_NUMPY_INCLUDE_DIRS=$( $PYTHON -c "import numpy; print (numpy.get_include())")
  export TARGET_NUMPY_INCLUDE_DIRS=$SP_DIR/numpy/core/include

  echo "Copying files from $BUILD_NUMPY_INCLUDE_DIRS to $TARGET_NUMPY_INCLUDE_DIRS"
  mkdir -p $TARGET_NUMPY_INCLUDE_DIRS
  cp -r $BUILD_NUMPY_INCLUDE_DIRS/numpy $TARGET_NUMPY_INCLUDE_DIRS
fi

cmake ${CMAKE_ARGS} .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_UNIT_TESTS=OFF \
      -DBUILD_BENCHMARK=OFF \
      -DBUILD_EXAMPLES=OFF \
      -DPYTHON_EXECUTABLE=$PYTHON

make -j${CPU_COUNT}
make install

if [[ $CONDA_BUILD_CROSS_COMPILATION == 1 ]]; then
  echo $BUILD_PREFIX
  echo $PREFIX
  sed -i.back 's|'"$BUILD_PREFIX"'|'"$PREFIX"'|g' $PREFIX/lib/cmake/crocoddyl/crocoddylTargets.cmake
  rm $PREFIX/lib/cmake/crocoddyl/crocoddylTargets.cmake.back
fi
