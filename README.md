# Nebula Third Party
Project to build third-party dependencies of Nebula Graph


# How to build

## Build requirements
To build this project, you must have:
  * make
  * cmake 3.10+
  * GCC 6.0+ or Clang7.0+


## Standalone

```sh
# Clone the repo
$ git clone https://github.com/vesoft-inc/nebula-third-party.git

# Change to the source directory
$ cd nebula-third-party

# Create a directory to build in a out-of-source way
$ mkdir -p build && cd build

# Set the prefix of installation
$ NEBULA_THIRDPARTY_ROOT=/prefix/to/installation

# Configure the building
$ cmake -DCMAKE_INSTALL_PREFIX=$NEBULA_THIRDPARTY_ROOT ..

# Build and install
$ make

# That's it!
# After installation, the hierarchy of the directory $NEBULA_THIRDPARTY_ROOT is like
$ ls $NEBULA_THIRDPARTY_ROOT
bin  etc  include  lib  lib64  man  sbin  share  var
```

You could tell cmake to use a non-default compiler by:
```sh
$ cmake -DCMAKE_CXX_COMPILER=/path/to/g++ -DCMAKE_C_COMPILER=/path/to/gcc ...
```

Of course, you could just _prepend_ the path to your compiler's location to `PATH`:
```sh
$ PATH=/path/to/gcc/bin:$PATH cmake ...
```


## As an external project

Please refer to [samples/CMakeLists.txt](samples/CMakeLists.txt) for an example.
