---
description: "Testing practices and standards for software development."
applyTo: "**/test_*.py, **/*_test.py, **/tests/**"
---

# Testing Standards

## Testing Approaches

- Use a hybrid approach with both pytest-style (function-based) and unittest-style (class-based) tests
- Use pytest-style for core modules and simple components
- Use unittest-style for API implementations and stateful components
- Tests should not require Docker or network access when possible
- Use appropriate fixtures to simulate different environments

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

## Coverage and Quality Requirements

- Core utility functions must have high test coverage
- Components should have tests for all public methods
- Edge cases and error conditions must be tested
- Use unittest.mock for all mocking needs consistently

## Documentation in Tests

- Every test function or method must have a one-line summary ending with a period
- Omit blank lines after the summary when there is no further description
- If additional description is needed, add a blank line after the summary, then the description

---

*Synthesized from imported project guidelines and best practices. Review and update as needed for your project.*
