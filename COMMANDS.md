# Command Reference

Like `git`, the `shenv` command delegates to subcommands based on its
first argument.

The most common subcommands are:

* [`shenv commands`](#shenv-commands)
* [`shenv local`](#shenv-local)
* [`shenv global`](#shenv-global)
* [`shenv shell`](#shenv-shell)
* [`shenv install`](#shenv-install)
* [`shenv uninstall`](#shenv-uninstall)
* [`shenv rehash`](#shenv-rehash)
* [`shenv version`](#shenv-version)
* [`shenv versions`](#shenv-versions)
* [`shenv which`](#shenv-which)
* [`shenv whence`](#shenv-whence)


## `shenv commands`

Lists all available shenv commands.


## `shenv local`

Sets a local application-specific shell version by writing the version
name to a `.shell-version` file in the current directory. This version
overrides the global version, and can be overridden itself by setting
the `SHENV_VERSION` environment variable or with the `shenv shell`
command.

    $ shenv local 2.7.6

When run without a version number, `shenv local` reports the currently
configured local version. You can also unset the local version:

    $ shenv local --unset

Previous versions of shenv stored local version specifications in a
file named `.shenv-version`. For backwards compatibility, shenv will
read a local version specified in an `.shenv-version` file, but a
`.shell-version` file in the same directory will take precedence.


### `shenv local` (advanced)

You can specify multiple versions as local shell at once.

Let's say if you have two versions of 2.7.6 and 3.3.3. If you prefer 2.7.6 over 3.3.3,

    $ shenv local bash-4.4.12 bash-4.3.0
    $ shenv versions
      system
    * bash-4.4.12 (set by /Users/yyuu/path/to/project/.shell-version)
    * bash-4.3.0 (set by /Users/yyuu/path/to/project/.shell-version)
    $ bash --version
    Bash 4.4.12
    $ bash4.3 --version
    Bash 4.3.0
    $ bash4.4 --version
    Bash 4.4.12

## `shenv global`

Sets the global version of shell to be used in all shells by writing
the version name to the `~/.shenv/version` file. This version can be
overridden by an application-specific `.shell-version` file, or by
setting the `SHENV_VERSION` environment variable.

    $ shenv global bash-4.4.12

The special version name `system` tells shenv to use the system shell
(detected by searching your `$PATH`).

When run without a version number, `shenv global` reports the
currently configured global version.


### `shenv global` (advanced)

You can specify multiple versions as global shell at once.

Let's say if you have two versions of Bash 4.4.12 and Bash 4.3.0. If you prefer 4.4.12 over 4.3.0,

    $ shenv global bash-4.4.12 bash-4.3.0
    $ shenv versions
      system
    * bash-4.4.12 (set by /Users/yyuu/.shenv/version)
    * bash-4.3.0 (set by /Users/yyuu/.shenv/version)
    $ bash --version
    Bash 4.4.12
    $ bash4.3 --version
    Bash 4.3.0
    $ bash4.4 --version
    Bash 4.4.12


## `shenv shell`

Sets a shell-specific shell version by setting the `SHENV_VERSION`
environment variable in your shell. This version overrides
application-specific versions and the global version.

    $ shenv shell pypy-2.2.1

When run without a version number, `shenv shell` reports the current
value of `SHENV_VERSION`. You can also unset the shell version:

    $ shenv shell --unset

Note that you'll need shenv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`SHENV_VERSION` variable yourself:

    $ export SHENV_VERSION=pypy-2.2.1


### `shenv shell` (advanced)

You can specify multiple versions via `SHENV_VERSION` at once.

Let's say if you have two versions of Bash 4.4.12 and Bash 4.3.0. If you prefer 4.4.12 over 4.3.0,

    $ shenv shell bash-4.4.12 bash-4.3.0
    $ shenv versions
      system
    * bash-4.4.12 (set by SHENV_VERSION environment variable)
    * bash-4.3.0 (set by SHENV_VERSION environment variable)
    $ bash --version
    Bash 4.4.12
    $ bash4.3 --version
    Bash 4.3.0
    $ bash4.4 --version
    Bash 4.4.12


## `shenv install`

Install a shell version (using [`shell-build`](https://github.com/shenv/shenv/tree/master/plugins/shell-build)).

    Usage: shenv install [-f] [-kvp] <version>
           shenv install [-f] [-kvp] <definition-file>
           shenv install -l|--list

      -l/--list             List all available versions
      -f/--force            Install even if the version appears to be installed already
      -s/--skip-existing    Skip the installation if the version appears to be installed already

      shell-build options:

      -k/--keep        Keep source tree in $SHENV_BUILD_ROOT after installation
                       (defaults to $SHENV_ROOT/sources)
      -v/--verbose     Verbose mode: print compilation status to stdout
      -p/--patch       Apply a patch from stdin before building
      -g/--debug       Build a debug version

To list the all available versions of shell, including Anaconda, Jython, pypy, and stackless, use:

    $ shenv install --list

Then install the desired versions:

    $ shenv install 2.7.6
    $ shenv install 2.6.8
    $ shenv versions
      system
      2.6.8
    * 2.7.6 (set by /home/yyuu/.shenv/version)

## `shenv uninstall`

Uninstall a specific shell version.

    Usage: shenv uninstall [-f|--force] <version>

       -f  Attempt to remove the specified version without prompting
           for confirmation. If the version does not exist, do not
           display an error message.


## `shenv rehash`

Installs shims for all shell binaries known to shenv (i.e.,
`~/.shenv/versions/*/bin/*`). Run this command after you install a new
version of shell, or install a package that provides binaries.

    $ shenv rehash


## `shenv version`

Displays the currently active shell version, along with information on
how it was set.

    $ shenv version
    bash-4.4.12 (set by /home/yyuu/.shenv/version)


## `shenv versions`

Lists all shell versions known to shenv, and shows an asterisk next to
the currently active version.

    $ shenv versions
      bash-4.2.0
      bash-4.3.0
    * bash-4.4.12 (set by /home/yyuu/.shenv/version)
      bash-4.4.0
      fish-2.5.3
      zsh-2.2.1


## `shenv which`

Displays the full path to the executable that shenv will invoke when
you run the given command.

    $ shenv which bash4.3
    /home/yyuu/.shenv/versions/4.3.0/bin/bash4.3


## `shenv whence`

Lists all shell versions with the given command installed.

    $ shenv whence file
    bash-4.2.0
    bash-4.3.0
    bash-4.4.0
