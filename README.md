# Simple Shell Version Management: shenv

[![Join the chat at https://gitter.im/Pawamoy/shenv](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Pawamoy/shenv?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![Build Status](https://travis-ci.org/shenv/shenv.svg?branch=master)](https://travis-ci.org/shenv/shenv)

shenv lets you easily switch between multiple versions of shell. It's
simple, unobtrusive, and follows the UNIX tradition of single-purpose
tools that do one thing well.

This project was forked from [pyenv](https://github.com/pyenv/pyenv)
and modified for shell.

<img src="https://i.gyazo.com/699a58927b77e46e71cd674c7fc7a78d.png" width="735" height="490" />


### shenv _does..._

* Let you **change the global shell version** on a per-user basis.
* Provide support for **per-project shell versions**.
* Allow you to **override the shell version** with an environment
  variable.
* Search commands from **multiple versions of shell at a time**.

----


## Table of Contents

* **[How It Works](#how-it-works)**
  * [Understanding PATH](#understanding-path)
  * [Understanding Shims](#understanding-shims)
  * [Choosing the shell version](#choosing-the-shell-version)
  * [Locating the shell installation](#locating-the-shell-installation)
* **[Installation](#installation)**
  * [Basic GitHub Checkout](#basic-github-checkout)
    * [Upgrading](#upgrading)
    * [Homebrew on Mac OS X](#homebrew-on-mac-os-x)
    * [Advanced Configuration](#advanced-configuration)
    * [Uninstalling shell versions](#uninstalling-shell-versions)
* **[Command Reference](#command-reference)**
* **[Development](#development)**
  * [Version History](#version-history)
  * [License](#license)


----


## How It Works

At a high level, shenv intercepts shell commands using shim
executables injected into your `PATH`, determines which shell version
has been specified by your application, and passes your commands along
to the correct shell installation.

### Understanding PATH

When you run a command like `bash` or `fish`, your operating system
searches through a list of directories to find an executable file with
that name. This list of directories lives in an environment variable
called `PATH`, with each directory in the list separated by a colon:

    /usr/local/bin:/usr/bin:/bin

Directories in `PATH` are searched from left to right, so a matching
executable in a directory at the beginning of the list takes
precedence over another one at the end. In this example, the
`/usr/local/bin` directory will be searched first, then `/usr/bin`,
then `/bin`.

### Understanding Shims

shenv works by inserting a directory of _shims_ at the front of your
`PATH`:

    $(shenv root)/shims:/usr/local/bin:/usr/bin:/bin

Through a process called _rehashing_, shenv maintains shims in that
directory to match every shell command across every installed version
of shell.

Shims are lightweight executables that simply pass your command along
to shenv. So with shenv installed, when you run, say, `pip`, your
operating system will do the following:

* Search your `PATH` for an executable file named `pip`
* Find the shenv shim named `pip` at the beginning of your `PATH`
* Run the shim named `pip`, which in turn passes the command along to
  shenv

### Choosing the shell version

When you execute a shim, shenv determines which shell version to use by
reading it from the following sources, in this order:

1. The `SHENV_VERSION` environment variable (if specified). You can use
   the [`shenv shell`](https://github.com/shenv/shenv/blob/master/COMMANDS.md#shenv-shell) command to set this environment
   variable in your current shell session.

2. The application-specific `.shell-version` file in the current
   directory (if present). You can modify the current directory's
   `.shell-version` file with the [`shenv local`](https://github.com/shenv/shenv/blob/master/COMMANDS.md#shenv-local)
   command.

3. The first `.shell-version` file found (if any) by searching each parent
   directory, until reaching the root of your filesystem.

4. The global `$(shenv root)/version` file. You can modify this file using
   the [`shenv global`](https://github.com/shenv/shenv/blob/master/COMMANDS.md#shenv-global) command. If the global version
   file is not present, shenv assumes you want to use the "system"
   shell. (In other words, whatever version would run if shenv weren't in your
   `PATH`.)


### Locating the shell installation

Once shenv has determined which version of shell your application has
specified, it passes the command along to the corresponding shell
installation.

Each shell version is installed into its own directory under
`$(shenv root)/versions`.

For example, you might have these versions installed:

* `$(shenv root)/versions/2.7.8/`
* `$(shenv root)/versions/3.4.2/`
* `$(shenv root)/versions/pypy-2.4.0/`

As far as shenv is concerned, version names are simply the directories in
`$(shenv root)/versions`.

### Managing Virtual Environments

There is a shenv plugin named [shenv-virtualenv](https://github.com/shenv/shenv-virtualenv) which comes with various features to help shenv users to manage virtual environments created by virtualenv or Anaconda.
Because the `activate` script of those virtual environments are relying on mutating `$PATH` variable of user's interactive shell, it will intercept shenv's shim style command execution hooks.
We'd recommend to install shenv-virtualenv as well if you have some plan to play with those virtual environments.


----


## Installation

If you're on Mac OS X, consider [installing with Homebrew](#homebrew-on-mac-os-x).


### The automatic installer

Visit my other project:
https://github.com/shenv/shenv-installer


### Basic GitHub Checkout

This will get you going with the latest version of shenv and make it
easy to fork and contribute any changes back upstream.

1. **Check out shenv where you want it installed.**
   A good place to choose is `$HOME/.shenv` (but you can install it somewhere else).

        $ git clone https://github.com/shenv/shenv.git ~/.shenv


2. **Define environment variable `SHENV_ROOT`** to point to the path where
   shenv repo is cloned and add `$SHENV_ROOT/bin` to your `$PATH` for access
   to the `shenv` command-line utility.

    ```sh
    $ echo 'export SHENV_ROOT="$HOME/.shenv"' >> ~/.bash_profile
    $ echo 'export PATH="$SHENV_ROOT/bin:$PATH"' >> ~/.bash_profile
    ```
    **Zsh note**: Modify your `~/.zshenv` file instead of `~/.bash_profile`.  
    **Ubuntu and Fedora note**: Modify your `~/.bashrc` file instead of `~/.bash_profile`.  
    **Proxy note**: If you use a proxy, export `http_proxy` and `HTTPS_PROXY` too.

3. **Add `shenv init` to your shell** to enable shims and autocompletion.
   Please make sure `eval "$(shenv init -)"` is placed toward the end of the shell
   configuration file since it manipulates `PATH` during the initialization.
    ```sh
    $ echo -e 'if command -v shenv 1>/dev/null 2>&1; then\n  eval "$(shenv init -)"\nfi' >> ~/.bash_profile
    ```
    **Zsh note**: Modify your `~/.zshenv` file instead of `~/.bash_profile`.  
    **Ubuntu and Fedora note**: Modify your `~/.bashrc` file instead of `~/.bash_profile`.

    **General warning**: There are some systems where the `BASH_ENV` variable is configured
    to point to `.bashrc`. On such systems you should almost certainly put the abovementioned line
    `eval "$(shenv init -)"` into `.bash_profile`, and **not** into `.bashrc`. Otherwise you
    may observe strange behaviour, such as `shenv` getting into an infinite loop.
    See [#264](https://github.com/shenv/shenv/issues/264) for details.

4. **Restart your shell so the path changes take effect.**
   You can now begin using shenv.
    ```sh
    $ exec "$SHELL"
    ```
5. **Install shell versions into `$(shenv root)/versions`.**
   For example, to download and install Bash 4.4.12, run:
    ```sh
    $ shenv install bash-4.4.12
    ```
   **NOTE:** If you need to pass configure option to build, please use
   ```CONFIGURE_OPTS``` environment variable.

   **NOTE:** If you want to use proxy to download, please use `http_proxy` and `https_proxy`
   environment variable.

   **NOTE:** If you are having trouble installing a shell version,
   please visit the wiki page about
   [Common Build Problems](https://github.com/shenv/shenv/wiki/Common-build-problems)


#### Upgrading

If you've installed shenv using the instructions above, you can
upgrade your installation at any time using git.

To upgrade to the latest development version of shenv, use `git pull`:

```sh
$ cd $(shenv root)
$ git pull
```

To upgrade to a specific release of shenv, check out the corresponding tag:

```sh
$ cd $(shenv root)
$ git fetch
$ git tag
v0.1.0
$ git checkout v0.1.0
```

### Uninstalling shenv

The simplicity of shenv makes it easy to temporarily disable it, or
uninstall from the system.

1. To **disable** shenv managing your shell versions, simply remove the
  `shenv init` line from your shell startup configuration. This will
  remove shenv shims directory from PATH, and future invocations like
  `bash` will execute the system shell version, as before shenv.

  `shenv` will still be accessible on the command line, but your shell
  apps won't be affected by version switching.

2. To completely **uninstall** shenv, perform step (1) and then remove
   its root directory. This will **delete all shell versions** that were
   installed under `` $(shenv root)/versions/ `` directory:
    ```sh
    rm -rf $(shenv root)
    ```
   If you've installed shenv using a package manager, as a final step
   perform the shenv package removal. For instance, for Homebrew:

        brew uninstall shenv

### Homebrew on Mac OS X

You can also install shenv using the [Homebrew](http://brew.sh)
package manager for Mac OS X.

    $ brew update
    $ brew install shenv


To upgrade shenv in the future, use `upgrade` instead of `install`.

Then follow the rest of the post-installation steps under [Basic GitHub Checkout](https://github.com/shenv/shenv#basic-github-checkout) above, starting with #3 ("Add `shenv init` to your shell to enable shims and autocompletion").

### Advanced Configuration

Skip this section unless you must know what every line in your shell
profile is doing.

`shenv init` is the only command that crosses the line of loading
extra commands into your shell. Coming from rvm, some of you might be
opposed to this idea. Here's what `shenv init` actually does:

1. **Sets up your shims path.** This is the only requirement for shenv to
   function properly. You can do this by hand by prepending
   `$(shenv root)/shims` to your `$PATH`.

2. **Installs autocompletion.** This is entirely optional but pretty
   useful. Sourcing `$(shenv root)/completions/shenv.bash` will set that
   up. There is also a `$(shenv root)/completions/shenv.zsh` for Zsh
   users.

3. **Rehashes shims.** From time to time you'll need to rebuild your
   shim files. Doing this on init makes sure everything is up to
   date. You can always run `shenv rehash` manually.

4. **Installs the sh dispatcher.** This bit is also optional, but allows
   shenv and plugins to change variables in your current shell, making
   commands like `shenv shell` possible. The sh dispatcher doesn't do
   anything crazy like override `cd` or hack your shell prompt, but if
   for some reason you need `shenv` to be a real script rather than a
   shell function, you can safely skip it.

To see exactly what happens under the hood for yourself, run `shenv init -`.


### Uninstalling shell versions

As time goes on, you will accumulate shell versions in your
`$(shenv root)/versions` directory.

To remove old shell versions, `shenv uninstall` command to automate
the removal process.

Alternatively, simply `rm -rf` the directory of the version you want
to remove. You can find the directory of a particular shell version
with the `shenv prefix` command, e.g. `shenv prefix 2.6.8`.


----


## Command Reference

See [COMMANDS.md](COMMANDS.md).


----

## Environment variables

You can affect how shenv operates with the following settings:

name | default | description
-----|---------|------------
`SHENV_VERSION` | | Specifies the shell version to be used.<br>Also see [`shenv shell`](https://github.com/shenv/shenv/blob/master/COMMANDS.md#shenv-shell)
`SHENV_ROOT` | `~/.shenv` | Defines the directory under which shell versions and shims reside.<br>Also see `shenv root`
`SHENV_DEBUG` | | Outputs debug information.<br>Also as: `shenv --debug <subcommand>`
`SHENV_HOOK_PATH` | [_see wiki_][hooks] | Colon-separated list of paths searched for shenv hooks.
`SHENV_DIR` | `$PWD` | Directory to start searching for `.shell-version` files.
`SHELL_BUILD_ARIA2_OPTS` | | Used to pass additional parameters to [`aria2`](https://aria2.github.io/).<br>if `aria2c` binary is available on PATH, shenv use `aria2c` instead of `curl` or `wget` to download the shell Source code. If you have an unstable internet connection, you can use this variable to instruct `aria2` to accelerate the download.<br>In most cases, you will only need to use `-x 10 -k 1M` as value to `SHELL_BUILD_ARIA2_OPTS` environment variable



## Development

The shenv source code is [hosted on
GitHub](https://github.com/shenv/shenv).  It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Tests are executed using [Bats](https://github.com/sstephenson/bats):

    $ bats test
    $ bats/test/<file>.bats

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/shenv/shenv/issues).


  [shenv-virtualenv]: https://github.com/shenv/shenv-virtualenv#readme
  [hooks]: https://github.com/shenv/shenv/wiki/Authoring-plugins#shenv-hooks
