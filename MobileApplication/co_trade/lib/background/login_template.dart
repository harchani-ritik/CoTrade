import 'dart:math';
import 'package:flutter/material.dart';
import '../services/constants.dart';

class LoginTemplate extends CustomPainter{

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color= kDarkBlue
      ..style= PaintingStyle.fill;

    var path = Path();
    path.moveTo(0, size.height*0.40);
    path.quadraticBezierTo(size.width*0.55, size.height *0.65,size.width, size.height * 0.45);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    canvas.drawPath(path, paint);

    paint.color=kRed;
    canvas.drawCircle(Offset(0,size.height*0.70), 42, paint);
    canvas.drawCircle(Offset(size.width*0.20,size.height*0.60), 14, paint);

    paint.color=kGreen;
    canvas.drawCircle(Offset(size.width*0.96,size.height*0.94), 60, paint);

  }
}