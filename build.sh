#!/bin/bash

# Setting up build env
sudo yum install -y https://centos7.iuscommunity.org/ius-release.rpm
sudo yum update -y
sudo yum install -y git cmake gcc-c++ gcc python3 python37 python3-libs python3-devel python3-pip chrpath
mkdir -p lambda-package/cv2 build/numpy

python3.7 -m venv venv
. venv/bin/activate

# Build numpy
pip install --install-option="--prefix=$PWD/build/numpy" numpy
cp -rf build/numpy/lib64/python3.7/site-packages/numpy lambda-package/numpy

# Build OpenCV 3.4
(
	NUMPY=$PWD/lambda-package/numpy/core/include
	cd build
	git clone https://github.com/Itseez/opencv.git
	cd opencv
	git checkout 3.4.5
	mkdir build && cd build
	cmake \
		-D CMAKE_BUILD_TYPE=RELEASE \
		-D WITH_TBB=ON \
		-D WITH_IPP=ON \
		-D WITH_V4L=ON \
		-D ENABLE_AVX=ON \
		-D ENABLE_SSSE3=ON \
		-D ENABLE_SSE41=ON \
		-D ENABLE_SSE42=ON \
		-D ENABLE_POPCNT=ON \
		-D ENABLE_FAST_MATH=ON \
		-D BUILD_EXAMPLES=OFF \
		-D BUILD_TESTS=OFF \
		-D BUILD_PERF_TESTS=OFF \
		-D PYTHON3_NUMPY_INCLUDE_DIRS="$NUMPY" \
	..
	make -j`cat /proc/cpuinfo | grep MHz | wc -l`
)
cp build/opencv/build/lib/python3/cv2.cpython-37m-x86_64-linux-gnu.so lambda-package/cv2/__init__.so
cp -L build/opencv/build/lib/*.so.3.4 lambda-package/cv2
strip --strip-all lambda-package/cv2/*
chrpath -r '$ORIGIN' lambda-package/cv2/__init__.so
touch lambda-package/cv2/__init__.py

# Copy template function and zip package
cp template.py lambda-package/lambda_function.py
cd lambda-package
zip -r ../lambda-package.zip *
