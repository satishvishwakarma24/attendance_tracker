# Logging Rules and Standards

- **Core Utility**: Use only the global `Logger` utility defined at `lib/core/utils/logger.dart` for console printing, debugging, warning, and error tracing.
- **No Direct Console Output**: Never use raw `print()` or `debugPrint()` anywhere in the application code.
- **Network Tracing**: All network requests, successful responses, and API exceptions must be logged using `Logger.info()`, `Logger.debug()`, and `Logger.error()` respectively.
- **Exception Tracing**: Catch blocks must log both the error object and its corresponding `StackTrace` using `Logger.error(message, error, stackTrace)`.
