import 'package:flutter/material.dart';

class SmoothTypingIndicator extends StatefulWidget {
  const SmoothTypingIndicator({super.key});

  @override
  SmoothTypingIndicatorState createState() => SmoothTypingIndicatorState();
}

class SmoothTypingIndicatorState extends State<SmoothTypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final int dotCount = 3;
  final double dotSize = 6.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _getOpacity(int index) {
    // Each dot animation is offset by 1/3 duration
    double progress = (_controller.value - index / dotCount) % 1.0;
    if (progress < 0) progress += 1.0;
    // Map progress [0..1] to opacity [0.3..1..0.3] smooth fade
    if (progress < 0.5) {
      return 0.3 + progress * 1.4; // from 0.3 to 1
    } else {
      return 0.3 + (1 - progress) * 1.4; // from 1 to 0.3
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(dotCount, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return Opacity(
              opacity: _getOpacity(index).clamp(0.3, 1.0),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 3),
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inverseSurface,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
