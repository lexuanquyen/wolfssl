#!/bin/sh

wolf_riot_setup () {
#copy the test sources here
cp ../../wolfcrypt/benchmark/benchmark.c ./

cp ../../wolfcrypt/src/*.c ./

cp ../../src/*.c ./

}

wolf_riot_cleanup () {
    rm ./*.c
    #leave this line in for testing. Comment it out when you want to build
    # a .elf for flashing to a device
    make clean &> /dev/null
}
trap wolf_riot_cleanup INT TERM

BACKUPCFLAGS=${CFLAGS}
export CFLAGS="${CFLAGS} -DWOLFSSL_RIOT_OS"

# copy the necessary files to this directory
wolf_riot_setup

# build the test
make &> /dev/null
RESULT=$?
 [ $RESULT != 0 ] && echo "Make FAILED: running verbose make" &&
                     make
if [ $RESULT != 0 ];
then
    wolf_riot_cleanup && echo "cleanup done" && exit 2
fi

# run the test
./bin/native/wolfbenchmark.elf

# confirm success or failure
export CFLAGS="${BACKUPCFLAGS}"
RESULT=$?
 [ $RESULT != 0 ] && echo "TEST FAILED"  && wolf_riot_cleanup &&
                     echo "cleanup done" && exit 2

echo "TEST PASSED!"

# cleanup. All changes made should be to the files in:
# <wolfssl-root>/src
# <wolfssl-root>/wolfcrypt/src
# or other. Never make changes to the files copied here as they are only
# temporary. Once changes are made, to test them just run this script again.
wolf_riot_cleanup 0


