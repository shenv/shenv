.PHONY: test

# Do not pass in user flags to build tests.
unexport SHELL_CFLAGS
unexport SHELL_CONFIGURE_OPTS

test: bats
	PATH="./bats/bin:$$PATH" test/run
	cd plugins/shell-build && $(PWD)/bats/bin/bats $${CI:+--tap} test

bats:
	git clone --depth 1 --single-branch --branch v1.2.0 https://github.com/bats-core/bats-core.git bats
