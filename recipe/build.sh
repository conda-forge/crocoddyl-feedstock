#!/bin/sh

mkdir build
cd build

export BUILD_SP_DIR=$( $PYTHON -c "import pinocchio; print (pinocchio.__file__.split('/pinocchio/__init__.py')[0])")
export TARGET_SP_DIR=$SP_DIR

if [[ $CONDA_BUILD_CROSS_COMPILATION == 1 ]]; then
  echo "Copying files from $BUILD_SP_DIR to $TARGET_SP_DIR"
  cp -r $BUILD_SP_DIR/pinocchio $TARGET_SP_DIR/pinocchio
  cp -r $BUILD_SP_DIR/numpy $TARGET_SP_DIR/numpy
fi

cmake ${CMAKE_ARGS} .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING=OFF \
      -DBUILD_BENCHMARK=OFF \
      -DBUILD_EXAMPLES=OFF \
      -DBUILD_WITH_MULTITHREADS=ON \
      -DCMAKE_CXX_STANDARD=14 \
      -DCMAKE_CROSSCOMPILING=$CONDA_BUILD_CROSS_COMPILATION \
      -DCMAKE_CROSSCOMPILING_EMULATOR=$CONDA_BUILD_CROSS_COMPILATION \
      -DPYTHON_EXECUTABLE=$PYTHON \
      -DOpenMP_ROOT=$CONDA_PREFIX

make -j${CPU_COUNT}
make install

if [[ $CONDA_BUILD_CROSS_COMPILATION == 1 ]]; then
  echo $BUILD_PREFIX
  echo $PREFIX
  sed -i.back 's|'"$BUILD_PREFIX"'|'"$PREFIX"'|g' $PREFIX/lib/cmake/crocoddyl/crocoddylTargets.cmake
  rm $PREFIX/lib/cmake/crocoddyl/crocoddylTargets.cmake.back
fi
