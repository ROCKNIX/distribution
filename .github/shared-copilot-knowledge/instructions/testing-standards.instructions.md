---
description: "Testing practices and standards for software development."
applyTo: "**/test_*.py, **/*_test.py, **/tests/**"
---

# Testing Standards

## Testing Approaches

- Use a hybrid approach with both pytest-style (function-based) and unittest-style (class-based) tests
- Use pytest-style for core modules and simple components
- Use unittest-style for API implementations and stateful components

## Test Organization

- Place tests in directories mirroring the implementation structure
- Test modules: `test_<module_name>.py`
- Pytest functions: `test_<function_under_test>_<scenario>`
- Unittest methods: `test_<method_under_test>_<scenario>`

## Test Structure Standards

1. **Imports**: Standard library, third-party, local application imports in that order
2. **Test classes or functions** with clear organization
3. **Set Up and Tear Down** when needed
4. **Clear assertions** with meaningful error messages

## Environmental Considerations

- Tests should not require Docker or network access when possible
- Tests should be environment-aware when testing functionality that changes by environment
- Use appropriate fixtures to simulate container environment

### Platform-Specific Testing Setup
- **macOS Homebrew Python**: Requires `PYTHONPATH="$PWD/src:$PYTHONPATH"` prefix for proper module imports due to virtual environment isolation issues
- **Linux/Container environments**: Standard virtual environment behavior works as expected
- **Configuration**: Use `pyproject.toml` dev dependencies for pytest management
- **Verification**: Always test module imports before running test suites

## Mock Usage Standards

- Use unittest.mock for all mocking needs
- Use context managers or decorators consistently within each file
- Prefer patch when mocking functions or methods
- Use explicit cleanup in setUp/tearDown when necessary

## Coverage and Quality Requirements

- Core utility functions must have high test coverage
- Components should have tests for all public methods
- Edge cases and error conditions must be tested

## Documentation in Tests

- Every test function or method must have a one-line summary ending with a period
- Omit blank lines after the summary when there is no further description
- If additional description is needed, add a blank line after the summary, then the description

---

*Synthesized from imported project guidelines and best practices. Review and update as needed for your project.*
