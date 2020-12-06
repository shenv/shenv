.PHONY: test

# Do not pass in user flags to build tests.
unexport SHELL_CFLAGS
unexport SHELL_CONFIGURE_OPTS

test:
	PATH="./bats-core/bin:$$PATH" test/run
	cd plugins/shell-build && $(PWD)/bats-core/bin/bats $${CI:+--tap} test
