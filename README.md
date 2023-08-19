# Clang Compiler build scripts

The repository is part of the [Compiler Explorer](https://godbolt.org/) project. It builds
the docker images used to build the various clang compilers used on the site.

## To Test

This assumes you have set up your user account to be able to run
`docker` [without being root](https://docs.docker.com/engine/security/rootless/);
if you haven't done so, you'll need to prefix these commands with `sudo`.

* `docker build --build-arg image=22.04 -t clangbuilder .`
* `docker run clangbuilder ./build.sh trunk`

### Alternative to run (for better debugging)

* `docker run -t -i clangbuilder bash`
* `./build.sh trunk`
