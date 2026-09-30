// In-Class Activity 06 — Drawing with Flutter
// Student: Praneeth Shankar Ravuri
// Date: September 30, 2026

import 'dart:math' show pi, Random, min, max;

import 'package:flutter/material.dart';

void main() {
  runApp(const SmileyApp());
}

class SmileyApp extends StatelessWidget {
  const SmileyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smiley Painter Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const DrawingPlayground(),
    );
  }
}

enum FaceType {
  classic,
  sleepy,
  surprised,
}

class FaceConfig {
  final double mood;
  final FaceType faceType;
  final bool hat;
  final bool glasses;
  final bool mustache;

  const FaceConfig({
    required this.mood,
    required this.faceType,
    required this.hat,
    required this.glasses,
    required this.mustache,
  });

  FaceConfig copyWith({
    double? mood,
    FaceType? faceType,
    bool? hat,
    bool? glasses,
    bool? mustache,
  }) {
    return FaceConfig(
      mood: mood ?? this.mood,
      faceType: faceType ?? this.faceType,
      hat: hat ?? this.hat,
      glasses: glasses ?? this.glasses,
      mustache: mustache ?? this.mustache,
    );
  }
}

class DrawingPlayground extends StatefulWidget {
  const DrawingPlayground({super.key});

  @override
  State<DrawingPlayground> createState() => _DrawingPlaygroundState();
}

class _DrawingPlaygroundState extends State<DrawingPlayground> {
  FaceConfig config = const FaceConfig(
    mood: 0.8,
    faceType: FaceType.classic,
    hat: false,
    glasses: false,
    mustache: false,
  );

  final List<FaceConfig> undoStack = [];

  final Random random = Random();

  void saveForUndo() {
    undoStack.add(config);
  }

  void updateConfig(FaceConfig newConfig) {
    saveForUndo();

    setState(() {
      config = newConfig;
    });
  }

  void changeMood(double value) {
    setState(() {
      config = config.copyWith(
        mood: value,
      );
    });
  }

  void cycleFace() {
    saveForUndo();

    setState(() {
      switch (config.faceType) {
        case FaceType.classic:
          config = config.copyWith(
            faceType: FaceType.sleepy,
          );
          break;

        case FaceType.sleepy:
          config = config.copyWith(
            faceType: FaceType.surprised,
          );
          break;

        case FaceType.surprised:
          config = config.copyWith(
            faceType: FaceType.classic,
          );
          break;
      }
    });

    showMessage('Face changed');
  }

  void randomizeFace() {
    saveForUndo();

    final faceTypes = FaceType.values;

    setState(() {
      config = config.copyWith(
        mood: random.nextDouble(),
        faceType: faceTypes[
          random.nextInt(faceTypes.length)
        ],
      );
    });

    showMessage('Mood and face randomized');
  }

  void toggleHat() {
    updateConfig(
      config.copyWith(
        hat: !config.hat,
      ),
    );

    showMessage(
      config.hat ? 'Hat added' : 'Hat removed',
    );
  }

  void toggleGlasses() {
    updateConfig(
      config.copyWith(
        glasses: !config.glasses,
      ),
    );

    showMessage(
      config.glasses
          ? 'Glasses added'
          : 'Glasses removed',
    );
  }

  void toggleMustache() {
    updateConfig(
      config.copyWith(
        mustache: !config.mustache,
      ),
    );

    showMessage(
      config.mustache
          ? 'Mustache added'
          : 'Mustache removed',
    );
  }

  void undo() {
    if (undoStack.isEmpty) {
      showMessage('Nothing to undo');
      return;
    }

    setState(() {
      config = undoStack.removeLast();
    });

    showMessage('Previous configuration restored');
  }

  void showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String faceName() {
    switch (config.faceType) {
      case FaceType.classic:
        return 'Classic';

      case FaceType.sleepy:
        return 'Sleepy';

      case FaceType.surprised:
        return 'Surprised';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CustomPainter Smiley Lab',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final availableHeight = constraints.maxHeight;

            final canvasSize = min(
              availableWidth - 32,
              availableHeight * 0.55,
            );

            final drawingSize = max(
              220.0,
              canvasSize,
            );

            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: cycleFace,
                      onLongPress: randomizeFace,
                      child: CustomPaint(
                        size: Size(
                          drawingSize,
                          drawingSize,
                        ),
                        painter: SmileyPainter(
                          mood: config.mood,
                          faceType: config.faceType,
                          hat: config.hat,
                          glasses: config.glasses,
                          mustache: config.mustache,
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    4,
                    16,
                    8,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${faceName()} • Mood: '
                        '${config.mood.toStringAsFixed(2)}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),

                      const SizedBox(height: 4),

                      Slider(
                        value: config.mood,
                        min: 0,
                        max: 1,
                        divisions: 100,
                        label: config.mood.toStringAsFixed(2),
                        onChanged: changeMood,
                      ),

                      const SizedBox(height: 2),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            tooltip: 'Hat',
                            onPressed: toggleHat,
                            icon: Icon(
                              config.hat
                                  ? Icons.checkroom
                                  : Icons.checkroom_outlined,
                            ),
                          ),

                          IconButton(
                            tooltip: 'Glasses',
                            onPressed: toggleGlasses,
                            icon: Icon(
                              config.glasses
                                  ? Icons.visibility
                                  : Icons.visibility_outlined,
                            ),
                          ),

                          IconButton(
                            tooltip: 'Mustache',
                            onPressed: toggleMustache,
                            icon: Icon(
                              config.mustache
                                  ? Icons.face
                                  : Icons.face_outlined,
                            ),
                          ),

                          IconButton(
                            tooltip: 'Undo',
                            onPressed:
                                undoStack.isEmpty
                                    ? null
                                    : undo,
                            icon: const Icon(
                              Icons.undo,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 2),

                      Text(
                        'Tap the face to change • '
                        'Long-press to randomize',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall,
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class SmileyPainter extends CustomPainter {
  SmileyPainter({
    required this.mood,
    required this.faceType,
    required this.hat,
    required this.glasses,
    required this.mustache,
  });

  final double mood;
  final FaceType faceType;

  final bool hat;
  final bool glasses;
  final bool mustache;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = size.shortestSide * 0.38;

    // ------------------------------------------------------------
    // BACKGROUND
    // ------------------------------------------------------------

    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Offset.zero & size,
      backgroundPaint,
    );

    // ------------------------------------------------------------
    // FACE COLOR BASED ON MOOD
    // ------------------------------------------------------------

    final Color faceColor;

    if (mood < 0.35) {
      faceColor = Colors.lightBlue.shade200;
    } else if (mood <= 0.7) {
      faceColor = Colors.yellow.shade600;
    } else {
      faceColor = Colors.orange.shade300;
    }

    // ------------------------------------------------------------
    // FACE
    // ------------------------------------------------------------

    final facePaint = Paint()
      ..color = faceColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center,
      radius,
      facePaint,
    );

    // Face border
    final borderPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.035;

    canvas.drawCircle(
      center,
      radius,
      borderPaint,
    );

    // ------------------------------------------------------------
    // EYES
    // ------------------------------------------------------------

    final eyePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final eyeDx = radius * 0.35;

    final eyeY =
        center.dy - radius * 0.18;

    final eyeRadius =
        radius * 0.075;

    if (faceType == FaceType.sleepy) {
      final sleepyEyePaint = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.035
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(
            center.dx - eyeDx,
            eyeY,
          ),
          width: eyeRadius * 3,
          height: eyeRadius * 1.8,
        ),
        0.15 * pi,
        0.70 * pi,
        false,
        sleepyEyePaint,
      );

      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(
            center.dx + eyeDx,
            eyeY,
          ),
          width: eyeRadius * 3,
          height: eyeRadius * 1.8,
        ),
        0.15 * pi,
        0.70 * pi,
        false,
        sleepyEyePaint,
      );
    } else if (faceType == FaceType.surprised) {
      final surprisedEyeRadius =
          radius * 0.12;

      canvas.drawCircle(
        Offset(
          center.dx - eyeDx,
          eyeY,
        ),
        surprisedEyeRadius,
        eyePaint,
      );

      canvas.drawCircle(
        Offset(
          center.dx + eyeDx,
          eyeY,
        ),
        surprisedEyeRadius,
        eyePaint,
      );

      // White highlights
      final highlightPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(
          center.dx -
              eyeDx -
              surprisedEyeRadius * 0.25,
          eyeY -
              surprisedEyeRadius * 0.25,
        ),
        surprisedEyeRadius * 0.3,
        highlightPaint,
      );

      canvas.drawCircle(
        Offset(
          center.dx +
              eyeDx -
              surprisedEyeRadius * 0.25,
          eyeY -
              surprisedEyeRadius * 0.25,
        ),
        surprisedEyeRadius * 0.3,
        highlightPaint,
      );
    } else {
      // Classic eyes
      canvas.drawCircle(
        Offset(
          center.dx - eyeDx,
          eyeY,
        ),
        eyeRadius,
        eyePaint,
      );

      canvas.drawCircle(
        Offset(
          center.dx + eyeDx,
          eyeY,
        ),
        eyeRadius,
        eyePaint,
      );
    }

    // ------------------------------------------------------------
    // EYEBROWS
    // ------------------------------------------------------------

    final eyebrowPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.035
      ..strokeCap = StrokeCap.round;

    if (faceType == FaceType.surprised) {
      canvas.drawLine(
        Offset(
          center.dx -
              eyeDx -
              radius * 0.10,
          eyeY -
              radius * 0.14,
        ),
        Offset(
          center.dx -
              eyeDx +
              radius * 0.10,
          eyeY -
              radius * 0.20,
        ),
        eyebrowPaint,
      );

      canvas.drawLine(
        Offset(
          center.dx +
              eyeDx -
              radius * 0.10,
          eyeY -
              radius * 0.20,
        ),
        Offset(
          center.dx +
              eyeDx +
              radius * 0.10,
          eyeY -
              radius * 0.14,
        ),
        eyebrowPaint,
      );
    }

    // ------------------------------------------------------------
    // MOUTH
    // ------------------------------------------------------------

    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.045
      ..strokeCap = StrokeCap.round;

    if (faceType == FaceType.surprised) {
      final mouthHeight =
          radius * (0.22 + mood * 0.18);

      final mouthRect = Rect.fromCenter(
        center: Offset(
          center.dx,
          center.dy + radius * 0.30,
        ),
        width: radius * 0.42,
        height: mouthHeight,
      );

      final openMouthPaint = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.fill;

      canvas.drawOval(
        mouthRect,
        openMouthPaint,
      );
    } else {
      final mouthRect = Rect.fromCenter(
        center: Offset(
          center.dx,
          center.dy + radius * 0.15,
        ),
        width: radius,
        height: radius *
            (0.35 + mood * 0.55),
      );

      if (faceType == FaceType.sleepy) {
        canvas.drawArc(
          mouthRect,
          0.18 * pi,
          0.64 * pi,
          false,
          mouthPaint,
        );
      } else if (mood < 0.35) {
        final frownRect = mouthRect.translate(
          0,
          radius * 0.25,
        );

        canvas.drawArc(
          frownRect,
          1.15 * pi,
          0.70 * pi,
          false,
          mouthPaint,
        );
      } else if (mood <= 0.7) {
        canvas.drawArc(
          mouthRect,
          0.15 * pi,
          0.70 * pi,
          false,
          mouthPaint,
        );
      } else {
        canvas.drawArc(
          mouthRect,
          0.10 * pi,
          0.80 * pi,
          false,
          mouthPaint,
        );
      }
    }

    // ------------------------------------------------------------
    // BLUSH
    // ------------------------------------------------------------

    if (mood > 0.55) {
      final blushPaint = Paint()
        ..color =
            Colors.pink.withOpacity(0.28)
        ..style = PaintingStyle.fill;

      final blushWidth =
          radius * 0.30;

      final blushHeight =
          radius * 0.12;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            center.dx - radius * 0.62,
            center.dy + radius * 0.22,
          ),
          width: blushWidth,
          height: blushHeight,
        ),
        blushPaint,
      );

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            center.dx + radius * 0.62,
            center.dy + radius * 0.22,
          ),
          width: blushWidth,
          height: blushHeight,
        ),
        blushPaint,
      );
    }

    // ------------------------------------------------------------
    // MUSTACHE
    // ------------------------------------------------------------

    if (mustache) {
      final mustachePaint = Paint()
        ..color = Colors.brown.shade800
        ..style = PaintingStyle.fill;

      final leftMustache = Path()
        ..moveTo(
          center.dx,
          center.dy + radius * 0.30,
        )
        ..quadraticBezierTo(
          center.dx - radius * 0.15,
          center.dy + radius * 0.20,
          center.dx - radius * 0.40,
          center.dy + radius * 0.30,
        )
        ..quadraticBezierTo(
          center.dx - radius * 0.20,
          center.dy + radius * 0.48,
          center.dx,
          center.dy + radius * 0.34,
        )
        ..close();

      final rightMustache = Path()
        ..moveTo(
          center.dx,
          center.dy + radius * 0.30,
        )
        ..quadraticBezierTo(
          center.dx + radius * 0.15,
          center.dy + radius * 0.20,
          center.dx + radius * 0.40,
          center.dy + radius * 0.30,
        )
        ..quadraticBezierTo(
          center.dx + radius * 0.20,
          center.dy + radius * 0.48,
          center.dx,
          center.dy + radius * 0.34,
        )
        ..close();

      canvas.drawPath(
        leftMustache,
        mustachePaint,
      );

      canvas.drawPath(
        rightMustache,
        mustachePaint,
      );
    }

    // ------------------------------------------------------------
    // GLASSES
    // ------------------------------------------------------------

    if (glasses) {
      final glassesPaint = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.035;

      final glassesWidth =
          radius * 0.48;

      final glassesHeight =
          radius * 0.28;

      final leftGlassesRect =
          Rect.fromCenter(
        center: Offset(
          center.dx - eyeDx,
          eyeY,
        ),
        width: glassesWidth,
        height: glassesHeight,
      );

      final rightGlassesRect =
          Rect.fromCenter(
        center: Offset(
          center.dx + eyeDx,
          eyeY,
        ),
        width: glassesWidth,
        height: glassesHeight,
      );

      canvas.drawOval(
        leftGlassesRect,
        glassesPaint,
      );

      canvas.drawOval(
        rightGlassesRect,
        glassesPaint,
      );

      // Bridge
      canvas.drawLine(
        Offset(
          center.dx - radius * 0.10,
          eyeY,
        ),
        Offset(
          center.dx + radius * 0.10,
          eyeY,
        ),
        glassesPaint,
      );
    }

    // ------------------------------------------------------------
    // HAT
    // ------------------------------------------------------------

    if (hat) {
      final hatPaint = Paint()
        ..color = Colors.indigo.shade700
        ..style = PaintingStyle.fill;

      final hatBandPaint = Paint()
        ..color = Colors.indigo.shade900
        ..style = PaintingStyle.fill;

      final hatTop = Path()
        ..moveTo(
          center.dx - radius * 0.50,
          center.dy - radius * 0.78,
        )
        ..lineTo(
          center.dx - radius * 0.32,
          center.dy - radius * 1.15,
        )
        ..quadraticBezierTo(
          center.dx,
          center.dy - radius * 1.28,
          center.dx + radius * 0.32,
          center.dy - radius * 1.15,
        )
        ..lineTo(
          center.dx + radius * 0.50,
          center.dy - radius * 0.78,
        )
        ..close();

      canvas.drawPath(
        hatTop,
        hatPaint,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(
              center.dx,
              center.dy - radius * 0.77,
            ),
            width: radius * 1.25,
            height: radius * 0.16,
          ),
          Radius.circular(
            radius * 0.05,
          ),
        ),
        hatBandPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant SmileyPainter oldDelegate,
  ) {
    return oldDelegate.mood != mood ||
        oldDelegate.faceType != faceType ||
        oldDelegate.hat != hat ||
        oldDelegate.glasses != glasses ||
        oldDelegate.mustache != mustache;
  }
}