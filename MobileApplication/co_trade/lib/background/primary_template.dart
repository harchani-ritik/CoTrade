import 'dart:math';
import 'package:flutter/material.dart';
import '../services/constants.dart';

class PrimaryTemplate extends CustomPainter{

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color= kDarkBlue
      ..style= PaintingStyle.fill;

    var path = Path();
    path.moveTo(0, size.height*0.12);
    path.quadraticBezierTo(size.width*0.55, size.height *0.35,size.width, size.height * 0.12);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    canvas.drawPath(path, paint);

    paint.color=kRed;
    final rect = Rect.fromCenter(
      center: Offset(size.width,size.height*0.34),
      width: size.width*0.18,
      height: size.height*0.14,
    );
    canvas.drawArc(rect, pi/2, pi, false, paint);

    // canvas.drawCircle(Offset(center["x"], center["y"]), radius, brush);
    paint.color=kGreen;
    canvas.drawCircle(Offset(0,size.height*0.89), 50, paint);
    canvas.drawCircle(Offset(size.width*0.06,size.height*0.75), 14, paint);

  }
}