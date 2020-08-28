import 'dart:math';

import 'package:flutter/material.dart';

class TapePainter extends CustomPainter {
  TapePainter({
    @required this.rotationValue,
    @required this.title,
    @required this.progress,
  });

  double rotationValue;
  String title;
  double progress;

  double holeRadius;
  Offset leftHolePosition;
  Offset rightHolePosition;
  Path leftHole;
  Path rightHole;
  Path centerWindowPath;

  Paint paintObject;
  Size size;
  Canvas canvas;

  @override
  void paint(Canvas canvas, Size size) {
    this.size = size;
    this.canvas = canvas;

    holeRadius = size.height / 12;
    paintObject = Paint();

    _initHoles();
    _initCenterWindow();

    _drawTape();
    _drawTapeReels();
    _drawLabel();
    _drawCenterWindow();
    _drawBlackRect();
    _drawHoleRings();
    _drawTextLabel();
    _drawTapePins();
  }

  void _drawTapeReels() {
    Path leftTapeRoll = Path()..addOval(
        Rect.fromCircle(
            center: leftHolePosition,
            radius: holeRadius * (1 - progress) * 5
        )
    );

    Path rightTapeRoll = Path()..addOval(
        Rect.fromCircle(
            center: rightHolePosition,
            radius: holeRadius * progress * 5
        )
    );

    leftTapeRoll = Path.combine(PathOperation.difference, leftTapeRoll, leftHole);
    rightTapeRoll = Path.combine(PathOperation.difference, rightTapeRoll, rightHole);

    paintObject.color = Colors.black;
    canvas.drawPath(leftTapeRoll, paintObject);
    canvas.drawPath(rightTapeRoll, paintObject);
  }

  void _drawTapePins() {
    paintObject.color = Colors.white;
    final int pinCount = 8;

    for (var i = 0; i < pinCount; i++) {
      _drawTapePin(leftHolePosition, rotationValue + i / pinCount);
      _drawTapePin(rightHolePosition, rotationValue + i / pinCount);
    }
  }

  void _drawTapePin(Offset center, double angle) {
    _drawRotated(Offset(center.dx, center.dy), -angle, () {
      canvas.drawRect(
          Rect.fromLTWH(
            center.dx - 2,
            center.dy - holeRadius,
            4,
            holeRadius / 4,
          ),
          paintObject
      );
    });
  }

  void _drawRotated(Offset center, double angle, Function drawFunction) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle * pi * 2);
    canvas.translate(-center.dx, -center.dy);
    drawFunction();
    canvas.restore();
  }

  void _drawTextLabel() {
    TextSpan span = new TextSpan(style: new TextStyle(color: Colors.black), text: title);
    TextPainter textPainter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center
    );

    double labelPadding = size.width * 0.05;

    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width - labelPadding * 2,
    );

    final offset = Offset(
        (size.width - textPainter.width) * 0.5,
        (size.height - textPainter.height) * 0.12
    );

    textPainter.paint(canvas, offset);
  }

  void _drawHoleRings() {
    Path leftHoleRing = Path()..addOval(
        Rect.fromCircle(
            center: leftHolePosition,
            radius: holeRadius * 1.1
        )
    );

    Path rightHoleRing = Path()..addOval(
        Rect.fromCircle(
            center: rightHolePosition,
            radius: holeRadius * 1.1
        )
    );

    leftHoleRing = Path.combine(PathOperation.difference, leftHoleRing, leftHole);
    rightHoleRing = Path.combine(PathOperation.difference, rightHoleRing, rightHole);

    paintObject.color = Colors.white;
    canvas.drawPath(leftHoleRing, paintObject);
    canvas.drawPath(rightHoleRing, paintObject);
  }

  void _drawCenterWindow() {
    paintObject.color = Colors.black38;
    canvas.drawPath(centerWindowPath, paintObject);
  }

  void _drawBlackRect() {
    Rect blackRect = Rect.fromLTWH(size.width * 0.2, size.height * 0.31, size.width * 0.6, size.height * 0.3);
    Path blackRectPath = Path()
      ..addRRect(
          RRect.fromRectXY(blackRect, 4, 4)
      );

    blackRectPath = Path.combine(PathOperation.difference, blackRectPath, leftHole);
    blackRectPath = Path.combine(PathOperation.difference, blackRectPath, rightHole);
    blackRectPath = _cutCenterWindowIntoPath(blackRectPath);

    paintObject.color = Colors.black.withOpacity(0.8);
    canvas.drawPath(blackRectPath, paintObject);
  }

  void _drawLabel() {
    double labelPadding = size.width * 0.05;
    Rect label = Rect.fromLTWH(labelPadding, labelPadding, size.width - labelPadding * 2, size.height * 0.7);
    Path labelPath = Path()..addRect(label);
    labelPath = _cutHolesIntoPath(labelPath);
    labelPath = _cutCenterWindowIntoPath(labelPath);

    Rect labelTop = Rect.fromLTRB(label.left, label.top + label.height * 0.2, label.right, label.bottom - label.height * 0.1);
    Path labelTopPath = Path()..addRect(labelTop);
    labelTopPath = _cutHolesIntoPath(labelTopPath);
    labelTopPath = _cutCenterWindowIntoPath(labelTopPath);

    paintObject.color = Color(0xffd3c5ae);
    canvas.drawPath(labelPath, paintObject);
    paintObject.color = Colors.red;
    canvas.drawPath(labelTopPath, paintObject);
  }

  Path _cutCenterWindowIntoPath(Path path) {
    return Path.combine(PathOperation.difference, path, centerWindowPath);
  }

  void _initCenterWindow() {
    Rect centerWindow = Rect.fromLTRB(size.width * 0.4, size.height * 0.37, size.width * 0.6, size.height * 0.55);
    centerWindowPath = Path()..addRect(centerWindow);
  }

  void _initHoles() {
    leftHolePosition = Offset(size.width * 0.3, size.height * 0.46);
    rightHolePosition = Offset(size.width * 0.7, size.height * 0.46);

    leftHole = Path()..addOval(
        Rect.fromCircle(
            center: leftHolePosition,
            radius: holeRadius
        )
    );

    rightHole = Path()..addOval(
        Rect.fromCircle(
            center: rightHolePosition,
            radius: holeRadius
        )
    );
  }

  _drawTape() {
    RRect tape = RRect.fromRectAndRadius(
        Rect.fromLTRB(0, 0, size.width, size.height),
        Radius.circular(16)
    );

    Path tapePath = Path()..addRRect(tape);

    tapePath = _cutHolesIntoPath(tapePath);
    tapePath = _cutCenterWindowIntoPath(tapePath);

    canvas.drawShadow(tapePath, Colors.black, 3.0, false);
    paintObject.color = Colors.black;
    paintObject.color = Color(0xff522f19).withOpacity(0.8);
    canvas.drawPath(tapePath, paintObject);
  }

  _cutHolesIntoPath(Path path) {
    path = Path.combine(PathOperation.difference, path, leftHole);
    path = Path.combine(PathOperation.difference, path, rightHole);

    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}