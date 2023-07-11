OPT_LEVEL1="O0" # Optimization level for clang
OPT_LEVEL2="00" # Optimization level for LLTFI

rm -rf ./llfi*
fname=$1

echo "Compiling..."
clang++ -w -emit-llvm -fno-unroll-loops -lstdc++ -fno-use-cxa-atexit -$OPT_LEVEL1 -S *.cc
echo "Calling llvm-link..."
$HOME/llvm-project/build/bin/llvm-link -o "$fname.ll" -S *.ll

opt "$fname.ll" -$OPT_LEVEL1 --disable-inlining -time-passes -S -o "$fname.ll"

echo "Instrumenting..."
python3 $LLFI_BUILD_ROOT/bin/instrument.py -lstdc++ --readable "$fname.ll"

shift
echo "Profiling..."
python3 $LLFI_BUILD_ROOT/bin/profile.py ./llfi/"$fname-profiling.exe" $OPT_LEVEL2 $@

echo "Injecting faults..."
python3 $LLFI_BUILD_ROOT/bin/injectfault.py ./llfi/"$fname-faultinjection.exe" $OPT_LEVEL2 $@

echo "All done!" 
