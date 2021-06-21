#!/bin/tcsh
# you also need to change tb_conv.v to suit your mode 
set MODE="8x8t"

# Compile cnn kernels
# echo "\033[32m[ConvKernel: ] Start to build whole systems \033[0m"
cd ../src/
if (-e ./build) then
    echo "\033[32m[ConvKernel: ] Build already exists, try to override it \033[0m"
    # rm -rf ./build
else
    echo "\033[32m[ConvKernel: ] Build whole systems under ./build \033[0m"
endif

mkdir build 
cd build
cp ../Makefile ./
make comp -s

echo "\033[32m[ConvKernel: ] Copy benchmarks, under mode: ${MODE} \033[0m"
cp ../../data/${MODE}/ifm.txt ./
cp ../../data/${MODE}/weight.txt ./
cp ../../data/${MODE}/ofm.txt ./

echo "\033[32m[ConvKernel: ] Start to run simulation \033[0m"
echo "\033[32m[ConvKernel: ] Result writes to ./build/conv_acc_out.txt \033[0m"
# run simulation
make sim 

cd ../../script/
python ./compare.py

