# How to Build?

The GNU C Library cannot be compiled in the source directory.  You must build it in a separate build directory.  For example, if you have unpacked the GNU C Library sources in `/src/gnu/glibc-VERSION`, create a directory `/src/gnu/glibc-build` to put the object files in.

## Steps
The steps to build Glibc for Occlum are as follows:

1. Install the required modules
```
sudo apt-get update
sudo apt-get install gawk bison -y
```

2. Configure, build and install Glibc
```
cd <glibc-build-folder>
unset LD_LIBRARY_PATH
CFLAGS="-O2 -g" <glibc-VERSION>/configure \
--prefix=<glibc-install-folder> --with-tls --without-selinux --enable-stack-protector=strong --disable-nscd
make
make install
```
When completed, the resulting Glibc can be found in `<glibc-install-folder>` directory.
