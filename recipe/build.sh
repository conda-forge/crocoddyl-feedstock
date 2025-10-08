#!/bin/sh

mkdir build
cd build

export BUILD_SP_DIR=$( $PYTHON -c "import pinocchio; print (pinocchio.__file__.split('/pinocchio/__init__.py')[0])")
export TARGET_SP_DIR=$SP_DIR

export BUILD_NUMPY_INCLUDE_DIRS=$( $PYTHON -c "import numpy; print (numpy.get_include())")
export TARGET_NUMPY_INCLUDE_DIRS=$SP_DIR/numpy/core/include

echo $BUILD_NUMPY_INCLUDE_DIRS
echo $TARGET_NUMPY_INCLUDE_DIRS

GENERATE_PYTHON_STUBS=1
if [[ $CONDA_BUILD_CROSS_COMPILATION == 1 ]]; then
  echo "Copying files from $BUILD_SP_DIR to $TARGET_SP_DIR"
  cp -r $BUILD_SP_DIR/pinocchio $TARGET_SP_DIR/pinocchio
  cp -r $BUILD_SP_DIR/numpy $TARGET_SP_DIR/numpy  
  GENERATE_PYTHON_STUBS=0
  export Python3_NumPy_INCLUDE_DIR=$TARGET_NUMPY_INCLUDE_DIRS
else
  export Python3_NumPy_INCLUDE_DIR=$BUILD_NUMPY_INCLUDE_DIRS
fi

cmake ${CMAKE_ARGS} .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING=OFF \
      -DBUILD_BENCHMARK=OFF \
      -DBUILD_EXAMPLES=OFF \
      -DCMAKE_CXX_STANDARD=14 \
      -DBUILD_WITH_IPOPT=OFF \
      -DGENERATE_PYTHON_STUBS=$GENERATE_PYTHON_STUBS \
      -DPython3_NumPy_INCLUDE_DIR=$Python3_NumPy_INCLUDE_DIR \
      -DCMAKE_CROSSCOMPILING=$CONDA_BUILD_CROSS_COMPILATION \
      -DCMAKE_CROSSCOMPILING_EMULATOR=$CONDA_BUILD_CROSS_COMPILATION \
      -DPYTHON_EXECUTABLE=$PYTHON

make
make install

if [[ $CONDA_BUILD_CROSS_COMPILATION == 1 ]]; then
  echo $BUILD_PREFIX
  echo $PREFIX
  sed -i.back 's|'"$BUILD_PREFIX"'|'"$PREFIX"'|g' $PREFIX/lib/cmake/crocoddyl/crocoddylTargets.cmake
  rm $PREFIX/lib/cmake/crocoddyl/crocoddylTargets.cmake.back
fi
