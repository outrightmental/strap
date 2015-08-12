# Testing

## Mocks

### Mock Buckles

Some tests will `export STRAP_MOCK_BUCKLES` before a test, to mock external dependencies.

Possible values:

+ `STRAP_MOCK_BUCKLES=positive` mocks dependencies to perform OK
+ `STRAP_MOCK_BUCKLES=negative` mocks dependencies to fail

### Mock Git

Some tests will `export STRAP_MOCK_GIT` before a test, to mock the underlying git functionality.

Possible values:

+ `STRAP_MOCK_GIT=positive` mocks git to perform OK
+ `STRAP_MOCK_GIT=negative` mocks git to fail