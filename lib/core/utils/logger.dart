import 'package:talker/talker.dart';

abstract final class Logger {
  static final Talker talker = Talker();

  static final Talker _talker = Talker(
    settings: TalkerSettings(
      useConsoleLogs: true,
      enabled: true,
    ),
  );

  static void info(String message) {
    talker.info(message);
  }

  static void warning(String message) {
    _talker.warning(message);
  }

  static void error(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _talker.error(
      message,
      error,
      stackTrace,
    );
  }

  static void debug(String message) {
    _talker.debug(message);
  }
}

/**
Logger.info("App started");
Logger.debug("Button clicked");
Logger.warning("Low memory");
Logger.error("API failed", exception, stackTrace);
 */
