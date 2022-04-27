import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

///  Name:探索二：绘制的曲线添加绘制动画
///  Created by fitem on 2022/4/11
class ExploreTwoScreen extends StatefulWidget {
  const ExploreTwoScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ExploreTwoScreenState();
}

class ExploreTwoScreenState extends State<ExploreTwoScreen>
    with SingleTickerProviderStateMixin {
  final int _duration = 5;
  double _fraction = 0.0;
  late final AnimationController _controller;
  late final Animation<double> _animation;
  var color = const Color(0xFF156FEC);
  var text = 'Love';

  // 左半爱心
  var leftPath = Path();
  // 右半爱心
  var rightPath = Path();
  double centerX = 180;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: Duration(seconds: _duration));
    // 左半爱心
    leftPath.moveTo(centerX, 400);
    leftPath.cubicTo(centerX - 207, 267, centerX - 107, 100, centerX, 194);
    // 右半爱心
    rightPath.moveTo(centerX, 400);
    rightPath.cubicTo(centerX + 207, 267, centerX + 107, 100, centerX, 194);

    PathMetrics pms = leftPath.computeMetrics();
    PathMetric pm = pms.elementAt(0);
    double len = pm.length;

    _animation = Tween(begin: 0.0, end: len).animate(_controller)
      ..addListener(() {
        setState(() {
          _fraction = _animation.value;
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isCompleted = _controller.status == AnimationStatus.completed;
    var isDismissed = _controller.status == AnimationStatus.dismissed;
    if (isCompleted) {
      color = BezierPainter.red;
      text = 'I Love You';
    } else if (isDismissed) {
      color = BezierPainter.blue;
      text = 'Love';
    }
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 500,
          child: CustomPaint(
            painter: BezierPainter(_fraction, leftPath, rightPath),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(primary: color),
          child: Text(
            text,
          ),
          onPressed: () {
            if (isCompleted) {
              _controller.reverse();
            } else {
              _controller.forward();
            }
          },
        ),
      ],
    );
  }
}

class BezierPainter extends CustomPainter {
  final double _fraction;
  final Path leftPath;
  final Path rightPath;
  final List<Offset> _leftPoints = [];
  final List<Offset> _rightPoints = [];
  static const blue = Color(0xFF156FEC);
  static const red = Color(0xFFE53020);
  final _paint1 = Paint()
    ..color = blue
    ..strokeWidth = 2.0
    ..style = PaintingStyle.stroke;

  final _paint2 = Paint()
    ..color = red
    ..strokeWidth = 2.0
    ..style = PaintingStyle.stroke;

  BezierPainter(this._fraction, this.leftPath, this.rightPath);

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制背景
    canvas.drawColor(const Color(0xFFF1F1F1), BlendMode.color);
    // 获取path上的点数据
    // 左边
    PathMetrics leftPms = leftPath.computeMetrics();
    PathMetric leftPm = leftPms.elementAt(0);
    double leftLen = leftPm.length;

    double tmpStart = 0;
    double leftEnd = min(_fraction, leftLen);
    var isCompleted = leftEnd == leftLen;

    for (; tmpStart < leftEnd; tmpStart += 1) {
      Tangent? t = leftPm.getTangentForOffset(tmpStart);
      if (t != null) {
        _leftPoints.add(t.position);
      }
    }
    // 右边
    PathMetrics rightPms = rightPath.computeMetrics();
    PathMetric rightPm = rightPms.elementAt(0);
    double rightLen = rightPm.length;
    tmpStart = 0;
    double rightEnd = min(_fraction, rightLen);
    for (; tmpStart < rightEnd; tmpStart += 1) {
      Tangent? t = rightPm.getTangentForOffset(tmpStart);
      if (t != null) {
        _rightPoints.add(t.position);
      }
    }
    // 绘制爱心
    // 动画结束时，填充爱心
    if (isCompleted) {
      _paint1.style = PaintingStyle.fill;
      _paint1.color = red;
    }
    // 绘制背景线
    canvas.drawPath(leftPath, _paint1);
    canvas.drawPath(rightPath, _paint1);
    // 绘制点
    canvas.drawPoints(PointMode.points, _leftPoints, _paint2);
    canvas.drawPoints(PointMode.points, _rightPoints, _paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
