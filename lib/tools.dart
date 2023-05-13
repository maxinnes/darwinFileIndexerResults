import 'dart:async';

// Function to run and stop another function after a specific duration
Future<void> runFunctionWithTimeout(
    Future<void> Function() targetFunction, Duration timeout) async {
  // Create a completer to handle the function completion
  final completer = Completer<void>();

  // Run the target function and complete the completer when it finishes
  targetFunction().then((_) => completer.complete());

  // Run the timeout, and if it finishes before the target function, complete the completer with an error
  Timer(timeout, () {
    if (!completer.isCompleted) {
      completer.completeError(TimeoutException('Function timed out'));
    }
  });

  // Wait for the completer to complete (either by the function finishing or the timeout)
  try {
    await completer.future;
  } catch (e) {
    if (e is TimeoutException) {
      print(e.message);
    } else {
      print('An unexpected error occurred: $e');
    }
  }
}
