import 'package:logger/logger.dart';

Logger get logger => Log.instance;

class Log extends Logger {
  Log._() : super(output: buffer, printer: SimplePrinter(/*printTime: true*/));
  static final instance = Log._();
}

final buffer = BufferOutput();

class BufferOutput extends LogOutput {
  String lastLogLine = '';
  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      lastLogLine = line;
      // ignore: avoid_print
      print(line);
    }
  }
}
