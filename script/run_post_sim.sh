#!/bin/tcsh
# you also need to change tb_conv.v to suit your mode 
set MODE="8x8t"

# Compile cnn kernels
# echo "\033[32m[ConvKernel: ] Start to build whole systems \033[0m"
cd ../src/
if (-e ./sbuild) then
    echo "\033[32m[ConvKernel: ] Build already exists, remove it \033[0m"
    rm -rf ./sbuild
else
    echo "\033[32m[ConvKernel: ] Build whole systems under ./build \033[0m"
endif

mkdir sbuild 
cd sbuild
cp ../Makefile.synth ./Makefile
make comp -s

echo "\033[32m[ConvKernel: ] Copy benchmarks, under mode: ${MODE} \033[0m"
cp ../../data/${MODE}/ifm.txt ./
cp ../../data/${MODE}/weight.txt ./
cp ../../data/${MODE}/ofm.txt ./

echo "\033[32m[ConvKernel: ] Start to run simulation \033[0m"
echo "\033[32m[ConvKernel: ] Result write to ./build/conv_acc_out.txt \033[0m"
# run simulation
make sim 

cd ../../script/
python ./compare_syn.py
