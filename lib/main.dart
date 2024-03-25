import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: MyApp()));
}

final stopwatchProvider = ChangeNotifierProvider((ref) => StopwatchModel());

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Stopwatch Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Stopwatch Demo'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Consumer(
              builder: (context, watch, _) {
                final stopwatch = ref.watch(stopwatchProvider);
                return CircleProgressIndicator(
                  progress: stopwatch.elapsedSeconds / 60.0,
                  text: stopwatch.durationText,
                );
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: ref.read(stopwatchProvider).start,
                  child: Text('Start'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: ref.read(stopwatchProvider).stop,
                  child: Text('Stop'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: ref.read(stopwatchProvider).reset,
                  child: Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CircleProgressIndicator extends StatelessWidget {
  final double progress;
  final String text;

  const CircleProgressIndicator(
      {Key? key, required this.progress, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CirclePainter(progress: progress, text: text),
      size: Size(200, 200),
    );
  }
}

class CirclePainter extends CustomPainter {
  final double progress;
  final String text;

  CirclePainter({required this.progress, required this.text});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint outerCircle = Paint()
      ..strokeWidth = 10
      ..color = Colors.grey
      ..style = PaintingStyle.stroke;

    final Paint completeArc = Paint()
      ..strokeWidth = 10
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: 20, color: Colors.black),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2 - 10;

    canvas.drawCircle(center, radius, outerCircle);

    double angle = 2 * pi * progress;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
        angle, false, completeArc);

    // Center the text inside the circle
    final textOffset = Offset(
        center.dx - textPainter.width / 2, center.dy - textPainter.height / 2);
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class StopwatchModel extends ChangeNotifier {
  Stopwatch _stopwatch = Stopwatch();
  bool _isRunning = false;
  Timer? _timer;

  String get durationText {
    final milliseconds = _stopwatch.elapsedMilliseconds;
    final seconds = (milliseconds / 1000).floor();
    final minutes = (seconds / 60).floor();
    final hours = (minutes / 60).floor();

    final String hoursStr = (hours % 60).toString().padLeft(2, '0');
    final String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    final String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr:$secondsStr';
  }

  double get elapsedSeconds => _stopwatch.elapsedMilliseconds / 1000;

  void start() {
    if (!_isRunning) {
      _isRunning = true;
      _stopwatch.start();
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        notifyListeners();
      });
    }
  }

  void stop() {
    if (_isRunning) {
      _isRunning = false;
      _stopwatch.stop();
      _timer?.cancel();
    }
  }

  void reset() {
    if (!_isRunning) {
      _stopwatch.reset();
      notifyListeners();
    }
  }
}
