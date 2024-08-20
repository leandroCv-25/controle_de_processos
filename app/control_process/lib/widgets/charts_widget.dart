import 'package:flutter/material.dart';

class ChartsWidget extends StatefulWidget {
  const ChartsWidget(
      {super.key,
      required this.data,
      required this.height,
      required this.maxValue});

  final Map<int, double> data;
  final double height;
  final double maxValue;

  @override
  State<ChartsWidget> createState() => _ChartsWidgetState();
}

class _ChartsWidgetState extends State<ChartsWidget> {
  bool isThereNegative = false;
  double pasY = 0;
  double pasX = 0;

  void isNegative() {
    int last = 0;
    widget.data.forEach((index, value) {
      if (value < 0) isThereNegative = true;
      last = index;
    });
    pasX = (MediaQuery.of(context).size.width - 100) / (last);
    setState(() {
      if (isThereNegative) {
        pasY = widget.height / (2 * widget.maxValue);
      } else {
        pasY = widget.height / widget.maxValue;
      }
    });
  }

  Path drawPath() {
    isNegative();
    final path = Path();
    if (widget.data[0] != null) {
      if (isThereNegative) {
        path.moveTo(0, widget.height / 2 - pasY * widget.data[0]!);
      } else {
        path.moveTo(0, widget.height - pasY * widget.data[0]!);
      }
    } else {
      path.moveTo(0, widget.height);
    }

    widget.data.forEach((index, value) {
      if (index != 0) {
        if (isThereNegative) {
          path.lineTo(
              index * pasX, widget.height / 2 - pasY * widget.data[index]!);
        } else {
          path.lineTo(index * pasX, widget.height - pasY * widget.data[index]!);
        }
      }
    });
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(
        MediaQuery.of(context).size.width - 100,
        widget.height,
      ),
      painter: PathPainter(
        path: drawPath(),
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
