import 'dart:io';

enum DebugLevel {
  DEBUG,
  INFO,
  WARNING,
  ERROR,
  NONE,
}

DebugLevel DEBUG_LEVEL = DebugLevel.INFO;

class DebugLog {

  static writeln(DebugLevel level, String str) {
    if (level.index >= DEBUG_LEVEL.index) {
      stdout.writeln(str);
    }
  }

  static writeerrln(String str) {
    stderr.writeln(str);
  }
}