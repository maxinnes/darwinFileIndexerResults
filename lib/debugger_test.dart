import 'package:logger/logger.dart';

void main() {
  var logger = Logger(
    printer: PrettyPrinter(),
  );
  Logger.level = Level.debug;
  logger.d("Sample test");
}
