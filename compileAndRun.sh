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
$LLFI_BUILD_ROOT/bin/instrument -lstdc++ --readable "$fname.ll"

shift
echo "Profiling..."
$LLFI_BUILD_ROOT/bin/profile ./llfi/"$fname-profiling.exe" $NUM_RUNS $@

echo "Injecting faults..."
$LLFI_BUILD_ROOT/bin/injectfault ./llfi/"$fname-faultinjection.exe" $NUM_RUNS $@

echo "All done!" 
