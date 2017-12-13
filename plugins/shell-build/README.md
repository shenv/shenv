# shell-build

shell-build is a [shenv](https://github.com/shenv/shenv) plugin that
provides a `shenv install` command to compile and install different versions
of shell on UNIX-like systems.

You can also use shell-build without shenv in environments where you need
precise control over shell version installation.

See the [list of releases](https://github.com/shenv/shenv/releases)
for changes in each version.


## Installation

### Installing as a shenv plugin (recommended)

You need nothing to do since shell-build is bundled with shenv by
default.

### Installing as a standalone program (advanced)

Installing shell-build as a standalone program will give you access to the
`shell-build` command for precise control over shell version installation. If you
have shenv installed, you will also be able to use the `shenv install` command.

    git clone git://github.com/shenv/shenv.git
    cd shenv/plugins/shell-build
    ./install.sh

This will install shell-build into `/usr/local`. If you do not have write
permission to `/usr/local`, you will need to run `sudo ./install.sh` instead.
You can install to a different prefix by setting the `PREFIX` environment
variable.

To update shell-build after it has been installed, run `git pull` in your cloned
copy of the repository, then re-run the install script.

### Installing with Homebrew (for OS X users)

Mac OS X users can install shell-build with the [Homebrew](http://brew.sh)
package manager. This will give you access to the `shell-build` command. If you
have shenv installed, you will also be able to use the `shenv install` command.

*This is the recommended method of installation if you installed shenv with
Homebrew.*

    brew install shenv

Or, if you would like to install the latest development release:

    brew install --HEAD shenv


## Usage

Before you begin, you should ensure that your build environment has the proper
system dependencies for compiling the wanted shell Version (see our [recommendations](https://github.com/shenv/shenv/wiki#suggested-build-environment)).

### Using `shenv install` with shenv

To install a shell version for use with shenv, run `shenv install` with
exact name of the version you want to install. For example,

    shenv install 2.7.4

shell versions will be installed into a directory of the same name under
`~/.shenv/versions`.

To see a list of all available shell versions, run `shenv install --list`. You
may also tab-complete available shell versions if your shenv installation is
properly configured.

### Using `shell-build` standalone

If you have installed shell-build as a standalone program, you can use the
`shell-build` command to compile and install shell versions into specific
locations.

Run the `shell-build` command with the exact name of the version you want to
install and the full path where you want to install it. For example,

    shell-build 2.7.4 ~/local/shell-2.7.4

To see a list of all available shell versions, run `shell-build --definitions`.

Pass the `-v` or `--verbose` flag to `shell-build` as the first argument to see
what's happening under the hood.

### Custom definitions

Both `shenv install` and `shell-build` accept a path to a custom definition file
in place of a version name. Custom definitions let you develop and install
versions of shell that are not yet supported by shell-build.

See the [shell-build built-in definitions](https://github.com/shenv/shenv/tree/master/plugins/shell-build/share/shell-build) as a starting point for
custom definition files.

[definitions]: https://github.com/shenv/shenv/tree/master/plugins/shell-build/share/shell-build

### Special environment variables

You can set certain environment variables to control the build process.

* `TMPDIR` sets the location where shell-build stores temporary files.
* `SHELL_BUILD_BUILD_PATH` sets the location in which sources are downloaded and
  built. By default, this is a subdirectory of `TMPDIR`.
* `SHELL_BUILD_CACHE_PATH`, if set, specifies a directory to use for caching
  downloaded package files.
* `SHELL_BUILD_MIRROR_URL` overrides the default mirror URL root to one of your
  choosing.
* `SHELL_BUILD_SKIP_MIRROR`, if set, forces shell-build to download packages from
  their original source URLs instead of using a mirror.
* `SHELL_BUILD_ROOT` overrides the default location from where build definitions
  in `share/shell-build/` are looked up.
* `SHELL_BUILD_DEFINITIONS` can be a list of colon-separated paths that get
  additionally searched when looking up build definitions.
* `CC` sets the path to the C compiler.
* `SHELL_CFLAGS` lets you pass additional options to the default `CFLAGS`. Use
  this to override, for instance, the `-O3` option.
* `CONFIGURE_OPTS` lets you pass additional options to `./configure`.
* `MAKE` lets you override the command to use for `make`. Useful for specifying
  GNU make (`gmake`) on some systems.
* `MAKE_OPTS` (or `MAKEOPTS`) lets you pass additional options to `make`.
* `MAKE_INSTALL_OPTS` lets you pass additional options to `make install`.
* `SHELL_CONFIGURE_OPTS` and `SHELL_MAKE_OPTS` and `SHELL_MAKE_INSTALL_OPTS` allow
  you to specify configure and make options for building Cshell. These variables
  will be passed to shell only, not any dependent packages (e.g. libyaml).

### Applying patches to shell before compiling

Both `shenv install` and `shell-build` support the `--patch` (`-p`) flag that
signals that a patch from stdin should be applied to shell, Jython or PyPy
source code before the `./configure` and compilation steps.

Example usage:

```sh
# applying a single patch
$ shenv install --patch 2.7.10 < /path/to/shell.patch

# applying a patch from HTTP
$ shenv install --patch 2.7.10 < <(curl -sSL http://git.io/shell.patch)

# applying multiple patches
$ cat fix1.patch fix2.patch | shenv install --patch 2.7.10
```


### Building with `--enable-shared`

You can build Cshell with `--enable-shared` to install a version with
shared object.

If `--enable-shared` was found in `SHELL_CONFIGURE_OPTS` or `CONFIGURE_OPTS`,
`shell-build` will automatically set `RPATH` to the shenv's prefix directory.
This means you don't have to set `LD_LIBRARY_PATH` or `DYLD_LIBRARY_PATH` for
the version(s) installed with `--enable-shared`.

```sh
$ env SHELL_CONFIGURE_OPTS="--enable-shared" shenv install 2.7.9
```

### Checksum verification

If you have the `shasum`, `openssl`, or `sha256sum` tool installed, shell-build will
automatically verify the SHA2 checksum of each downloaded package before
installing it.

Checksums are optional and specified as anchors on the package URL in each
definition. (All bundled definitions include checksums.)

### Package download mirrors

shell-build will first attempt to download package files from a mirror hosted on
GitHub Pages. If a package is not available on the mirror, if the mirror
is down, or if the download is corrupt, shell-build will fall back to the
official URL specified in the definition file.

You can point shell-build to another mirror by specifying the
`SHELL_BUILD_MIRROR_URL` environment variable--useful if you'd like to run your
own local mirror, for example. Package mirror URLs are constructed by joining
this variable with the SHA2 checksum of the package file.

If you don't have an SHA2 program installed, shell-build will skip the download
mirror and use official URLs instead. You can force shell-build to bypass the
mirror by setting the `SHELL_BUILD_SKIP_MIRROR` environment variable.

The official shell-build download mirror is provided by
[GitHub Pages](http://pyenv.github.io/shells/).

### Package download caching

You can instruct shell-build to keep a local cache of downloaded package files
by setting the `SHELL_BUILD_CACHE_PATH` environment variable. When set, package
files will be kept in this directory after the first successful download and
reused by subsequent invocations of `shell-build` and `shenv install`.

The `shenv install` command defaults this path to `~/.shenv/cache`, so in most
cases you can enable download caching simply by creating that directory.

### Keeping the build directory after installation

Both `shell-build` and `shenv install` accept the `-k` or `--keep` flag, which
tells shell-build to keep the downloaded source after installation. This can be
useful if you need to use `gdb` and `memprof` with shell.

Source code will be kept in a parallel directory tree `~/.shenv/sources` when
using `--keep` with the `shenv install` command. You should specify the
location of the source code with the `SHELL_BUILD_BUILD_PATH` environment
variable when using `--keep` with `shell-build`.


## Getting Help

Please see the [shenv wiki](https://github.com/shenv/shenv/wiki) for solutions to common problems.

[wiki]: https://github.com/shenv/shenv/wiki

If you can't find an answer on the wiki, open an issue on the [issue
tracker](https://github.com/shenv/shenv/issues). Be sure to include
the full build log for build failures.
