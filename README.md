# Clang Compiler build scripts

The repository is part of the [Compiler Explorer](https://godbolt.org/) project. It builds
the docker images used to build the various clang compilers used on the site.

## To Test

* `sudo docker build -t clangbuilder .`
* `sudo docker run clangbuilder ./build.sh trunk`

### Alternative to run (for better debugging)

* `sudo docker run -t -i clangbuilder bash`
* `./build.sh trunk`
