# tarball

A fixture package for the package script's tests, whose fetch script
extracts its program from a tar archive in `test/fixtures/upstream`. The
archive holds other files beside the program, which the fetch must leave
out. A test adds the package when it needs it.
