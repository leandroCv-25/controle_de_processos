import 'package:flutter/material.dart';

class ChartsWidget extends StatelessWidget {
  const ChartsWidget({super.key, required this.data, required this.height});

  final Map<int, double> data;
  final double height;

  @override
  Widget build(BuildContext context) {
    Path drawPath() {
      final pasX =
          (MediaQuery.of(context).size.width - 100) / (data.length - 1);
      bool isThereNegative = true;
      data.forEach((index, value) {
        if (value < 0) isThereNegative = true;
      });
      late final pasY;
      if (isThereNegative) {
        pasY = height / 400;
      } else {
        pasY = height / 200;
      }

      final path = Path();
      if (data[0] != null) {
        if (isThereNegative) {
          path.moveTo(0, height / 2 - pasY * data[0]!);
        } else {
          path.moveTo(0, height - pasY * data[0]!);
        }
      } else {
        path.moveTo(0, height);
      }

      data.forEach((index, value) {
        if (index != 0) {
          if (isThereNegative) {
            path.lineTo(index * pasX, height / 2 - pasY * data[index]!);
          } else {
            path.lineTo(index * pasX, height - pasY * data[index]!);
          }
        }
      });
      return path;
    }

    return SizedBox(
      height: height + 40,
      child: Stack(
        children: [
          Positioned(
            top: 40,
            child: CustomPaint(
              size: Size(
                MediaQuery.of(context).size.width - 100,
                height,
              ),
              painter: PathPainter(
                path: drawPath(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PathPainter extends CustomPainter {
  Path path;
  PathPainter({required this.path});
  @override
  void paint(Canvas canvas, Size size) {
    // paint the line
    final paint = Paint()
      ..color = Colors.deepPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
