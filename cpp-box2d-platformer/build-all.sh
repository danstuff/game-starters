#!/usr/bin/env bash

# Use this to build theCrunchGame on any system with a bash shell
rm -rf build
mkdir build
cd build
cmake ..
cmake --build .
