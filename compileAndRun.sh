OPT_LEVEL="O0" # Optimization level for clang
NUM_RUNS="10" # Number of runs for LLTFI

rm -rf ./llfi*
fname=$1

echo "Compiling..."
clang++ -w -emit-llvm -fno-unroll-loops -lstdc++ -fno-use-cxa-atexit -$OPT_LEVEL -S *.cc
echo "Calling llvm-link..."
$HOME/llvm-project/build/bin/llvm-link -o "$fname.ll" -S *.ll

opt "$fname.ll" -$OPT_LEVEL --disable-preinline -time-passes -S -o "$fname.ll"

echo "Instrumenting..."
python3 $LLFI_BUILD_ROOT/bin/instrument.py -lstdc++ --readable "$fname.ll"

shift
echo "Profiling..."
python3 $LLFI_BUILD_ROOT/bin/profile.py ./llfi/"$fname-profiling.exe" $NUM_RUNS $@

echo "Injecting faults..."
python3 $LLFI_BUILD_ROOT/bin/injectfault.py ./llfi/"$fname-faultinjection.exe" $NUM_RUNS $@

echo "All done!" 
