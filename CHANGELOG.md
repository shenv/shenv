## Version History

## Unreleased

* shell-build: Add PyPy 5.9.0
* shell-build: Add Miniconda[23] 4.3.14, 4.3.21, 4.3.27, 4.3.30
* shell-build: Add Anaconda[23] 5.0.1
* shell-build: Update Anaconda[23] 5.0.0 to 5.0.0.1 bugfix release

## v1.1.5

* shell-build: Add Cshell 3.6.3
* shell-build: Add Cshell 3.7.0a1
* shell-build: Add Anaconda[23] 5.0.0

## v1.1.4

* shenv: Workaround for scripts in `$PATH` which needs to be source'd (#100, #688, #953)
* shell-build: Add support for PyPy3 executables like `libpypy3-c.so` (#955, #956)
* shell-build: Add Cshell 2.7.14, 3.4.7, 3.5.4 (#965, #971, #980)
* shell-build: Add Jython 2.7.1 (#973)

## v1.1.3

* shell-build: Add Cshell 3.6.2 (#951)

## v1.1.2

* shenv: Fix incorrect `shenv --version` output in v1.1.1 (#947)

## v1.1.1

* shell-build: Update links to Portable Pypy 5.8-1 bugfix release, affects pypy2.7-5.8.0 and pypy3.5-5.8.0 definitions (#939)

## v1.1.0

* shell-build: Add PyPy 5.7.1 (#888)
* shenv: Merge rbenv master (#927)
* shell-build: Add PyPy 5.8.0 (#932)
* shell-build: Anaconda[23] 4.4.0
* shell-build: Add microshell-dev

## 1.0.10

* shell-build: Add Anaconda2/Anaconda3 4.3.1 (#876)
* shell-build: Make miniconda-latest point to miniconda2-latest (#881)
* shell-build: Fix typo in MacOS packages for anaconda2-4.3.0/4.2.0 (#880)

## 1.0.9

* shenv: Migrate project site from https://github.com/pyenv/pyenv to https://github.com/shenv/shenv
* shell-build: Add PyPy2 5.7.0 (#872, #868)
* shell-build: Add PyPy3 5.7.0-beta (#871, #869)
* shell-build: Add Cshell 3.6.1 (#873)
* shell-build: Add Pyston 0.6.1 (#859)
* shell-build: Change default mirror site URL from https://pyenv.github.io/shells to https://shenv.github.io/shells
* shell-build: Upgrade OpenSSL from 1.0.2g to 1.0.2k (#850)

## 1.0.8

* shenv: Fix fish subcommand completion (#831)
* shell-build: Add Anaconda2/Anaconda3 4.3.0  (#824)
* shell-build: Use Cshell on GitHub as the source repository of Cshell development versions (#836, #837)
* shell-build: Fix checksum verification issue on the platform where OpenSSL isn't available (#840)

## 1.0.7

* shell-build: Add Cshell 3.5.3 (#811)
* shell-build: Add Cshell 3.4.6 (#812)
* shell-build: Fix tar.gz checksum of Cshell 3.6.0 (#793)
* shell-build: Jython installer workaround (#800)
* shell-build: Disable optimization (`-O0`) when `--debug` was specified (#808)

## 1.0.6

* shell-build: Add Cshell 3.6.0 (#787)

## 1.0.5

* shell-build: Add Cshell 2.7.13 (#782)
* shell-build: Add Cshell 3.6.0rc2 (#781)
* shell-build: Add Anaconda 4.2.0 (#774)
* shell-build: Add Anaconda3 4.2.0 (#765)
* shell-build: Add Ironshell 2.7.7 (#755)

## 1.0.4

* shell-build: Add PyPy 5.6.0 (#751)
* shell-build: Add PyPy3 3.5 nightlies (`pypy3.5-c-jit-latest` #737)
* shell-build: Add Stackless 2.7.12 (#753)
* shell-build: Add Stackless 2.7.11
* shell-build: Add Stackless 2.7.10
* shell-build: Add Pyston 0.6.0
* shell-build: Add Cshell 3.6.0b4 (#762)

## 1.0.3

* shell-build: Add Cshell 3.6.0b3 (#731, #744)
* shell-build: Add PyPy3.3 5.5-alpha (#734, #736)
* shell-build: Stop specifying `--enable-unicode=ucs4` on OS X (#257, #726)
* shell-build: Fix 3.6-dev and add 3.7-dev (#729, #730)
* shell-build: Add a patch for https://bugs.shell.org/issue26664 (#725)
* shell-build: Add Pyston 0.5.1 (#718)
* shell-build: Add Stackless 3.4.2 (#720)
* shell-build: Add Ironshell 2.7.6.3 (#716)
* shell-build: Add Stackless 2.7.9 (#714)

## 1.0.2

* shell-build: Add Cshell 3.6.0b1 (#699)
* shell-build: Add anaconda[23] 4.1.1 (#701, #702)
* shell-build: Add miniconda[23] 4.1.11 (#703, #704, #706)
* shell-build: Remove `bin.orig` if exists to fix an issue with `--enable-framework` (#687, #700)

## 1.0.1

* shell-build: Add Cshell 3.6.0a4 (#673)
* shell-build: Add PyPy2 5.4, 5.4.1 (#683, #684, #695, #697)
* shell-build: Add PyPy Portable 5.4, 5.4.1 (#685, #686, #696)
* shell-build: Make all HTTP source URLs to HTTPS (#680)

## 1.0.0

* shenv: Import latest changes from rbenv as of Aug 15, 2016 (#669)
* shenv: Add workaround for system shell at `/bin/shell` (#628)
* shell-build: Import changes from ruby-build v20160602 (#668)

## 20160726

* shell-build: pypy-5.3.1: Remove stray text (#648)
* shell-build: Add Cshell 3.6.0a3 (#657)
* shell-build: Add anaconda[23]-4.1.0
* shenv: Keep using `.tar.gz` archives if tar doesn't support `-J` (especially on BSD) (#654, #663)
* shenv: Fixed conflict between shenv-virtualenv's `rehash` hooks of `envs.bash`
* shenv: Write help message of `sh-*` commands to stdout properly (#650, #651)

## 20160629

* shell-build: Added Cshell 2.7.12 (#645)
* shell-build: Added PyPy 3.5.1 (#646)
* shell-build: Added PyPy Portable 5.3.1

## 20160628

* shell-build: Added PyPy3.3 5.2-alpha1 (#631)
* shell-build: Added Cshell 2.7.12rc1
* shell-build: Added Cshell 3.6.0a2 (#630)
* shell-build: Added Cshell 3.5.2 (#643)
* shell-build: Added Cshell 3.4.5 (#643)
* shell-build: Added PyPy2 5.3 (#626)
* shenv: Skip creating shims for system executables bundled with Anaconda rather than ignoring them in `shenv-which` (#594, #595, #599)
* shell-build: Configured GCC as a requirement to build Cshell prior to 2.4.4 (#613)
* shell-build: Use `aria2c` - ultra fast download utility if available (#534)

## 20160509

* shell-build: Fixed wrong SHA256 of `pypy-5.1-linux_x86_64-portable.tar.bz2` (#586, #587)
* shell-build: Added miniconda[23]-4.0.5
* shell-build: Added PyPy (Portable) 5.1.1 (#591, #592, #593)

## 20160422

* shell-build: Added PyPy 5.1 (#579)
* shell-build: Added PyPy 5.1 Portable
* shell-build: Added PyPy 5.0.1 (#558)
* shell-build: Added PyPy 5.0.1 Portable
* shell-build: Added PyPy 5.0 Portable
* shell-build: Added anaconda[23]-4.0.0 (#572)
* shell-build: Added Jython 2.7.1b3 (#557)

## 20160310

* shell-build: Add PyPy-5.0.0 (#555)
* shenv: Import recent changes from rbenv 1.0 (#549)

## 20160303

* shell-build: Add anaconda[23]-2.5.0 (#543)
* shell-build: Import recent changes from ruby-build 20160130
* shell-build: Compile with `--enable-unicode=ucs4` by default for Cshell (#257, #542)
* shell-build: Switch download URL of Continuum products from HTTP to HTTPS (#543)
* shell-build: Added pypy-dev special case in shenv-install to use py27 (#547)
* shell-build: Upgrade OpenSSL to 1.0.2g (#550)

## 20160202

* shenv: Run rehash automatically after `conda install`
* shell-build: Add Cshell 3.4.4 (#511)
* shell-build: Add anaconda[23]-2.4.1, miniconda[23]-3.19.0
* shell-build: Fix broken build definitions of Cshell/Stackless 3.2.x (#531)

### 20151222

* shenv: Merge recent changes from rbenv as of 2015-12-14 (#504)
* shell-build: Add a `OPENSSL_NO_SSL3` patch for Cshell 2.6, 2.7, 3.0, 3.1, 3.2 and 3.3 series (#507, #511)
* shell-build: Stopped using mirror at shenv.github.io for Cshell since http://www.shell.org is on fast.ly

### 20151210

* shenv: Add a default hook for Anaconda to look for original `$PATH` (#491)
* shenv: Skip virtualenv aliases on `shenv versions --skip-aliases` (shenv/shenv-virtualenv#126)
* shell-build: Add Cshell 2.7.11, 3.5.1 (#494, #498)
* shell-build: Update OpenSSL to 1.0.1q (#496)
* shell-build: Adding SSL patch to build 2.7.3 on Debian (#495)

### 20151124

* shenv: Import recent changes from rbenv 5fb9c84e14c8123b2591d22e248f045c7f8d8a2c
* shenv: List anaconda-style virtual environments as a version in shenv (#471)
* shell-build: Import recent changes from ruby-build v20151028
* shell-build: Add PyPy 4.0.1 (#489)
* shell-build: Add `miniconda*-3.18.3` (#477)
* shell-build: Add Cshell 2.7.11 RC1

### 20151105

* shell-build: Add anaconda2-2.4.0 and anacondaa3-2.4.0
* shell-build: Add Portable PyPy 4.0 (#472)

### 20151103

* shell-build: Add PyPy 4.0.0 (#463)
* shell-build: Add Jython 2.7.1b2
* shell-build: Add warning about setuptools issues on Cshell 3.0.1 on OS X (#456)

### 20151006

* shenv: Different behaviour when invoking .py script through symlink (#379, #404)
* shenv: Enabled Gitter on the project (#436, #444)
* shell-build: Add Jython 2.7.1b1
* shell-build: Install OpenSSL on OS X if no proper version is available (#429)

### 20150913

* shell-build: Add Cshell 3.5.0
* shell-build: Remove Cshell 3.5.0 release candidates
* shell-build: Fixed anaconda3 repo's paths (#439)
* shell-build: Add miniconda-3.16.0 and miniconda3-3.16.0 (#435)

### 20150901

* shell-build: Add Cshell 3.5.0 release candidates; 3.5.0rc1 and 3.5.0rc2
* shell-build: Disabled `_FORTITY_SOURCE` to fix Cshell >= 2.4, <= 2.4.3 builds (#422)
* shell-build: Removed Cshell 3.5.0 betas
* shell-build: Add miniconda-3.10.1 and miniconda3-3.10.1 (#414)
* shell-build: Add PyPy 2.6.1 (#433)
* shell-build: Add PyPy-STM 2.3 and 2.5.1 (#428)
* shell-build: Ignore user's site-packages on ensurepip/get-pip (#411)
* shenv: Import recent changes from ruby-build v20150818

#### 20150719

* shell-build: Add Cshell `3.6-dev` (#413)
* shell-build: Add Anaconda/Anaconda3 2.3.0
* shell-build: Fix download URL of portable PyPy 2.6 (fixes #389)
* shell-build: Use custom `MACOSX_DEPLOYMENT_TARGET` if defined (#312)
* shell-build: Use original Cshell repository instead of mirror at bitbucket.org as the source of `*-dev` versions (#409)
* shell-build: Pin pip version to 1.5.6 for shell 3.1.5 (#351)

#### 20150601

* shell-build: Add PyPy 2.6.0
* shell-build: Add PyPy 2.5.1 portable
* shell-build: Add Cshell 3.5.0 beta releases; 3.5.0b1 and 3.5.0b2
* shell-build: Removed Cshell 3.5.0 alpha releases
* shell-build: Fix inverted condition for `--altinstall` of ensurepip (#255)
* shell-build: Skip installing `setuptools` by `ez_setup.py` explicitly (fixes #381)
* shell-build: Import changes from ruby-build v20150519

#### 20150524

* shenv: Improve `shenv version`, if there is one missing (#290)
* shenv: Improve pip-rehash to handle versions in command, like `pip2` and `pip3.4` (#368)
* shell-build: Add Cshell release; 2.7.10 (#380)
* shell-build: Add Miniconda/Miniconda3 3.9.1 and Anaconda/Anaconda3 2.2.0 (#375, #376)

#### 20150504

* shell-build: Add Jython 2.7.0
* shell-build: Add Cshell alpha release; 3.5.0a4
* shell-build: Add Cshell 3.1, 3.1.1, and 3.1.2
* shell-build: Fix pip version to 1.5.6 for Cshell 3.1.x (#351)

#### 20150326

* shell-build: Add Portable PyPy binaries from https://github.com/squeaky-pl/portable-pypy (#329)
* shell-build: Add Cshell alpha release; 3.5.0a2 (#328)
* shell-build: Add pypy-2.5.1 (fixes #338)
* shenv: Import recent changes from rbenv 4d72eefffc548081f6eee2e54d3b9116b9f9ee8e

#### 20150226

* shell-build: Add Cshell release; 3.4.3 (#323)
* shell-build: Add Cshell alpha release; 3.5.0a1 (#324)
* shell-build: Add Miniconda/Miniconda3 3.8.3 (#318)

#### 20150204

* shell-build: Add PyPy 2.5.0 release (#311)
* shell-build: Add note about `--enable-shared` and RPATH (#217)
* shell-build: Fix regression of `SHELL_MAKE_INSTALL_TARGET` and add test (#255)
* shell-build: Symlink `shellX.Y-config` to `shell-config` if `shell-config` is missing (#296)
* shell-build: Latest `pip` can't be installed into `3.0.1` (#309)

#### 20150124

* shell-build: Import recent changes from ruby-build v20150112
* shell-build: Prevent adding `/Library/shell/X.X/site-packages` to `sys.path` when `--enable-framework` is enabled on OS X. Thanks @s1341 (#292)
* shell-build: Add new Ironshell release; 2.7.5

#### 20141211

* shenv: Add built-in `pip-rehash` feature. You don't need to install [shenv-pip-rehash](https://github.com/shenv/shenv-pip-rehash) anymore.
* shell-build: Add new Cshell release; 2.7.9 (#284)
* shell-build: Add new PyPy releases; pypy3-2.4.0, pypy3-2.4.0-src (#277)
* shell-build: Add build definitions of PyPy nightly build

#### 20141127

* shell-build: Add new Cshell release candidates; 2.7.9rc1 (#276)

#### 20141118

* shell-build: Fix broken `setup_builtin_patches` (#270)
* shell-build: Add a patch to allow building 2.6.9 on OS X 10.9 with `--enable-framework` (#269, #271)

#### 20141106

* shenv: Optimize shenv-which. Thanks to @blueyed (#129)
* shell-build: Add Miniconda/Miniconda3 3.7.0 and Anaconda/Anaconda3 2.1.0 (#260)
* shell-build: Use HTTPS for mirror download URLs (#262)
* shell-build: Set `rpath` for `--shared` build of PyPy (#244)
* shell-build: Support `make altinstall` when building Cshell/Stackless (#255)
* shell-build: Import recent changes from ruby-build v20141028 (#265)

#### 20141012

* shell-build: Add new Cshell releases; 3.2.6, 3.3.6 (#253)

#### 20141011

* shell-build: Fix build error of Stackless 3.3.5 on OS X (#250)
* shell-build: Add new Stackless releases; stackless-2.7.7, stackless-2.7.8, stackless-3.4.1 (#252)

#### 20141008

* shell-build: Add new Cshell release; 3.4.2 (#251)
* shell-build: Add new Cshell release candidates; 3.2.6rc1, 3.3.6rc1 (#248)

#### 20140924

* shenv: Fix an unintended behavior when user does not have write permission on `$SHENV_ROOT` (#230)
* shenv: Fix a zsh completion issue (#232)
* shell-build: Add new PyPy release; pypy-2.4.0, pypy-2.4.0-src (#241)

#### 20140825

* shenv: Fix zsh completion with multiple words (#215)
* shell-build: Display the package name of `hg` as `mercurial` in message (#212)
* shell-build: Unset `PIP_REQUIRE_VENV` during build (#216)
* shell-build: Set `MACOSX_DEPLOYMENT_TARGET` from the product version of OS X (#219, #220)
* shell-build: Add new Jython release; jython2.7-beta3 (#223)

#### 20140705

* shell-build: Add new Cshell release; 2.7.8 (#201)
* shell-build: Support `SETUPTOOLS_VERSION` and `PIP_VERSION` to allow installing specific version of setuptools/pip (#202)

#### 20140628

* shell-build: Add new Anaconda releases; anaconda-2.0.1, anaconda3-2.0.1 (#195)
* shell-build: Add new PyPy3 release; pypy3-2.3.1 (#198)
* shell-build: Add ancient Cshell releases; 2.1.3, 2.2.3, 2.3.7 (#199)
* shell-build: Use `ez_setup.py` and `get-pip.py` instead of installing them from tarballs (#194)
* shell-build: Add support for command-line options to `ez_setup.py` and `get-pip.py` (#200)

#### 20140615

* shell-build: Update default setuptools version (4.0.1 -> 5.0) (#190)

#### 20140614

* shenv: Change versioning schema (`v0.4.0-YYYYMMDD` -> `vYYYYMMDD`)
* shell-build: Add new PyPy release; pypy-2.3.1, pypy-2.3.1-src
* shell-build: Create symlinks for executables with version suffix (#182)
* shell-build: Use SHA2 as default digest algorithm to verify downloaded archives
* shell-build: Update default setuptools version (4.0 -> 4.0.1) (#183)
* shell-build: Import recent changes from ruby-build v20140524 (#184)

#### 0.4.0-20140602

* shell-build: Add new Anaconda/Anaconda3 releases; anaconda-2.0.0, anaconda3-2.0.0 (#179)
* shell-build: Add new Cshell release; 2.7.7 (#180)
* shell-build: Update default setuptools version (3.6 -> 4.0) (#181)
* shell-build: Respect environment variables of `CPPFLAGS` and `LDFLAGS` (#168)
* shell-build: Support for xz-compressed shell tarballs (#177)

#### 0.4.0-20140520

* shell-build: Add new Cshell release; 3.4.1 (#170, #171)
* shell-build: Update default pip version (1.5.5 -> 1.5.6) (#169)

#### 0.4.0-20140516

* shenv: Prefer gawk over awk if both are available.
* shell-build: Add new PyPy release; pypy-2.3, pypy-2.3-src (#162)
* shell-build: Add new Anaconda release; anaconda-1.9.2 (#155)
* shell-build: Add new Miniconda releases; miniconda-3.3.0, minoconda-3.4.2, miniconda3-3.3.0, miniconda3-3.4.2
* shell-build: Add new Stackless releases; stackless-2.7.3, stackless-2.7.4, stackless-2.7.5, stackless-2.7.6, stackless-3.2.5, stackless-3.3.5 (#164)
* shell-build: Add Ironshell versions (setuptools and pip will work); ironshell-2.7.4, ironshell-dev
* shell-build: Add new Jython beta release; jython-2.7-beta2
* shell-build: Update default setuptools version (3.4.1 -> 3.6)
* shell-build: Update default pip version (1.5.4 -> 1.5.5)
* shell-build: Update GNU Readline (6.2 -> 6.3)
* shell-build: Import recent changes from ruby-build v20140420

#### 0.4.0-20140404

* shenv: Reads only the first word from version file. This is as same behavior as rbenv.
* shell-build: Fix build of Tkinter with Tcl/Tk 8.6 (#131)
* shell-build: Fix build problem with Readline 6.3 (#126, #131, #149, #152)
* shell-build: Do not exit with errors even if some of modules are absent (#131)
* shell-build: MacOSX was misspelled as MaxOSX in `anaconda_architecture` (#136)
* shell-build: Use default `cc` as the C Compiler to build Cshell (#148, #150)
* shell-build: Display value from `pypy_architecture` and `anaconda_architecture` on errors (shenv/shenv-virtualenv#18)
* shell-build: Remove old development version; 2.6-dev
* shell-build: Update default setuptools version (3.3 -> 3.4.1)

#### 0.4.0-20140317

* shell-build: Add new Cshell releases; 3.4.0 (#133)
* shell-build: Add new Anaconda releases; anaconda-1.9.0, anaconda-1.9.1
* shell-build: Add new Miniconda releases; miniconda-3.0.4, miniconda-3.0.5, miniconda3-3.0.4, miniconda3-3.0.5
* shell-build: Update default setuptools version (3.1 -> 3.3)

#### 0.4.0-20140311

* shell-build: Add new Cshell releases; 3.3.5 (#127)
* shell-build: Add new Cshell release candidates; 3.4.0rc1, 3.4.0rc2, 3.4.0rc3
* shell-build: Update default setuptools version (2.2 -> 3.1)
* shell-build: Update default pip version (1.5.2 -> 1.5.4)
* shell-build: Import recent changes from ruby-build v20140225

#### 0.4.0-20140211

* shell-build: Add new Cshell release candidates; 3.3.4, 3.4.0b3
* shell-build: Add [Anaconda](https://store.continuum.io/cshop/anaconda/) and [Miniconda](http://repo.continuum.io/miniconda/) binary distributions
* shell-build: Display error if the wget does not support Server Name Indication (SNI) to avoid SSL verification error when downloading from https://pypi.shell.org. (#60)
* shell-build: Update default setuptools version (2.1 -> 2.2)
* shell-build: Update default pip version (1.5.1 -> 1.5.2)
* shell-build: Import recent changes from ruby-build v20140204

#### 0.4.0-20140123

* shenv: Always append the directory at the top of the `$PATH` to return proper value for `sys.executable` (#98)
* shenv: Unset `GREP_OPTIONS` to avoid issues of conflicting options (#101)
* shell-build: Install `pip` with using `ensurepip` if available
* shell-build: Add support for framework installation (`--enable-framework`) of Cshell (#55, #99)
* shell-build: Import recent changes from ruby-build v20140110.1
* shell-build: Import `bats` tests from ruby-build v20140110.1

#### 0.4.0-20140110.1

* shell-build: Fix build error of Cshell 2.x on the platform where the `gcc` is llvm-gcc.

#### 0.4.0-20140110

* shenv: Reliably detect parent shell in `shenv init` (#93)
* shenv: Import recent changes from rbenv 0.4.0
* shenv: Import `bats` tests from rbenv 0.4.0
* shell-build: Add new Cshell releases candidates; 3.4.0b2
* shell-build: Add ruby-build style patching feature (#91)
* shell-build: Set `RPATH` if `--enable-shared` was given (#65, #66, 82)
* shell-build: Update default setuptools version (2.0 -> 2.1)
* shell-build: Update default pip version (1.4.1 -> 1.5)
* shell-build: Activate friendly Cshell during build if the one is not activated (8fa6b4a1847851919ad7857c6c42ed809a4d277b)
* shell-build: Fix broken install.sh
* shell-build: Import recent changes from ruby-build v20131225.1
* version-ext-compat: Removed from default plugin. Please use [shenv-version-ext](https://github.com/shenv/shenv-version-ext) instead.

#### 0.4.0-20131217

* shell-build: Fix broken build of Cshell 3.3+ on Darwin
* shell-build: Not build GNU Readline uselessly on Darwin

#### 0.4.0-20131216

* shell-build: Add new Cshell releases; 3.3.3 (#80)
* shell-build: Add new Cshell releases candidates; 3.4.0b1
* shell-build: Add new PyPy releases; pypy-2.2.1, pypy-2.2.1-src
* shell-build: Update default setuptools version (1.3.2 -> 2.0)
* shell-build: Imported recent changes from ruby-build v20131211
* shenv: Fix shenv-prefix to trim "/bin" in `shenv prefix system` (#88)

#### 0.4.0-20131116

* shell-build: Add new Cshell releases; 2.6.9, 2.7.6 (#76)
* shell-build: Add new Cshell release candidates; 3.3.3-rc1, 3.3.3-rc2
* shell-build: Add new PyPy releases; pypy-2.2, pypy-2.2-src (#77)
* shell-build: Update default setuptools version (1.1.6 -> 1.3.2)
* shell-build: Imported recent changes from ruby-build v20131030

#### 0.4.0-20131023

* shenv: Improved [fish shell](http://fishshell.com/) support
* shell-build: Add new PyPy releases; pypy-2.1, pypy-2.1-src, pypy3-2.1-beta1, pypy3-2.1-beta1-src
* shell-build: Add ancient versions; 2.4, 2.4.1, 2.4.3, 2.4.4 and 2.4.5
* shell-build: Add alpha releases; 3.4.0a2, 3.4.0a3, 3.4.0a4
* shell-build: Update default pip version (1.4 -> 1.4.1)
* shell-build: Update default setuptools version (0.9.7 -> 1.1.6)

#### 0.4.0-20130726

* shenv: Fix minor issue of variable scope in `shenv versions`
* shell-build: Update base version to ruby-build v20130628
* shell-build: Use brew managed OpenSSL and GNU Readline if they are available
* shell-build: Fix build of Cshell 3.3+ on OS X (#29)
* shell-build: Fix build of native modules of Cshell 2.5 on OS X (#33)
* shell-build: Fix build of Cshell 2.6+ on openSUSE (#36)
* shell-build: Add ancient versions; 2.4.2 and 2.4.6. The build might be broken. (#37)
* shell-build: Update default pip version (1.3.1 -> 1.4)
* shell-build: Update default setuptools version (0.7.2 -> 0.9.7)

#### 0.4.0-20130613

* shenv: Changed versioning schema. There are two parts; the former is the base rbenv version, and the latter is the date of release.
* shell-build: Add `--debug` option to build Cshell with debug symbols. (#11)
* shell-build: Add new Cshell versions: 2.7.4, 2.7.5, 3.2.4, 3.2.5, 3.3.1, 3.3.2 (#12, #17)
* shell-build: Add `svnversion` patch for old Cshell versions (#14)
* shell-build: Enable mirror by default for faster download (#20)
* shell-build: Add `OPENSSL_NO_SSL2` patch for old Cshell versions (#22)
* shell-build: Install GNU Readline on Darwin if the system one is broken (#23)
* shell-build: Bundle patches in `${SHELL_BUILD_ROOT}/share/shell-build/patches` and improve patching mechanism (`apply_patches`).
* shell-build: Verify native extensions after building. (`build_package_verify_py*`)
* shell-build: Add `install_hg` to install package from Mercurial repository
* shell-build: Support building Jython and PyPy.
* shell-build: Add new Cshell development versions: 2.6-dev, 2.7-dev, 3.1-dev, 3.2-dev, 3.3-dev, 3.4-dev
* shell-build: Add new Jython development versions: jython-2.5.4-rc1, jython-2.5-dev, jython-2.7-beta1, jython-dev
* shell-build: Add new PyPy versions: pypy-1.5{,-src}, pypy-1.6, pypy-1.7, pypy-2.0{,-src}, pypy-2.0.1{,-src}, pypy-2.0.2{,-src}
* shell-build: Add new PyPy development versions: pypy-1.7-dev, pypy-1.8-dev, pypy-1.9-dev, pypy-2.0-dev, pypy-dev, pypy-py3k-dev
* shell-build: Add new Stackless development versions: stackless-2.7-dev, stackless-3.2-dev, stackless-3.3-dev, stackless-dev
* shell-build: Update default pip version (1.2.1 -> 1.3.1)
* shell-build: Update default setuptools version (0.6.34 (distribute) -> 0.7.2 ([new setuptools](https://bitbucket.org/pypa/setuptools)))

#### 0.2.0 (February 18, 2013)

* Import changes from rbenv 0.4.0.

#### 0.1.2 (October 23, 2012)

* Add push/pop for version stack management.
* Support multiple versions via environment variable.
* Now GCC is not a requirement to build Cshell and Stackless.

#### 0.1.1 (September 3, 2012)

* Support multiple versions of shell at a time.

#### 0.1.0 (August 31, 2012)

* Initial public release.
